#!/usr/bin/env python3
"""
Сервис контроля подписок.

Каждые N минут:
  1. Конвертирует старые бесплатные подписки (100 лет) в грейс-период (3 дня)
     и уведомляет пользователей.
  2. Приостанавливает (suspend) на XRay-сервере пользователей с истёкшей
     подпиской — VPN перестаёт работать, но конфиг сохраняется.
     При оплате достаточно resume — ключ тот же.
"""

import os
import sys
import time
import traceback
from datetime import datetime

import paramiko
import telebot
from sqlalchemy import create_engine, text

# ── Конфигурация ──────────────────────────────────────────────────────────
DB_URL = os.getenv("DB_URL", "postgresql+psycopg2://vpn_user:vpn_pass@127.0.0.1:5432/vpn_db")
CHECK_INTERVAL = int(os.getenv("CHECK_INTERVAL_MINUTES", "30")) * 60
GRACE_PERIOD_DAYS = int(os.getenv("GRACE_PERIOD_DAYS", "3"))

# Все пользователи считаются с активной подпиской (enforcer никого не трогает)
ALL_FREE = True

XRAY_HOST = os.getenv("XRAY_HOST", "185.221.22.150")
XRAY_USER = os.getenv("XRAY_USER", "root")
SSH_KEY_PATH = os.getenv("VPN_SSH_KEY_PATH", "/root/.ssh/vpn_remote_key")
EASY_XRAY_PATH = os.getenv("EASY_XRAY_PATH", "/root/easy-xray")

TELEBOT_API = os.getenv("TELEBOT_API", "")

engine = create_engine(DB_URL)

# ── Telegram бот для уведомлений ─────────────────────────────────────────
notify_bot = None
if TELEBOT_API:
    try:
        notify_bot = telebot.TeleBot(TELEBOT_API)
        print("✅ Telegram-бот для уведомлений подключён")
    except Exception as e:
        print(f"⚠️  Не удалось создать Telegram-бот: {e}")


def notify_user(user_id: int, message: str):
    if not notify_bot:
        return
    try:
        notify_bot.send_message(user_id, message)
        print(f"    📩 Уведомление → {user_id}")
    except Exception as e:
        print(f"    ⚠️  Не уведомлён {user_id}: {e}")


# ── SSH ───────────────────────────────────────────────────────────────────
_ssh_client = None


def _get_ssh():
    global _ssh_client
    if _ssh_client is None:
        _ssh_client = paramiko.SSHClient()
        _ssh_client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        kwargs = {"hostname": XRAY_HOST, "username": XRAY_USER}
        if SSH_KEY_PATH and os.path.exists(SSH_KEY_PATH):
            kwargs["key_filename"] = SSH_KEY_PATH
        _ssh_client.connect(**kwargs)
        print(f"✅ SSH → {XRAY_HOST}")
    return _ssh_client


def _close_ssh():
    global _ssh_client
    if _ssh_client:
        try:
            _ssh_client.close()
        except Exception:
            pass
        _ssh_client = None


def suspend_users_on_xray(user_ids: list[int]) -> int:
    """
    Приостанавливает пользователей на XRay (ex.sh suspend).
    Один вызов для всех — push выполняется 1 раз в конце (XRay не дёргается).
    """
    if not user_ids:
        return 0
    ex_script = os.path.join(EASY_XRAY_PATH, "ex.sh")
    ids_str = " ".join(str(uid) for uid in user_ids)
    cmd = f"cd {EASY_XRAY_PATH} && echo -e 'Y\\nS' | {ex_script} suspend {ids_str}"
    try:
        ssh = _get_ssh()
        stdin, stdout, stderr = ssh.exec_command(cmd, timeout=120)
        output = stdout.read().decode().strip()
        exit_code = stdout.channel.recv_exit_status()
        if exit_code != 0:
            err = stderr.read().decode().strip()
            print(f"    ⚠️  suspend batch exit={exit_code}: {err or output}")
            return 0
        n = output.lower().count("suspended") + output.lower().count("updated")
        print(f"    🔒 Приостановлено: {len(user_ids)} пользователей, 1 push")
        return len(user_ids)
    except Exception as e:
        print(f"    ❌ Ошибка suspend: {e}")
        _close_ssh()
        return 0


# ── БД ────────────────────────────────────────────────────────────────────

def migrate_free_subscriptions():
    """Конвертирует 100-летние подписки в грейс-период. Возвращает [user_id]."""
    if ALL_FREE:
        return []
    with engine.begin() as conn:
        rows = conn.execute(text("""
            SELECT user_id FROM vpn_subs
            WHERE date_end > NOW() + INTERVAL '50 years'
        """)).fetchall()

        if not rows:
            return []

        grace_sql = f"""
            UPDATE vpn_subs
            SET date_start = NOW(),
                date_end = NOW() + INTERVAL '{GRACE_PERIOD_DAYS} days'
            WHERE date_end > NOW() + INTERVAL '50 years'
        """
        conn.execute(text(grace_sql))

        user_ids = [r[0] for r in rows]
        print(f"🧹 {len(user_ids)} бесплатных подписок → грейс {GRACE_PERIOD_DAYS} дн.")
        return user_ids


def get_expired_users_with_vpn():
    """Пользователи с vpn_url, но без активной подписки."""
    if ALL_FREE:
        return []
    with engine.begin() as conn:
        rows = conn.execute(text("""
            SELECT u.user_id
            FROM vpn_users u
            LEFT JOIN (
                SELECT user_id, MAX(date_end) AS max_end
                FROM vpn_subs
                GROUP BY user_id
            ) s ON u.user_id = s.user_id
            WHERE u.vpn_url IS NOT NULL
              AND (s.max_end IS NULL OR s.max_end <= NOW())
              AND u.user_id NOT IN :free_ids
        """), {"free_ids": tuple(FREE_USER_IDS)}).fetchall()
    return rows


# ── Основной цикл ────────────────────────────────────────────────────────

def enforce():
    now = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    print(f"\n{'='*60}")
    print(f"[{now}] Проверка подписок...")

    # ── Шаг 1: миграция бесплатных подписок ───────────────────────────
    migrated = migrate_free_subscriptions()
    for uid in migrated:
        notify_user(
            uid,
            f"⚠️ Важное обновление!\n\n"
            f"Наш VPN-сервис перешёл на платную модель.\n\n"
            f"Ваш VPN будет работать ещё {GRACE_PERIOD_DAYS} дня.\n"
            f"После этого нужна подписка — 200₽/мес.\n\n"
            f"Откройте бот и нажмите «💳 Подписка» для оплаты.",
        )

    # ── Шаг 2: suspend для просроченных (batch — 1 push в конце) ─────
    expired = get_expired_users_with_vpn()
    print(f"Просроченных с VPN: {len(expired)}")

    user_ids = [row[0] for row in expired]
    suspended = suspend_users_on_xray(user_ids)

    print(f"Приостановлено: {suspended}/{len(expired)}")
    print(f"{'='*60}\n")


def main():
    print("🔒 Subscription Enforcer запущен")
    print(f"   XRay: {XRAY_HOST}")
    print(f"   Грейс-период: {GRACE_PERIOD_DAYS} дн.")
    print(f"   Интервал: {CHECK_INTERVAL // 60} мин")
    print(f"   Уведомления: {'✅' if notify_bot else '❌ (TELEBOT_API не задан)'}")
    print()

    while True:
        try:
            enforce()
        except Exception as e:
            print(f"❌ Ошибка: {e}")
            traceback.print_exc()
            _close_ssh()

        print(f"💤 Следующая проверка через {CHECK_INTERVAL // 60} мин...")
        time.sleep(CHECK_INTERVAL)


if __name__ == "__main__":
    main()

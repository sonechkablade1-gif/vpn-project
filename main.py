import os
import time
import datetime
import sys

import telebot
from sqlalchemy import create_engine, text
from dotenv import load_dotenv

from src.utils import (
    main_keyboard,
    make_help_markup,
    make_subscription_status_markup,
    make_no_sub_markup,
)
from src.database import add_payment_to_db, ensure_payments_table, check_db_tables
from src.xray import cook_user_xray_link, XRayRemoteInterface
from src.const import HOST_IDS

load_dotenv(override=True)

# ─── Конфигурация подписки ────────────────────────────────────────────────
GRACE_PERIOD_DAYS      = 3         # Грейс-период для старых пользователей
# ──────────────────────────────────────────────────────────────────────────

# Флаг: все пользователи имеют бесплатный доступ (подписка не проверяется)
ALL_FREE = True


def log_action(user_id, action, details="", username=None, error=None):
    timestamp = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    user_info = f"User {user_id} ({username})" if username else f"User {user_id}"
    log_message = f"[{timestamp}] [{action}] {user_info}"
    if details:
        log_message += f": {details}"
    if error:
        log_message += f" | ERROR: {error}"
    print(log_message, flush=True)
    sys.stdout.flush()


# БД: локальная (Beget удалена)
DB_URL = os.getenv("DB_URL", "postgresql+psycopg2://vpn_user:vpn_pass@127.0.0.1:5432/vpn_db")
engine = create_engine(DB_URL)

bot = telebot.TeleBot(token=os.environ["TELEBOT_API"])
_bot_instance = bot

YOOKASSA_PROVIDER_TOKEN = os.environ.get("YOOKASSA_PROVIDER_TOKEN")
if not YOOKASSA_PROVIDER_TOKEN:
    print("⚠️  ВНИМАНИЕ: YOOKASSA_PROVIDER_TOKEN не установлен! Платежи работать не будут.")


# ═══════════════════════════════════════════════════════════════════════════
#  РОУТИНГ (v2rayTun) — Gemini через VPN (явно), RU/яндекс direct, остальное VPN
# ═══════════════════════════════════════════════════════════════════════════

# Gemini ПЕРВЫМ — иначе возможна утечка в direct и "не поддерживается в вашей стране"
# trimagent.pro / sales.trimagent.pro — direct, чтобы сайт был доступен при включённом VPN
ROUTING_B64 = (
    "eyJpZCI6IjcxQjYwM0IyLUJGMDItNDZBRS04RjgzLUY4RDVFMDI3NTkzNCIsImRv"
    "bWFpblN0cmF0ZWd5IjoiQXNJcyIsImRvbWFpbk1hdGNoZXIiOiJoeWJyaWQiLCJy"
    "dWxlcyI6W3siX19uYW1lX18iOiJHZW1pbmlWUE4iLCJ0eXBlIjoiZmllbGQiLCJv"
    "dXRib3VuZFRhZyI6InByb3h5IiwiZG9tYWluIjpbImRvbWFpbjpnZW1pbmkuZ29v"
    "Z2xlLmNvbSIsImRvbWFpbjpnZW5lcmF0aXZlbGFuZ3VhZ2UuZ29vZ2xlYXBpcy5j"
    "b20iLCJkb21haW46YWkuZ29vZ2xlLmRldiIsImRvbWFpbjpnb29nbGUuY29tIiwi"
    "ZG9tYWluOmdvb2dsZWFwaXMuY29tIiwiZG9tYWluOmdzdGF0aWMuY29tIiwiZG9t"
    "YWluOmdvb2dsZXVzZXJjb250ZW50LmNvbSJdLCJuZXR3b3JrIjpbInRjcCIsInVk"
    "cCJdfSx7Il9fbmFtZV9fIjoiRGlyZWN0VlBOIiwidHlwZSI6ImZpZWxkIiwib3V0"
    "Ym91bmRUYWciOiJkaXJlY3QiLCJkb21haW4iOlsiZG9tYWluOnhuLS1wbGFpIiwi"
    "ZG9tYWluOnhuLS05MGFpcyIsImRvbWFpbjpydSIsImRvbWFpbjpiZWdldC5jb20i"
    "LCJkb21haW46YmVnZXQudGVjaCIsImRvbWFpbjpiZWdldGhvc3QuY29tIiwiZG9t"
    "YWluOnRyaW1hZ2VudC5wcm8iLCJkb21haW46c2FsZXMudHJpbWFnZW50LnBybyJd"
    "LCJpZCI6IkQwQTgxNTFFLUNDM0ItNEY2Ri05RTM4LThBQ0NERTM2NjFERiIsIm5l"
    "dHdvcmsiOlsidGNwIiwidWRwIl19XSwiYmFsYW5jZXJzIjpbXSwibmFtZSI6IlJV"
    "X0JZUEFTUyJ9"
)


def _get_routing_config():
    """Роутинг: Gemini/Google → VPN, RU/яндекс → direct, остальное → VPN."""
    return f"v2rayTun://import_route/{ROUTING_B64}"


# ═══════════════════════════════════════════════════════════════════════════
#  ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ (БД)
# ═══════════════════════════════════════════════════════════════════════════

def is_active_user(user_id) -> bool:
    """
    Проверяет, есть ли активная подписка.
    Если ALL_FREE = True — подписка считается активной для всех пользователей.
    """
    if ALL_FREE:
        return True
    with engine.begin() as conn:
        result = conn.execute(text("""
            SELECT 1 FROM vpn_subs
            WHERE user_id = :uid
              AND date_end > NOW()
              AND date_end < NOW() + INTERVAL '50 years'
            LIMIT 1
        """), {"uid": user_id})
        return result.fetchone() is not None


def has_legacy_subscription(user_id) -> bool:
    """Проверяет, есть ли у пользователя старая бесплатная подписка (100 лет)."""
    if ALL_FREE:
        return False
    with engine.begin() as conn:
        result = conn.execute(text("""
            SELECT 1 FROM vpn_subs
            WHERE user_id = :uid
              AND date_end > NOW() + INTERVAL '50 years'
            LIMIT 1
        """), {"uid": user_id})
        return result.fetchone() is not None


def migrate_legacy_subscription(user_id, username=None) -> datetime.datetime:
    """
    Конвертирует 100-летнюю подписку в грейс-период (3 дня).
    Возвращает дату окончания грейс-периода.
    """
    with engine.begin() as conn:
        conn.execute(text("""
            DELETE FROM vpn_subs
            WHERE user_id = :uid AND date_end > NOW() + INTERVAL '50 years'
        """), {"uid": user_id})

        start = datetime.datetime.now()
        end = start + datetime.timedelta(days=GRACE_PERIOD_DAYS)
        conn.execute(
            text("INSERT INTO vpn_subs (user_id, date_start, date_end, username) VALUES (:uid, :ds, :de, :uname)"),
            {"uid": user_id, "ds": start, "de": end, "uname": username},
        )
    log_action(user_id, "LEGACY_MIGRATED",
               f"100-летняя подписка → грейс-период до {end.strftime('%d.%m.%Y %H:%M')}")
    return end


def ensure_user_migrated(user_id, username=None):
    """
    Если у пользователя legacy-подписка — мигрирует на грейс-период.
    Возвращает (was_migrated, grace_end) или (False, None).
    """
    if ALL_FREE:
        return False, None
    if has_legacy_subscription(user_id):
        end = migrate_legacy_subscription(user_id, username=username)
        return True, end
    return False, None


def is_user_exists(user_id) -> bool:
    with engine.begin() as conn:
        result = conn.execute(
            text("SELECT 1 FROM vpn_users WHERE user_id = :uid LIMIT 1"),
            {"uid": user_id},
        )
        return result.fetchone() is not None


def create_user(user_id, username=None):
    if not username:
        try:
            chat = bot.get_chat(user_id)
            username = getattr(chat, 'username', None)
            if username:
                username = f"@{username}"
            else:
                first_name = getattr(chat, 'first_name', '')
                last_name = getattr(chat, 'last_name', '')
                username = f"{first_name} {last_name}".strip() or None
        except Exception as e:
            log_action(user_id, "USER_CREATE_ERROR", "Не удалось получить username", error=str(e))
            username = None

    try:
        with engine.begin() as conn:
            conn.execute(
                text('INSERT INTO vpn_users (user_id, username) VALUES (:user_id, :username)'),
                {"user_id": user_id, "username": username},
            )
        log_action(user_id, "USER_CREATED_DB", f"username: {username}", username)
    except Exception as e:
        log_action(user_id, "USER_CREATE_DB_ERROR", "Ошибка создания в БД", username, error=str(e))
        raise


def _activate_subscription(user_id, days, period_name, username=None):
    """Активирует/продлевает подписку и восстанавливает VPN-доступ."""
    try:
        with engine.begin() as conn:
            # 1) Удаляем legacy-подписки (100 лет), если есть
            conn.execute(text("""
                DELETE FROM vpn_subs
                WHERE user_id = :uid AND date_end > NOW() + INTERVAL '50 years'
            """), {"uid": user_id})

            # 2) Ищем текущую ПЛАТНУЮ активную подписку для продления
            row = conn.execute(text("""
                SELECT date_end FROM vpn_subs
                WHERE user_id = :uid
                  AND date_end > NOW()
                  AND date_end < NOW() + INTERVAL '50 years'
                ORDER BY date_end DESC LIMIT 1
            """), {"uid": user_id}).fetchone()

            if row:
                # Продлеваем от текущего конца подписки
                start = row[0]
            else:
                start = datetime.datetime.now()
                # Удаляем устаревшие записи
                conn.execute(text("DELETE FROM vpn_subs WHERE user_id = :uid"), {"uid": user_id})

            end = start + datetime.timedelta(days=days)
            conn.execute(
                text("INSERT INTO vpn_subs (user_id, date_start, date_end, username) VALUES (:uid, :ds, :de, :uname)"),
                {"uid": user_id, "ds": start, "de": end, "uname": username},
            )

        log_action(user_id, "SUBSCRIPTION_ACTIVATED",
                   f"{period_name} (до {end.strftime('%Y-%m-%d %H:%M')})")

        # ── Восстанавливаем VPN-доступ ────────────────────────────────
        # 1) Пробуем resume (для тех, кого enforcer приостановил)
        # 2) Если resume не помог или нет URL — создаём заново
        try:
            ssh_key = os.getenv('VPN_SSH_KEY_PATH')
            xray = XRayRemoteInterface(ssh_key_path=ssh_key)
            xray.resume_xray_user(user_id)
            xray.close()
            log_action(user_id, "XRAY_RESUMED", "Пользователь восстановлен на XRay")
        except Exception as re:
            log_action(user_id, "XRAY_RESUME_WARN",
                       "resume не удался (возможно новый пользователь)", error=str(re))

        # Получаем или генерируем VPN-конфиг
        try:
            urls = cook_user_xray_link(
                engine=engine,
                user_id=user_id,
                host_ids=HOST_IDS,
                bot=bot,
                chat_id=user_id,
                force_rotate=False,  # если URL есть — берём из БД
            )

            bot.send_message(user_id, "✅ Готово! Ваш VPN-доступ обновлён.")
            bot.send_message(user_id, text='📋 Ваши VPN-ссылки:')
            for url in urls:
                bot.send_message(user_id, text=f'<code>{url}</code>', parse_mode='HTML')

            routing_config = _get_routing_config()
            bot.send_message(
                user_id,
                text=f'🔀 Роутинг:\n<code>{routing_config}</code>',
                parse_mode='HTML',
            )
            log_action(user_id, "VPN_RESTORED", "VPN восстановлен после оплаты")

        except Exception as ve:
            log_action(user_id, "VPN_RESTORE_ERROR",
                       "Ошибка восстановления VPN", error=str(ve))
            bot.send_message(
                user_id,
                "✅ Готово! Нажмите «Подключиться», чтобы получить ключ.",
                reply_markup=main_keyboard(),
            )

    except Exception as e:
        log_action(user_id, "SUBSCRIPTION_ACTIVATE_ERROR",
                   f"Ошибка активации: {period_name}", error=str(e))
        raise


# ═══════════════════════════════════════════════════════════════════════════
#  ХЕНДЛЕРЫ КОМАНД
# ═══════════════════════════════════════════════════════════════════════════

@bot.message_handler(commands=["start"])
def handle_start(message):
    user_id = message.from_user.id
    username = getattr(message.from_user, 'username', None)
    if username:
        username = f"@{username}"
    else:
        first_name = getattr(message.from_user, 'first_name', '')
        last_name = getattr(message.from_user, 'last_name', '')
        username = f"{first_name} {last_name}".strip() or None

    log_action(user_id, "START", "Пользователь запустил бота", username)

    # Создаём пользователя если его нет
    if not is_user_exists(user_id):
        log_action(user_id, "USER_CREATE", "Новый пользователь", username)
        create_user(user_id, username)

    was_migrated, _ = ensure_user_migrated(user_id, username=username)
    if was_migrated:
        pass

    text_to_print = (
        "Мы обеспечиваем сверх-быстрое и защищённое соединение, "
        "используя передовые технологии VPN.\n\n"
        "Стабильная работа Instagram и YouTube в 4K без рекламы, "
        "интернет-банкинг остаётся рабочим. Доступно на всех устройствах: "
        "смартфонах, ноутбуках, планшетах и телевизорах.\n\n"
        "Подключайтесь ⚡️ прямо сейчас!"
    )
    bot.send_message(message.chat.id, text=text_to_print, reply_markup=main_keyboard())


@bot.message_handler(content_types=['text'])
def handle_text(message):
    user_id = message.from_user.id
    username = getattr(message.from_user, 'username', None)
    if username:
        username = f"@{username}"

    if message.text in ('Подключиться', '⚡️ Подключиться'):
        log_action(user_id, "CONNECT_REQUEST", "Запрос VPN конфигурации", username)
        _connect(message)
    elif message.text in ('Приложение', '📱 Приложение', 'Установить приложение'):
        log_action(user_id, "HELP_REQUEST", "Запрос помощи", username)
        _help(message)
    elif isinstance(message.text, str) and message.text.startswith('/speedtest'):
        log_action(user_id, "SPEEDTEST_REQUEST", "Speedtest", username)
        handle_speedtest(message)
    else:
        log_action(user_id, "UNKNOWN_MESSAGE", f"{message.text[:50]}", username)


@bot.message_handler(commands=["speedtest"])
def handle_speedtest(message):
    user_id = message.from_user.id
    log_action(user_id, "SPEEDTEST_REQUEST", "Speedtest через команду")
    bot.send_message(
        message.chat.id,
        f'Проверить скорость:\n<code>https://www.speedtest.net/</code>',
        parse_mode='HTML',
        disable_web_page_preview=True,
    )


# ═══════════════════════════════════════════════════════════════════════════
#  ПОДКЛЮЧЕНИЕ К VPN (с проверкой подписки)
# ═══════════════════════════════════════════════════════════════════════════

def _connect(message):
    user_id = message.from_user.id
    username = getattr(message.from_user, 'username', None)
    if username:
        username = f"@{username}"

    # Создаём пользователя если нет
    if not is_user_exists(user_id):
        if not username:
            first_name = getattr(message.from_user, 'first_name', '')
            last_name = getattr(message.from_user, 'last_name', '')
            username = f"{first_name} {last_name}".strip() or None
        create_user(user_id, username)
        log_action(user_id, "USER_CREATE", "При подключении", username)

    ensure_user_migrated(user_id, username=username)

    if not is_active_user(user_id):
        log_action(user_id, "CONNECT_NO_SUB", "Нет доступа", username)
        bot.send_message(user_id, "⛔ Доступ временно недоступен. Попробуйте позже.", reply_markup=make_no_sub_markup())
        return

    log_action(user_id, "CONNECT_START", "Генерация VPN конфигурации", username)

    status_msg = bot.send_message(user_id, text='🔄 Генерируем VPN конфиг...')

    try:
        bot.edit_message_text(
            chat_id=user_id,
            message_id=status_msg.message_id,
            text='🔧 Создаём конфигурацию...',
        )

        urls = cook_user_xray_link(
            engine=engine,
            user_id=user_id,
            host_ids=HOST_IDS,
            bot=bot,
            chat_id=user_id,
            force_rotate=False,
        )

        bot.edit_message_text(
            chat_id=user_id,
            message_id=status_msg.message_id,
            text='✅ Конфиг готов!',
        )

        log_action(user_id, "CONNECT_SUCCESS",
                   f"Отправлено {len(urls)} URL", username)

        bot.send_message(user_id, text='📋 Скопируй ссылки в своё приложение:')
        for url in urls:
            bot.send_message(message.chat.id, text=f'<code>{url}</code>', parse_mode='HTML')

        routing_config = _get_routing_config()
        bot.send_message(
            user_id,
            text=f'🔀 Роутинг:\n<code>{routing_config}</code>',
            parse_mode='HTML',
        )
        log_action(user_id, "ROUTING_SENT", "Роутинг отправлен", username)

        try:
            with engine.begin() as conn:
                result = conn.execute(text("""
                    SELECT id FROM routing_usage
                    WHERE user_id = :user_id
                    ORDER BY routing_sent_at DESC LIMIT 1
                """), {"user_id": user_id})
                if not result.fetchone():
                    conn.execute(text("""
                        INSERT INTO routing_usage (user_id, routing_sent_at)
                        VALUES (:user_id, NOW())
                    """), {"user_id": user_id})
        except Exception as e:
            log_action(user_id, "ROUTING_DB_ERROR", "", username, error=str(e))

    except Exception as e:
        log_action(user_id, "CONNECT_ERROR", "Ошибка генерации", username, error=str(e))
        try:
            bot.edit_message_text(
                chat_id=user_id,
                message_id=status_msg.message_id,
                text=f'❌ Ошибка при создании конфига. Попробуйте ещё раз.',
            )
        except Exception:
            pass


def _help(message):
    user_id = message.from_user.id
    log_action(user_id, "HELP_OPEN", "Страница помощи")
    bot.send_message(message.chat.id, 'Установить приложение', reply_markup=make_help_markup())


# ═══════════════════════════════════════════════════════════════════════════
#  CALLBACK: подписка (страница упрощена)
# ═══════════════════════════════════════════════════════════════════════════

def _show_subscription(user_id, username=None):
    """Ранее страница подписки — теперь просто возврат в меню."""
    ensure_user_migrated(user_id, username=username)
    bot.send_message(
        user_id,
        "Используйте кнопку «Подключиться» для получения VPN-конфига.",
        reply_markup=make_subscription_status_markup(True),
    )


def _send_payment_invoice(user_id):
    """Платежи отключены — возврат в меню."""
    bot.send_message(user_id, "Используйте «Подключиться» для получения VPN.", reply_markup=main_keyboard())


# ═══════════════════════════════════════════════════════════════════════════
#  CALLBACK-ХЕНДЛЕРЫ
# ═══════════════════════════════════════════════════════════════════════════

@bot.callback_query_handler(lambda q: q.data == 'get_key')
def handle_get_key_callback(query):
    bot.answer_callback_query(query.id)  # сразу убираем спиннер
    user_id = query.from_user.id
    username = getattr(query.from_user, 'username', None)
    if username:
        username = f"@{username}"
    log_action(user_id, "CALLBACK_GET_KEY", "Подключиться", username)

    class FakeMessage:
        def __init__(self, q):
            self.chat = q.message.chat
            self.from_user = q.from_user
    _connect(FakeMessage(query))


@bot.callback_query_handler(lambda q: q.data == 'subscription')
def handle_subscription_callback(query):
    bot.answer_callback_query(query.id)
    user_id = query.from_user.id
    username = getattr(query.from_user, 'username', None)
    if username:
        username = f"@{username}"
    log_action(user_id, "CALLBACK_SUBSCRIPTION", "Просмотр подписки", username)
    _show_subscription(user_id, username=username)


@bot.callback_query_handler(lambda q: q.data == 'pay_1_month')
def handle_pay_1_month(query):
    bot.answer_callback_query(query.id)
    user_id = query.from_user.id
    log_action(user_id, "CALLBACK_PAY", "Оплата 1 месяц")
    _send_payment_invoice(user_id)


@bot.callback_query_handler(lambda q: q.data == 'get_help')
def handle_get_help_callback(query):
    bot.answer_callback_query(query.id)
    user_id = query.from_user.id
    log_action(user_id, "CALLBACK_GET_HELP", "Помощь")
    bot.send_message(query.from_user.id, 'Установить приложение', reply_markup=make_help_markup())


@bot.callback_query_handler(lambda q: q.data == 'back')
def handle_back(query):
    bot.answer_callback_query(query.id)
    log_action(query.from_user.id, "CALLBACK_BACK", "Назад")
    try:
        bot.delete_message(query.from_user.id, query.message.id)
    except Exception:
        pass


@bot.callback_query_handler(lambda q: q.data == 'menu')
def handle_menu(query):
    bot.answer_callback_query(query.id)
    user_id = query.from_user.id
    log_action(user_id, "CALLBACK_MENU", "Главное меню")
    text_to_print = (
        "Мы обеспечиваем сверх-быстрое и защищённое соединение, "
        "используя передовые технологии VPN.\n\n"
        "Стабильная работа Instagram и YouTube в 4K без рекламы, "
        "интернет-банкинг остаётся рабочим. Доступно на всех устройствах.\n\n"
        "Подключайтесь ⚡️ прямо сейчас!"
    )
    bot.send_message(query.from_user.id, text=text_to_print, reply_markup=main_keyboard())


# ═══════════════════════════════════════════════════════════════════════════
#  ОБРАБОТКА ПЛАТЕЖЕЙ (Telegram Payments + ЮКасса)
# ═══════════════════════════════════════════════════════════════════════════

@bot.pre_checkout_query_handler(func=lambda query: True)
def checkout(pre_checkout_query):
    user_id = pre_checkout_query.from_user.id
    try:
        bot.answer_pre_checkout_query(pre_checkout_query.id, ok=True)
        log_action(user_id, "PAYMENT_PRECHECKOUT",
                   f"{pre_checkout_query.total_amount / 100} {pre_checkout_query.currency}")
    except Exception as e:
        log_action(user_id, "PAYMENT_PRECHECKOUT_ERROR", "", error=str(e))
        bot.answer_pre_checkout_query(
            pre_checkout_query.id, ok=False,
            error_message="Произошла ошибка при обработке платежа",
        )


@bot.message_handler(content_types=['successful_payment'])
def got_payment(message):
    """Обработка успешного платежа (если пришёл из Telegram Payments)."""
    try:
        payment = message.successful_payment
        payload = payment.invoice_payload

        parts = payload.split('_')
        if len(parts) >= 3:
            user_id = int(parts[0])
            days = int(parts[1])
            payment_id = parts[2]
        else:
            raise ValueError(f"Неверный формат payload: {payload}")

        username = getattr(message.from_user, 'username', None)
        if username:
            username = f"@{username}"

        period_name = "1 месяц" if days == 30 else f"{days} дней"
        amount = payment.total_amount / 100
        currency = payment.currency

        log_action(user_id, "PAYMENT_SUCCESS",
                   f"{amount} {currency}, {period_name}, id={payment_id}", username)

        add_payment_to_db(engine, user_id, amount, currency, payment_id, days, period_name)
        _activate_subscription(user_id, days, period_name, username=username)

    except Exception as e:
        user_id = message.from_user.id
        log_action(user_id, "PAYMENT_ERROR", "Ошибка обработки платежа", error=str(e))
        bot.send_message(message.chat.id, "❌ Ошибка. Попробуйте позже.")


# ═══════════════════════════════════════════════════════════════════════════
#  ЗАПУСК
# ═══════════════════════════════════════════════════════════════════════════

if __name__ == '__main__':
    ensure_payments_table(engine)
    ok, errs = check_db_tables(engine)
    if not ok:
        for e in errs:
            log_action(0, "DB_CHECK_FAIL", e)
        raise SystemExit("Не хватает таблиц в БД. Проверьте vpn_users, vpn_subs, payments.")
    log_action(0, "BOT_START", "Бот запущен (БД: vpn_users, vpn_subs, payments OK)")
    while True:
        try:
            bot.polling(none_stop=True)
        except Exception as e:
            log_action(0, "BOT_ERROR", "Ошибка polling", error=str(e))
            time.sleep(15)

#!/usr/bin/env python3
"""
Диагностика: почему VPN может не работать.
Запуск: python scripts/check_vpn.py
"""
import os
import sys

# добавляем корень проекта в path
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

def check_env():
    from dotenv import load_dotenv
    load_dotenv(override=True)
    key_path = os.getenv("VPN_SSH_KEY_PATH", "/root/.ssh/vpn_remote_key")
    print("1. Переменные окружения")
    print(f"   VPN_SSH_KEY_PATH = {key_path}")
    if not key_path:
        print("   ❌ VPN_SSH_KEY_PATH не задан!")
        return False
    if os.path.isfile(key_path):
        print(f"   ✅ Файл ключа существует: {key_path}")
    else:
        print(f"   ❌ Файл ключа не найден: {key_path}")
        return False
    return True

def check_ssh():
    print("\n2. Подключение к XRay-серверу по SSH")
    host = "194.48.142.252"
    key_path = os.getenv("VPN_SSH_KEY_PATH", "/root/.ssh/vpn_remote_key")
    try:
        import paramiko
        client = paramiko.SSHClient()
        client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        client.connect(
            host,
            username="root",
            key_filename=key_path,
            timeout=10,
        )
        print(f"   ✅ SSH к {host} успешен")
        # проверяем easy-xray
        stdin, stdout, stderr = client.exec_command(
            "test -f /root/easy-xray/ex.sh && echo OK || echo MISSING",
            timeout=5,
        )
        out = stdout.read().decode().strip()
        err = stderr.read().decode().strip()
        client.close()
        if out == "OK":
            print("   ✅ /root/easy-xray/ex.sh найден на сервере")
        else:
            print("   ❌ На сервере нет /root/easy-xray/ex.sh (или путь другой)")
        return True
    except Exception as e:
        print(f"   ❌ SSH ошибка: {e}")
        return False

def check_db():
    print("\n3. База данных")
    try:
        from main import engine, check_db_tables
        ok, errs = check_db_tables(engine)
        if ok:
            print("   ✅ Таблицы vpn_users, vpn_subs, payments доступны")
        else:
            print("   ❌ Ошибки БД:", errs)
        return ok
    except Exception as e:
        print(f"   ❌ Подключение к БД: {e}")
        return False

def main():
    print("=== Диагностика VPN ===\n")
    r1 = check_env()
    r2 = check_ssh()
    r3 = check_db()
    print("\n--- Итог ---")
    if r1 and r2 and r3:
        print("Окружение в порядке. Если VPN всё равно не работает:")
        print("  • У пользователя может быть истёкшая подписка (enforcer сделал suspend).")
        print("  • Нужно продлить подписку — тогда выполнится resume и ключ снова заработает.")
        print("  • Либо при «Подключиться» бот падает с ошибкой — смотри логи контейнера/процесса.")
    else:
        print("Есть проблемы выше — исправьте их (ключ SSH, доступ к серверу, БД).")

if __name__ == "__main__":
    main()

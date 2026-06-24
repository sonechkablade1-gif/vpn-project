#!/usr/bin/env python3
"""
Миграция данных из Beget PostgreSQL в локальную БД.
Старая БД НЕ удаляется и НЕ отключается.
Запуск: python scripts/migrate_to_local.py
"""

import os
from sqlalchemy import create_engine, text

OLD_DB = "postgresql+psycopg2://cloud_user:QVEQK*j64!Dp@oraskisjernek.beget.app:5432/default_db?sslmode=disable&target_session_attrs=read-write"
NEW_DB = os.getenv("DB_URL_LOCAL", "postgresql+psycopg2://vpn_user:vpn_pass@127.0.0.1:5432/vpn_db")

TABLES = ["vpn_users", "vpn_subs", "payments", "routing_usage"]


def migrate_table(eng_old, eng_new, table):
    """Копирует таблицу из старой БД в новую."""
    with eng_old.connect() as conn:
        rows = conn.execute(text(f"SELECT * FROM {table}")).fetchall()
    if not rows:
        print(f"  {table}: пусто, пропуск")
        return 0
    cols = list(rows[0]._mapping.keys())
    # Проверяем существующие колонки в новой БД
    with eng_new.connect() as conn:
        res = conn.execute(text(f"SELECT column_name FROM information_schema.columns WHERE table_name = :t"), {"t": table})
        new_cols = {r[0] for r in res}
    cols = [c for c in cols if c in new_cols]
    if not cols:
        print(f"  {table}: нет общих колонок, пропуск")
        return 0
    cols_str = ", ".join(cols)
    placeholders = ", ".join(f":{c}" for c in cols)
    copied = 0
    with eng_new.begin() as conn:
        for row in rows:
            d = {c: row._mapping[c] for c in cols}
            try:
                conn.execute(
                    text(f"INSERT INTO {table} ({cols_str}) VALUES ({placeholders}) ON CONFLICT DO NOTHING"),
                    d,
                )
                copied += 1
            except Exception as e:
                print(f"    (пропуск строки: {e})")
    print(f"  {table}: {copied}/{len(rows)} строк")
    return copied


def main():
    print("=== Миграция БД ===\n")
    print(f"Откуда: Beget (oraskisjernek.beget.app)")
    print(f"Куда:  {NEW_DB.replace('vpn_pass', '***')}\n")

    eng_old = create_engine(OLD_DB)
    eng_new = create_engine(NEW_DB)

    try:
        eng_old.connect()
        print("✅ Подключение к старой БД — OK")
    except Exception as e:
        print(f"❌ Не удалось подключиться к старой БД: {e}")
        return 1

    try:
        eng_new.connect()
        print("✅ Подключение к локальной БД — OK\n")
    except Exception as e:
        print(f"❌ Не удалось подключиться к локальной БД: {e}")
        print("   Запустите: docker compose up -d postgres")
        return 1

    total = 0
    for table in TABLES:
        try:
            n = migrate_table(eng_old, eng_new, table)
            total += n
        except Exception as e:
            print(f"  {table}: ошибка — {e}")

    print(f"\n✅ Миграция завершена. Всего строк: {total}")
    print("\nТест: закомментируйте старый DB_URL в .env и добавьте:")
    print("  DB_URL=postgresql+psycopg2://vpn_user:vpn_pass@127.0.0.1:5432/vpn_db")
    print("Затем: docker compose up -d vpn-bot")
    return 0


if __name__ == "__main__":
    exit(main())

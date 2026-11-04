from sqlalchemy import text


def ensure_payments_table(eng):
    """Создаёт таблицу payments, если её ещё нет."""
    with eng.begin() as conn:
        conn.execute(text("""
            CREATE TABLE IF NOT EXISTS payments (
                user_id BIGINT NOT NULL,
                amount NUMERIC NOT NULL,
                currency TEXT NOT NULL,
                payment_id TEXT NOT NULL UNIQUE,
                days INTEGER NOT NULL,
                period_name TEXT NOT NULL,
                status TEXT NOT NULL DEFAULT 'completed'
            )
        """))


def check_db_tables(eng):
    """
    Проверяет наличие таблиц, нужных боту. Возвращает (True, []) или (False, [ошибки]).
    """
    required = [
        ("vpn_users", "SELECT 1 FROM vpn_users LIMIT 1"),
        ("vpn_subs", "SELECT 1 FROM vpn_subs LIMIT 1"),
        ("payments", "SELECT 1 FROM payments LIMIT 1"),
    ]
    errors = []
    with eng.connect() as conn:
        for name, sql in required:
            try:
                conn.execute(text(sql))
            except Exception as e:
                errors.append(f"{name}: {e}")
    return (len(errors) == 0, errors)


def get_urls_from_db(eng, user_id, host_ids=[0]):
    """Получает VPN URL пользователя из БД."""
    with eng.begin() as conn:
        result = conn.execute(
            text("SELECT vpn_url FROM vpn_users WHERE user_id = :uid AND vpn_url IS NOT NULL"),
            {"uid": user_id},
        )
        row = result.fetchone()
        return [row[0]] if row else []


def add_url_to_db(eng, user_id, host_id, url):
    """Сохраняет VPN URL в БД (создаёт пользователя если нет)."""
    with eng.begin() as conn:
        result = conn.execute(
            text("SELECT 1 FROM vpn_users WHERE user_id = :uid LIMIT 1"),
            {"uid": user_id},
        )
        if not result.fetchone():
            conn.execute(
                text("INSERT INTO vpn_users (user_id) VALUES (:uid)"),
                {"uid": user_id},
            )

        conn.execute(
            text("UPDATE vpn_users SET vpn_url = :url WHERE user_id = :uid"),
            {"uid": user_id, "url": url},
        )
        print(f"✅ URL для пользователя {user_id} сохранен в БД")


def add_payment_to_db(eng, user_id, amount, currency, payment_id, days, period_name):
    """Сохраняет платёж в таблицу payments."""
    with eng.begin() as conn:
        conn.execute(
            text("""
                INSERT INTO payments (user_id, amount, currency, payment_id, days, period_name, status)
                VALUES (:uid, :amount, :currency, :pid, :days, :period, 'completed')
                ON CONFLICT (payment_id) DO NOTHING
            """),
            {
                "uid": user_id,
                "amount": amount,
                "currency": currency,
                "pid": payment_id,
                "days": days,
                "period": period_name,
            },
        )
        print(f"✅ Платёж {payment_id} сохранён: {amount} {currency}")

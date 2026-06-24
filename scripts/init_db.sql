-- Схема БД VPN-бота (локальный PostgreSQL)
-- Старая БД (Beget) не затрагивается — только для миграции данных

CREATE TABLE IF NOT EXISTS vpn_users (
    user_id BIGINT PRIMARY KEY,
    username TEXT,
    vpn_url TEXT,
    total_traffic_mb NUMERIC DEFAULT 0
);

CREATE TABLE IF NOT EXISTS vpn_subs (
    id SERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    date_start TIMESTAMP WITH TIME ZONE NOT NULL,
    date_end TIMESTAMP WITH TIME ZONE NOT NULL,
    username TEXT
);

CREATE INDEX IF NOT EXISTS idx_vpn_subs_user_id ON vpn_subs(user_id);
CREATE INDEX IF NOT EXISTS idx_vpn_subs_date_end ON vpn_subs(date_end);

CREATE TABLE IF NOT EXISTS payments (
    user_id BIGINT NOT NULL,
    amount NUMERIC NOT NULL,
    currency TEXT NOT NULL,
    payment_id TEXT PRIMARY KEY,
    days INTEGER NOT NULL,
    period_name TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'completed'
);

CREATE TABLE IF NOT EXISTS routing_usage (
    id SERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    routing_sent_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    uses_routing BOOLEAN DEFAULT FALSE,
    last_traffic_check TIMESTAMP WITH TIME ZONE
);

CREATE INDEX IF NOT EXISTS idx_routing_usage_user_id ON routing_usage(user_id);

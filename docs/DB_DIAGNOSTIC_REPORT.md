# Диагностика миграции БД — отчёт

**Дата:** 2026-02-23

## 1. Сравнение данных (Beget vs локальная)

| Таблица        | Beget | Локальная | Статус |
|----------------|-------|-----------|--------|
| vpn_users      | 179   | 179       | ✅     |
| vpn_subs       | 179   | 179       | ✅     |
| payments       | 6     | 6         | ✅     |
| routing_usage  | 72    | 72        | ✅     |

**Вывод:** Количество строк совпадает.

---

## 2. Проверка компонентов

| Компонент            | БД             | Статус                               |
|----------------------|----------------|--------------------------------------|
| vpn-bot              | Локальная      | ✅ check_db_tables, get_urls, get_user_end_time |
| traffic-collector    | Локальная      | ✅ Пишет трафик в vpn_users          |
| routing-tracker      | Локальная      | ✅ Читает routing_usage, vpn_subs    |
| broadcast_message.py | Локальная      | ✅ Использует DB_URL из .env         |
| enforcer             | Не запущен     | — (удалён ранее)                     |

---

## 3. Исправления перед удалением Beget

Сделано:

1. **traffic_service/docker-compose.yml** — добавлен `env_file: ../.env`, удалён жёстко заданный Beget DB_URL.
2. **routing_tracker_service/docker-compose.yml** — то же.
3. **src/traffic_collector.py** — добавлен `os.getenv("DB_URL")` вместо константы.

---

## 4. Что проверить перед удалением БД в Beget

- [ ] Бот реагирует на команды (Подключиться, Подписка)
- [ ] Платежи проходят и записываются
- [ ] Трафик обновляется (traffic-collector логирует «Сохранено»)
- [ ] Рассылка (broadcast) работает при необходимости

---

## 5. Когда можно удалять Beget

**Удалять Beget можно, если:**

1. В `.env` задан `DB_URL=postgresql+psycopg2://vpn_user:vpn_pass@127.0.0.1:5432/vpn_db`
2. Все сервисы перезапущены после изменений в `docker-compose`
3. Проверки из п. 4 выполнены успешно
4. Локальный PostgreSQL стабильно работает (`docker compose up -d postgres`)

**Перед удалением:**

- Сделать финальный дамп: `python scripts/migrate_to_local.py` (если за время проверки появились новые данные)
- Сохранить бэкап локальной БД: `docker exec vpn-postgres pg_dump -U vpn_user vpn_db > backup.sql`

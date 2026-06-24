# Миграция БД на локальный PostgreSQL

## Что сделано

- **PostgreSQL 16** в Docker (порт 5432)
- **Схема** в `scripts/init_db.sql`
- **Миграция** выполнена: 179 пользователей, 179 подписок, 6 платежей, 72 routing_usage
- **Старая БД Beget** не отключена, не удалена

## Тест локальной БД

1. Раскомментируйте в `.env`:
   ```
   DB_URL=postgresql+psycopg2://vpn_user:vpn_pass@127.0.0.1:5432/vpn_db
   ```

2. Перезапустите бота:
   ```bash
   docker compose up -d vpn-bot
   ```

3. Проверьте работу бота. Если всё ок — оставьте локальную БД.

4. Чтобы вернуться на Beget — закомментируйте `DB_URL` в `.env`.

## Повторная миграция

Если в старой БД появились новые данные:
```bash
python scripts/migrate_to_local.py
```

## traffic_service, routing_tracker, broadcast

Эти сервисы тоже используют `DB_URL` из env. Добавьте в их окружение или в общий `.env` тот же `DB_URL` при переходе на локальную БД.

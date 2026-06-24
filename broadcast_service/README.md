# Broadcast Service

Универсальный сервис для рассылки сообщений пользователям VPN бота.

## Использование

### Рассылка всем пользователям

```bash
# Интерактивный ввод текста
python broadcast_service/broadcast_message.py --all

# Текст из аргумента
python broadcast_service/broadcast_message.py --all --text "Привет всем!"

# Текст из файла
python broadcast_service/broadcast_message.py --all --file message.txt
```

### Рассылка пользователям без трафика

Рассылка пользователям, у которых `total_traffic_mb IS NULL` или `= 0`, с автоматической подстановкой их персональных VPN ключей.

```bash
# Использует message.txt по умолчанию
python broadcast_service/broadcast_message.py --no-traffic

# Текст из файла
python broadcast_service/broadcast_message.py --no-traffic --file message.txt
```

При использовании `--no-traffic` скрипт автоматически:
- Находит строку "Твой персональный ключ:" в тексте
- Подставляет персональный VPN ключ каждого пользователя после этой строки
- Если строка не найдена, добавляет ключ в конец сообщения

## Файлы

- `broadcast_message.py` - основной скрипт рассылки
- `message.txt` - шаблон сообщения по умолчанию для рассылки пользователям без трафика

## Требования

- Python 3
- Переменная окружения `TELEBOT_API` с токеном Telegram бота
- Доступ к базе данных PostgreSQL


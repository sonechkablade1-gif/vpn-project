FROM python:3.11-slim

# Устанавливаем зависимости системы
RUN apt-get update && apt-get install -y \
    wget \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Устанавливаем Xray
RUN wget -O /tmp/xray.zip https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip \
    && unzip /tmp/xray.zip -d /usr/local/bin/ \
    && chmod +x /usr/local/bin/xray \
    && rm /tmp/xray.zip

# Устанавливаем Python зависимости
RUN pip install --no-cache-dir \
    sqlalchemy \
    psycopg2-binary \
    paramiko

# Создаем рабочую директорию
WORKDIR /app

# Копируем скрипт
COPY collector.py /app/

# Делаем скрипт исполняемым
RUN chmod +x /app/collector.py

# Запускаем сервис
CMD ["python3", "-u", "/app/collector.py"]


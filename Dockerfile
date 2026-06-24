FROM python:3.10-slim

# Устанавливаем системные зависимости
RUN apt-get update && apt-get install -y \
    gcc \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Создаем рабочую директорию
WORKDIR /app

# Копируем только requirements.txt сначала для лучшего кэширования
COPY requirements.txt /app/

# Устанавливаем Python зависимости
RUN pip install --no-cache-dir -r requirements.txt

# Копируем код приложения
COPY src/ /app/src/
COPY main.py /app/

# Убеждаемся что Python выводит логи без буферизации
ENV PYTHONUNBUFFERED=1

# Запускаем приложение
CMD ["python", "-u", "main.py"]
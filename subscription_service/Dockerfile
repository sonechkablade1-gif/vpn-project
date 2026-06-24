FROM python:3.11-slim

RUN pip install --no-cache-dir \
    sqlalchemy \
    psycopg2-binary \
    paramiko \
    pyTelegramBotAPI

WORKDIR /app

COPY enforcer.py /app/
RUN chmod +x /app/enforcer.py

CMD ["python3", "-u", "/app/enforcer.py"]

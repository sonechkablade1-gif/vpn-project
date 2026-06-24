#!/usr/bin/env python3
"""Микросервис сбора трафика VPN пользователей"""
import subprocess
import json
import re
import time
from datetime import datetime
from sqlalchemy import create_engine, text
import os
import paramiko

DB_URL = os.getenv('DB_URL', "postgresql+psycopg2://vpn_user:vpn_pass@127.0.0.1:5432/vpn_db")
XRAY_API_HOST = os.getenv('XRAY_API_HOST', '127.0.0.1:8080')
INTERVAL_MINUTES = int(os.getenv('INTERVAL_MINUTES', '30'))
REMOTE_HOST = os.getenv('REMOTE_XRAY_HOST', '')
REMOTE_USER = os.getenv('REMOTE_XRAY_USER', 'root')
SSH_KEY_PATH = os.getenv('VPN_SSH_KEY_PATH', '')

# SSH клиент для удаленного сервера (если указан)
_ssh_client = None

def get_ssh_client():
    """Получить или создать SSH клиент для удаленного сервера"""
    global _ssh_client
    
    if not REMOTE_HOST:
        return None
    
    if _ssh_client is None:
        _ssh_client = paramiko.SSHClient()
        _ssh_client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        
        try:
            if SSH_KEY_PATH and os.path.exists(SSH_KEY_PATH):
                _ssh_client.connect(
                    REMOTE_HOST,
                    username=REMOTE_USER,
                    key_filename=SSH_KEY_PATH,
                    timeout=10
                )
            else:
                _ssh_client.connect(
                    REMOTE_HOST,
                    username=REMOTE_USER,
                    timeout=10
                )
            print(f"[{datetime.now()}] ✅ SSH подключение к {REMOTE_HOST} установлено")
        except Exception as e:
            print(f"[{datetime.now()}] ❌ Ошибка SSH подключения к {REMOTE_HOST}: {e}")
            _ssh_client = None
            return None
    
    return _ssh_client

def get_xray_traffic():
    """Получить текущую статистику из Xray API (локально или через SSH)"""
    try:
        ssh = get_ssh_client()
        
        if ssh:
            # Выполняем команду через SSH на удаленном сервере
            stdin, stdout, stderr = ssh.exec_command(
                f'xray api statsquery -server={XRAY_API_HOST} -pattern=user',
                timeout=10
            )
            output = stdout.read().decode()
            error = stderr.read().decode()
            
            if error and 'xray: command not found' in error:
                # Пробуем с полным путем
                stdin, stdout, stderr = ssh.exec_command(
                    f'/usr/local/bin/xray api statsquery -server={XRAY_API_HOST} -pattern=user',
                    timeout=10
                )
                output = stdout.read().decode()
                error = stderr.read().decode()
            
            if error and not output:
                print(f"[{datetime.now()}] ⚠️  SSH ошибка: {error}")
                return {}
            
            data = json.loads(output)
        else:
            # Локальное выполнение
            result = subprocess.run(
                ['xray', 'api', 'statsquery', f'-server={XRAY_API_HOST}', '-pattern', 'user'],
                capture_output=True, text=True, timeout=10
            )
            data = json.loads(result.stdout)
        
        user_traffic = {}
        
        if 'stat' in data:
            for item in data['stat']:
                name = item.get('name', '')
                value = int(item.get('value', 0))
                
                # Парсим: user>>>123@example.com>>>traffic>>>downlink
                match = re.match(r'user>>>(\d+)@example\.com>>>traffic>>>(downlink|uplink)', name)
                if match:
                    user_id = int(match.group(1))
                    direction = match.group(2)
                    
                    if user_id not in user_traffic:
                        user_traffic[user_id] = {'downlink': 0, 'uplink': 0}
                    user_traffic[user_id][direction] = value
        
        return user_traffic
        
    except Exception as e:
        print(f"[{datetime.now()}] ❌ Ошибка получения статистики Xray: {e}")
        import traceback
        traceback.print_exc()
        return {}

def save_traffic_to_db(user_traffic):
    """Сохранить трафик в БД накопительным итогом"""
    if not user_traffic:
        return 0
    
    try:
        engine = create_engine(DB_URL)
        saved_count = 0
        total_mb = 0
        
        with engine.begin() as conn:
            for user_id, traffic in user_traffic.items():
                total_bytes = traffic['downlink'] + traffic['uplink']
                
                if total_bytes > 0:
                    traffic_mb = round(total_bytes / (1024 * 1024))
                    total_mb += traffic_mb
                    
                    result = conn.execute(text("""
                        UPDATE vpn_users 
                        SET total_traffic_mb = COALESCE(total_traffic_mb, 0) + :mb
                        WHERE user_id = :uid
                        RETURNING total_traffic_mb, username
                    """), {"uid": user_id, "mb": traffic_mb})
                    
                    row = result.fetchone()
                    if row:
                        new_total_mb, username = row[0], row[1]
                        print(f"  ✅ User {user_id} ({username}): +{traffic_mb} MB → {new_total_mb} MB")
                        saved_count += 1
        
        engine.dispose()
        return saved_count, total_mb
        
    except Exception as e:
        print(f"[{datetime.now()}] ❌ Ошибка сохранения в БД: {e}")
        return 0, 0

def reset_xray_stats():
    """Сбросить счетчики Xray после сохранения (локально или через SSH)"""
    try:
        ssh = get_ssh_client()
        
        if ssh:
            # Выполняем команду через SSH
            stdin, stdout, stderr = ssh.exec_command(
                f'xray api statscmd -server={XRAY_API_HOST} -reset',
                timeout=10
            )
            error = stderr.read().decode()
            
            if error and 'xray: command not found' in error:
                # Пробуем с полным путем
                stdin, stdout, stderr = ssh.exec_command(
                    f'/usr/local/bin/xray api statscmd -server={XRAY_API_HOST} -reset',
                    timeout=10
                )
                error = stderr.read().decode()
            
            if error and 'command not found' in error:
                print(f"[{datetime.now()}] ⚠️  Xray не найден на удаленном сервере: {error}")
                return False
        else:
            # Локальное выполнение
            subprocess.run(
                ['xray', 'api', 'statscmd', f'-server={XRAY_API_HOST}', '-reset'],
                capture_output=True, text=True, timeout=10
            )
        return True
    except Exception as e:
        print(f"[{datetime.now()}] ⚠️  Ошибка сброса статистики: {e}")
        return False

def collect_and_save():
    """Основной цикл: собрать и сохранить трафик"""
    print(f"[{datetime.now()}] 🔄 Запуск сбора трафика...")
    
    # Получаем данные из Xray
    user_traffic = get_xray_traffic()
    
    if not user_traffic:
        print(f"[{datetime.now()}] ℹ️  Нет активного трафика")
        return
    
    print(f"[{datetime.now()}] 📊 Найдено {len(user_traffic)} пользователей с трафиком")
    
    # Сохраняем в БД
    saved_count, total_mb = save_traffic_to_db(user_traffic)
    
    if saved_count > 0:
        print(f"[{datetime.now()}] ✅ Сохранено: {saved_count} записей, {total_mb} MB")
        
        # Сбрасываем счетчики Xray
        if reset_xray_stats():
            print(f"[{datetime.now()}] 🔄 Счетчики Xray сброшены")
    
    print(f"[{datetime.now()}] ✓ Цикл завершен\n")

def main():
    """Главная функция микросервиса"""
    print("="*70)
    print("🚀 TRAFFIC COLLECTOR SERVICE")
    if REMOTE_HOST:
        print(f"🌐 Удаленный сервер: {REMOTE_HOST}")
    print(f"📡 Xray API: {XRAY_API_HOST}")
    print(f"⏱️  Интервал: {INTERVAL_MINUTES} минут")
    print(f"💾 БД подключена")
    print("="*70)
    print()
    
    while True:
        try:
            collect_and_save()
            
            # Ждем указанное количество минут
            next_run = datetime.now().replace(second=0, microsecond=0)
            next_run = next_run.replace(minute=(next_run.minute // INTERVAL_MINUTES + 1) * INTERVAL_MINUTES % 60)
            if next_run.minute == 0:
                next_run = next_run.replace(hour=next_run.hour + 1)
            
            sleep_seconds = INTERVAL_MINUTES * 60
            print(f"[{datetime.now()}] 😴 Ожидание {INTERVAL_MINUTES} минут до следующего запуска...")
            time.sleep(sleep_seconds)
            
        except KeyboardInterrupt:
            print(f"\n[{datetime.now()}] 🛑 Остановка сервиса...")
            break
        except Exception as e:
            print(f"[{datetime.now()}] ❌ Ошибка: {e}")
            print(f"[{datetime.now()}] ⏳ Повтор через 5 минут...")
            time.sleep(300)

if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""Микросервис отслеживания использования роутинга V2RayTun"""
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
INTERVAL_MINUTES = int(os.getenv('INTERVAL_MINUTES', '60'))
REMOTE_HOST = os.getenv('REMOTE_XRAY_HOST', '')
REMOTE_USER = os.getenv('REMOTE_XRAY_USER', 'root')
SSH_KEY_PATH = os.getenv('VPN_SSH_KEY_PATH', '')

# SSH клиент для удаленного сервера
_ssh_client = None

def get_ssh_client():
    """Получить или создать SSH клиент"""
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
            print(f"[{datetime.now()}] ❌ Ошибка SSH подключения: {e}")
            _ssh_client = None
            return None
    
    return _ssh_client

def get_active_users():
    """Получить список активных пользователей из Xray API"""
    try:
        ssh = get_ssh_client()
        
        if ssh:
            stdin, stdout, stderr = ssh.exec_command(
                f'xray api statsquery -server={XRAY_API_HOST} -pattern=user',
                timeout=10
            )
            output = stdout.read().decode()
            error = stderr.read().decode()
            
            if error and 'xray: command not found' in error:
                stdin, stdout, stderr = ssh.exec_command(
                    f'/usr/local/bin/xray api statsquery -server={XRAY_API_HOST} -pattern=user',
                    timeout=10
                )
                output = stdout.read().decode()
            
            if error and not output:
                return set()
            
            data = json.loads(output)
        else:
            result = subprocess.run(
                ['xray', 'api', 'statsquery', f'-server={XRAY_API_HOST}', '-pattern', 'user'],
                capture_output=True, text=True, timeout=10
            )
            data = json.loads(result.stdout)
        
        active_users = set()
        
        if 'stat' in data:
            for item in data['stat']:
                name = item.get('name', '')
                value = int(item.get('value', 0))
                
                if 'user>>>' in name and value > 0:
                    match = re.match(r'user>>>(\d+)@example\.com', name)
                    if match:
                        active_users.add(int(match.group(1)))
        
        return active_users
        
    except Exception as e:
        print(f"[{datetime.now()}] ❌ Ошибка получения активных пользователей: {e}")
        return set()

def get_users_with_routing():
    """Получить список пользователей, которым был отправлен роутинг"""
    try:
        engine = create_engine(DB_URL)
        with engine.connect() as conn:
            result = conn.execute(text("""
                SELECT DISTINCT user_id 
                FROM routing_usage
                WHERE routing_sent_at IS NOT NULL
            """))
            users = {row[0] for row in result}
        engine.dispose()
        return users
    except Exception as e:
        print(f"[{datetime.now()}] ⚠️  Ошибка получения пользователей с роутингом: {e}")
        return set()

def update_routing_usage():
    """Обновить статистику использования роутинга"""
    print(f"[{datetime.now()}] 🔄 Проверка использования роутинга...")
    
    # Получаем активных пользователей
    active_users = get_active_users()
    print(f"[{datetime.now()}] 📊 Активных пользователей: {len(active_users)}")
    
    # Получаем пользователей с роутингом
    users_with_routing = get_users_with_routing()
    print(f"[{datetime.now()}] 🔀 Пользователей с роутингом: {len(users_with_routing)}")
    
    # Пересечение = потенциальные пользователи роутинга
    potential_routing_users = active_users & users_with_routing
    
    if not potential_routing_users:
        print(f"[{datetime.now()}] ℹ️  Нет пользователей, использующих роутинг")
        return
    
    print(f"[{datetime.now()}] ✅ Потенциально используют роутинг: {len(potential_routing_users)}")
    
    # Обновляем базу данных
    try:
        engine = create_engine(DB_URL)
        updated_count = 0
        
        with engine.begin() as conn:
            for user_id in potential_routing_users:
                # Проверяем, был ли уже обновлен статус
                result = conn.execute(text("""
                    SELECT uses_routing 
                    FROM routing_usage 
                    WHERE user_id = :uid
                    ORDER BY routing_sent_at DESC
                    LIMIT 1
                """), {"uid": user_id})
                
                row = result.fetchone()
                
                if not row or not row[0]:
                    # Обновляем статус
                    conn.execute(text("""
                        UPDATE routing_usage 
                        SET uses_routing = TRUE,
                            last_traffic_check = NOW()
                        WHERE user_id = :uid
                    """), {"uid": user_id})
                    updated_count += 1
                    print(f"  ✅ User {user_id}: роутинг используется")
                else:
                    # Просто обновляем время последней проверки
                    conn.execute(text("""
                        UPDATE routing_usage 
                        SET last_traffic_check = NOW()
                        WHERE user_id = :uid
                    """), {"uid": user_id})
        
        engine.dispose()
        
        if updated_count > 0:
            print(f"[{datetime.now()}] ✅ Обновлено записей: {updated_count}")
        
    except Exception as e:
        print(f"[{datetime.now()}] ❌ Ошибка обновления БД: {e}")
        import traceback
        traceback.print_exc()

def show_statistics():
    """Показать статистику использования роутинга"""
    try:
        engine = create_engine(DB_URL)
        
        with engine.connect() as conn:
            # Общая статистика
            result = conn.execute(text("""
                SELECT 
                    COUNT(DISTINCT user_id) as total_users,
                    COUNT(DISTINCT CASE WHEN uses_routing THEN user_id END) as using_routing,
                    COUNT(DISTINCT CASE WHEN NOT uses_routing THEN user_id END) as not_using_routing
                FROM routing_usage
            """))
            
            row = result.fetchone()
            total, using, not_using = row[0] or 0, row[1] or 0, row[2] or 0
            
            print(f"\n{'='*70}")
            print(f"📊 СТАТИСТИКА ИСПОЛЬЗОВАНИЯ РОУТИНГА")
            print(f"{'='*70}")
            print(f"Всего пользователей с роутингом: {total}")
            print(f"Используют роутинг: {using}")
            print(f"Не используют: {not_using}")
            
            if total > 0:
                usage_percent = (using / total) * 100
                print(f"Процент использования: {usage_percent:.1f}%")
            
            # Топ пользователей
            print(f"\n👥 Пользователи, использующие роутинг:")
            result = conn.execute(text("""
                SELECT DISTINCT ru.user_id, vu.username, ru.last_traffic_check
                FROM routing_usage ru
                LEFT JOIN vpn_users vu ON ru.user_id = vu.user_id
                WHERE ru.uses_routing = TRUE
                ORDER BY ru.last_traffic_check DESC
                LIMIT 10
            """))
            
            users = result.fetchall()
            if users:
                print(f"{'User ID':<15} {'Username':<25} {'Последняя активность':<20}")
                print("-" * 70)
                for user_id, username, last_check in users:
                    username_str = (username[:23] if username else '-')
                    check_str = str(last_check)[:19] if last_check else '-'
                    print(f"{user_id:<15} {username_str:<25} {check_str:<20}")
            else:
                print("  (пока нет данных)")
            
            print(f"{'='*70}\n")
        
        engine.dispose()
        
    except Exception as e:
        print(f"[{datetime.now()}] ❌ Ошибка получения статистики: {e}")

def main():
    """Главная функция микросервиса"""
    print("="*70)
    print("🚀 ROUTING TRACKER SERVICE")
    if REMOTE_HOST:
        print(f"🌐 Удаленный сервер: {REMOTE_HOST}")
    print(f"📡 Xray API: {XRAY_API_HOST}")
    print(f"⏱️  Интервал: {INTERVAL_MINUTES} минут")
    print(f"💾 БД подключена")
    print("="*70)
    print()
    
    # Показываем статистику при старте
    show_statistics()
    
    last_stats_hour = datetime.now().hour
    
    while True:
        try:
            update_routing_usage()
            
            # Показываем статистику раз в 4 часа
            current_hour = datetime.now().hour
            if current_hour != last_stats_hour and current_hour % 4 == 0:
                show_statistics()
                last_stats_hour = current_hour
            
            sleep_seconds = INTERVAL_MINUTES * 60
            print(f"[{datetime.now()}] 😴 Ожидание {INTERVAL_MINUTES} минут до следующей проверки...")
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


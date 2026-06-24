# src/traffic_collector.py
"""Collect and accumulate traffic statistics from Xray (legacy — user_traffic table)"""
import os
import re
import subprocess
import json
from sqlalchemy import create_engine, text
from datetime import datetime

DB_URL = os.getenv("DB_URL", "postgresql+psycopg2://vpn_user:vpn_pass@127.0.0.1:5432/vpn_db")

def convert_to_bytes(size_str):
    if not size_str or not size_str.strip():
        return 0
    match = re.match(r'([\d.]+)\s*(MB|kB|GB|B)', size_str.strip(), re.IGNORECASE)
    if not match:
        return 0
    value, unit = float(match.group(1)), match.group(2).upper()
    multipliers = {'B': 1, 'KB': 1024, 'MB': 1024**2, 'GB': 1024**3}
    return int(value * multipliers.get(unit, 0))

def get_xray_stats():
    """Получить статистику трафика напрямую через Xray API"""
    # Сначала получаем список всех счетчиков статистики
    try:
        result = subprocess.run(
            ['xray', 'api', 'statsquery', '-server=127.0.0.1:8080', '-pattern', 'user'],
            capture_output=True, text=True, timeout=10
        )
        
        # Если есть статистика - парсим её
        data = json.loads(result.stdout)
        
        stats = {}
        # Группируем данные по пользователям
        user_data = {}
        
        if 'stat' in data:
            for item in data['stat']:
                name = item.get('name', '')
                value = int(item.get('value', 0))
                
                # Парсим имя: user>>>123@example.com>>>traffic>>>downlink
                match = re.match(r'user>>>(\d+)@example\.com>>>traffic>>>(downlink|uplink)', name)
                if match:
                    user_id = int(match.group(1))
                    direction = match.group(2)
                    
                    if user_id not in user_data:
                        user_data[user_id] = {'downlink': 0, 'uplink': 0}
                    user_data[user_id][direction] = value
            
            # Суммируем download + upload для каждого пользователя
            for user_id, traffic in user_data.items():
                total = traffic['downlink'] + traffic['uplink']
                if total > 0:
                    stats[user_id] = total
                    
        print(f"🔍 DEBUG: Найдено {len(stats)} пользователей с трафиком через API")
        return stats
        
    except (subprocess.TimeoutExpired, json.JSONDecodeError, Exception) as e:
        print(f"⚠️  Ошибка получения статистики через API: {e}")
        print(f"    Попробуйте проверить: systemctl status xray")
        return {}

def accumulate_traffic():
    stats = get_xray_stats()
    if not stats:
        print("ℹ️ No new traffic")
        return
    
    print(f"📊 Collecting traffic for {len(stats)} users...")
    engine = create_engine(DB_URL)
    with engine.begin() as conn:
        for user_id, new_bytes in stats.items():
            result = conn.execute(text("""
                INSERT INTO user_traffic (user_id, total_traffic_bytes)
                VALUES (:uid, :bytes)
                ON CONFLICT (user_id) DO UPDATE 
                SET total_traffic_bytes = user_traffic.total_traffic_bytes + :bytes
                RETURNING total_traffic_bytes
            """), {"uid": user_id, "bytes": new_bytes})
            total = result.fetchone()[0]
            print(f"✅ User {user_id}: +{new_bytes/1024**2:.2f}MB → {total/1024**2:.2f}MB total")
    
    subprocess.run(['./ex.sh', 'stats', 'reset'], cwd='/root/easy-xray', input='y\n', text=True, capture_output=True)
    print("✅ Stats reset\n")
    engine.dispose()

def show_stats():
    engine = create_engine(DB_URL)
    print("\n📊 All-Time Traffic Statistics")
    print("="*70)
    with engine.begin() as conn:
        result = conn.execute(text("""
            SELECT ut.user_id, ut.total_traffic_bytes, vu.username
            FROM user_traffic ut
            LEFT JOIN vpn_users vu ON ut.user_id = vu.user_id
            ORDER BY ut.total_traffic_bytes DESC
        """))
        print(f"{'User ID':<15} {'Traffic':<15} {'Username':<20}")
        print("-"*70)
        total_bytes = 0
        for user_id, bytes_val, username in result:
            mb = bytes_val/1024**2
            total_bytes += bytes_val
            print(f"{user_id:<15} {mb:>10.2f} MB   {username or '-':<20}")
        print("-"*70)
        print(f"{'TOTAL:':<15} {total_bytes/1024**2:>10.2f} MB")
    engine.dispose()

if __name__ == "__main__":
    import sys
    if '--show' in sys.argv:
        accumulate_traffic()  # Сначала собираем и записываем
        show_stats()          # Потом показываем
    else:
        accumulate_traffic()  # Только сбор
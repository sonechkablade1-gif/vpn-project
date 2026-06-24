#!/usr/bin/env python3
"""
Универсальный скрипт для рассылки сообщений пользователям VPN бота

Использование:
    # Рассылка всем пользователям
    python broadcast_service/run.py --all
    python broadcast_service/run.py --all --text "Ваш текст"
    python broadcast_service/run.py --all --file message.txt
    
    # Рассылка пользователям без трафика (с автоматической подстановкой VPN ключей)
    python broadcast_service/run.py --no-traffic
    python broadcast_service/run.py --no-traffic --file message.txt
"""

import os
import time
import sys
import argparse
from pathlib import Path
from dotenv import load_dotenv
import telebot
import pandas as pd
from sqlalchemy import create_engine

# Загружаем настройки окружения
load_dotenv(override=True)

# БД: локальная (Beget удалена)
DB_URL = os.getenv("DB_URL", "postgresql+psycopg2://vpn_user:vpn_pass@127.0.0.1:5432/vpn_db")
engine = create_engine(DB_URL)

bot = telebot.TeleBot(token=os.environ.get("TELEBOT_API"))


def get_all_users():
    """Получает всех пользователей из таблицы vpn_users"""
    try:
        with engine.begin() as conn:
            query = "SELECT DISTINCT user_id, username FROM vpn_users ORDER BY user_id"
            df = pd.read_sql_query(query, conn)
        return df
    except Exception as e:
        print(f"❌ Ошибка при получении пользователей из базы: {e}")
        return pd.DataFrame()


def get_users_without_traffic():
    """Получает всех пользователей без трафика (total_traffic_mb IS NULL или = 0) с их vpn_url"""
    try:
        with engine.begin() as conn:
            query = """
                SELECT user_id, username, vpn_url 
                FROM vpn_users 
                WHERE (total_traffic_mb IS NULL OR total_traffic_mb = 0)
                  AND vpn_url IS NOT NULL
                ORDER BY user_id
            """
            df = pd.read_sql_query(query, conn)
        return df
    except Exception as e:
        print(f"❌ Ошибка при получении пользователей из базы: {e}")
        return pd.DataFrame()


def read_message_from_file(file_path=None):
    """Читает текст сообщения из файла"""
    if file_path:
        message_file = Path(file_path)
    else:
        # По умолчанию ищем message.txt в той же папке
        script_dir = Path(__file__).parent
        message_file = script_dir / "message.txt"
    
    try:
        with open(message_file, 'r', encoding='utf-8') as f:
            return f.read().strip()
    except FileNotFoundError:
        print(f"❌ Файл '{message_file}' не найден")
        sys.exit(1)
    except Exception as e:
        print(f"❌ Ошибка при чтении файла: {e}")
        sys.exit(1)


def format_message_with_key(message_text, vpn_url):
    """Форматирует сообщение с подстановкой VPN ключа"""
    if "Твой персональный ключ:" in message_text:
        parts = message_text.split("Твой персональный ключ:", 1)
        if len(parts) > 1:
            return f"{parts[0]}Твой персональный ключ:\n\n```{vpn_url}```\n\n{parts[1].lstrip()}"
        else:
            return f"{message_text}\n\n```{vpn_url}```"
    else:
        return f"{message_text}\n\n```{vpn_url}```"


def show_preview(message_text, mode='all'):
    """Показывает предпросмотр сообщения"""
    print("\n" + "="*70)
    print("📋 ПРЕДПРОСМОТР СООБЩЕНИЯ")
    print("="*70)
    
    if mode == 'no-traffic':
        example_key = "vless://12345678-1234-1234-1234-123456789abc@example.com:443?type=tcp&security=tls&sni=example.com#VPN_Connection"
        final_message = format_message_with_key(message_text, example_key)
        print("\n📨 Финальное сообщение (с автоматической подстановкой VPN ключа):")
        print("-" * 70)
        print(final_message)
        print("-" * 70)
        print("\n💡 В Telegram ключ будет отображаться как код-блок после строки 'Твой персональный ключ:'")
    else:
        print("\n📨 Сообщение:")
        print("-" * 70)
        print(message_text)
        print("-" * 70)
    
    print("="*70)
    print()


def send_broadcast_all(message_text, delay_seconds=0.05):
    """Отправляет сообщение всем пользователям"""
    print("📋 Получаю список пользователей из базы данных...")
    users_df = get_all_users()
    
    if users_df.empty:
        print("❌ Не найдено ни одного пользователя в базе данных")
        return None
    
    total_users = len(users_df)
    print(f"✅ Найдено пользователей: {total_users}")
    print(f"📝 Текст сообщения:\n{message_text}\n")
    
    confirmation = input("⚠️  Начать рассылку? (yes/no): ").strip().lower()
    if confirmation not in ['yes', 'y', 'да', 'д']:
        print("❌ Рассылка отменена")
        return None
    
    stats = {
        'total': total_users,
        'success': 0,
        'failed': 0,
        'blocked': 0,
        'errors': []
    }
    
    print(f"\n🚀 Начинаю рассылку для {total_users} пользователей...\n")
    
    for index, row in users_df.iterrows():
        user_id = row['user_id']
        username = row.get('username', 'N/A')
        
        try:
            bot.send_message(user_id, message_text)
            stats['success'] += 1
            
            progress = ((index + 1) / total_users) * 100
            print(f"[{index + 1}/{total_users}] ({progress:.1f}%) ✅ Отправлено пользователю {user_id} ({username})")
            
            if delay_seconds > 0:
                time.sleep(delay_seconds)
                
        except telebot.apihelper.ApiTelegramException as e:
            stats['failed'] += 1
            
            if "bot was blocked by the user" in str(e).lower() or "chat not found" in str(e).lower():
                stats['blocked'] += 1
                print(f"[{index + 1}/{total_users}] ⛔ Пользователь {user_id} ({username}) заблокировал бота")
            else:
                error_msg = f"Пользователь {user_id} ({username}): {e}"
                stats['errors'].append(error_msg)
                print(f"[{index + 1}/{total_users}] ❌ Ошибка для {user_id} ({username}): {e}")
        
        except Exception as e:
            stats['failed'] += 1
            error_msg = f"Пользователь {user_id} ({username}): {e}"
            stats['errors'].append(error_msg)
            print(f"[{index + 1}/{total_users}] ❌ Неожиданная ошибка для {user_id} ({username}): {e}")
    
    return stats


def send_broadcast_no_traffic(message_text, delay_seconds=0.05):
    """Отправляет сообщение пользователям без трафика с автоматической подстановкой VPN ключей"""
    print("📋 Получаю список пользователей без трафика из базы данных...")
    users_df = get_users_without_traffic()
    
    if users_df.empty:
        print("❌ Не найдено ни одного пользователя без трафика с vpn_url")
        return None
    
    total_users = len(users_df)
    print(f"✅ Найдено пользователей без трафика: {total_users}")
    print(f"📝 Текст сообщения:\n{message_text}\n")
    
    confirmation = input("⚠️  Начать рассылку? (yes/no): ").strip().lower()
    if confirmation not in ['yes', 'y', 'да', 'д']:
        print("❌ Рассылка отменена")
        return None
    
    stats = {
        'total': total_users,
        'success': 0,
        'failed': 0,
        'blocked': 0,
        'errors': []
    }
    
    print(f"\n🚀 Начинаю рассылку для {total_users} пользователей...\n")
    
    for index, row in users_df.iterrows():
        user_id = row['user_id']
        username = row.get('username', 'N/A')
        vpn_url = row.get('vpn_url', '')
        
        if not vpn_url:
            print(f"[{index + 1}/{total_users}] ⚠️  Пропущен пользователь {user_id} ({username}) - нет vpn_url")
            continue
        
        try:
            final_message = format_message_with_key(message_text, vpn_url)
            bot.send_message(user_id, final_message, parse_mode='Markdown')
            
            stats['success'] += 1
            
            progress = ((index + 1) / total_users) * 100
            print(f"[{index + 1}/{total_users}] ({progress:.1f}%) ✅ Отправлено пользователю {user_id} ({username})")
            
            if delay_seconds > 0:
                time.sleep(delay_seconds)
                
        except telebot.apihelper.ApiTelegramException as e:
            stats['failed'] += 1
            
            if "bot was blocked by the user" in str(e).lower() or "chat not found" in str(e).lower():
                stats['blocked'] += 1
                print(f"[{index + 1}/{total_users}] ⛔ Пользователь {user_id} ({username}) заблокировал бота")
            else:
                error_msg = f"Пользователь {user_id} ({username}): {e}"
                stats['errors'].append(error_msg)
                print(f"[{index + 1}/{total_users}] ❌ Ошибка для {user_id} ({username}): {e}")
        
        except Exception as e:
            stats['failed'] += 1
            error_msg = f"Пользователь {user_id} ({username}): {e}"
            stats['errors'].append(error_msg)
            print(f"[{index + 1}/{total_users}] ❌ Неожиданная ошибка для {user_id} ({username}): {e}")
    
    return stats


def print_stats(stats):
    """Выводит статистику рассылки"""
    if not stats:
        return
    
    print("\n" + "="*70)
    print("📊 СТАТИСТИКА РАССЫЛКИ")
    print("="*70)
    print(f"Всего пользователей: {stats['total']}")
    print(f"✅ Успешно отправлено: {stats['success']}")
    print(f"❌ Ошибок: {stats['failed']}")
    print(f"⛔ Заблокировали бота: {stats['blocked']}")
    if stats['total'] > 0:
        print(f"📈 Процент успеха: {(stats['success'] / stats['total'] * 100):.1f}%")
    
    if stats['errors']:
        print(f"\n⚠️  Детали ошибок (первые 10):")
        for error in stats['errors'][:10]:
            print(f"  - {error}")
        if len(stats['errors']) > 10:
            print(f"  ... и еще {len(stats['errors']) - 10} ошибок")
    
    print("="*70)


def get_message_text(args):
    """Получает текст сообщения из различных источников"""
    if args.text:
        return args.text
    elif args.file:
        return read_message_from_file(args.file)
    else:
        # Интерактивный ввод
        print("Введите текст сообщения для рассылки.")
        print("(Для многострочного текста используйте Enter, завершите ввод пустой строкой)")
        print("-" * 70)
        
        message_lines = []
        while True:
            try:
                line = input()
                if line.strip() == "" and message_lines:
                    break
                if line.strip():
                    message_lines.append(line)
            except EOFError:
                break
        
        if not message_lines:
            print("❌ Сообщение не может быть пустым. Рассылка отменена.")
            sys.exit(1)
        
        return "\n".join(message_lines)


def main():
    """Главная функция"""
    parser = argparse.ArgumentParser(
        description='Универсальный скрипт для рассылки сообщений пользователям VPN бота',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Примеры использования:
  # Рассылка всем пользователям
  python broadcast_service/broadcast_message.py --all
  python broadcast_service/broadcast_message.py --all --text "Привет всем!"
  python broadcast_service/broadcast_message.py --all --file message.txt
  
  # Рассылка пользователям без трафика (с автоматической подстановкой VPN ключей)
  python broadcast_service/broadcast_message.py --no-traffic
  python broadcast_service/broadcast_message.py --no-traffic --file message.txt
        """
    )
    
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument('--all', action='store_true', help='Рассылка всем пользователям')
    group.add_argument('--no-traffic', action='store_true', help='Рассылка пользователям без трафика (с VPN ключами)')
    
    parser.add_argument('--text', type=str, help='Текст сообщения для рассылки')
    parser.add_argument('--file', type=str, help='Путь к файлу с текстом сообщения')
    
    args = parser.parse_args()
    
    print("="*70)
    if args.all:
        print("📢 РАССЫЛКА ВСЕМ ПОЛЬЗОВАТЕЛЯМ")
    else:
        print("📢 РАССЫЛКА ПОЛЬЗОВАТЕЛЯМ БЕЗ ТРАФИКА")
    print("="*70)
    print()
    
    # Проверяем наличие токена бота
    if not os.environ.get("TELEBOT_API"):
        print("❌ Ошибка: TELEBOT_API не установлен в переменных окружения")
        sys.exit(1)
    
    # Получаем текст сообщения
    message_text = get_message_text(args)
    
    if not message_text or not message_text.strip():
        print("❌ Сообщение не может быть пустым. Рассылка отменена.")
        sys.exit(1)
    
    # Показываем предпросмотр
    mode = 'all' if args.all else 'no-traffic'
    show_preview(message_text, mode=mode)
    
    # Выполняем рассылку
    if args.all:
        stats = send_broadcast_all(message_text, delay_seconds=0.05)
    else:
        stats = send_broadcast_no_traffic(message_text, delay_seconds=0.05)
    
    # Выводим статистику
    if stats:
        print_stats(stats)
    
    print("\n✅ Рассылка завершена!")


if __name__ == '__main__':
    try:
        main()
    except KeyboardInterrupt:
        print("\n\n⚠️  Рассылка прервана пользователем")
        sys.exit(1)
    except Exception as e:
        print(f"\n❌ Критическая ошибка: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)
    finally:
        engine.dispose()


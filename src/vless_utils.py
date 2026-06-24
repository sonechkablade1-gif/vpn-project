"""
Утилиты для работы с VLESS ключами
Включает кодирование/декодирование и валидацию
"""

import base64
import re
from urllib.parse import urlparse

def decode_vless_url(encoded_url):
    """Декодирует VLESS URL из base64"""
    try:
        decoded_url = base64.b64decode(encoded_url.encode()).decode()
        return decoded_url
    except Exception as e:
        print(f"❌ Ошибка декодирования VLESS URL: {e}")
        return None

def validate_vless_url(vless_url):
    """Проверяет валидность VLESS URL"""
    try:
        if not vless_url.startswith('vless://'):
            return False, "URL должен начинаться с 'vless://'"
        
        # Парсим URL
        url_parts = vless_url[8:]  # Убираем 'vless://'
        
        if '#' in url_parts:
            main_part, fragment = url_parts.split('#', 1)
        else:
            main_part = url_parts
            fragment = ""
        
        # Проверяем наличие пользователя и сервера
        if '@' not in main_part:
            return False, "Не найден символ '@' для разделения пользователя и сервера"
        
        user_part, server_part = main_part.split('@', 1)
        
        # Проверяем UUID пользователя
        uuid_pattern = r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$'
        if not re.match(uuid_pattern, user_part, re.IGNORECASE):
            return False, f"Неверный формат UUID: {user_part}"
        
        # Проверяем сервер и порт
        if ':' not in server_part:
            return False, "Не найден порт сервера"
        
        server, port_part = server_part.split(':', 1)
        
        # Извлекаем порт (может быть параметры после ?)
        if '?' in port_part:
            port, params = port_part.split('?', 1)
        else:
            port = port_part
            params = ""
        
        try:
            port_num = int(port)
            if not (1 <= port_num <= 65535):
                return False, f"Неверный номер порта: {port_num}"
        except ValueError:
            return False, f"Порт должен быть числом: {port}"
        
        # Проверяем IP адрес или домен
        ip_pattern = r'^(\d{1,3}\.){3}\d{1,3}$'
        domain_pattern = r'^[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
        
        if not (re.match(ip_pattern, server) or re.match(domain_pattern, server)):
            return False, f"Неверный формат сервера: {server}"
        
        return True, "VLESS URL валиден"
        
    except Exception as e:
        return False, f"Ошибка валидации: {e}"

def get_vless_info(vless_url):
    """Извлекает информацию из VLESS URL"""
    try:
        if not vless_url.startswith('vless://'):
            return None
        
        url_parts = vless_url[8:]  # Убираем 'vless://'
        
        if '#' in url_parts:
            main_part, fragment = url_parts.split('#', 1)
        else:
            main_part = url_parts
            fragment = ""
        
        if '@' not in main_part:
            return None
        
        user_part, server_part = main_part.split('@', 1)
        
        # Извлекаем сервер и порт
        if ':' not in server_part:
            return None
        
        server, port_part = server_part.split(':', 1)
        
        if '?' in port_part:
            port, params = port_part.split('?', 1)
        else:
            port = port_part
            params = ""
        
        return {
            "uuid": user_part,
            "server": server,
            "port": int(port),
            "params": params,
            "fragment": fragment,
            "full_url": vless_url
        }
        
    except Exception as e:
        print(f"❌ Ошибка извлечения информации: {e}")
        return None

def create_safe_vless_url(vless_url):
    """Создает безопасную версию VLESS URL"""
    try:
        # Валидируем URL
        is_valid, message = validate_vless_url(vless_url)
        if not is_valid:
            print(f"⚠️ Невалидный VLESS URL: {message}")
            return None
        
        # Кодируем в base64
        encoded_url = base64.b64encode(vless_url.encode()).decode()
        
        return {
            "original": vless_url,
            "base64": encoded_url,
            "safe": encoded_url,
            "info": get_vless_info(vless_url)
        }
        
    except Exception as e:
        print(f"❌ Ошибка создания безопасного URL: {e}")
        return None

def format_vless_for_user(vless_url, encode=True):
    """Форматирует VLESS URL для отправки пользователю"""
    try:
        if encode:
            # Кодируем URL
            safe_info = create_safe_vless_url(vless_url)
            if safe_info:
                return safe_info["safe"]
            else:
                return vless_url
        else:
            return vless_url
            
    except Exception as e:
        print(f"❌ Ошибка форматирования: {e}")
        return vless_url

def decode_and_validate_user_url(encoded_url):
    """Декодирует и валидирует URL от пользователя"""
    try:
        # Пробуем декодировать
        decoded_url = decode_vless_url(encoded_url)
        if not decoded_url:
            return None, "Не удалось декодировать URL"
        
        # Валидируем
        is_valid, message = validate_vless_url(decoded_url)
        if not is_valid:
            return None, f"Невалидный URL: {message}"
        
        return decoded_url, "URL валиден"
        
    except Exception as e:
        return None, f"Ошибка обработки URL: {e}"

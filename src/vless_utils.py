"""
Утилиты для работы с VLESS ключами
Разбор VLESS URL
"""


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


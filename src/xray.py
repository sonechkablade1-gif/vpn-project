import os
import time

from urllib.parse import urlparse
from src.database import get_urls_from_db, add_url_to_db
import paramiko

# 185.221.22.150 — VPN-сервер (XRay/easy-xray). Сюда подключаются клиенты.
XRAY_SERVER = os.getenv("XRAY_HOST", "185.221.22.150")
OLD_IP = "89.40.233.3"
OLD_SERVER_IPS = [OLD_IP, "185.245.35.92", "194.48.142.252"]

class CmdError(Exception):
    pass


class URLFormatError(Exception):
    pass


class XRayRemoteInterface(object):
    """Интерфейс для работы с XRay через SSH на удаленном сервере"""
    
    def __init__(self, host=None, username="root", ssh_key_path=None, easy_xray_path="/root/easy-xray"):
        self.host = host or XRAY_SERVER
        self.username = username
        self.ssh_key_path = ssh_key_path
        self.easy_xray_path = easy_xray_path
        self.ex_script = os.path.join(easy_xray_path, "ex.sh")
        self._ssh_client = None
    
    def _get_ssh_client(self):
        """Получает или создает SSH клиент"""
        if self._ssh_client is None:
            self._ssh_client = paramiko.SSHClient()
            self._ssh_client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
            
            if self.ssh_key_path and os.path.exists(self.ssh_key_path):
                self._ssh_client.connect(
                    self.host,
                    username=self.username,
                    key_filename=self.ssh_key_path
                )
            else:
                self._ssh_client.connect(
                    self.host,
                    username=self.username
                )
        return self._ssh_client
    
    def _exec_ssh_command(self, command, timeout=60):
        """Выполняет команду на удаленном сервере через SSH"""
        ssh = self._get_ssh_client()
        stdin, stdout, stderr = ssh.exec_command(
            f"cd {self.easy_xray_path} && {command}",
            timeout=timeout
        )
        
        output = stdout.read().decode().strip()
        error = stderr.read().decode().strip()
        exit_status = stdout.channel.recv_exit_status()
        
        if exit_status != 0:
            error_msg = error if error else f"Command failed with exit status {exit_status}"
            raise CmdError(f"SSH command failed: {error_msg}")
        
        return output.split('\n') if output else []
    
    def _exec_ssh_command_interactive(self, command, input_text, timeout=60):
        """Выполняет интерактивную команду с автоматическими ответами"""
        ssh = self._get_ssh_client()
        stdin, stdout, stderr = ssh.exec_command(
            f"cd {self.easy_xray_path} && {command}",
            timeout=timeout,
            get_pty=True
        )
        
        # Отправляем ответы
        stdin.write(input_text)
        stdin.flush()
        
        # Ждем завершения команды
        output = stdout.read().decode().strip()
        error = stderr.read().decode().strip()
        exit_status = stdout.channel.recv_exit_status()
        
        if exit_status != 0:
            error_msg = error if error else f"Command failed with exit status {exit_status}"
            raise CmdError(f"SSH command failed: {error_msg}")
        
        return output.split('\n') if output else []
    
    def add_xray_user(self, user_id, add_user_exception='warn'):
        """Добавляет пользователя на удаленном сервере"""
        cmd = f"{self.ex_script} add {user_id}"
        auto_responses = "Y\nS\n"
        
        try:
            output = self._exec_ssh_command_interactive(cmd, auto_responses, timeout=60)
            print(f"✅ Пользователь {user_id} добавлен на удаленном сервере: {output}")
            time.sleep(2)
            return True
        except Exception as e:
            if add_user_exception == 'raise':
                raise e
            else:
                print(f"⚠️ Предупреждение при добавлении пользователя {user_id}: {e}")
                return False
    
    def get_xray_url(self, user_id, url_format_exception='warn'):
        """Получает VLESS URL для пользователя с удаленного сервера"""
        config_path = f'conf/config_client_{user_id}.json'
        cmd = f"{self.ex_script} link {config_path}"
        
        try:
            output = self._exec_ssh_command(cmd, timeout=60)
            
            url = None
            for line in output:
                line = line.strip()
                if line.startswith('vless://'):
                    url = line
                    break
            
            if not url:
                raise CmdError("No valid URL found in output")
            
            # ex.sh на 194.48.142.252 отдаёт ссылку с адресом из шаблона (185.245.35.92 — бот).
            # Подменяем на VPN-сервер 194.48.142.252, куда клиенты должны подключаться.
            url = self._replace_server_ip(url)
            check_url_format(url, url_format_exception)
            return url
            
        except Exception as e:
            if url_format_exception == 'raise':
                raise e
            else:
                print(f"⚠️ Предупреждение при получении URL для {user_id}: {e}")
                return None
    
    def _replace_server_ip(self, vless_url):
        """Заменяет IP адрес в VLESS URL на IP удаленного сервера"""
        from src.vless_utils import get_vless_info
        
        info = get_vless_info(vless_url)
        if not info:
            return vless_url
        
        # Сохраняем все параметры, меняем только IP
        uuid = info["uuid"]
        port = info["port"]
        params = info["params"]
        fragment = info["fragment"]
        
        new_url = f"vless://{uuid}@{self.host}:{port}"
        if params:
            new_url += f"?{params}"
        if fragment:
            new_url += f"#{fragment}"
        
        return new_url
    
    def resume_xray_user(self, user_id):
        """Восстанавливает пользователя на XRay (VPN снова работает, тот же ключ)"""
        cmd = f"{self.ex_script} resume {user_id}"
        auto_responses = "Y\nS\n"
        try:
            self._exec_ssh_command_interactive(cmd, auto_responses, timeout=60)
            print(f"✅ Пользователь {user_id} восстановлен на XRay")
            time.sleep(2)
            return True
        except Exception as e:
            print(f"⚠️ Ошибка при восстановлении {user_id} на XRay: {e}")
            return False

    def close(self):
        """Закрывает SSH соединение"""
        if self._ssh_client:
            self._ssh_client.close()
            self._ssh_client = None


def check_url_format(url, format_exception='raise'):
    url_components = urlparse(url)
    checks = [
        url_components.scheme == 'vless',
        all([
            url_components.scheme,
            url_components.netloc,
            url_components.query,
            url_components.fragment
        ])
    ]

    if not all(checks) and format_exception == 'raise':
        raise URLFormatError(f'Wrong URL format: {url}')
    elif not all(checks) and format_exception == 'warn':
        print(f'Warning: wrong URL format: {url}')

    return all(checks)


def update_vless_url_ip(vless_url, new_ip=None, old_ips=None):
    """
    Обновляет IP адрес в существующем VLESS URL после переноса сервера.
    Сначала пробует разобрать URL; если не получилось — подменяет старые IP строкой (fallback).
    """
    from src.vless_utils import get_vless_info

    new_ip = new_ip or XRAY_SERVER
    old_ips = old_ips if old_ips is not None else OLD_SERVER_IPS

    info = get_vless_info(vless_url)
    if info:
        uuid = info["uuid"]
        port = info["port"]
        params = info["params"]
        fragment = info["fragment"]
        new_url = f"vless://{uuid}@{new_ip}:{port}"
        if params:
            new_url += f"?{params}"
        if fragment:
            new_url += f"#{fragment}"
        return new_url

    # Fallback: парсинг не сработал — заменяем все известные старые IP в строке
    result = vless_url
    for old_ip in old_ips:
        if old_ip in result:
            result = result.replace(old_ip, new_ip)
    return result


def cook_user_xray_link(engine, user_id, host_ids=None, bot=None, chat_id=None, force_rotate=False):
    host_ids = host_ids or [0]

    if not force_rotate:
        urls = get_urls_from_db(engine, user_id, host_ids)
        if len(urls) > 0:
            updated_urls = [update_vless_url_ip(url) for url in urls]
            if updated_urls != urls:
                for url in updated_urls:
                    add_url_to_db(engine, user_id, host_ids[0], url)
                    print(f"✅ URL для пользователя {user_id} сохранен в базе данных")
            return updated_urls

    urls = []
    for id_ in host_ids:
        try:
            ssh_key = os.getenv('VPN_SSH_KEY_PATH')
            xray_client = XRayRemoteInterface(ssh_key_path=ssh_key)
            print(f"🔧 Провиженим пользователя {user_id} на {xray_client.host} ...")

            success = xray_client.add_xray_user(user_id)
            if success:
                url = xray_client.get_xray_url(user_id)
                if url:
                    urls.append(url)
                    add_url_to_db(engine, user_id, id_, url)
                    print(f"✅ Новый VLESS сохранён для {user_id}")
                else:
                    raise Exception("Не удалось получить URL после создания конфига")
            else:
                raise Exception("Не удалось создать конфиг пользователя")

            xray_client.close()
            break
        except Exception as e:
            print(f"❌ Ошибка для хоста {id_}: {e}")
            import traceback; traceback.print_exc()
            continue

    if not urls:
        raise Exception("Не удалось создать ни одного URL для пользователя")

    return urls

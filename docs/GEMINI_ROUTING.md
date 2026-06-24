# Поддержка Gemini (gemini.google.com) через VPN

**Требование:** весь трафик (включая Gemini) идёт через VPN-сервер **194.48.142.252**.

## Сделано

### 1. Client routing (v2rayTun)

В `main.py` правило **GeminiVPN** в начале списка:
- Домены: `gemini.google.com`, `generativelanguage.googleapis.com`, `ai.google.dev`, `google.com`, `googleapis.com`, `gstatic.com`, `googleusercontent.com`
- Направление: **proxy** — трафик идёт через 194.48.142.252 (не в обход VPN)

### 2. Server routing (XRay) на 194.48.142.252

В `config_server.json` правило для Gemini/Google:
- Домены: `gemini.google.com`, `generativelanguage.googleapis.com`, `ai.google.dev`, `google.com`, `googleapis.com`
- Направление: **direct** (если сервер в регионе, где Gemini доступен) или **исходящий прокси** (см. ниже)

### 3. Если Gemini пишет «не поддерживается в вашей стране»

Значит исходящий IP сервера 194.48.142.252 в регионе, где Gemini заблокирован. Нужно на **сервере** отправлять трафик к Google/Gemini через прокси в поддерживаемой стране (США/ЕС и т.д.):

1. В `config_server.json` на 194.48.142.252 добавить **outbound** с выходом в нужный регион (например VMess/VLESS на другой сервер или SOCKS5-прокси в США).
2. В **routing.rules** добавить правило **перед** остальными: для доменов Gemini/Google использовать `outboundTag` этого исходящего прокси (а не `direct`).
3. Перезапустить XRay и применить конфиг:
   ```bash
   ssh root@194.48.142.252 "cd /root/easy-xray && echo 'S' | ./ex.sh push"
   ```

Пример правила (в начале `rules`):

```json
{
  "domain": [
    "domain:gemini.google.com",
    "domain:generativelanguage.googleapis.com",
    "domain:ai.google.dev",
    "domain:google.com",
    "domain:googleapis.com"
  ],
  "outboundTag": "gemini-proxy"
}
```

Где `gemini-proxy` — тег вашего исходящего прокси (VMess/VLESS/SOCKS) с выходом в регион, где Gemini разрешён.

## Для пользователей

После обновления бота **заново получить роутинг**: «Подключиться» → скопировать ссылку роутинга и применить в приложении (v2rayTun и др.).

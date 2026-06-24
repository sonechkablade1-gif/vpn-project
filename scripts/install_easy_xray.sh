#!/usr/bin/env bash
# Автоматическая установка easy-xray (EvgenyNerush/easy-xray) на VPS
# Запуск на сервере: bash install_easy_xray.sh [SERVER_IP]
set -euo pipefail

SERVER_IP="${1:-$(curl -4 -s ifconfig.me 2>/dev/null || hostname -I | awk '{print $1}')}"
INSTALL_DIR="/root/easy-xray"

echo "=== easy-xray install ==="
echo "Server IP: ${SERVER_IP}"

export DEBIAN_FRONTEND=noninteractive
if command -v apt-get >/dev/null 2>&1; then
  apt-get update -qq
  apt-get install -y -qq curl jq openssl ca-certificates
elif command -v dnf >/dev/null 2>&1; then
  dnf install -y curl jq openssl ca-certificates
elif command -v yum >/dev/null 2>&1; then
  yum install -y epel-release 2>/dev/null || true
  yum install -y curl jq openssl ca-certificates unzip
fi

if [ -d "$INSTALL_DIR" ]; then
  echo "Directory ${INSTALL_DIR} already exists, updating..."
  cd "$INSTALL_DIR"
  git pull --ff-only 2>/dev/null || true
else
  curl -fsSL https://codeload.github.com/EvgenyNerush/easy-xray/tar.gz/main | tar -xz -C /root
  mv /root/easy-xray-main "$INSTALL_DIR"
  cd "$INSTALL_DIR"
fi

chmod +x ex.sh

# Install: no CDN, generate configs, duckduckgo.com, autogen grpc, no extra users, push config
printf '\n\n\n%s\n\n\n\nn\n' "$SERVER_IP" | ./ex.sh install

echo ""
echo "=== Status ==="
systemctl is-active xray
systemctl status xray --no-pager -l | head -15
ss -tlnp | grep -E ':443|:80' || true

echo ""
echo "=== Client link ==="
./ex.sh link conf/config_client.json 2>/dev/null || true

echo ""
echo "Done. easy-xray is in ${INSTALL_DIR}"

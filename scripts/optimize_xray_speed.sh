#!/bin/bash
# Оптимизация пропускной способности VPN (XRay) на сервере
# Запуск: bash scripts/optimize_xray_speed.sh (на сервере)

set -e

CONF=/etc/sysctl.d/99-xray.conf

echo "=== Оптимизация скорости XRay ==="

cat > "$CONF" << 'EOF'
# BBR congestion control (вместо cubic)
net.core.default_qdisc=fq
net.ipv4.tcp_congestion_control=bbr

# Буферы: до 64MB для быстрого канала
net.core.rmem_max=67108864
net.core.wmem_max=67108864
net.core.rmem_default=1048576
net.core.wmem_default=1048576
net.core.netdev_max_backlog=500000
net.core.somaxconn=65535
net.core.optmem_max=67108864

# TCP: Fast Open, MTU probing, крупные окна
net.ipv4.tcp_fastopen=3
net.ipv4.tcp_mtu_probing=1
net.ipv4.tcp_max_syn_backlog=65535
net.ipv4.tcp_rmem=4096 87380 67108864
net.ipv4.tcp_wmem=4096 65536 67108864
net.ipv4.tcp_tw_reuse=1
net.ipv4.tcp_slow_start_after_idle=0
net.ipv4.ip_local_port_range=10000 65000

# Больше дескрипторов для множества подключений
fs.file-max=2097152
vm.swappiness=10
EOF

sysctl -p "$CONF" 2>/dev/null || sysctl --system 2>/dev/null || true

# Лимит файлов для XRay (если через systemd)
mkdir -p /etc/systemd/system/xray.service.d 2>/dev/null || true
if ! grep -q "LimitNOFILE" /etc/systemd/system/xray.service 2>/dev/null; then
  echo "[Service]" > /etc/systemd/system/xray.service.d/limits.conf 2>/dev/null
  echo "LimitNOFILE=1048576" >> /etc/systemd/system/xray.service.d/limits.conf 2>/dev/null
  systemctl daemon-reload 2>/dev/null || true
fi

echo "Готово. Проверка:"
sysctl net.ipv4.tcp_congestion_control net.core.rmem_max net.ipv4.tcp_fastopen net.ipv4.tcp_slow_start_after_idle 2>/dev/null

# Оптимизация скорости VPN

## Применено на сервере (194.48.142.252)

| Параметр | Значение |
|----------|----------|
| **TCP congestion** | bbr |
| **net.core.rmem/wmem_max** | 64 MB |
| **net.core.somaxconn** | 65535 |
| **net.core.netdev_max_backlog** | 500000 |
| **tcp_fastopen** | 3 |
| **tcp_slow_start_after_idle** | 0 |
| **tcp_rmem / tcp_wmem** | до 64 MB |
| **fs.file-max** | 2M |
| **LimitNOFILE (XRay)** | 1M |

Скрипт: `scripts/optimize_xray_speed.sh`

## Если скорость всё ещё низкая

### 1. Ограничения хостинга
- Уточнить тариф и лимиты провайдера (пропускная способность канала)
- Проверить CPU (nproc) — 1 ядро может быть узким местом

### 2. Удалённость
- Задержка до сервера влияет на TCP throughput
- BBR лучше cubic при потере пакетов и высокой latency

### 3. XRay-конфиг
- Используется VLESS + Reality + xtls-rprx-vision — уже оптимальная связка
- Дополнительно можно рассмотреть multiplex (mux) для нескольких стримов — увеличивает latency, но иногда помогает

### 4. Клиент
- Включить TCP Fast Open в клиенте
- Проверить MTU: иногда снижение MTU помогает при потерях

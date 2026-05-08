#!/bin/bash

# 注册 Redis 为 systemd 服务（redis-server-{port}）
# 用法: ./setup_redis_systemd.sh <密码> <端口>

set -e

if [ -z "$1" ]; then
    echo "错误: 必须提供密码作为第一个参数"
    echo "用法: $0 <密码> <端口>"
    exit 1
fi
REDIS_PASSWORD="$1"

if [ -z "$2" ]; then
    echo "错误: 必须提供端口作为第二个参数"
    echo "用法: $0 <密码> <端口>"
    exit 1
fi
PORT="$2"

SERVICE_NAME="redis-server-${PORT}"
UNIT_FILE="/etc/systemd/system/${SERVICE_NAME}.service"
REDIS_CONF_DIR="/etc/redis"
REDIS_DATA_DIR="/var/lib/redis"
REDIS_LOG_DIR="/var/log/redis"
REDIS_BIN=$(which redis-server 2>/dev/null || echo "/usr/local/bin/redis-server")
CONFIG_FILE="${REDIS_CONF_DIR}/redis-${PORT}.conf"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

if [ ! -f "$REDIS_BIN" ]; then
    echo -e "${RED}错误: 未找到 redis-server，请先安装 Redis${NC}"
    exit 1
fi

if [ -f "$UNIT_FILE" ]; then
    echo -e "${YELLOW}服务 $SERVICE_NAME 已注册，跳过安装${NC}"
    echo "当前状态: $(systemctl is-active $SERVICE_NAME 2>/dev/null || echo inactive)"
    exit 0
fi

echo -e "${GREEN}=== 注册 Redis systemd 服务: $SERVICE_NAME ===${NC}"

echo "创建目录..."
sudo mkdir -p "$REDIS_CONF_DIR" "$REDIS_DATA_DIR/$PORT" "$REDIS_LOG_DIR"
sudo chmod 755 "$REDIS_DATA_DIR/$PORT"

echo "生成配置文件: $CONFIG_FILE"
sudo tee "$CONFIG_FILE" > /dev/null << EOF
# Redis 配置 - 端口 ${PORT}
port ${PORT}
bind 0.0.0.0
protected-mode no

# 由 systemd 管理进程，禁用守护进程模式
daemonize no
pidfile /var/run/redis_${PORT}.pid

logfile "${REDIS_LOG_DIR}/redis-${PORT}.log"
dir "${REDIS_DATA_DIR}/${PORT}"

# 密码认证
requirepass ${REDIS_PASSWORD}

# 不限制内存
maxmemory 0

# 关闭持久化
save ""
appendonly no

# 性能优化
tcp-backlog 511
timeout 0
tcp-keepalive 300
databases 16

# 客户端连接限制
maxclients 1000000

# 慢查询日志
slowlog-log-slower-than 10000
slowlog-max-len 128

loglevel notice
syslog-enabled no
EOF

echo "生成 systemd unit 文件: $UNIT_FILE"
sudo tee "$UNIT_FILE" > /dev/null << EOF
[Unit]
Description=Redis Server (port ${PORT})
After=network.target

[Service]
Type=simple
ExecStart=${REDIS_BIN} ${CONFIG_FILE}
ExecStop=/bin/sh -c 'REDISCLI_AUTH="${REDIS_PASSWORD}" redis-cli -p ${PORT} shutdown || true'
Restart=on-failure
RestartSec=5
LimitNOFILE=1048576

[Install]
WantedBy=multi-user.target
EOF

echo "重载 systemd..."
sudo systemctl daemon-reload

echo "设置开机自启并启动服务..."
sudo systemctl enable "$SERVICE_NAME"
sudo systemctl start "$SERVICE_NAME"

sleep 1
if systemctl is-active --quiet "$SERVICE_NAME"; then
    echo -e "${GREEN}✓ 服务 $SERVICE_NAME 启动成功${NC}"
    SERVER_IP=$(curl -s --max-time 3 ifconfig.me 2>/dev/null || ip route get 1 | awk '{print $7; exit}')
    echo ""
    echo "常用命令:"
    echo "  systemctl status  $SERVICE_NAME"
    echo "  systemctl stop    $SERVICE_NAME"
    echo "  systemctl restart $SERVICE_NAME"
    echo "  journalctl -u $SERVICE_NAME -f"
    echo ""
    echo "连接命令:"
    echo "  redis-cli -p $PORT -a '$REDIS_PASSWORD'"
    echo "  redis-cli -p $PORT -a '$REDIS_PASSWORD' -h $SERVER_IP"
else
    echo -e "${RED}✗ 服务启动失败，查看日志:${NC}"
    echo "  journalctl -u $SERVICE_NAME --no-pager -n 30"
    exit 1
fi

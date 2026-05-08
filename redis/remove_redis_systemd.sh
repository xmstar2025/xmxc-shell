#!/bin/bash

# 删除 Redis systemd 服务（redis-server-{port}）及所有相关文件
# 用法: ./remove_redis_systemd.sh <端口>

set -e

if [ -z "$1" ]; then
    echo "错误: 必须提供端口作为第一个参数"
    echo "用法: $0 <端口>"
    exit 1
fi
PORT="$1"

SERVICE_NAME="redis-server-${PORT}"

if [[ "$SERVICE_NAME" != *"redis"* ]] || [[ "$SERVICE_NAME" == "redis" ]]; then
    echo "错误: 服务名 '$SERVICE_NAME' 不合法，必须包含 redis 且不能是默认的 redis 服务"
    exit 1
fi

UNIT_FILE="/etc/systemd/system/${SERVICE_NAME}.service"
REDIS_CONF_DIR="/etc/redis"
REDIS_DATA_DIR="/var/lib/redis"
REDIS_LOG_DIR="/var/log/redis"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}=== 删除 Redis systemd 服务: $SERVICE_NAME ===${NC}"

if ! systemctl list-unit-files --quiet "$SERVICE_NAME.service" 2>/dev/null | grep -q "$SERVICE_NAME"; then
    echo -e "${YELLOW}服务 $SERVICE_NAME 不存在${NC}"
    # 仍然继续清理残留文件
fi

if systemctl is-active --quiet "$SERVICE_NAME" 2>/dev/null; then
    echo -n "停止服务... "
    sudo systemctl stop "$SERVICE_NAME"
    echo -e "${GREEN}✓${NC}"
fi

if systemctl is-enabled --quiet "$SERVICE_NAME" 2>/dev/null; then
    echo -n "禁用开机自启... "
    sudo systemctl disable "$SERVICE_NAME"
    echo -e "${GREEN}✓${NC}"
fi

if [ -f "$UNIT_FILE" ]; then
    echo -n "删除 unit 文件... "
    sudo rm -f "$UNIT_FILE"
    echo -e "${GREEN}✓${NC}"
fi

echo -n "重载 systemd... "
sudo systemctl daemon-reload
echo -e "${GREEN}✓${NC}"

if [ -d "$REDIS_DATA_DIR/$PORT" ]; then
    echo -n "删除数据目录 $REDIS_DATA_DIR/$PORT ... "
    sudo rm -rf "$REDIS_DATA_DIR/$PORT"
    echo -e "${GREEN}✓${NC}"
fi

if [ -f "$REDIS_LOG_DIR/redis-${PORT}.log" ]; then
    echo -n "删除日志文件... "
    sudo rm -f "$REDIS_LOG_DIR/redis-${PORT}.log"
    echo -e "${GREEN}✓${NC}"
fi

if [ -f "$REDIS_CONF_DIR/redis-${PORT}.conf" ]; then
    echo -n "删除配置文件... "
    sudo rm -f "$REDIS_CONF_DIR/redis-${PORT}.conf"
    echo -e "${GREEN}✓${NC}"
fi

sudo rm -f "/var/run/redis_${PORT}.pid"

echo ""
echo -e "${GREEN}✓ 服务 $SERVICE_NAME 已成功删除${NC}"

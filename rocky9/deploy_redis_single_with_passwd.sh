#!/bin/bash

# Redis一键启动脚本（单实例，外网访问，密码认证）
# 用法: ./deploy_redis_single_with_passwd.sh <密码> <端口> {start|stop|restart|status|clean}

if [ -z "$1" ] || [[ "$1" == start || "$1" == stop || "$1" == restart || "$1" == status || "$1" == clean ]]; then
    echo "错误: 必须提供密码作为第一个参数"
    echo "用法: $0 <密码> <端口> {start|stop|restart|status|clean}"
    exit 1
fi
REDIS_PASSWORD="$1"
shift

if [ -z "$1" ] || [[ "$1" == start || "$1" == stop || "$1" == restart || "$1" == status || "$1" == clean ]]; then
    echo "错误: 必须提供端口作为第二个参数"
    echo "用法: $0 <密码> <端口> {start|stop|restart|status|clean}"
    exit 1
fi
PORT="$1"
shift

REDIS_CONF_DIR="/etc/redis"
REDIS_DATA_DIR="/var/lib/redis"
REDIS_LOG_DIR="/var/log/redis"
REDIS_BIN=$(which redis-server 2>/dev/null || echo "/usr/local/bin/redis-server")

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

check_redis() {
    if [ ! -f "$REDIS_BIN" ]; then
        echo -e "${RED}错误: 未找到redis-server，请先安装Redis${NC}"
        exit 1
    fi
}

create_dirs() {
    sudo mkdir -p $REDIS_CONF_DIR
    sudo mkdir -p $REDIS_DATA_DIR
    sudo mkdir -p $REDIS_LOG_DIR
}

generate_config() {
    local port=$1
    local config_file="$REDIS_CONF_DIR/redis-$port.conf"

    sudo tee $config_file > /dev/null << EOF
# Redis配置文件 - 端口 $port
port $port
bind 0.0.0.0
protected-mode no
daemonize yes
pidfile /var/run/redis_$port.pid
logfile "$REDIS_LOG_DIR/redis-$port.log"
dir "$REDIS_DATA_DIR/$port"

# 密码认证
requirepass $REDIS_PASSWORD

# 内存管理
maxmemory-policy noeviction

# 关闭持久化
save ""
appendonly no

# 性能优化
tcp-backlog 511
timeout 0
tcp-keepalive 300
databases 16

# 客户端连接限制
maxclients 10000

# 慢查询日志
slowlog-log-slower-than 10000
slowlog-max-len 128

# 安全设置（禁用危险命令）
rename-command FLUSHALL ""
rename-command FLUSHDB ""
rename-command CONFIG ""

# 其他设置
loglevel notice
syslog-enabled no
EOF

    echo $config_file
}

start_instance() {
    echo -e "${GREEN}=== 启动Redis实例 ===${NC}"
    echo -e "${YELLOW}端口: $PORT  密码: $REDIS_PASSWORD${NC}\n"

    check_redis
    create_dirs
    sudo mkdir -p "$REDIS_DATA_DIR/$PORT"
    sudo chmod 755 "$REDIS_DATA_DIR/$PORT"

    if pgrep -f "redis-server.*$PORT" > /dev/null; then
        echo -e "端口 $PORT: ${YELLOW}已运行${NC}"
        exit 0
    fi

    config_file=$(generate_config $PORT)

    echo -n "启动端口 $PORT: "
    sudo $REDIS_BIN $config_file > /dev/null 2>&1

    sleep 0.5
    if pgrep -f "redis-server.*$PORT" > /dev/null; then
        echo -e "${GREEN}✓ 成功${NC}"
        echo "连接命令: redis-cli -p $PORT -a '$REDIS_PASSWORD' -h <服务器IP>"
    else
        echo -e "${RED}✗ 失败${NC}"
        echo "请检查日志: $REDIS_LOG_DIR/redis-$PORT.log"
        exit 1
    fi
}

stop_instance() {
    echo -e "${GREEN}=== 停止Redis实例 (端口 $PORT) ===${NC}"
    echo -n "停止端口 $PORT: "

    redis-cli -p $PORT -a "$REDIS_PASSWORD" shutdown > /dev/null 2>&1

    if [ -f "/var/run/redis_$PORT.pid" ]; then
        pid=$(cat "/var/run/redis_$PORT.pid")
        if kill -0 $pid 2>/dev/null; then
            kill $pid > /dev/null 2>&1
        fi
        rm -f "/var/run/redis_$PORT.pid"
    fi

    sleep 0.5
    if pgrep -f "redis-server.*$PORT" > /dev/null; then
        pkill -f "redis-server.*$PORT" > /dev/null 2>&1
    fi

    sleep 0.5
    if pgrep -f "redis-server.*$PORT" > /dev/null; then
        echo -e "${RED}✗ 失败${NC}"
    else
        echo -e "${GREEN}✓ 成功${NC}"
    fi
}

status_instance() {
    echo -e "${GREEN}=== Redis实例状态 (端口 $PORT) ===${NC}"

    if pgrep -f "redis-server.*$PORT" > /dev/null; then
        pid=$(pgrep -f "redis-server.*$PORT" | head -1)
        mem=$(ps -o rss= -p $pid 2>/dev/null | awk '{print $1/1024 " MB"}')
        echo -e "端口 $PORT: ${GREEN}运行中${NC} (PID: $pid, 内存: $mem)"

        if redis-cli -p $PORT -a "$REDIS_PASSWORD" ping 2>/dev/null | grep -q "PONG"; then
            echo -e "连接测试: ${GREEN}成功${NC}"
        else
            echo -e "连接测试: ${RED}失败${NC}"
        fi
    else
        echo -e "端口 $PORT: ${RED}未运行${NC}"
    fi
}

clean_instance() {
    echo -e "${YELLOW}警告: 这将删除端口 $PORT 的所有数据和日志文件！${NC}"
    read -p "确认继续? (y/n): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        stop_instance
        echo "清理数据文件..."
        sudo rm -rf "$REDIS_DATA_DIR/$PORT"/*
        sudo rm -f "$REDIS_LOG_DIR/redis-$PORT.log"
        echo -e "${GREEN}清理完成${NC}"
    else
        echo "取消清理"
    fi
}

case "$1" in
    start)
        start_instance
        ;;
    stop)
        stop_instance
        ;;
    restart)
        stop_instance
        sleep 2
        start_instance
        ;;
    status)
        status_instance
        ;;
    clean)
        clean_instance
        ;;
    *)
        echo "用法: $0 <密码> <端口> {start|stop|restart|status|clean}"
        echo ""
        echo "  start   - 启动指定端口的Redis实例"
        echo "  stop    - 停止指定端口的Redis实例"
        echo "  restart - 重启指定端口的Redis实例"
        echo "  status  - 查看指定端口的Redis实例状态"
        echo "  clean   - 清理指定端口的数据和日志"
        exit 1
        ;;
esac

exit 0

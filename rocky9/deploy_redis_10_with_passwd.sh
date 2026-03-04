#!/bin/bash

# Redis一键启动脚本（10实例，外网访问，密码认证）
# 用法: ./deploy_redis_10_with_passwd.sh <密码> {start|stop|restart|status|clean}

# 配置参数
if [ -z "$1" ] || [[ "$1" == start || "$1" == stop || "$1" == restart || "$1" == status || "$1" == clean ]]; then
    echo "错误: 必须提供密码作为第一个参数"
    echo "用法: $0 <密码> {start|stop|restart|status|clean}"
    exit 1
fi
REDIS_PASSWORD="$1"
shift
PORTS=($(seq 39900 39909))
REDIS_CONF_DIR="/etc/redis"
REDIS_DATA_DIR="/var/lib/redis"
REDIS_LOG_DIR="/var/log/redis"
REDIS_BIN=$(which redis-server 2>/dev/null || echo "/usr/local/bin/redis-server")

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# 检查Redis是否安装
check_redis() {
    if [ ! -f "$REDIS_BIN" ]; then
        echo -e "${RED}错误: 未找到redis-server，请先安装Redis${NC}"
        exit 1
    fi
}

# 创建必要的目录
create_dirs() {
    sudo mkdir -p $REDIS_CONF_DIR
    sudo mkdir -p $REDIS_DATA_DIR
    sudo mkdir -p $REDIS_LOG_DIR
}

# 生成Redis配置文件
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

# 启动所有Redis实例
start_all() {
    echo -e "${GREEN}=== 启动所有Redis实例 ===${NC}"
    echo -e "${YELLOW}使用密码: $REDIS_PASSWORD${NC}\n"

    check_redis
    create_dirs

    for port in "${PORTS[@]}"; do
        # 创建数据目录
        sudo mkdir -p "$REDIS_DATA_DIR/$port"
        sudo chmod 755 "$REDIS_DATA_DIR/$port"

        # 检查是否已运行
        if pgrep -f "redis-server.*$port" > /dev/null; then
            echo -e "端口 $port: ${YELLOW}已运行${NC}"
            continue
        fi

        # 生成配置文件
        config_file=$(generate_config $port)

        # 启动Redis
        echo -n "启动端口 $port: "
        sudo $REDIS_BIN $config_file > /dev/null 2>&1

        # 检查是否启动成功
        sleep 0.5
        if pgrep -f "redis-server.*$port" > /dev/null; then
            echo -e "${GREEN}✓ 成功${NC}"
        else
            echo -e "${RED}✗ 失败${NC}"
            echo "请检查日志: $REDIS_LOG_DIR/redis-$port.log"
        fi
    done

    echo -e "\n${GREEN}=== 启动完成 ===${NC}"
    echo "使用以下命令连接任意实例："
    echo -e "${YELLOW}redis-cli -p [PORT] -a '$REDIS_PASSWORD' -h <服务器IP>${NC}"
}

# 停止所有Redis实例
stop_all() {
    echo -e "${GREEN}=== 停止所有Redis实例 ===${NC}"

    for port in "${PORTS[@]}"; do
        echo -n "停止端口 $port: "

        # 方法1: 使用redis-cli优雅停止
        redis-cli -p $port -a "$REDIS_PASSWORD" shutdown > /dev/null 2>&1

        # 方法2: 如果上面的方法失败，尝试用PID文件停止
        if [ -f "/var/run/redis_$port.pid" ]; then
            pid=$(cat "/var/run/redis_$port.pid")
            if kill -0 $pid 2>/dev/null; then
                kill $pid > /dev/null 2>&1
            fi
            rm -f "/var/run/redis_$port.pid"
        fi

        # 方法3: 强制kill进程
        sleep 0.5
        if pgrep -f "redis-server.*$port" > /dev/null; then
            pkill -f "redis-server.*$port" > /dev/null 2>&1
        fi

        # 检查是否停止成功
        sleep 0.5
        if pgrep -f "redis-server.*$port" > /dev/null; then
            echo -e "${RED}✗ 失败${NC}"
        else
            echo -e "${GREEN}✓ 成功${NC}"
        fi
    done

    echo -e "${GREEN}=== 停止完成 ===${NC}"
}

# 查看所有Redis实例状态
status_all() {
    echo -e "${GREEN}=== Redis实例状态 ===${NC}"
    echo "密码: $REDIS_PASSWORD"
    echo ""

    running_count=0
    for port in "${PORTS[@]}"; do
        if pgrep -f "redis-server.*$port" > /dev/null; then
            pid=$(pgrep -f "redis-server.*$port" | head -1)
            mem=$(ps -o rss= -p $pid 2>/dev/null | awk '{print $1/1024 " MB"}')
            echo -e "端口 $port: ${GREEN}运行中${NC} (PID: $pid, 内存: $mem)"

            if redis-cli -p $port -a "$REDIS_PASSWORD" ping 2>/dev/null | grep -q "PONG"; then
                echo "          连接测试: ${GREEN}成功${NC}"
            else
                echo "          连接测试: ${RED}失败${NC}"
            fi
            ((running_count++))
        else
            echo -e "端口 $port: ${RED}未运行${NC}"
        fi
    done

    echo ""
    echo "运行实例: $running_count / ${#PORTS[@]}"
}

# 清理所有Redis数据和日志
clean_all() {
    echo -e "${YELLOW}警告: 这将删除所有Redis数据和日志文件！${NC}"
    read -p "确认继续? (y/n): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        stop_all

        echo "清理数据文件..."
        for port in "${PORTS[@]}"; do
            sudo rm -rf "$REDIS_DATA_DIR/$port"/*
            sudo rm -f "$REDIS_LOG_DIR/redis-$port.log"
        done

        echo -e "${GREEN}清理完成${NC}"
    else
        echo "取消清理"
    fi
}

# 主函数
case "$1" in
    start)
        start_all
        ;;
    stop)
        stop_all
        ;;
    restart)
        stop_all
        sleep 2
        start_all
        ;;
    status)
        status_all
        ;;
    clean)
        clean_all
        ;;
    *)
        echo "用法: $0 {start|stop|restart|status|clean}"
        echo ""
        echo "  start   - 启动所有Redis实例（端口 39900-39909）"
        echo "  stop    - 停止所有Redis实例"
        echo "  restart - 重启所有Redis实例"
        echo "  status  - 查看所有Redis实例状态"
        echo "  clean   - 清理所有Redis数据和日志"
        exit 1
        ;;
esac

exit 0

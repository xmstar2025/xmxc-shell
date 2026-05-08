#!/bin/bash
# Rocky Linux 9 安装 Redis 8.6（via Remi 仓库）

set -e

if [ "$(id -u)" -ne 0 ]; then
    echo "请用 root 或 sudo 执行此脚本"
    exit 1
fi

echo "==> 安装 Remi 仓库..."
dnf install -y https://rpms.remirepo.net/enterprise/remi-release-9.rpm

echo "==> 启用 Redis 8.6 模块流..."
dnf module switch-to -y redis:remi-8.6

echo "==> 安装 Redis..."
dnf install -y redis

echo "==> 设置开机自启..."
systemctl enable redis

echo "==> 启动 Redis..."
systemctl start redis

systemctl status redis --no-pager

echo ""
echo "✓ Redis 8.6 安装完成"
echo "  配置文件: /etc/redis/redis.conf"
echo "  日志文件: /var/log/redis/redis.log"

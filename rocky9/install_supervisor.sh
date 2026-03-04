#!/bin/bash
# Rocky Linux 9 安装 supervisor

set -e

if [ "$(id -u)" -ne 0 ]; then
    echo "请用 root 或 sudo 执行此脚本"
    exit 1
fi

echo "==> 安装 supervisor..."
dnf install -y supervisor

echo "==> 设置开机自启..."
systemctl enable supervisord

echo "==> 启动 supervisord..."
systemctl start supervisord

systemctl status supervisord --no-pager

echo ""
echo "✓ supervisor 安装完成"
echo "  配置目录: /etc/supervisord.d/"
echo "  主配置:   /etc/supervisord.conf"
echo "  日志目录: /var/log/supervisor/"

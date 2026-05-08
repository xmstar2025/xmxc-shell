#!/bin/bash
# Rocky Linux 9 安装并启动 chrony 时间同步

set -e

if [ "$(id -u)" -ne 0 ]; then
    echo "请用 root 或 sudo 执行此脚本"
    exit 1
fi

echo "==> 安装 chrony..."
dnf install -y chrony

echo "==> 启动并设置开机自启..."
systemctl enable --now chronyd

sleep 2

echo "==> 立即强制同步时间..."
chronyc -a makestep

echo ""
chronyc tracking
echo ""
echo "✓ 时间同步配置完成"

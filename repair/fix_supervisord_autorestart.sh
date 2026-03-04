#!/bin/bash
# 修复 supervisord 崩溃后不自动重启的问题

set -e

if [ "$(id -u)" -ne 0 ]; then
    echo "请用 root 或 sudo 执行此脚本"
    exit 1
fi

echo "==> 配置 supervisord 崩溃自动重启..."
mkdir -p /etc/systemd/system/supervisord.service.d
cat > /etc/systemd/system/supervisord.service.d/restart.conf <<'EOF'
[Service]
Restart=always
RestartSec=5s
EOF

echo "==> 重载 systemd 配置..."
systemctl daemon-reload

echo "==> 重启 supervisord..."
systemctl restart supervisord

echo "==> 验证配置..."
systemctl show supervisord | grep "^Restart="

echo ""
echo "✓ 修复完成，supervisord 崩溃后将自动重启"

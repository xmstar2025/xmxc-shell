#!/bin/bash
# Rocky Linux 9 安装 supervisor

set -e

if [ "$(id -u)" -ne 0 ]; then
    echo "请用 root 或 sudo 执行此脚本"
    exit 1
fi

echo "==> 安装 supervisor..."
dnf install -y supervisor

echo "==> 调整 minfds 为 1000000..."
if grep -q '^minfds=' /etc/supervisord.conf; then
    sed -i 's/^minfds=.*/minfds=1000000/' /etc/supervisord.conf
else
    sed -i '/^\[supervisord\]/a minfds=1000000' /etc/supervisord.conf
fi

echo "==> 配置 supervisord 崩溃自动重启..."
mkdir -p /etc/systemd/system/supervisord.service.d
cat > /etc/systemd/system/supervisord.service.d/restart.conf <<'EOF'
[Service]
Restart=always
RestartSec=5s
EOF
systemctl daemon-reload

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

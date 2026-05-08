#!/bin/bash
# 修复同网段互通问题：将直连路由改为经默认网关转发并持久化

set -euo pipefail

if [ "$(id -u)" -ne 0 ]; then
    echo "请用 root 或 sudo 执行此脚本"
    exit 1
fi

# 自动识别默认出口网卡与网关
IFACE="$(ip -4 route show default | awk 'NR==1{print $5}')"
GW="$(ip -4 route show default | awk 'NR==1{print $3}')"

if [ -z "${IFACE:-}" ] || [ -z "${GW:-}" ]; then
    echo "[ERROR] 无法识别默认网卡或网关"
    ip -4 route || true
    exit 1
fi

echo "==> 网卡: $IFACE  网关: $GW"

# 下发修复脚本
install -d -m 0755 /usr/local/sbin
cat > /usr/local/sbin/fix-local-subnet-route.sh <<'EOS'
#!/usr/bin/env bash
set -euo pipefail

IFACE="$(ip -4 route show default | awk 'NR==1{print $5}')"
GW="$(ip -4 route show default | awk 'NR==1{print $3}')"

[ -n "${IFACE:-}" ] && [ -n "${GW:-}" ] || exit 0

ip -4 route show dev "$IFACE" scope link | awk '{print $1}' | while read -r SUBNET; do
    [ -n "${SUBNET:-}" ] || continue
    case "$SUBNET" in
        */*)
            ip -4 route replace "$SUBNET" via "$GW" dev "$IFACE" || true
            ;;
    esac
done
EOS
chmod 0755 /usr/local/sbin/fix-local-subnet-route.sh

# 创建 systemd 服务（开机持久化）
cat > /etc/systemd/system/fix-local-subnet-route.service <<'EOF'
[Unit]
Description=Fix local subnet route via default gateway
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
ExecStart=/usr/local/sbin/fix-local-subnet-route.sh
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable fix-local-subnet-route.service

echo "==> 立即执行路由修复..."
/usr/local/sbin/fix-local-subnet-route.sh

systemctl restart fix-local-subnet-route.service || true

echo ""
echo "✓ 路由修复完成，已设置开机自动执行"

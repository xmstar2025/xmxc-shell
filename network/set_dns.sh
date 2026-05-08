#!/bin/bash

# Rocky Linux 9 DNS 配置脚本

set -e

DNS_SERVERS=("8.8.8.8" "8.8.4.4" "1.1.1.1" "1.0.0.1")
DNS_STR=$(IFS=' '; echo "${DNS_SERVERS[*]}")
DNS_RESOLV=$(printf 'nameserver %s\n' "${DNS_SERVERS[@]}")

echo "=== Rocky Linux 9 DNS 配置脚本 ==="

# 备份 resolv.conf（软链接也能备份内容）
BACKUP="/etc/resolv.conf.bak.$(date +%Y%m%d_%H%M%S)"
sudo cp /etc/resolv.conf "$BACKUP"
echo "[✓] 已备份 resolv.conf -> $BACKUP"

# 若 resolv.conf 是软链接，先删掉再创建真实文件
if [ -L /etc/resolv.conf ]; then
    echo "[*] 检测到 /etc/resolv.conf 是软链接，替换为真实文件..."
    sudo rm -f /etc/resolv.conf
fi

# 直接写入 resolv.conf
echo "$DNS_RESOLV" | sudo tee /etc/resolv.conf > /dev/null
echo "[✓] 已写入 /etc/resolv.conf"

# 用 nmcli 持久化配置，防止重启后被覆盖
if systemctl is-active --quiet NetworkManager; then
    CONNECTIONS=$(nmcli -t -f NAME,STATE con show --active | grep ':activated' | cut -d: -f1)
    if [ -n "$CONNECTIONS" ]; then
        while IFS= read -r CON; do
            sudo nmcli con mod "$CON" ipv4.dns "$DNS_STR"
            sudo nmcli con mod "$CON" ipv4.ignore-auto-dns yes
        done <<< "$CONNECTIONS"
        echo "[✓] nmcli 持久化配置完成（重启不丢失）"
    fi

    # 让 NetworkManager 不再动 resolv.conf
    if ! grep -q "dns=none" /etc/NetworkManager/NetworkManager.conf 2>/dev/null; then
        sudo sed -i '/^\[main\]/a dns=none' /etc/NetworkManager/NetworkManager.conf
        sudo systemctl reload NetworkManager
        echo "[✓] 已设置 NetworkManager dns=none，resolv.conf 不再被覆盖"
    fi
fi

echo ""
echo "=== 当前 /etc/resolv.conf ==="
cat /etc/resolv.conf

echo ""
echo "=== 连通性测试 ==="
for dns in "${DNS_SERVERS[@]}"; do
    if ping -c 1 -W 2 "$dns" > /dev/null 2>&1; then
        echo "  [✓] $dns 可达"
    else
        echo "  [✗] $dns 不可达"
    fi
done

echo ""
echo "完成！"

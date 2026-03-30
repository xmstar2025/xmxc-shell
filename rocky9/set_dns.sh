#!/bin/bash

# Rocky Linux 9 DNS 配置脚本
# 优先使用 NetworkManager (nmcli) 持久化配置，resolv.conf 仅作补充

set -e

DNS_SERVERS=("8.8.8.8" "8.8.4.4" "1.1.1.1" "1.0.0.1")
DNS_STR=$(IFS=' '; echo "${DNS_SERVERS[*]}")
DNS_RESOLV=$(printf 'nameserver %s\n' "${DNS_SERVERS[@]}")

echo "=== Rocky Linux 9 DNS 配置脚本 ==="

# 备份 resolv.conf
BACKUP="/etc/resolv.conf.bak.$(date +%Y%m%d_%H%M%S)"
sudo cp /etc/resolv.conf "$BACKUP"
echo "[✓] 已备份 resolv.conf -> $BACKUP"

# 检查 NetworkManager 是否运行
if systemctl is-active --quiet NetworkManager; then
    echo "[*] 检测到 NetworkManager，使用 nmcli 持久化配置..."

    # 获取所有已连接的网络接口
    CONNECTIONS=$(nmcli -t -f NAME,STATE con show --active | grep ':activated' | cut -d: -f1)

    if [ -z "$CONNECTIONS" ]; then
        echo "[!] 未找到活动网络连接，跳过 nmcli 配置"
    else
        while IFS= read -r CON; do
            echo "    -> 配置连接: $CON"
            sudo nmcli con mod "$CON" ipv4.dns "$DNS_STR"
            sudo nmcli con mod "$CON" ipv4.ignore-auto-dns yes
        done <<< "$CONNECTIONS"

        # 重新激活所有连接使配置生效
        while IFS= read -r CON; do
            sudo nmcli con up "$CON" > /dev/null 2>&1 && \
                echo "    -> 已重新激活: $CON" || \
                echo "    [!] 重新激活失败: $CON（可能需要手动重连）"
        done <<< "$CONNECTIONS"

        echo "[✓] nmcli DNS 配置完成"
    fi

    # 让 NetworkManager 不覆盖 resolv.conf（可选加固）
    if ! grep -q "dns=none" /etc/NetworkManager/NetworkManager.conf 2>/dev/null; then
        echo ""
        echo "[提示] 若 resolv.conf 仍被覆盖，可在 /etc/NetworkManager/NetworkManager.conf"
        echo "       的 [main] 段添加 dns=none，然后运行 systemctl restart NetworkManager"
    fi
else
    echo "[*] NetworkManager 未运行，直接写入 /etc/resolv.conf..."

    # 直接写入 resolv.conf
    echo "$DNS_RESOLV" | sudo tee /etc/resolv.conf > /dev/null
    # 防止被覆盖（设置不可变属性）
    sudo chattr +i /etc/resolv.conf
    echo "[✓] 已写入 resolv.conf 并设置不可变属性（chattr +i）"
    echo "[提示] 如需再次修改，请先运行: sudo chattr -i /etc/resolv.conf"
fi

echo ""
echo "=== 当前 DNS 配置 ==="
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

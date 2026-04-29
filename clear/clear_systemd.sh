#!/bin/bash
# 清理单个 systemd 服务
# 用法：sudo bash clear/clear_systemd.sh <服务名>
# 示例：sudo bash clear/clear_systemd.sh hc-2026-03-10-html-0


set -e

if [ "$(id -u)" -ne 0 ]; then
    echo "请用 root 或 sudo 执行此脚本"
    exit 1
fi

if [ -z "$1" ]; then
    echo "用法：sudo bash clear/clear_systemd.sh <服务名>"
    exit 1
fi

SERVICE_NAME="$1"
SERVICE_FILE="/etc/systemd/system/${SERVICE_NAME}.service"

if systemctl is-active --quiet "${SERVICE_NAME}" 2>/dev/null; then
    systemctl stop "${SERVICE_NAME}"
    echo "==> 已停止: ${SERVICE_NAME}"
else
    echo "==> 未运行: ${SERVICE_NAME}"
fi

if systemctl is-enabled --quiet "${SERVICE_NAME}" 2>/dev/null; then
    systemctl disable "${SERVICE_NAME}"
    echo "==> 已禁用: ${SERVICE_NAME}"
fi

if [ -f "$SERVICE_FILE" ]; then
    rm "$SERVICE_FILE"
    echo "==> 已删除: $SERVICE_FILE"
else
    echo "==> 不存在: $SERVICE_FILE"
fi

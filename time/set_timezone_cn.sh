#!/bin/bash
# 设置时区为中国标准时间（CST UTC+8）

set -e

if [ "$(id -u)" -ne 0 ]; then
    echo "请用 root 或 sudo 执行此脚本"
    exit 1
fi

timedatectl set-timezone Asia/Shanghai

echo "✓ 时区已设置为 $(timedatectl | grep 'Time zone')"

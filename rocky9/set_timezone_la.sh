#!/bin/bash
# 设置时区为洛杉矶（美国太平洋时间）

set -e

if [ "$(id -u)" -ne 0 ]; then
    echo "请用 root 或 sudo 执行此脚本"
    exit 1
fi

timedatectl set-timezone America/Los_Angeles

echo "✓ 时区已设置为 $(timedatectl | grep 'Time zone')"

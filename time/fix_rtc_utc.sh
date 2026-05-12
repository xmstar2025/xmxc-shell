#!/bin/bash
# 将硬件时钟（RTC）设置为 UTC，避免双系统时间错乱

set -e

if [ "$(id -u)" -ne 0 ]; then
    echo "请用 root 或 sudo 执行此脚本"
    exit 1
fi

timedatectl set-local-rtc 0

echo "✓ 硬件时钟已设置为 UTC"

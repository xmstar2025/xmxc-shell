#!/bin/bash
# Rocky Linux 9 安装 FFmpeg（通过 RPM Fusion 仓库）

set -e

if [ "$(id -u)" -ne 0 ]; then
    echo "请用 root 或 sudo 执行此脚本"
    exit 1
fi

echo "==> 安装 RPM Fusion Free 仓库..."
dnf install -y https://mirrors.rpmfusion.org/free/el/rpmfusion-free-release-9.noarch.rpm

echo "==> 启用 CRB（CodeReady Builder）仓库..."
dnf config-manager --set-enabled crb

echo "==> 安装 FFmpeg..."
dnf install -y ffmpeg

echo ""
echo "✓ FFmpeg 安装完成"
ffmpeg -version

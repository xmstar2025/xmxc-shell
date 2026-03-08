#!/bin/bash
# Rocky Linux 9 基础系统环境配置

set -e

if [ "$(id -u)" -ne 0 ]; then
    echo "请用 root 或 sudo 执行此脚本"
    exit 1
fi

echo "==> 更新系统..."
dnf update -y

echo "==> 启用 EPEL 仓库..."
dnf install -y epel-release

echo "==> 安装开发工具组..."
dnf groupinstall -y "Development Tools"

echo "==> 安装监控工具..."
dnf install -y atop htop bmon

echo "==> 安装 uv..."
curl -LsSf https://astral.sh/uv/install.sh | sh
chcon -t bin_t /root/.local/bin/uv

echo "✓ 基础系统环境配置完成"

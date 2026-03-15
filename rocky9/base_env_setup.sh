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
dnf install -y atop htop bmon lsof python3-pip

echo "==> 安装 py-spy..."
pip3 install py-spy

echo "==> 安装 uv..."
curl -LsSf https://astral.sh/uv/install.sh | sh
#restorecon -v /root/.local/bin/uv 2>/dev/null || chcon -u system_u -r object_r -t bin_t /root/.local/bin/uv 2>/dev/null || true

echo "✓ 基础系统环境配置完成"

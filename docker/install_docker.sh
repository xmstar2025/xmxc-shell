#!/bin/bash
# Rocky Linux 9 安装 Docker 和 Docker Compose

set -e

if [ "$(id -u)" -ne 0 ]; then
    echo "请用 root 或 sudo 执行此脚本"
    exit 1
fi

echo "==> 移除冲突包..."
dnf remove -y docker docker-client docker-client-latest docker-common \
    docker-latest docker-latest-logrotate docker-logrotate docker-engine \
    podman runc 2>/dev/null || true

echo "==> 添加 Docker 官方仓库..."
dnf config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo

echo "==> 安装 Docker Engine 和 Docker Compose..."
dnf install -y docker-ce docker-ce-cli containerd.io \
    docker-buildx-plugin docker-compose-plugin

echo "==> 设置开机自启..."
systemctl enable docker

echo "==> 启动 Docker..."
systemctl start docker

systemctl status docker --no-pager

echo ""
echo "✓ Docker 安装完成"
docker --version
docker compose version

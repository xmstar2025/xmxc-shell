#!/bin/bash
# Rocky Linux 9 安装 Google Cloud CLI（含 gsutil）

set -e

if [ "$(id -u)" -ne 0 ]; then
    echo "请用 root 或 sudo 执行此脚本"
    exit 1
fi

echo "==> 添加 Google Cloud CLI 官方仓库..."
tee /etc/yum.repos.d/google-cloud-sdk.repo << EOM
[google-cloud-cli]
name=Google Cloud CLI
baseurl=https://packages.cloud.google.com/yum/repos/cloud-sdk-el9-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=0
gpgkey=https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOM

echo "==> 安装 Google Cloud CLI..."
dnf install -y google-cloud-cli

echo ""
echo "✓ Google Cloud CLI 安装完成"
gcloud --version

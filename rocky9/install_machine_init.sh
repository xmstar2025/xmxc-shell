#!/bin/bash
set -e

BASE_URL="https://raw.githubusercontent.com/xmstar2025/xmxc-shell/refs/heads/main/rocky9"

echo "=== [1/7] 基础环境初始化 ==="
curl -sL "$BASE_URL/base_env_setup.sh" | bash

echo "=== [2/7] 安装 Redis ==="
curl -sL "$BASE_URL/install_redis.sh" | bash

echo "=== [3/7] 设置中国时区 ==="
curl -sL "$BASE_URL/set_timezone_cn.sh" | bash

echo "=== [4/7] 设置文件描述符限制 ==="
curl -sL "$BASE_URL/set_nofile_limit.sh" | bash

echo "=== [5/7] 修复本地子网路由 ==="
curl -sL "$BASE_URL/fix_local_subnet_route.sh" | bash

echo "=== [6/7] 设置 DNS ==="
curl -sL "$BASE_URL/set_dns.sh" | bash

echo "=== [7/7] 安装 Git ==="
curl -s https://r2.xmxcmoe.com/install/install-git.sh | bash

echo ""
echo "=== 初始化完成 ==="

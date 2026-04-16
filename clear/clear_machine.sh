#!/bin/bash
# 清理机器进程：systemd 服务 + 代码目录 + Redis
# 用法：sudo bash clear/clear_machine.sh

set -e

if [ "$(id -u)" -ne 0 ]; then
    echo "请用 root 或 sudo 执行此脚本"
    exit 1
fi

DEPLOY_DIRS=(
    "/home/work/scrapy-html-crawler"
    "/home/work/scrapy-pdf-crawler"
    "/home/work/pdf-docling"
)
REDIS_CLI="redis-cli"
SCRIPT_DIR="$(dirname "$0")"

# ── 1. 清理 systemd 服务 ───────────────────────────────────────
echo "==> [1/3] 清理 systemd 服务..."

# 按需修改：填入要清理的完整服务名
SERVICES=(
    hc-2026-03-08-html-pilot-0
    hc-2026-03-08-html-pilot-1
    hc-2026-03-01-html-0
    hc-2026-03-01-html-1
    hc-2026-03-10-html-0
    hc-2026-03-10-html-1
    hc-2026-03-20-html-0
    hc-2026-03-20-html-1
    docling-worker
    docling-uploader
    docling-watchdog
    hc-2026-03-10-html-re-0
    hc-2026-03-10-html-re-1
    github-fetch-metadata
    github-fetch-repo
    github-metrics-pusher

#    pc-2026-03-16-pdf-0
#    pc-2026-03-16-pdf-1
)

for SVC in "${SERVICES[@]}"; do
    bash "$SCRIPT_DIR/clear_systemd.sh" "$SVC" || true
done

# 动态清理所有 xmxc- 开头的 systemd 服务
echo "==> 清理所有 xmxc-* 服务..."
while IFS= read -r SVC; do
    [ -z "$SVC" ] && continue
    bash "$SCRIPT_DIR/clear_systemd.sh" "$SVC" || true
done < <(systemctl list-units --all --no-legend --plain 'xmxc-*' 2>/dev/null \
    | awk '{print $1}' \
    | sed 's/\.service$//')

systemctl reset-failed || true

# ── 2. 删除临时文件 ────────────────────────────────────────────
echo "==> [2/4] 删除临时文件..."
rm -rf /tmp/cc_html*
echo "==> 已删除: /tmp/cc_html*"

# ── 3. 删除代码目录 ────────────────────────────────────────────
echo "==> [3/4] 删除代码目录..."
for DEPLOY_DIR in "${DEPLOY_DIRS[@]}"; do
    if [ -d "$DEPLOY_DIR" ]; then
        rm -rf "$DEPLOY_DIR"
        echo "==> 已删除: $DEPLOY_DIR"
    else
        echo "==> 不存在: $DEPLOY_DIR"
    fi
done

# ── 3. 清理 Redis ──────────────────────────────────────────────
echo "==> [4/4] 清理 Redis..."
$REDIS_CLI flushdb
echo "==> Redis flushdb 完成"

echo ""
echo "✓ 机器清理完成"

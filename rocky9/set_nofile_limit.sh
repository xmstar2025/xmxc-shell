#!/usr/bin/env bash
# 调大系统文件描述符限制（nofile）至 1000000

set -e

if [ "$(id -u)" -ne 0 ]; then
    echo "请用 root 或 sudo 执行此脚本"
    exit 1
fi

# 1. 在 limits.d 里写一个独立文件，避免和原 limits.conf 冲突
cat > /etc/security/limits.d/99-nofile.conf <<EOF
* soft nofile 1000000
* hard nofile 1000000
root soft nofile 1000000
root hard nofile 1000000
EOF

# 2. 确保 pam_limits 在 system-auth 和 password-auth 里启用
for f in /etc/pam.d/system-auth /etc/pam.d/password-auth; do
    if ! grep -q pam_limits.so "$f"; then
        echo "session required pam_limits.so" >> "$f"
    fi
done

# 3. systemd 全局默认（给所有 service 用）
mkdir -p /etc/systemd/system.conf.d
cat > /etc/systemd/system.conf.d/99-nofile.conf <<EOF
[Manager]
DefaultLimitNOFILE=1000000
EOF

# 4. 让 systemd 重新加载配置（无需重启系统）
systemctl daemon-reexec

echo ""
echo "✓ 文件描述符限制已设置为 1000000"
echo "  请退出当前 SSH 重新登录后执行：ulimit -n && ulimit -Hn"

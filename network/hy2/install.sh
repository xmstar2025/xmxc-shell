#!/usr/bin/env bash
# Run this file from its GitHub checkout; never copy it between servers.
set -euo pipefail
umask 077
[[ $EUID -eq 0 ]] || { echo 'Run as root' >&2; exit 1; }
address=${1:?Usage: install.sh PUBLIC_IPV4 [PORT] [ACME_EMAIL]}
port=${2:-29885}
email=${3:-mexcmoe@gmail.com}
[[ "$address" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]] || exit 2
[[ "$port" =~ ^[0-9]+$ ]] && ((port >= 1 && port <= 65535)) || exit 2
[[ $(uname -m) == x86_64 ]] || { echo 'This pinned build requires x86_64' >&2; exit 2; }
source_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
[[ "$source_dir" == /home/work/* ]] || { echo 'Clone the repository under /home/work/' >&2; exit 2; }
uv_bin=$(command -v uv || true)
[[ -n "$uv_bin" ]] || { echo 'Install uv before running this script' >&2; exit 2; }
state=/etc/xmxc-hy2
runtime=/home/work/xmxc-hy2
version=1.13.11
sha256=10ff037632165ca4f6472a0ec21393280ef5a33677e05bcde7fbcf6f9737637b
mkdir -p "$state/letsencrypt" "$runtime/bin" "$runtime/certbot-work" "$runtime/certbot-logs"
chmod 700 "$state" "$state/letsencrypt" "$runtime"
"$uv_bin" sync --project "$source_dir" --frozen --python 3.12 --no-dev
certbot_bin="$source_dir/.venv/bin/certbot"
binary="$runtime/bin/sing-box"
if [[ ! -f "$runtime/bin/sing-box-$version.verified" ]]; then
    archive="$runtime/sing-box-$version.tar.gz"
    curl -fL --retry 3 --connect-timeout 15 --max-time 180 \
        "https://github.com/SagerNet/sing-box/releases/download/v$version/sing-box-$version-linux-amd64.tar.gz" -o "$archive"
    printf '%s  %s\n' "$sha256" "$archive" | sha256sum --check -
    tar -xzf "$archive" -C "$runtime"
    install -m 755 "$runtime/sing-box-$version-linux-amd64/sing-box" "$binary.new"
    mv "$binary.new" "$binary"
    touch "$runtime/bin/sing-box-$version.verified"
fi
# Standalone HTTP-01 binds TCP/80 only during issuance and renewal.
# HY2 continues running on UDP throughout this operation.
"$certbot_bin" certonly --non-interactive --agree-tos --email "$email" \
    --standalone --preferred-challenges http --required-profile shortlived \
    --ip-address "$address" --cert-name "$address" --key-type ecdsa \
    --config-dir "$state/letsencrypt" --work-dir "$runtime/certbot-work" \
    --logs-dir "$runtime/certbot-logs" --keep-until-expiring
"$source_dir/.venv/bin/python" "$source_dir/configure.py" "$address" --port "$port"
"$binary" check -c "$state/config.json"
cat > /etc/systemd/system/xmxc-hy2.service <<EOF
[Unit]
Description=XM​XC HY2 sing-box server
Wants=network-online.target
After=network-online.target
[Service]
Type=simple
WorkingDirectory=$runtime
ExecStart=$binary run -c $state/config.json
Restart=on-failure
RestartSec=5
LimitNOFILE=1048576
UMask=0077
NoNewPrivileges=true
PrivateTmp=true
ProtectSystem=strict
ProtectHome=true
ReadOnlyPaths=$state $runtime
CapabilityBoundingSet=CAP_NET_BIND_SERVICE
[Install]
WantedBy=multi-user.target
EOF
cat > /etc/systemd/system/xmxc-hy2-cert-renew.service <<EOF
[Unit]
Description=Renew XM​XC HY2 short-lived IP certificate
Wants=network-online.target
After=network-online.target
[Service]
Type=oneshot
WorkingDirectory=$runtime
ExecStart=$certbot_bin renew --non-interactive --cert-name $address --config-dir $state/letsencrypt --work-dir $runtime/certbot-work --logs-dir $runtime/certbot-logs --deploy-hook "/usr/bin/systemctl try-restart xmxc-hy2.service"
UMask=0077
TimeoutStartSec=300
EOF
cat > /etc/systemd/system/xmxc-hy2-cert-renew.timer <<'EOF'
[Unit]
Description=Check XM​XC HY2 IP certificate every six hours
[Timer]
OnCalendar=*-*-* 00,06,12,18:00:00
RandomizedDelaySec=300
Persistent=true
[Install]
WantedBy=timers.target
EOF
if command -v firewall-cmd >/dev/null && firewall-cmd --state >/dev/null 2>&1; then
    firewall-cmd --permanent --add-port="$port/udp"
    firewall-cmd --permanent --add-port=80/tcp
    firewall-cmd --add-port="$port/udp"
    firewall-cmd --add-port=80/tcp
fi
systemctl daemon-reload
systemctl enable xmxc-hy2.service
systemctl restart xmxc-hy2.service
systemctl enable --now xmxc-hy2-cert-renew.timer
systemctl is-active xmxc-hy2.service xmxc-hy2-cert-renew.timer
openssl x509 -in "$state/letsencrypt/live/$address/cert.pem" -noout -subject -issuer -dates -ext subjectAltName
printf 'HY2 ready: %s:%s/udp; client URI: %s/client-uri.txt\n' "$address" "$port" "$state"

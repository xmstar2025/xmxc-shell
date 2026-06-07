#!/usr/bin/env bash
set -euo pipefail

BASE="https://raw.githubusercontent.com/xmstar2025/xmxc-shell/refs/heads/main"

run() {
  local url="$BASE/$1"
  echo ">>> $1"
  if [[ "${2:-}" == "optional" ]]; then
    curl -sSL "$url" | bash || true
  else
    curl -sL "$url" | bash
  fi
}

run system/base_env_setup.sh      optional
run network/fix_local_subnet_route.sh optional
run network/set_dns.sh
run system/set_nofile_limit.sh    optional
run time/set_timezone_cn.sh
run time/install_chrony.sh
run time/fix_rtc_utc.sh
run redis/install_redis.sh

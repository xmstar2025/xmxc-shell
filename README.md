# xmxc-shell

常用服务器运维脚本集合，适用于 Rocky Linux 9。

## 装机脚本

```bash
curl -sSL https://raw.githubusercontent.com/xmstar2025/xmxc-shell/refs/heads/main/system/base_env_setup.sh | bash || true
curl -sSL https://raw.githubusercontent.com/xmstar2025/xmxc-shell/refs/heads/main/network/fix_local_subnet_route.sh | bash || true
curl -sL https://raw.githubusercontent.com/xmstar2025/xmxc-shell/refs/heads/main/network/set_dns.sh | bash
curl -sSL https://raw.githubusercontent.com/xmstar2025/xmxc-shell/refs/heads/main/system/set_nofile_limit.sh | bash || true
curl -sL https://raw.githubusercontent.com/xmstar2025/xmxc-shell/refs/heads/main/time/set_timezone_cn.sh | bash
curl -sL https://raw.githubusercontent.com/xmstar2025/xmxc-shell/refs/heads/main/time/install_chrony.sh | bash
curl -sL https://raw.githubusercontent.com/xmstar2025/xmxc-shell/refs/heads/main/redis/install_redis.sh | bash
```

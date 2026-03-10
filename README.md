# xmxc-shell

常用服务器运维脚本集合，适用于 Rocky Linux 9。

## rocky9 脚本

| 脚本 | 说明 | 一键安装命令 |
|------|------|------|
| `base_env_setup.sh` | 基础环境初始化 | `bash <(curl -sL https://raw.githubusercontent.com/xmstar2025/xmxc-shell/refs/heads/main/rocky9/base_env_setup.sh)` |
| `install_docker.sh` | 安装 Docker | `bash <(curl -sL https://raw.githubusercontent.com/xmstar2025/xmxc-shell/refs/heads/main/rocky9/install_docker.sh)` |
| `install_redis.sh` | 安装 Redis | `bash <(curl -sL https://raw.githubusercontent.com/xmstar2025/xmxc-shell/refs/heads/main/rocky9/install_redis.sh)` |
| `install_supervisor.sh` | 安装 Supervisor | `bash <(curl -sL https://raw.githubusercontent.com/xmstar2025/xmxc-shell/refs/heads/main/rocky9/install_supervisor.sh)` |
| `install_ffmpeg.sh` | 安装 FFmpeg（通过 RPM Fusion 仓库） | `bash <(curl -sL https://raw.githubusercontent.com/xmstar2025/xmxc-shell/refs/heads/main/rocky9/install_ffmpeg.sh)` |
| `set_timezone_cn.sh` | 设置时区为上海 | `bash <(curl -sL https://raw.githubusercontent.com/xmstar2025/xmxc-shell/refs/heads/main/rocky9/set_timezone_cn.sh)` |
| `set_timezone_la.sh` | 设置时区为洛杉矶 | `bash <(curl -sL https://raw.githubusercontent.com/xmstar2025/xmxc-shell/refs/heads/main/rocky9/set_timezone_la.sh)` |
| `set_nofile_limit.sh` | 设置文件描述符限制 | `bash <(curl -sL https://raw.githubusercontent.com/xmstar2025/xmxc-shell/refs/heads/main/rocky9/set_nofile_limit.sh)` |
| `fix_local_subnet_route.sh` | 修复本地子网路由 | `bash <(curl -sL https://raw.githubusercontent.com/xmstar2025/xmxc-shell/refs/heads/main/rocky9/fix_local_subnet_route.sh)` |
| `deploy_redis_10_with_passwd.sh` | 部署10个Redis实例（带密码，外网访问，端口39900-39909） | `bash <(curl -sL https://raw.githubusercontent.com/xmstar2025/xmxc-shell/refs/heads/main/rocky9/deploy_redis_10_with_passwd.sh) <密码> start` |

## repair 脚本

| 脚本 | 说明 | 一键安装命令 |
|------|------|------|
| `fix_supervisord_autorestart.sh` | 修复 supervisord 自动重启 | `bash <(curl -sL https://raw.githubusercontent.com/xmstar2025/xmxc-shell/refs/heads/main/repair/fix_supervisord_autorestart.sh)` |

## 一键执行

```bash
# 基础环境初始化
bash <(curl -sL https://raw.githubusercontent.com/xmstar2025/xmxc-shell/refs/heads/main/rocky9/base_env_setup.sh)

# 安装 Docker
bash <(curl -sL https://raw.githubusercontent.com/xmstar2025/xmxc-shell/refs/heads/main/rocky9/install_docker.sh)

# 安装 Redis
bash <(curl -sL https://raw.githubusercontent.com/xmstar2025/xmxc-shell/refs/heads/main/rocky9/install_redis.sh)

# 安装 Supervisor
bash <(curl -sL https://raw.githubusercontent.com/xmstar2025/xmxc-shell/refs/heads/main/rocky9/install_supervisor.sh)

# 安装 FFmpeg
bash <(curl -sL https://raw.githubusercontent.com/xmstar2025/xmxc-shell/refs/heads/main/rocky9/install_ffmpeg.sh)

# 设置时区为上海
bash <(curl -sL https://raw.githubusercontent.com/xmstar2025/xmxc-shell/refs/heads/main/rocky9/set_timezone_cn.sh)

# 设置时区为洛杉矶
bash <(curl -sL https://raw.githubusercontent.com/xmstar2025/xmxc-shell/refs/heads/main/rocky9/set_timezone_la.sh)

# 设置文件描述符限制
bash <(curl -sL https://raw.githubusercontent.com/xmstar2025/xmxc-shell/refs/heads/main/rocky9/set_nofile_limit.sh)

# 修复本地子网路由
bash <(curl -sL https://raw.githubusercontent.com/xmstar2025/xmxc-shell/refs/heads/main/rocky9/fix_local_subnet_route.sh)

# 部署10个Redis实例（需传入密码）
bash <(curl -sL https://raw.githubusercontent.com/xmstar2025/xmxc-shell/refs/heads/main/rocky9/deploy_redis_10_with_passwd.sh) MyPassword123 start

# 修复 supervisord 自动重启
bash <(curl -sL https://raw.githubusercontent.com/xmstar2025/xmxc-shell/refs/heads/main/repair/fix_supervisord_autorestart.sh)
```
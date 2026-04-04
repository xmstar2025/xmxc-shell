# xmxc-shell

常用服务器运维脚本集合，适用于 Rocky Linux 9。

## rocky9 脚本

| 脚本 | 说明 | 一键安装命令 |
|------|------|------|
| `base_env_setup.sh` | 基础环境初始化 | `curl -sL https://raw.githubusercontent.com/xmstar2025/xmxc-shell/refs/heads/main/rocky9/base_env_setup.sh \| bash` |
| `install_docker.sh` | 安装 Docker | `curl -sL https://raw.githubusercontent.com/xmstar2025/xmxc-shell/refs/heads/main/rocky9/install_docker.sh \| bash` |
| `install_redis.sh` | 安装 Redis | `curl -sL https://raw.githubusercontent.com/xmstar2025/xmxc-shell/refs/heads/main/rocky9/install_redis.sh \| bash` |
| `install_supervisor.sh` | 安装 Supervisor | `curl -sL https://raw.githubusercontent.com/xmstar2025/xmxc-shell/refs/heads/main/rocky9/install_supervisor.sh \| bash` |
| `install_ffmpeg.sh` | 安装 FFmpeg（通过 RPM Fusion 仓库） | `curl -sL https://raw.githubusercontent.com/xmstar2025/xmxc-shell/refs/heads/main/rocky9/install_ffmpeg.sh \| bash` |
| `set_timezone_cn.sh` | 设置时区为上海 | `curl -sL https://raw.githubusercontent.com/xmstar2025/xmxc-shell/refs/heads/main/rocky9/set_timezone_cn.sh \| bash` |
| `set_timezone_la.sh` | 设置时区为洛杉矶 | `curl -sL https://raw.githubusercontent.com/xmstar2025/xmxc-shell/refs/heads/main/rocky9/set_timezone_la.sh \| bash` |
| `set_nofile_limit.sh` | 设置文件描述符限制 | `curl -sL https://raw.githubusercontent.com/xmstar2025/xmxc-shell/refs/heads/main/rocky9/set_nofile_limit.sh \| bash` |
| `fix_local_subnet_route.sh` | 修复本地子网路由 | `curl -sL https://raw.githubusercontent.com/xmstar2025/xmxc-shell/refs/heads/main/rocky9/fix_local_subnet_route.sh \| bash` |
| `deploy_redis_10_with_passwd.sh` | 部署10个Redis实例（带密码，外网访问，端口39900-39909） | `curl -sL https://raw.githubusercontent.com/xmstar2025/xmxc-shell/refs/heads/main/rocky9/deploy_redis_10_with_passwd.sh \| bash -s <密码> start` |
| `set_dns.sh` | 修改 DNS 配置（8.8.8.8 / 1.1.1.1，nmcli 持久化） | `curl -sL https://raw.githubusercontent.com/xmstar2025/xmxc-shell/refs/heads/main/rocky9/set_dns.sh \| bash` |

## clear 脚本

| 脚本 | 说明 | 一键执行命令 |
|------|------|------|
| `clear_systemd.sh` | 清理单个 systemd 服务（停止、禁用、删除 .service 文件） | `curl -sL https://raw.githubusercontent.com/xmstar2025/xmxc-shell/refs/heads/main/clear/clear_systemd.sh \| sudo bash -s <服务名>` |
| `clear_machine.sh` | 完整清理机器（systemd 服务 + 临时文件 + 代码目录 + Redis） | `curl -sL https://raw.githubusercontent.com/xmstar2025/xmxc-shell/refs/heads/main/clear/clear_machine.sh \| sudo bash` |

## 一键执行

```bash
# 基础环境初始化
curl -sL https://raw.githubusercontent.com/xmstar2025/xmxc-shell/refs/heads/main/rocky9/base_env_setup.sh | bash

# 安装 Docker
curl -sL https://raw.githubusercontent.com/xmstar2025/xmxc-shell/refs/heads/main/rocky9/install_docker.sh | bash

# 安装 Redis
curl -sL https://raw.githubusercontent.com/xmstar2025/xmxc-shell/refs/heads/main/rocky9/install_redis.sh | bash

# 安装 Supervisor
curl -sL https://raw.githubusercontent.com/xmstar2025/xmxc-shell/refs/heads/main/rocky9/install_supervisor.sh | bash

# 安装 FFmpeg
curl -sL https://raw.githubusercontent.com/xmstar2025/xmxc-shell/refs/heads/main/rocky9/install_ffmpeg.sh | bash

# 设置时区为上海
curl -sL https://raw.githubusercontent.com/xmstar2025/xmxc-shell/refs/heads/main/rocky9/set_timezone_cn.sh | bash

# 设置时区为洛杉矶
curl -sL https://raw.githubusercontent.com/xmstar2025/xmxc-shell/refs/heads/main/rocky9/set_timezone_la.sh | bash

# 设置文件描述符限制
curl -sL https://raw.githubusercontent.com/xmstar2025/xmxc-shell/refs/heads/main/rocky9/set_nofile_limit.sh | bash

# 修复本地子网路由
curl -sL https://raw.githubusercontent.com/xmstar2025/xmxc-shell/refs/heads/main/rocky9/fix_local_subnet_route.sh | bash

# 部署10个Redis实例（需传入密码）
curl -sL https://raw.githubusercontent.com/xmstar2025/xmxc-shell/refs/heads/main/rocky9/deploy_redis_10_with_passwd.sh | bash -s MyPassword123 start

# 修改 DNS 配置
curl -sL https://raw.githubusercontent.com/xmstar2025/xmxc-shell/refs/heads/main/rocky9/set_dns.sh | bash

# 清理单个 systemd 服务
curl -sL https://raw.githubusercontent.com/xmstar2025/xmxc-shell/refs/heads/main/clear/clear_systemd.sh | sudo bash -s <服务名>

# 完整清理机器
curl -sL https://raw.githubusercontent.com/xmstar2025/xmxc-shell/refs/heads/main/clear/clear_machine.sh | sudo bash
```

# xmxc-shell

常用服务器运维脚本集合，适用于 Rocky Linux 9。

## 查看脚本内容

所有脚本可通过以下地址直接查看或下载：

```
https://raw.githubusercontent.com/xmstar2025/xmxc-shell/refs/heads/main/rocky9/<脚本名>
```

## rocky9 脚本列表

| 脚本 | 说明 | 用法 |
|------|------|------|
| `base_env_setup.sh` | 基础环境初始化 | `bash <(curl -sL <url>)` |
| `install_docker.sh` | 安装 Docker | `bash <(curl -sL <url>)` |
| `install_redis.sh` | 安装 Redis | `bash <(curl -sL <url>)` |
| `install_supervisor.sh` | 安装 Supervisor | `bash <(curl -sL <url>)` |
| `set_timezone_cn.sh` | 设置时区为上海 | `bash <(curl -sL <url>)` |
| `set_timezone_la.sh` | 设置时区为洛杉矶 | `bash <(curl -sL <url>)` |
| `set_nofile_limit.sh` | 设置文件描述符限制 | `bash <(curl -sL <url>)` |
| `fix_local_subnet_route.sh` | 修复本地子网路由 | `bash <(curl -sL <url>)` |
| `deploy_redis_10_with_passwd.sh` | 部署10个Redis实例（带密码，外网访问，端口39900-39909） | `bash <(curl -sL <url>) <密码> start` |
| `install_ffmpeg.sh` | 安装 FFmpeg（通过 RPM Fusion 仓库） | `bash <(curl -sL <url>)` |

## 一键执行示例

```bash
# 基础环境初始化
bash <(curl -sL https://raw.githubusercontent.com/xmstar2025/xmxc-shell/refs/heads/main/rocky9/base_env_setup.sh)

# 安装 Docker
bash <(curl -sL https://raw.githubusercontent.com/xmstar2025/xmxc-shell/refs/heads/main/rocky9/install_docker.sh)

# 安装 Redis
bash <(curl -sL https://raw.githubusercontent.com/xmstar2025/xmxc-shell/refs/heads/main/rocky9/install_redis.sh)

# 部署10个Redis实例（需传入密码）
bash <(curl -sL https://raw.githubusercontent.com/xmstar2025/xmxc-shell/refs/heads/main/rocky9/deploy_redis_10_with_passwd.sh) MyPassword123 start

# 安装 FFmpeg
bash <(curl -sL https://raw.githubusercontent.com/xmstar2025/xmxc-shell/refs/heads/main/rocky9/install_ffmpeg.sh)
```

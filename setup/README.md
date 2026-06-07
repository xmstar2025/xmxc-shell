# 装机初始化脚本

Rocky Linux 9 新机器一键初始化，按顺序执行以下步骤：

| 步骤 | 脚本 | 说明 |
|------|------|------|
| 1 | `system/base_env_setup.sh` | 系统更新、EPEL、开发工具组、监控工具、uv |
| 2 | `network/fix_local_subnet_route.sh` | 修复同网段互通，将直连路由改为经网关转发并持久化 |
| 3 | `network/set_dns.sh` | 设置 DNS（8.8.8.8 / 1.1.1.1），防止重启被覆盖 |
| 4 | `system/set_nofile_limit.sh` | 文件描述符上限调至 1,000,000 |
| 5 | `time/set_timezone_cn.sh` | 时区设为 Asia/Shanghai（CST UTC+8） |
| 6 | `time/install_chrony.sh` | 安装 chrony 并立即强制同步时间 |
| 7 | `time/fix_rtc_utc.sh` | 硬件时钟设为 UTC |
| 8 | `redis/install_redis.sh` | 安装 Redis |

步骤 1、2、4 加了 `|| true`，失败不中断后续流程（可选步骤）。

## 用法

```bash
curl -sL https://raw.githubusercontent.com/xmstar2025/xmxc-shell/refs/heads/main/setup/init_server.sh | bash
```

或本地执行：

```bash
bash setup/init_server.sh
```

> 需要 root 权限。

# Redis 管理脚本

## 安装 Redis

```bash
curl -sL https://raw.githubusercontent.com/xmstar2025/xmxc-shell/refs/heads/main/redis/install_redis.sh | bash
```

## 注册服务

```bash
# 注册 Redis 为 systemd 服务（redis-server-{port}），开机自启
curl -sL https://raw.githubusercontent.com/xmstar2025/xmxc-shell/refs/heads/main/redis/setup_redis_systemd.sh | sudo bash -s <密码> <端口>
```

## 删除服务

```bash
# 删除 Redis systemd 服务及所有相关文件（数据/日志/配置）
curl -sL https://raw.githubusercontent.com/xmstar2025/xmxc-shell/refs/heads/main/redis/remove_redis_systemd.sh | sudo bash -s <端口>
```

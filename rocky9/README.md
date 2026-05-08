# Rocky Linux 9 基础脚本

## 基础环境初始化

```bash
curl -sL https://raw.githubusercontent.com/xmstar2025/xmxc-shell/refs/heads/main/rocky9/base_env_setup.sh | bash
```

## 设置时区为上海

```bash
curl -sL https://raw.githubusercontent.com/xmstar2025/xmxc-shell/refs/heads/main/rocky9/set_timezone_cn.sh | bash
```

## 设置文件描述符限制

```bash
curl -sL https://raw.githubusercontent.com/xmstar2025/xmxc-shell/refs/heads/main/rocky9/set_nofile_limit.sh | bash
```

## 修改 DNS 配置（8.8.8.8 / 1.1.1.1）

```bash
curl -sL https://raw.githubusercontent.com/xmstar2025/xmxc-shell/refs/heads/main/rocky9/set_dns.sh | bash
```

## 修复本地子网路由

```bash
curl -sL https://raw.githubusercontent.com/xmstar2025/xmxc-shell/refs/heads/main/rocky9/fix_local_subnet_route.sh | bash
```

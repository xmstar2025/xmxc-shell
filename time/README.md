# 时间管理脚本

## 设置时区为上海

```bash
curl -sL https://raw.githubusercontent.com/xmstar2025/xmxc-shell/refs/heads/main/time/set_timezone_cn.sh | bash
```

## 安装 chrony（NTP 时间同步）

```bash
curl -sL https://raw.githubusercontent.com/xmstar2025/xmxc-shell/refs/heads/main/time/install_chrony.sh | bash
```

## 设置硬件时钟为 UTC

解决双系统（Linux + Windows）时间错乱问题。

```bash
curl -sL https://raw.githubusercontent.com/xmstar2025/xmxc-shell/refs/heads/main/time/fix_rtc_utc.sh | bash
```

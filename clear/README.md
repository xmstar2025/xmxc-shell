# 清理脚本

## 清理单个 systemd 服务

停止、禁用、删除指定的 `.service` 文件。

```bash
curl -sL https://raw.githubusercontent.com/xmstar2025/xmxc-shell/refs/heads/main/clear/clear_systemd.sh | sudo bash -s <服务名>
```

## 完整清理机器

清理 systemd 服务、临时文件、代码目录、Redis。

```bash
curl -sL https://raw.githubusercontent.com/xmstar2025/xmxc-shell/refs/heads/main/clear/clear_machine.sh | sudo bash
```

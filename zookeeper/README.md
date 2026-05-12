# Zookeeper 管理脚本

## 启动 Zookeeper

```bash
# 启动 Zookeeper 容器（客户端端口 2181，管理界面端口 48080）
docker run -d --name zookeeper --restart unless-stopped -p 2181:2181 -p 48080:8080 zookeeper:latest
```

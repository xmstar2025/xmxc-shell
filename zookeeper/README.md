# Zookeeper 管理脚本

## 启动 Zookeeper

```bash
# 启动 Zookeeper 容器（客户端端口 2181，管理界面端口 48080）
docker run -d --name zookeeper -p 2181:2181 -p 48080:8080 zookeeper:latest
```

## Admin Server API

管理界面地址：`http://zk.xmxcmoe.com:48080`

### 查看所有可用命令

```bash
curl http://zk.xmxcmoe.com:48080/commands
```

### 健康检查

```bash
# 返回 "imok" 表示服务正常
curl http://zk.xmxcmoe.com:48080/commands/ruok
```

### 服务器信息

```bash
# 服务器基本状态（版本、模式、节点数等）
curl http://zk.xmxcmoe.com:48080/commands/srvr

# 详细监控指标（适合接入监控系统）
curl http://zk.xmxcmoe.com:48080/commands/mntr

# 运行环境变量
curl http://zk.xmxcmoe.com:48080/commands/envi
```

### 连接管理

```bash
# 查看所有活跃客户端连接
curl http://zk.xmxcmoe.com:48080/commands/cons

# 重置连接统计信息
curl http://zk.xmxcmoe.com:48080/commands/crst
```

### Watch 管理

```bash
# Watch 汇总（总数 / 各路径数量）
curl http://zk.xmxcmoe.com:48080/commands/wchs

# 按连接查看 Watch 详情
curl http://zk.xmxcmoe.com:48080/commands/wchc

# 按路径查看 Watch 详情
curl http://zk.xmxcmoe.com:48080/commands/wchp
```

### 数据与会话

```bash
# 导出所有 session 及临时节点
curl http://zk.xmxcmoe.com:48080/commands/dump

# 查看数据目录磁盘使用情况
curl http://zk.xmxcmoe.com:48080/commands/dirs
```

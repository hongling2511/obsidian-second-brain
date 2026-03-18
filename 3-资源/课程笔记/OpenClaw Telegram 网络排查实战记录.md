---
创建日期: 2026-03-18
类型: 课程
作者: 实战记录
关键词: OpenClaw, Telegram, 代理, Node.js, undici, 网络排查
tags: #资源 #概念
---

# OpenClaw Telegram 网络排查实战记录

## 背景

OpenClaw（宿主机直装，非 Docker）的 Telegram bot 无法正常通信。此前通过 TUN 透明代理正常工作过一段时间，某天突然失效。

### 环境

- 服务器：Rocky Linux 9.5，`192.168.1.12`
- 代理：`192.168.1.223:8234`（HTTP）/ `:8235`（SOCKS5），局域网另一台机器
- OpenClaw：v2026.3.14，systemd 管理，Node.js 22
- 模型 API：aicoding.2233.ai（原），sub2api 本地接口（最终方案）

## 排查过程

### 第一层：确认服务状态

```bash
systemctl status openclaw-gateway
journalctl -u openclaw-gateway --no-pager -n 80
```

**发现：** Telegram `deleteWebhook` 持续超时（`UND_ERR_CONNECT_TIMEOUT`），每 30 秒重试一次。

### 第二层：检查网络连通性

```bash
# shell 环境下 curl 正常
curl --proxy http://192.168.1.223:8234 https://api.telegram.org  # 302, 0.97s
curl https://www.google.com  # 200, 0.37s

# 检查代理环境变量
env | grep -iE 'proxy'  # .bashrc 中配置了 http_proxy/https_proxy

# 检查 TUN 设备
ip addr show tun0  # Device "tun0" does not exist
```

**发现：** TUN 透明代理已失效，代理环境变量在 `.bashrc` 中但 systemd 服务不继承。

### 第三层：定位 systemd 服务缺失代理变量

```bash
cat /etc/systemd/system/openclaw-gateway.service
# → 没有 Environment=http_proxy/https_proxy
cat /proc/<pid>/environ | tr '\0' '\n' | grep proxy
# → 进程无代理变量
```

**根因之一：** systemd 服务未配置代理环境变量，Node.js 进程无法访问 Telegram API。

### 第四层：添加代理后的新问题

给 systemd 添加 `HTTPS_PROXY`/`HTTP_PROXY`/`NO_PROXY` 后重启：

- Telegram **能收消息**了
- 但模型 API 调用**卡死 120 秒**

```bash
ss -tnp | grep <pid>
# recv-q=514 的连接持续不变 → 应用层没有消费数据
```

### 第五层：深挖 120 秒延迟

通过日志分析 `embedded run` 生命周期：

| 事件 | 时间 | 间隔 |
|------|------|------|
| `embedded run start` | 10:15:13 | - |
| `embedded run prompt start` | 10:17:13 | **120 秒** |
| `embedded run agent end` | 10:17:20 | 7 秒 |
| `sendMessage failed` | 10:17:21 | - |

**关键发现：**

1. **模型 API 本身只需 ~7 秒**（`prompt start` → `agent end`）
2. **120 秒延迟在 `run start` → `prompt start` 之间**
3. `sendChatAction`（typing 指示器）和 `sendMessage` 全部失败
4. `recv-q=514` 始终出现在代理连接上

### 第六层：undici ProxyAgent 连接池问题

OpenClaw 使用 undici 的 `EnvHttpProxyAgent` 作为全局 dispatcher（`setGlobalDispatcher`）。

**问题链：**

1. Telegram 长轮询（getUpdates）通过 HTTP CONNECT 隧道占用一个代理连接
2. undici 的 `ProxyAgent` 默认连接池有限（可能为 1）
3. 后续请求（sendChatAction、模型 API）排队等待
4. 长轮询 120 秒超时后释放连接，后续请求才能执行
5. 但此时 Telegram 连接已断，sendMessage 失败

**验证：**

```bash
# 手动 CONNECT 隧道正常
node -e "http.request({method:'CONNECT',path:'api.telegram.org:443'...})"  # 200, 0.93s

# 并发 curl 通过代理正常
curl --proxy ... https://api.telegram.org/...getMe &
curl --proxy ... https://api.telegram.org/...getMe &  # 两个都 200

# 但 EnvHttpProxyAgent 全局 dispatcher 下，连接池串扰
```

### 最终发现：代理节点故障

排查到最后，确认 `192.168.1.223:8234` 代理节点本身不稳定/已挂掉，导致所有通过代理的请求间歇性失败。

## 最终配置

### 模型 API：本地 sub2api（绕过代理）

```json
// openclaw.json
"models": {
  "providers": {
    "sub2api": {
      "baseUrl": "http://192.168.1.12:8081",
      "apiKey": "sk-xxx",
      "api": "anthropic-messages",
      "models": [...]
    }
  }
},
"agents": {
  "defaults": {
    "model": {
      "primary": "sub2api/claude-opus-4-6",
      "fallbacks": ["sub2api/claude-sonnet-4-6"]
    }
  }
}
```

### Telegram：应用级代理（待代理恢复）

```json
"channels": {
  "telegram": {
    "proxy": "http://192.168.1.223:8234"
  }
}
```

### systemd 服务：无全局代理变量

```ini
# /etc/systemd/system/openclaw-gateway.service
[Service]
Environment=NODE_ENV=production
Environment=HOME=/root
# 不设置 HTTPS_PROXY 等，避免全局 dispatcher 干扰
```

## 经验总结

### 1. systemd 服务不继承 shell 环境变量

`.bashrc` 中的 `http_proxy` 等变量对 systemd 服务不可见。需要在 service 文件的 `Environment=` 中显式声明。

### 2. undici EnvHttpProxyAgent 的全局 dispatcher 陷阱

`setGlobalDispatcher(new EnvHttpProxyAgent())` 会让**所有** fetch 请求走代理，包括不需要代理的本地 API。`NO_PROXY` 虽然理论上有效，但连接池共享导致长连接（如 Telegram 长轮询）阻塞其他请求。

### 3. `recv-q` 是排查连接池问题的利器

```bash
ss -tnp | grep <pid>
# recv-q > 0 且长时间不变 → 连接池有死连接
# 514 字节 → 特定的未消费响应数据
```

### 4. 分离代理作用域是关键

| 组件 | 需要代理 | 方案 |
|------|---------|------|
| Telegram API | 是 | `channels.telegram.proxy`（应用级） |
| 模型 API | 否 | 本地 sub2api，无代理 |

**避免用全局 `HTTPS_PROXY` 环境变量**，优先用应用级代理配置，避免代理作用域扩散。

### 5. 代理节点故障要优先排除

在深挖应用层问题之前，先验证代理本身是否可用：

```bash
curl -s --proxy http://proxy:port --connect-timeout 5 https://api.telegram.org
```

## 相关概念

- [[代理环境下应用网络排查模型]]
- [[透明代理]]
- [[Docker 网络模型]]

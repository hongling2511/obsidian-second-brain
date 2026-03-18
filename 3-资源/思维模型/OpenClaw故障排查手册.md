---
创建日期: 2026-03-18
类型: 文章
作者: Claude Code 整理
关键词: OpenClaw, Telegram Bot, 故障排查, 网络代理
tags: #资源
---

# OpenClaw 故障排查手册

## 服务器信息

| 项目 | 值 |
|------|-----|
| 服务器 IP | 192.168.1.12 |
| 系统用户 | root（密码 687092） |
| 系统 | Rocky Linux 9.5 (x86_64) |
| OpenClaw 版本 | 2026.3.13（npm 安装） |
| OpenClaw 可执行文件 | `/usr/bin/openclaw` |
| 配置文件 | `/root/.openclaw/openclaw.json` |
| Session 目录 | `/root/.openclaw/agents/main/sessions/` |
| 日志文件 | `/tmp/openclaw/openclaw-2026-03-18.log` |
| Systemd 服务 | `openclaw-gateway.service` |
| 透明代理 | mihomo (Clash Meta) v1.19.8 TUN 模式 |
| mihomo 配置 | `/etc/mihomo/config.yaml` |
| mihomo 服务 | `mihomo.service` |
| Sub2API 服务 | `sub2api.service`，端口 8081 |
| 当前模型提供商 | aicoding (`https://aicoding.2233.ai`) |
| Telegram Bot | `@hollyfoxbot` |

---

## 常用命令速查

```bash
# === 服务状态 ===
systemctl status openclaw-gateway
systemctl status mihomo
systemctl status sub2api

# === 日志 ===
journalctl -u openclaw-gateway -f              # 实时日志
journalctl -u openclaw-gateway --no-pager -n 50 # 最近 50 条
journalctl -u mihomo --no-pager -n 20           # mihomo 日志

# === 重启 ===
systemctl restart openclaw-gateway
systemctl restart mihomo

# === 强制停止（卡住时） ===
systemctl stop openclaw-gateway
pkill -9 openclaw   # 如果 stop 卡住

# === 配对管理 ===
openclaw pairing list
openclaw pairing approve telegram <配对码>

# === Session 管理 ===
openclaw sessions
rm -f /root/.openclaw/agents/main/sessions/*.jsonl  # 清理所有 session

# === 网络测试 ===
# 测试 Telegram 直连（走 TUN）
curl --noproxy '*' --connect-timeout 10 'https://api.telegram.org/bot<TOKEN>/getMe'
# 手动发消息测试
curl --noproxy '*' 'https://api.telegram.org/bot<TOKEN>/sendMessage' \
  -d 'chat_id=5750770751&text=测试'
# 用 Node.js 测试（模拟 OpenClaw 的行为）
node -e "fetch('https://api.telegram.org/bot<TOKEN>/getMe').then(r=>r.json()).then(console.log)"
# 检查 mihomo 是否在路由 Telegram 流量
journalctl -u mihomo --no-pager | grep telegram
```

---

## 故障一：Telegram Bot 不回复消息

### 排查步骤

**第 1 步：检查服务是否在运行**

```bash
systemctl status openclaw-gateway
```

- `active (running)` → 服务在运行，继续下一步
- `inactive` / `failed` → 执行 `systemctl start openclaw-gateway`

**第 2 步：检查日志中的错误**

```bash
journalctl -u openclaw-gateway --no-pager -n 50 | grep -i "error\|fail"
```

根据错误类型跳转到对应故障：
- `sendChatAction failed: Network request failed` → 见[[#故障二：网络代理问题]]
- `getUpdates conflict` → 见[[#故障三：多实例冲突]]
- `embedded run start` 后无后续日志 → 见[[#故障四：API 调用卡住]]

**第 3 步：确认消息是否收到**

```bash
journalctl -u openclaw-gateway --no-pager -n 20 | grep "update:"
```

如果能看到 `"text":"你发的消息"`，说明 Telegram 消息已经到达 gateway。

---

## 故障二：Telegram 消息发送失败（sendMessage/sendChatAction failed）

### 症状

日志中反复出现：
```
[telegram] sendChatAction failed: Network request for 'sendChatAction' failed!
[telegram] sendMessage failed: Network request for 'sendMessage' failed!
[telegram] final reply failed: HttpError: Network request for 'sendMessage' failed!
```

**特征：消息能收到（update 日志出现），agent 也跑完了（run done），但回复发不出去。**

### 根因分析（2026-03-18 排查结论）

这是 **OpenClaw 的 undici HTTP 客户端 bug**，不是代理本身的问题。

**核心机制：**
1. OpenClaw 使用 undici 库的 `setGlobalDispatcher()` 管理全局 HTTP 连接
2. Agent 运行时会调用 `ensureGlobalUndiciStreamTimeouts()` 重设全局 dispatcher
3. 这会**覆盖** Telegram 客户端原本使用的 dispatcher
4. 如果之前配置了 HTTP 代理（`proxy` 字段或 `http_proxy` 环境变量），新 dispatcher 不再携带代理配置
5. 发送请求变成"直连" → 国内直连 Telegram 不通 → 立即失败

**验证方式：**
```bash
# curl 通过代理可以发送 → 代理没问题
curl --proxy http://192.168.1.223:8234 'https://api.telegram.org/bot<TOKEN>/sendMessage' -d 'chat_id=xxx&text=test'
# Node.js fetch 可以发送 → Node 运行时没问题
node -e "fetch('https://api.telegram.org/bot<TOKEN>/getMe').then(r=>r.json()).then(console.log)"
# 但 OpenClaw 的 sendMessage 就是失败 → OpenClaw 内部 dispatcher 被覆盖
```

### 解决方案：mihomo TUN 透明代理（已部署）

**不再依赖 HTTP 代理配置**，改用 TUN 模式在系统网络层透明代理所有流量：

```
OpenClaw sendMessage → "以为在直连" → 被 TUN 拦截 → 走 mihomo 代理 → Telegram ✓
```

- mihomo 配置：`/etc/mihomo/config.yaml`
- TUN 栈：gVisor
- 代理节点：vmess（来自 Surge 订阅的 HK/JP/SG 节点）
- 规则：Telegram 域名和 IP 走代理，国内直连

**OpenClaw 配置中不再需要 `proxy` 字段和代理环境变量。**

### 如果 mihomo 挂了的应急方案

```bash
# 1. 检查 mihomo 状态
systemctl status mihomo
# 2. 重启 mihomo
systemctl restart mihomo
# 3. 验证 TUN 生效
curl --noproxy '*' --connect-timeout 10 'https://api.telegram.org/bot<TOKEN>/getMe'
# 4. 如果 mihomo 彻底不能用，临时恢复 HTTP 代理方式（有 dispatcher bug，只能处理短任务）
# 在 openclaw.json 的 channels.telegram 中加回 "proxy": "http://192.168.1.223:8234"
# 然后重启 gateway
```

---

## 故障三：多实例冲突（409 Conflict）

### 症状

```
[telegram] getUpdates conflict: terminated by other getUpdates request; make sure that only one bot instance is running
```

### 原因

409 冲突有两种情况：

**情况 1：真正的多进程（可修复）**
- 旧进程没正常退出，两个 gateway 同时 polling

**情况 2：OpenClaw 内部 polling 循环自我冲突（已知行为）**
- 只有一个进程但 409 持续出现
- 这是 OpenClaw 的 Telegram polling 实现特性
- 重启时旧的长轮询请求未在 Telegram 服务端过期，新请求与之冲突
- 退避机制（2s → 4s → 7s → 13s → 30s max）会逐渐收敛

### 排查

```bash
# 确认是否有多个进程
ps aux | grep openclaw | grep -v grep
# 正常应该只有 2 个：openclaw（父进程）和 openclaw-gateway（worker）

# 如果有多余进程
pkill -9 openclaw
systemctl start openclaw-gateway
```

### 重要结论（2026-03-18 验证）

**409 冲突不阻止消息收发！** 在 409 持续出现的情况下，bot 仍然能接收消息并正常回复。不要因为看到 409 就认为 bot 坏了。

### 如果需要强制清理 Telegram 端的会话

```bash
# 停止 gateway
systemctl stop openclaw-gateway && pkill -9 openclaw
# 调用 Telegram close API 清理服务端会话（不要用 logOut！）
curl --noproxy '*' 'https://api.telegram.org/bot<TOKEN>/close'
# 等 5 秒让 Telegram 清理
sleep 5
# 重启
systemctl start openclaw-gateway
```

> **警告：千万不要调用 `logOut` API！** `logOut` 会导致 bot 在 10 分钟内无法连接云端 API，并可能触发重新配对。`close` 就够了。

---

## 故障四：API 调用卡住

### 症状

日志停在 `embedded run start` 之后没有任何后续输出：
```
[agent/embedded] embedded run start: runId=xxx provider=sub2api model=claude-opus-4-6
```

等待数分钟也无 `run end` 或 `tool start` 日志。

### 排查

**第 1 步：确认 Sub2API 服务正常**

```bash
systemctl status sub2api
ss -tlnp | grep 8081
```

**第 2 步：手动测试 API 调用**

```bash
curl -s --connect-timeout 10 -X POST http://127.0.0.1:8081/v1/messages \
  -H "Content-Type: application/json" \
  -H "x-api-key: sk-aabfbfb2494e932a4cc7afb40c784ce6f1d9d21bd278718a6128cf357274e717" \
  -H "anthropic-version: 2023-06-01" \
  -d '{"model":"claude-opus-4-6","max_tokens":50,"messages":[{"role":"user","content":"hi"}]}'
```

- 正常返回 JSON → Sub2API 没问题，问题在 OpenClaw 端
- 超时或报错 → Sub2API 或上游 API 有问题

**第 3 步：检查 Sub2API 的日志**

```bash
journalctl -u sub2api --no-pager -n 20
```

**第 4 步：检查 OpenClaw 配置中 Sub2API 地址**

```bash
grep "baseUrl" /root/.openclaw/openclaw.json
```

> **重要**：`baseUrl` 必须使用 `http://127.0.0.1:8081` 而不是 `http://192.168.1.12:8081`，否则请求可能被代理拦截。

**第 5 步：检查 Session 是否过大**

```bash
ls -lh /root/.openclaw/agents/main/sessions/*.jsonl
```

如果 session 文件超过 500KB，可能因为上下文太大导致 API 调用超时。

### 修复：清理 Session

```bash
# 停止服务
systemctl stop openclaw-gateway
# 如果 stop 卡住
kill -9 $(pgrep -f openclaw-gateway)

# 备份并清空 session
cd /root/.openclaw/agents/main/sessions/
cp sessions.json sessions.json.bak
echo '{}' > sessions.json
# 可选：移走大的 jsonl 文件
mv *.jsonl /tmp/

# 重启
systemctl start openclaw-gateway
```

---

## 故障五：配对失败

### 症状

Telegram 发消息后提示需要配对，但配对码审批失败。

### 排查

```bash
cd /opt/openclaw

# 查看待处理的配对请求
node openclaw.mjs pairing list

# 审批配对码
node openclaw.mjs pairing approve <配对码>
```

### 注意

- 配对码有时效性，过期后需要在 Telegram 重新触发
- 如果提示 `No pending pairing request found`，说明码已过期，需要重新发消息获取新码

---

## 一键恢复流程

当 bot 完全无响应时，按以下顺序操作：

```bash
# 1. 确认 mihomo TUN 代理正常
systemctl is-active mihomo || systemctl start mihomo
curl --noproxy '*' --connect-timeout 5 'https://api.telegram.org/bot<TOKEN>/getMe'
# 如果超时 → mihomo 有问题，先修 mihomo

# 2. 强制停止 openclaw
systemctl stop openclaw-gateway
pkill -9 openclaw
sleep 3

# 3. 清理 session（可选，session 过大时执行）
rm -f /root/.openclaw/agents/main/sessions/*.jsonl

# 4. 清理 Telegram 端残留会话
curl --noproxy '*' 'https://api.telegram.org/bot<TOKEN>/close'
sleep 5

# 5. 重启
systemctl start openclaw-gateway

# 6. 验证（等 10 秒让 provider 启动）
sleep 10
journalctl -u openclaw-gateway --no-pager -n 15
# 看到 "starting provider (@hollyfoxbot)" 即可在 Telegram 发消息测试
```

---

## 架构总览

```
用户(Telegram) → Telegram 服务器 → [mihomo TUN 透明代理] → OpenClaw(getUpdates 长轮询)
                                                                     ↓
                                                               Agent 处理
                                                          (aicoding API → Claude)
                                                                     ↓
                                   OpenClaw(sendMessage) → [TUN 透明代理] → Telegram 服务器 → 用户
```

### 关键链路

| 环节 | 协议 | 说明 |
|------|------|------|
| Telegram ↔ OpenClaw | HTTPS via TUN/mihomo | 所有 Telegram API 调用走 TUN 透明代理 |
| OpenClaw → aicoding | HTTPS | 模型 API 调用（`aicoding.2233.ai`） |
| OpenClaw → sub2api | HTTP | 本地 API 代理（127.0.0.1:8081），备用 |

### 为什么用 TUN 而不是 HTTP 代理？

OpenClaw 内部有个 bug：agent 运行时调用 `setGlobalDispatcher()` 覆盖全局 undici HTTP 客户端，导致 Telegram 客户端丢失代理配置。HTTP 代理（无论是 `openclaw.json` 里的 `proxy` 字段还是 systemd 环境变量）都无法解决这个问题。

TUN 模式在**系统网络层**拦截流量，应用层无感知，彻底绕过了这个 bug。

### mihomo 配置关键点

- 配置文件：`/etc/mihomo/config.yaml`
- TUN 栈：gVisor（`tun.stack: gvisor`）
- DNS：fake-ip 模式
- 代理节点：vmess（从 Surge 订阅提取）
- 规则：telegram.org → 代理，GEOIP CN → 直连，其余直连
- systemd 服务：`mihomo.service`（开机自启）

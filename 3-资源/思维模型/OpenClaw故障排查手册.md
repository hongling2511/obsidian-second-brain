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
| 系统用户 | root |
| OpenClaw 安装目录 | `/opt/openclaw` |
| 配置文件 | `/root/.openclaw/openclaw.json` |
| Session 目录 | `/root/.openclaw/agents/main/sessions/` |
| 日志文件 | `/tmp/openclaw/openclaw-2026-03-18.log` |
| Systemd 服务 | `openclaw-gateway.service` |
| 代理配置覆盖 | `/etc/systemd/system/openclaw-gateway.service.d/proxy.conf` |
| Sub2API 服务 | `sub2api.service`，端口 8081 |
| Telegram Bot | `@hollyfoxbot` |

---

## 常用命令速查

```bash
# 查看服务状态
systemctl status openclaw-gateway
systemctl status sub2api

# 查看实时日志
journalctl -u openclaw-gateway -f

# 查看最近 N 条日志
journalctl -u openclaw-gateway --no-pager -n 50

# 重启服务
systemctl restart openclaw-gateway

# 强制停止（卡住时）
systemctl stop openclaw-gateway
# 如果 stop 也卡住，找到 PID 强杀
ps aux | grep openclaw | grep -v grep
kill -9 <PID>

# 配对管理
cd /opt/openclaw
node openclaw.mjs pairing list
node openclaw.mjs pairing approve <配对码>

# Session 管理
node openclaw.mjs sessions
node openclaw.mjs sessions cleanup --dry-run
node openclaw.mjs sessions cleanup --enforce
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

## 故障二：网络代理问题

### 症状

日志中反复出现：
```
[telegram] sendChatAction failed: Network request for 'sendChatAction' failed!
[telegram] Polling stall detected (no getUpdates for Xs); forcing restart.
```

### 原因

服务器在中国大陆，访问 Telegram API (`api.telegram.org`) 需要代理。Systemd 启动的进程不会继承 Shell 的环境变量。

### 排查

```bash
# 1. 检查 Shell 里的代理设置
env | grep -i proxy

# 2. 检查 systemd 服务是否有代理
cat /proc/$(pgrep -f "openclaw-gateway" | head -1)/environ | tr '\0' '\n' | grep -i proxy

# 3. 检查代理覆盖文件是否存在
cat /etc/systemd/system/openclaw-gateway.service.d/proxy.conf

# 4. 测试代理是否能连通 Telegram
curl -s --connect-timeout 5 --proxy http://192.168.1.223:8234 https://api.telegram.org/bot123/getMe
# 返回 {"ok":false,...} 说明代理通，返回连接超时说明代理挂了
```

### 修复

**如果代理覆盖文件不存在：**

```bash
mkdir -p /etc/systemd/system/openclaw-gateway.service.d
cat > /etc/systemd/system/openclaw-gateway.service.d/proxy.conf << 'EOF'
[Service]
Environment=http_proxy=http://192.168.1.223:8234
Environment=https_proxy=http://192.168.1.223:8234
Environment=all_proxy=socks5://192.168.1.223:8235
Environment=no_proxy=localhost,127.0.0.1,::1
EOF

systemctl daemon-reload
systemctl restart openclaw-gateway
```

**如果代理本身挂了（192.168.1.223:8234 不通）：**

检查代理服务器 192.168.1.223 的状态，或更换代理地址后更新 `proxy.conf`。

---

## 故障三：多实例冲突

### 症状

```
[telegram] getUpdates conflict: terminated by other getUpdates request; make sure that only one bot instance is running
```

### 原因

同一个 Bot Token 被多个进程同时使用拉取消息。可能原因：
- 旧进程没有正常退出
- 在其他地方也运行了相同的 bot

### 排查

```bash
# 查看所有 openclaw 相关进程
ps aux | grep openclaw | grep -v grep

# 如果有多个 openclaw-gateway 进程
kill -9 <旧PID>
systemctl restart openclaw-gateway
```

### 说明

偶尔出现一两次 409 冲突是正常的（重启过渡期），持续出现才需要排查。

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
# 1. 强制停止
systemctl stop openclaw-gateway || kill -9 $(pgrep -f openclaw-gateway)
sleep 2

# 2. 清理 session
cd /root/.openclaw/agents/main/sessions/
cp sessions.json sessions.json.bak
echo '{}' > sessions.json

# 3. 确认代理配置存在
cat /etc/systemd/system/openclaw-gateway.service.d/proxy.conf

# 4. 确认 sub2api baseUrl 是 127.0.0.1
grep "baseUrl" /root/.openclaw/openclaw.json

# 5. 重启
systemctl daemon-reload
systemctl start openclaw-gateway

# 6. 验证
sleep 5
journalctl -u openclaw-gateway --no-pager -n 15
# 确认无 error，然后在 Telegram 发消息测试
```

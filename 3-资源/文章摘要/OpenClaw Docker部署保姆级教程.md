---
创建日期: 2026-03-17
类型: 文章
作者: 个人实践总结
关键词: OpenClaw, Docker, Telegram Bot, 自部署, AI助手
复习间隔: 1, 7, 21, 60
复习日期: 2026-03-18
tags: #资源
---

# OpenClaw Docker 部署保姆级教程｜闲置 Linux 机器秒变 AI 助手

> 家里吃灰的服务器终于有用了！手把手教你用 Docker 部署 OpenClaw，对接 Telegram，随时随地和 AI 聊天。

---

## 先说结论

OpenClaw 是一个开源的 AI Gateway，可以把各种大模型（Claude、DeepSeek 等）统一接入 Telegram、Discord 等聊天平台。部署完成后，你可以直接在 Telegram 里和 AI 对话，体验丝滑。

**我的环境：** Rocky Linux 9.5 + Docker 28 + SELinux enforcing

**最终效果：**
- Telegram Bot 7×24 在线，随时响应
- 支持多模型自动降级（主力挂了自动切备用）
- Web Dashboard 可视化管理
- 开机自启，重启自恢复

---

## 部署全流程（10 步走）

### 第 1 步：克隆仓库

```bash
git clone https://github.com/openclaw/openclaw.git /opt/openclaw
```

确认目录下有 `docker-compose.yml`、`Dockerfile`、`docker-setup.sh` 三个关键文件。

---

### 第 2 步：拉取官方镜像

```bash
docker pull ghcr.io/openclaw/openclaw:latest
```

用官方预构建镜像，省去本地编译的时间。

---

### 第 3 步：创建数据目录 + 处理 SELinux

这一步很多教程不提，但在 **SELinux enforcing** 模式下不做就会翻车。

```bash
# 创建目录
mkdir -p /root/.openclaw/{workspace,credentials,agents}

# 容器内 node 用户 uid=1000，必须对齐
chown -R 1000:1000 /root/.openclaw

# SELinux 上下文，不加容器读不到文件
chcon -Rt svirt_sandbox_file_t /root/.openclaw
```

**踩坑提醒：** 如果容器启动后日志报 `permission denied`，大概率就是这步没做。

---

### 第 4 步：编写配置文件（核心！）

这是整个部署最关键的一步。跳过交互式向导，直接手写 `openclaw.json`。

```bash
# 先生成一个 Gateway 认证 token
openssl rand -hex 32
# 记下这个 64 位 hex 字符串
```

然后创建 `/root/.openclaw/openclaw.json`，核心结构如下：

```json
{
  "gateway": {
    "mode": "local",
    "bind": "lan",
    "port": 18789,
    "auth": {
      "mode": "token",
      "token": "你生成的64位hex字符串"
    }
  },
  "channels": {
    "telegram": {
      "enabled": true,
      "botToken": "你的Telegram Bot Token",
      "dmPolicy": "pairing",
      "groups": { "*": { "requireMention": true } },
      "streaming": "partial",
      "commands": { "native": "auto" }
    }
  },
  "models": {
    "providers": {
      "自定义名称": {
        "baseUrl": "你的模型API地址",
        "apiKey": "你的API Key",
        "api": "anthropic-messages 或 openai-chat",
        "models": [
          {
            "id": "模型ID",
            "name": "显示名称",
            "contextWindow": 200000,
            "maxTokens": 8192
          }
        ]
      }
    }
  },
  "agents": {
    "defaults": {
      "model": {
        "primary": "提供商名/主力模型ID",
        "fallbacks": ["提供商名/备用模型1", "提供商名/备用模型2"]
      }
    }
  },
  "tools": {
    "fs": { "workspaceOnly": true },
    "exec": { "security": "deny", "ask": "always" }
  }
}
```

**配置要点解读：**

| 字段 | 含义 |
|------|------|
| `gateway.bind: "lan"` | 允许局域网设备访问，不只是 localhost |
| `gateway.auth.mode: "token"` | 用 token 保护 API，防止裸奔 |
| `channels.telegram.dmPolicy: "pairing"` | 私聊需要配对确认，防止陌生人白嫖 |
| `channels.telegram.streaming: "partial"` | 流式输出，打字机效果 |
| `models.providers` | 支持多个模型提供商，格式灵活 |
| `agents.defaults.model.fallbacks` | 主力模型挂了自动切备用，高可用 |

写完后锁定权限：

```bash
chmod 600 /root/.openclaw/openclaw.json
chown -R 1000:1000 /root/.openclaw
```

---

### 第 5 步：启动 Gateway 容器

```bash
cd /opt/openclaw
OPENCLAW_IMAGE="ghcr.io/openclaw/openclaw:latest" docker compose up -d openclaw-gateway
```

启动后检查：

```bash
# 看容器状态
docker ps --filter "name=openclaw"

# 看日志，确认无 ERROR
docker logs --tail 50 $(docker ps -q --filter name=openclaw-gateway)

# 确认 Telegram bot 已连接
docker logs $(docker ps -q --filter name=openclaw-gateway) 2>&1 | grep -i telegram
```

---

### 第 6 步：配置防火墙

```bash
firewall-cmd --permanent --add-port=18789/tcp && firewall-cmd --reload
```

验证：`firewall-cmd --list-ports` 能看到 `18789/tcp`。

---

### 第 7 步：配置开机自启

```bash
# Docker 服务自启
systemctl enable docker

# 容器自启策略
docker update --restart unless-stopped $(docker ps -q --filter name=openclaw-gateway)
```

这样机器重启后 OpenClaw 会自动拉起。

---

### 第 8 步：Telegram 配对

因为我们配了 `dmPolicy: "pairing"`，首次使用需要配对：

1. 在 Telegram 中搜索你的 Bot，发一条消息
2. 服务器端查看并批准配对请求：

```bash
cd /opt/openclaw
docker compose run --rm openclaw-cli pairing list telegram
docker compose run --rm openclaw-cli pairing approve telegram <配对码>
```

3. 回到 Telegram 再发条消息，Bot 应该就能正常回复了

---

### 第 9 步：安全加固

```bash
# 锁定权限
chmod 700 /root/.openclaw
chmod 600 /root/.openclaw/openclaw.json

# 安全审计
cd /opt/openclaw && docker compose run --rm openclaw-cli security audit

# 验证未认证请求被拒（应该返回 401/403）
curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:18789/api/sessions
```

---

### 第 10 步：端到端验证

```bash
# 本机健康检查
curl -fsS http://127.0.0.1:18789/healthz

# 远程健康检查（从其他机器）
curl -fsS http://你的IP:18789/healthz

# 打开 Dashboard
docker compose run --rm openclaw-cli dashboard --no-open
```

浏览器访问 `http://你的IP:18789/`，Settings 里粘贴 Gateway token 完成配对。

最后做个重启测试：

```bash
docker restart $(docker ps -q --filter name=openclaw-gateway)
# 等 5 秒后确认容器恢复 Up 状态
```

---

## 我踩过的坑

**1. SELinux 权限问题**
容器启动后配置文件读不到，日志疯狂报错。解决：`chcon -Rt svirt_sandbox_file_t` 给数据目录打标签。

**2. 容器内用户是 uid=1000**
文件 owner 必须是 1000:1000，不是 root。否则容器内 node 进程无法读写。

**3. 配置文件是 JSON 不是 YAML**
手写容易少逗号多逗号，写完用 `python3 -m json.tool` 验证一下。

**4. firewalld 要 reload**
`--permanent` 加了规则不会立即生效，必须 `firewall-cmd --reload`。

---

## 配置速查表

| 配置项 | 推荐值 | 说明 |
|--------|--------|------|
| `gateway.bind` | `lan` | 局域网可访问 |
| `gateway.port` | `18789` | 默认端口 |
| `gateway.auth.mode` | `token` | Token 认证 |
| `telegram.dmPolicy` | `pairing` | 需配对确认 |
| `telegram.streaming` | `partial` | 流式打字效果 |
| `tools.exec.security` | `deny` | 禁止执行命令（安全） |

---

## 相关链接

- [[从LLM到Agent Skill底层逻辑拆解]]
- [[Claude Code完全指南]]

**参考文档：**
- OpenClaw Docker 安装文档
- OpenClaw Telegram 频道配置文档
- OpenClaw 模型提供商配置文档
- OpenClaw 安全加固文档

---

> **L3 总结：** OpenClaw 的核心价值是把模型 API "翻译"成聊天平台的原生体验。部署本身不难，关键是配置文件要写对（Gateway 认证 + 频道对接 + 模型端点），以及处理好 SELinux 权限。一旦跑起来，就是一个 7×24 在线的私人 AI 助手。

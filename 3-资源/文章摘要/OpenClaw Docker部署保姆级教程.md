---
创建日期: 2026-03-17
类型: 文章
作者: 个人实践总结
关键词: OpenClaw, Docker, 自部署, AI助手, DeepSeek, 私有化部署
复习间隔: 1, 7, 21, 60
复习日期: 2026-03-18
tags: #资源
---

# 闲置 Linux 机器秒变私人 AI 助手｜Docker 部署 OpenClaw 保姆级教程

> 家里吃灰的服务器终于有用了！手把手教你用 Docker 部署 OpenClaw，打造属于自己的私有化 AI 基础设施，数据完全自主可控。

---

## 先说结论

OpenClaw 是一个开源的 AI Gateway，可以把 DeepSeek、通义千问等大模型统一接入各种终端，部署在自己的服务器上。数据不经过第三方，随时随地通过消息客户端和 AI 对话。

**我的环境：** Rocky Linux 9.5 + Docker 28 + SELinux enforcing

**最终效果：**
- 私有 AI 助手 7×24 在线，随时响应
- 支持多模型自动降级（主力挂了自动切备用）
- Web Dashboard 可视化管理
- 开机自启，重启自恢复
- **数据全程在自己服务器上，不依赖任何第三方云服务**

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
    "im": {
      "enabled": true,
      "dmPolicy": "pairing",
      "streaming": "partial",
      "commands": { "native": "auto" }
    }
  },
  "models": {
    "providers": {
      "deepseek": {
        "baseUrl": "https://api.deepseek.com",
        "apiKey": "你的DeepSeek API Key",
        "api": "openai-chat",
        "models": [
          {
            "id": "deepseek-chat",
            "name": "DeepSeek V3",
            "contextWindow": 64000,
            "maxTokens": 8192
          },
          {
            "id": "deepseek-reasoner",
            "name": "DeepSeek R1",
            "contextWindow": 64000,
            "maxTokens": 8192
          }
        ]
      }
    }
  },
  "agents": {
    "defaults": {
      "model": {
        "primary": "deepseek/deepseek-chat",
        "fallbacks": ["deepseek/deepseek-reasoner"]
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
| `gateway.auth.mode: "token"` | 用 token 保护 API，防止未授权访问 |
| `channels.im.dmPolicy: "pairing"` | 私聊需要配对确认，仅限自己使用 |
| `channels.im.streaming: "partial"` | 流式输出，打字机效果 |
| `models.providers` | 支持多个模型提供商，这里用 DeepSeek |
| `agents.defaults.model.fallbacks` | 主力模型不可用时自动切备用，高可用 |

**为什么选 DeepSeek：** 国内直连、延迟低、API 价格实惠，V3 日常对话 + R1 深度推理组合性价比极高。

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

# 确认消息通道已连接
docker logs $(docker ps -q --filter name=openclaw-gateway) 2>&1 | grep -i "channel"
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

### 第 8 步：客户端配对

首次使用需要完成配对，确保只有自己能使用：

```bash
cd /opt/openclaw
docker compose run --rm openclaw-cli pairing list
docker compose run --rm openclaw-cli pairing approve <配对码>
```

配对完成后即可通过消息客户端与 AI 对话。

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
| `channels.im.dmPolicy` | `pairing` | 需配对确认 |
| `channels.im.streaming` | `partial` | 流式打字效果 |
| `tools.exec.security` | `deny` | 禁止执行命令（安全） |

---

## 相关链接

- [[从LLM到Agent Skill底层逻辑拆解]]
- [[Claude Code完全指南]]

**参考文档：**
- OpenClaw Docker 安装文档
- OpenClaw 消息通道配置文档
- OpenClaw 模型提供商配置文档
- OpenClaw 安全加固文档

---

> **L3 总结：** OpenClaw 的核心价值是把模型 API "翻译"成消息客户端的原生对话体验，同时保持数据完全自托管。部署本身不难，关键是配置文件要写对（Gateway 认证 + 通道对接 + 模型端点），以及处理好 SELinux 权限。推荐接入 DeepSeek，国内直连延迟低、价格实惠。一旦跑起来，就是一个 7×24 在线的私人 AI 助手，对话数据完全在自己手里。

---

## 小红书分享稿（审核优化版）

家里有台闲置服务器？手把手教你变成私人 AI 助手 🤖

很多人觉得"自己部署 AI"很难
其实用 Docker + OpenClaw，10 步走就能搞定

✅ DeepSeek V3 + R1 双模型配置
✅ 数据完全在自己服务器上，不经过任何第三方
✅ Web 界面可视化管理，7×24 在线
✅ 开机自启，重启自恢复

**为什么要自己部署而不直接用网页版？**
- 数据隐私：对话记录只在你的服务器上
- 成本可控：按 token 计费，比订阅制划算
- 随时可用：不依赖第三方服务稳定性
- 可以接入多个模型，灵活切换

**踩坑最多的地方：**
SELinux 权限 + 容器用户 uid 对齐
（Rocky Linux / CentOS 用户必看，其他教程基本不提这个）

完整 10 步教程在评论区，手把手带你跑起来 👇

\#DeepSeek \#Docker \#私有化部署 \#AI助手 \#Linux \#开源项目 \#程序员 \#服务器

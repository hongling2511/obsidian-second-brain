---
创建日期: 2026-03-17
标题: "从零搭建个人 AI 工作流：理解原理、善用工具、拥有基础设施"
slug: "build-personal-ai-workflow"
摘要: "一篇文章串联 AI 底层原理、Claude Code 实战技巧、订阅避坑、私有化部署到对话式运维，帮你搭建完整的个人 AI 工作流。"
分类: "tutorial"
标签: ["AI", "Claude Code", "OpenClaw", "Docker", "工作流", "LLM"]
博客状态: 草稿
tags: #博客
---

# 从零搭建个人 AI 工作流：理解原理、善用工具、拥有基础设施

过去几周，我从「大模型到底怎么工作」一路折腾到「在 Telegram 里用对话部署开源项目」。这篇文章把我的学习和实践串成一条线，分享给同样想搭建个人 AI 工作流的人。

整条路线分五步：

```mermaid
graph LR
    A[理解原理] --> B[搞定订阅]
    B --> C[掌握工具]
    C --> D[搭建基础设施]
    D --> E[对话式运维]

    style A fill:#e3f2fd,stroke:#1565c0,color:#000
    style B fill:#fff3e0,stroke:#e65100,color:#000
    style C fill:#e8f5e9,stroke:#2e7d32,color:#000
    style D fill:#f3e5f5,stroke:#6a1b9a,color:#000
    style E fill:#fce4ec,stroke:#c62828,color:#000
```

---

## 第一步：搞懂 AI 到底在干什么

很多人（包括之前的我）对大模型的理解停留在「它很聪明，能回答问题」。但要真正用好 AI，得先破除几个误解。

### 大模型不认识字

它本质上是一个巨大的数学函数，跑的全是矩阵运算。人类的文字要靠 Tokenizer（翻译官）转成数字才能喂给它。所以 Token 才是大模型处理文本的最基本单元，而不是「词」或「字」。

一个直观的数据：1 个 Token 大约等于 0.75 个英文单词，或 1.5-2 个汉字。**这就是为什么中文消耗 Token 更多。**

### 大模型没有记忆

你以为它记住了之前说的话？其实是程序每次都把历史对话打包重新发送。所谓的「记忆」只是 Context（临时记忆体），而且有上限——这就是 Context Window。

### 它不会主动「做事」

大模型只会输出「我想调用天气工具」这段文字，真正动手的是外部平台。它是出主意的军师，不是干活的工兵。

理解了这三点，整个 AI 技术栈就清晰了：

| 层级 | 概念 | 解决的痛点 |
|------|------|-----------|
| 底层 | LLM + Token | 让机器能处理语言 |
| 记忆层 | Context + Context Window | 让模型「记住」对话历史 |
| 指令层 | Prompt（User + System） | 让模型按要求输出 |
| 能力层 | Tool + MCP | 让模型感知和影响外部世界 |
| 自主层 | Agent | 让模型自主规划多步任务 |
| 定制层 | Agent Skill | 让 Agent 按你的私人规则干活 |

其中 MCP（Model Context Protocol）值得单独说一句：**它相当于 AI 界的 Type-C 接口**。以前每个平台接工具都要重新写代码，有了 MCP 统一标准，开发者只写一次就能到处用。这个标准正在快速普及。

---

## 第二步：搞定 Claude 订阅（少走弯路）

理解了原理，下一步是选工具。目前我的主力是 Claude，但订阅这件事坑不少。

### 支付

最省心的方案是**苹果内购**：美区 Apple ID + 礼品卡。礼品卡在支付宝 PockytShop 或 Apple 美区官网都能买。

虚拟信用卡也行，但卡段很关键——不是随便一张都能过。不想折腾可以试 bewild.ai，一站式解决支付问题。

**闲鱼买会员要谨慎**，翻车案例太多了。

### 网络环境

这是重中之重：

- **支付时**要求严格：住宅 IP 必须安排上，账单地址和 IP 所在地要一致，不一致直接风控拦截
- **日常使用**相对宽松：普通工具开增强模式即可，走虚拟网卡避免 DNS 泄漏

### 防封号

1. 新号别急着开 Pro，**先养号至少两周**
2. 别全程中文对话，英文更安全
3. 系统时区和语言改成美区对应的
4. 不要在北京时间活跃时段疯狂使用
5. 节点要干净：自建 > 共享，住宅 > 机房

---

## 第三步：用好 Claude Code

订阅搞定后，Claude Code 是目前我用过的最强 AI 编程工具。它不是聊天机器人——它能自己读代码、改代码、跑测试、部署上线。你只需要当甲方提需求。

### 三个核心心法

**1. 别追求一次完美，要追求试错速度**

AI 的价值不是一次性 100% 做对，而是光速输出 80%，然后通过测试验证循环逼近完美。**搭好反馈闭环比写完美提示词重要 100 倍。**

**2. 上下文管理 = 省钱 + 提智商**

Token 不是无限的。塞太多信息进去，AI 反而变笨。精简提示词 + 按需加载才是王道。

**3. 并行开发，效率翻倍**

一个 AI 不够用？用子代理 + Git 分支，同时让多个 Claude 干不同的活。

### 十个实用技巧

**入门级**

- **`claude.md` 是项目大脑**：放在根目录，每次对话自动加载。控制在 200-500 行，最重要的规则放最前面
- **`/init` 一键生成项目配置**：新项目第一件事就是跑这个
- **Plan Mode**：写代码前先进计划模式，花 1 分钟规划省 10 分钟返工

**进阶级**

- **Skills 技能系统**：把工作 SOP 写成 Markdown 放进 `.claude/skills/`，按需加载只占几十个 Token。**有 SOP 就有 Skill**
- **Sub-agents 子代理**：让主 AI 派小弟去干脏活累活。推荐三大子代理：研究员、代码审查员、QA 测试员
- **`/compact` 压缩上下文**：对话太长时一键压缩，防止「上下文腐烂」

**高阶级**

- **Git Worktrees 并行开发**：不同功能放不同分支文件夹，同时开多个实例
- **MCP 能力扩展**：让 AI 直接操作浏览器、调用外部软件。但注意有些 MCP 很吃 Token，成熟操作建议转成 Skills
- **Auto-research**：给 AI 一个优化指标，让它自己跑 A/B 测试、自我进化

### 避坑清单

- 别把完整 API 文档塞进 claude.md → 用 Skills 按需加载
- 别让 AI 重复犯错 → 让它把正确规则写进 claude.md
- 别只靠 AI 生成不验证 → 搭建截图循环 + TDD 测试
- AI 生成的支付/用户数据代码 → **绝对不能直接上线，必须人工审计**

---

## 第四步：搭建自己的 AI 基础设施

云端工具虽好，但数据在别人手里。如果你有一台闲置服务器（哪怕是最便宜的 VPS），完全可以搭建私有化的 AI 基础设施。

我用的方案是 **OpenClaw**——一个开源 AI Gateway，把 DeepSeek、通义千问等大模型统一接入各种终端。部署完成后你会得到：

- 私有 AI 助手 7×24 在线
- 支持多模型自动降级（主力挂了自动切备用）
- Web Dashboard 可视化管理
- **数据全程在自己服务器上，不依赖任何第三方**

### 核心部署步骤

完整流程 10 步，这里提炼最关键的几步：

**1. 创建数据目录并处理权限**

很多教程不提这步，但在 SELinux enforcing 模式下不做就会翻车：

```bash
mkdir -p /root/.openclaw/{workspace,credentials,agents}
chown -R 1000:1000 /root/.openclaw           # 容器内 node 用户 uid=1000
chcon -Rt svirt_sandbox_file_t /root/.openclaw # SELinux 上下文
```

**2. 手写配置文件**

跳过交互式向导，直接写 `openclaw.json`。核心是配好三件事：Gateway 认证、消息通道、模型端点。

推荐接入 DeepSeek：国内直连延迟低，V3 日常对话 + R1 深度推理，性价比极高。

```json
{
  "models": {
    "providers": {
      "deepseek": {
        "baseUrl": "https://api.deepseek.com",
        "apiKey": "你的API Key",
        "models": [
          { "id": "deepseek-chat", "name": "DeepSeek V3" },
          { "id": "deepseek-reasoner", "name": "DeepSeek R1" }
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
  }
}
```

**3. 启动并验证**

```bash
OPENCLAW_IMAGE="ghcr.io/openclaw/openclaw:latest" docker compose up -d openclaw-gateway
curl -fsS http://127.0.0.1:18789/healthz
```

### 踩坑记录

| 问题 | 原因 | 解决 |
|------|------|------|
| 容器内配置文件读不到 | SELinux 拦截 | `chcon -Rt svirt_sandbox_file_t` |
| Permission denied | 文件 owner 不对 | `chown -R 1000:1000` |
| JSON 解析失败 | 手写 JSON 格式错误 | `python3 -m json.tool` 验证 |
| 防火墙规则不生效 | 忘了 reload | `firewall-cmd --reload` |

---

## 第五步：用对话管理一切

OpenClaw 跑起来之后，最让我兴奋的不是聊天——而是**用对话部署开源项目**。

以前部署一个服务的流程：SSH 登录 → 查文档 → 写 docker-compose → 处理报错 → 配反代 → 配自启……

现在的流程：

```
我：帮我部署 sub2api，用 Docker，映射到 8080 端口

龙虾：好的，我来处理。正在拉取镜像…
      ✅ 镜像拉取完成
      正在创建容器…
      ✅ 容器已启动，端口 8080 已映射
      需要配置反代或开机自启吗？

我：加上开机自启

龙虾：✅ 已设置 restart: unless-stopped
```

整个过程没有一行命令是我手打的。

这个模式的本质是：**把「命令式运维」变成「意图表达」**。服务器不再是我要「登进去操作」的对象，而是 AI 帮我打理的基础设施。我保有完整控制权，只是操作方式变了。

理论上任何能 Docker 化的项目都可以这样部署：API 代理、订阅管理、自建密码库、数据看板……前提是接入的模型具备代码执行能力，且 `tools.exec` 配置为 `ask`（每次执行征询确认）。

---

## 写在最后

回顾这条路线：

1. **理解原理**——知道 Token、Context、Tool、Agent 分别在解决什么问题
2. **搞定订阅**——选对支付方式和网络环境，避免封号
3. **掌握工具**——用 Claude Code 的 Skills、Sub-agents、MCP 提升开发效率
4. **搭建基础设施**——Docker 部署 OpenClaw，拥有私有化 AI 助手
5. **对话式运维**——用自然语言管理服务器，降低运维摩擦

每一步都不复杂，但串起来就是一个完整的个人 AI 工作流。

最大的感受是：**AI 的价值不在于回答多少问题，而在于你能让它接入多深的工作场景**。从写代码到管服务器，从读文档到部署项目——把 AI 嵌入日常工作流的每个环节，才是真正的效率跃迁。

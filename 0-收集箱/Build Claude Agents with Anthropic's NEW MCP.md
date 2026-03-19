---
type: youtube
title: "Build Claude Agents with Anthropic's NEW MCP"
channel: "[[Tyler AI]]"
url: https://www.youtube.com/watch?v=MlXTzhZkKGY
video_id: MlXTzhZkKGY
date_watched: 2026-03-19
date_published: 2024-12-04
duration: "16:06"
content_type: tech_tutorial
one_line_summary: "本视频演示了如何通过配置官方预置及自定义编写的 [[MCP]] 服务器，让 [[Claude Desktop]] 具备联网、文件管理和查询天气的 Agent 能力 [1-4]。"
rating: 4
rating_detail:
  信息密度: 4
  实用性: 5
  新颖性: 4
related_concepts:
  - "[[MCP (Model Context Protocol)]]"
  - "[[MCP Server]]"
  - "[[MCP Client]]"
  - "[[Claude Desktop]]"
  - "[[claude_desktop_config.json]]"
  - "[[AI Agent]]"
has_actions: true
tags:
  - claude
  - claudemcp
  - anthropic
  - claudeai
  - crewai
  - desktopagents
  - aiagents
  - aiagents
  - claudeagents
  - tylerai
  - tylerai
  - buildanything
  - buildclaudeagents
  - howtobuildclaudeagents
---

# Build Claude Agents with Anthropic's NEW MCP

---
tags:
  - 视频笔记
  - tech_tutorial
信息密度: 4/5
实用性: 5/5
新颖性: 4/5
---

## 一句话总结
本视频演示了如何通过配置官方预置及自定义编写的 [[MCP]] 服务器，让 [[Claude Desktop]] 具备联网、文件管理和查询天气的 Agent 能力 [1-4]。

## 目标受众与前置知识
- **适合谁看**：希望在本地构建 AI Agent 的开发者或进阶技术爱好者（推断）。
- **前置知识**：[[JSON]] 配置文件修改（推断）、基本命令行/终端操作（推断）、[[Python]] 基础编程（推断）。

## 核心观点
1. **[[MCP]] 协议通过标准化降低了 AI 代理集成的复杂性**
   - 为什么重要：它允许开发者用统一的标准暴露数据，为 AI 客户端扩展能力 [1]。
   - 依据：讲者原话指出该协议旨在“replace the need for custom Integrations”（取代对自定义集成的需求）并“reduce complexity and maintenance overhead”（降低复杂性和维护开销） [1]。
2. **官方预置的 [[MCP Servers]] 提供了开箱即用的强大能力**
   - 为什么重要：无需编写复杂代码，只需配置 JSON 文件即可让 [[Claude Desktop]] 获得本地环境控制或网络搜索权限 [5, 6]。
   - 依据：讲者演示了接入本地文件系统，成功让大模型读取并列出了 Downloads 文件夹中的内容（屏幕展示/讲者原话：137 files, 15 directories），以及统计 Desktop 的截图数量（屏幕展示/讲者原话：总共 84 files, potential screenshot... a total of 100 files） [3, 7, 8]。
3. **开发者可以基于 [[Python]] 自由创建自定义 [[MCP Servers]]**
   - 为什么重要：当预置服务器无法满足需求时，开发者可以编写代码连接任意外部 API（如天气服务）来实现专属功能 [9, 10]。
   - 依据：讲者展示了编写调用 [[OpenWeatherMap API]] 的服务器代码，并在客户端中成功查询了 Tampa 的天气（屏幕展示/讲者原话：当前温度约 64°/65°）及未来 3 天的预测 [4, 11]。

## 概念关系
- [[Claude Desktop]] → [[MCP Client]]：[[Claude Desktop]] 作为主机端，扮演了 [[MCP Client]] 的角色 [5]。
- [[MCP Client]] → [[MCP Servers]]：客户端向服务器发起请求，以获取上下文、提示词以及各类工具 [5]。
- [[Anthropic]] → [[MCP]]：[[MCP]] (Model Context Protocol) 是由 [[Anthropic]] 推出的一项新协议技术 [1, 12]。
- [[MCP Servers]] ↔ [[Tools]]：服务器本质上是包含了各种工具（如读取文件、获取天气）的集合，供客户端调用执行 [6, 11, 12]。

## 详细笔记
### 介绍 [[MCP]] 与架构概述
- 讲者（所属频道推断为 [[Tyler AI]] 的 [[Tyler]]）介绍了如何利用 [[Anthropic]] 的 [[MCP]] 协议来构建 [[Claude]] AI Agent [1]。
- [[MCP]] 的核心理念是通过标准化的服务器暴露数据，从而取代繁琐的自定义集成流程 [1]。
- 该技术的架构主要包含作为 [[MCP Client]] 的主机端（如你的电脑上运行的 [[Claude Desktop]]），以及负责提供上下文和工具的 [[MCP Servers]] [5]。

### 安装与配置 [[Claude Desktop]] 及预置服务器
- [[GitHub]] 上目前提供了一系列官方精选的预置服务器，涵盖了文件系统、[[PostgreSQL]]、[[Slack]]、[[Puppeteer]] 和 [[Brave search]] 等 [5]。
- 讲者演示了针对 [[Mac]] 和 [[Windows]] 平台下载安装 [[Claude Desktop]] 的流程 [12]。
- 为了连接服务器，必须在特定的系统目录下通过终端命令创建 `claude_desktop_config.json` 配置文件 [6]。

### 演示预置服务器一：[[Brave search]]
- 讲者在 [[Cursor IDE]] 中打开上述 JSON 配置文件准备编辑 [6, 13]。
- 演示了在 [[Brave]] 开发者网站注册并获取免费 API Key 的过程 [2, 13]。
- 在未配置服务器前，询问 [[Claude]] 什么是 MCP 会导致失败；而将 [[Brave search]] 配置和 API Key 写入 JSON 并重启客户端后，成功触发了工具调用，并从网络上返回了正确定义 [2, 14]。

### 演示预置服务器二：本地文件系统 (File System)
- 讲者将文件系统服务器的配置追加到 JSON 文件中，并赋予了 Desktop 和 Downloads 两个本地路径的访问权限 [3, 7]。
- 演示功能一：请求列出下载目录的所有文件，大模型准确识别并列出了包括 [[Crew AI]]、[[LM Studio]] 在内的相关压缩包和 JSON 文件（屏幕展示/讲者原话：137 files, 15 directories） [3]。
- 演示功能二：请求统计桌面上的截图数量，大模型通过工具搜索并返回了统计结果（屏幕展示/讲者原话：总共 84 files，包含潜在截图共 100 files） [8]。
- 演示功能三：成功让大模型将桌面上名为 `local_flask.png` 的（推断与 [[Flask]] 相关的）图片移动到了下载目录中 [8, 9]。

### 开发自定义 MCP 服务器：[[OpenWeatherMap API]]
- 讲者提到预置服务器仓库目前虽然增长迅速（讲者原话：昨天 2500 Stars，不到 24 小时增长 600 达到 3100 Stars），但功能依然有限，因此展示了如何自建服务器 [9]。
- 开发自定义服务器需要大于 3.10 版本的 [[Python]]，讲者推荐在 [[Mac]] 上通过 [[Brew]] 安装 [[UV]] 工具来初始化项目 [10]。
- 讲者展示了连接 [[OpenWeatherMap API]] 的代码结构，包含定义属性和执行抓取数据的 `get_forecast` 工具函数 [11, 15]。
- 提到了启动该服务器的环境参数可能涉及 `uv`、`npx` 或 `pip`，将 API Key 填入 `.env` 文件并更新 JSON 配置文件重启后，成功查询到了 Tampa 的气温（讲者原话：约 64-65°） [4, 10, 16]。

### 讲者社区与课程宣传
- 讲者在视频结尾宣传了其持续增长的 AI 学校社区 [17]。
- 社区内容包含详尽的 [[Crew AI]] 课程，以及结合了无代码自动化工具 [[n8n]] 和 [[Crew AI]] 的免费教学内容 [17]。
- 讲者还提到社区每周会举办直播环节和咖啡时间供成员交流 [17]。

## 金句亮点
- "MCP just enables developers to expose data through standardize MCP servers and connect applications to these servers... replace the need for custom Integrations and then reduce complexity and maintenance overhead." — 概念定义 / 价值 [1]
- "You just have a desktop application that you can talk to once you give it the tools then it is just an AI agent to help you do whatever you need to do." — 核心洞察 / 价值 [8]

## 行动建议
- **配置预置搜索服务器**：安装 [[Claude Desktop]]，在终端创建并使用编辑器打开 `claude_desktop_config.json`，填入注册好的 [[Brave search]] API Key 配置并重启客户端 [2, 6, 12-14]。
  - **关联观点**：2
  - **验证标准**：在客户端中询问最新网络资讯，观察其是否会提示 "running Brave web search" 并成功返回联网搜索结果 [14]。
- **开发自定义天气服务器**：确保安装了 [[Python]] 3.10+ 和 [[UV]]，获取 [[OpenWeatherMap API]] 的密钥，编写包含 `get_forecast` 工具函数的自定义服务器代码并在 JSON 中配置对应运行路径 [10, 11, 15, 16]。
  - **关联观点**：3
  - **验证标准**：重启客户端后，向其提问指定城市的天气，能够成功触发工具并返回未来 3 天的具体温度与天气状况预测 [4, 16]。

## 技术栈与环境要求
- **核心技术**：[[MCP]] (Model Context Protocol), [[Claude Desktop]], [[Cursor IDE]], [[Brave Search]], [[OpenWeatherMap API]], [[Python]], [[uv]] [1-4]
- **环境要求**：
  - 操作系统：Mac 或 Windows [5]
  - 软件版本：[[Python]] 版本需大于 3.10 [4]
  - 依赖项：需安装 [[Claude Desktop]] 客户端和 [[uv]] 包管理器 [4, 5]
- **前置技能**：未明确提及

## 步骤拆解

1. **安装 Claude 客户端**
   - 具体操作描述：下载并安装适用于 Mac 或 Windows 的 [[Claude Desktop]] 应用程序 [5]。
   - 关键代码/命令：未明确提及
   - 注意事项：未明确提及

2. **创建与编辑配置文件**
   - 具体操作描述：通过终端创建 `claude_desktop_config.json` 文件，并使用 [[Cursor IDE]] 或其他文本编辑器打开以便后续添加服务器配置 [3, 6]。
   - 关键代码/命令：未明确提及（视频仅展示在终端粘贴了未指明的命令） [6]
   - 注意事项：每次修改配置文件并保存后，必须完全退出并重新启动 [[Claude Desktop]] 才能生效 [7]。

3. **配置预置 MCP 服务器（以 Brave Search 为例）**
   - 具体操作描述：在 [[Brave Search]] 官网注册免费账号，前往 Subscriptions 选项卡获取免费 API 密钥，并将密钥和相关配置粘贴入 `claude_desktop_config.json` 中 [3, 8]。
   - 关键代码/命令：未明确提及
   - 注意事项：未明确提及

4. **配置本地文件系统服务器**
   - 具体操作描述：在 JSON 配置文件中追加文件系统（file system）服务器配置，并为其分配允许访问的本地特定文件路径（如桌面或下载文件夹的路径） [9, 10]。
   - 关键代码/命令：未明确提及
   - 注意事项：测试时需在客户端聊天界面中点击允许（allow tool）以授权其操作特定文件 [11, 12]。

5. **创建自定义 MCP 服务器（以天气服务为例）**
   - 具体操作描述：使用 [[uv]] 工具创建一个名为 `weather-service` 的基础项目。注册并获取 [[OpenWeatherMap API]] 密钥，存入 `.env` 文件。随后需编写自定义代码以定义列出数据源、读取资源、以及定义名为 `get_forecast` 的天气获取工具 [4, 13]。
   - 关键代码/命令：Mac 环境安装依赖的命令为 `brew install uv`；创建项目的初始命令涉及 `uvx`（完整命令未明确提及） [4]。
   - 注意事项：注册开放天气账号后，必须前往注册邮箱点击确认邮件，否则 API 无法正常工作 [14]。

6. **运行并集成自定义服务器**
   - 具体操作描述：在 `claude_desktop_config.json` 中配置该自定义服务器，指定运行命令（如使用 uv 或 npx）、自定义服务器在本地机器上的绝对目录路径，以及传入 API 密钥 [15]。
   - 关键代码/命令：未明确提及
   - 注意事项：未明确提及

## 常见坑与解决方案

- **问题描述**：修改了配置文件后，新添加的工具/服务器在客户端中没有生效 [7]。
  - 解决方案：每次修改 `claude_desktop_config.json` 后，必须保存文件、完全退出（exit out）[[Claude Desktop]]，然后再重新打开 [7]。

- **问题描述**：[[OpenWeatherMap API]] 获取不到数据，接口不工作 [14]。
  - 解决方案：必须找到系统发送的确认邮件并完成邮箱验证验证流程 [14]。

- **问题描述**：存在多个工具时，Claude 可能会调用错误的工具（例如查天气时，默认去调用 [[Brave Search]] 进行网络搜索，而不是调用自定义的本地天气工具） [16]。
  - 解决方案：在提问时提供更明确、具体的指令，直接指定使用的工具名称（例如：“can you get the weather in Tampa for me using the weather tool”） [16]。

## 最佳实践
未明确提及

## 关键概念

### [[MCP (Model Context Protocol)]]
- **定义**：一种使开发者能通过标准化的服务器暴露数据，并将应用程序连接到这些服务器的新协议 [1]。
- **视频上下文**：作者指出使用它可以取代自定义集成，降低复杂性和维护成本，并在本地安全地使用各种工具 [1], [2]。
- **为什么重要**：它是使得像 Claude 这样的应用能够与本地或外部数据进行标准化交互的基础底层技术 [1]。
- **关联概念**：扩展 → [[MCP Server]]

### [[MCP Server]]
- **定义**：包含上下文、提示词和工具的组件，用于连接客户端并返回处理后的数据 [3]。
- **视频上下文**：作者展示了预置的服务器（如 Brave search、File system）的配置，以及如何用 Python 从零创建一个自定义的天气服务器 [3], [4], [5], [6], [7]。
- **为什么重要**：它是实际连接 API、执行具体任务（如移动文件、获取天气）并将结果发送回客户端的核心执行组件 [5], [8], [9]。
- **关联概念**：依赖 → [[MCP (Model Context Protocol)]]

### [[MCP Client]]
- **定义**：作为主机的应用程序，连接到 MCP 服务器以接收数据和工具调用 [3]。
- **视频上下文**：作者提到通常我们的电脑或特定软件（如 Claude Desktop）就是作为一个 MCP 客户端存在 [3]。
- **为什么重要**：它是用户直接交互的入口界面，负责向服务器端发起请求 [3]。
- **关联概念**：依赖 → [[MCP (Model Context Protocol)]]

### [[Claude Desktop]]
- **定义**：在本视频语境中作为具体 MCP Client 实例使用的桌面应用程序 [3], [10]。
- **视频上下文**：作者演示了下载安装此应用，并在配置后通过聊天界面让它搜索网络、查看下载文件夹、移动本地文件以及查询特定城市天气 [10], [11], [12], [6], [13]。
- **为什么重要**：结合 MCP 工具后，它从单纯的聊天机器人转变为了一个可以操作本地文件和获取外部实时数据的平台 [14]。
- **关联概念**：属于 → [[MCP Client]]

### [[claude_desktop_config.json]]
- **定义**：用于告诉 Claude Desktop 应该连接哪些 MCP 服务器以及分配哪些权限（或 API 密钥）的特定配置文件 [15]。
- **视频上下文**：作者在终端中创建此文件，并在其中编写 JSON 代码以接入 Brave Search 的 API 密钥、指定允许访问的本地文件路径，以及配置天气服务器的启动参数 [15], [16], [5], [17]。
- **为什么重要**：如果没有这个正确命名的配置文件，Claude Desktop 就无法识别工具，也会提示无权访问或无法执行指令 [15], [16], [14]。
- **关联概念**：依赖 → [[Claude Desktop]]

### [[AI Agent]]
- **定义**：在配备了特定工具和访问权限后，能够帮助用户自动执行具体操作任务的智能实体 [1], [14]。
- **视频上下文**：作者在展示通过配置使得 Claude 可以自动整理桌面文件、联网查数据后，强调它本质上变成了一个帮助用户做事的 AI Agent [1], [14], [2]。
- **为什么重要**：它是应用 MCP 协议和配置各项工具后所达成的最终目标形态 [1], [2]。
- **关联概念**：依赖 → [[Claude Desktop]]

## 概念关系图
- [[MCP Server]] → 依赖 → [[MCP (Model Context Protocol)]]
- [[MCP Client]] → 依赖 → [[MCP (Model Context Protocol)]]
- [[Claude Desktop]] → 属于 → [[MCP Client]]
- [[claude_desktop_config.json]] → 依赖 → [[Claude Desktop]]
- [[claude_desktop_config.json]] → 关联 → [[MCP Server]]
- [[AI Agent]] → 依赖 → [[Claude Desktop]]

## 行动项

- [ ] **下载并安装 Claude desktop app** [1]
  - 目的：作为运行 MCP client 和安装 MCP servers 的基础前提 [1, 2]
  - 难度：简单 [1]
  - 预估时间：未明确提及
  - 相关工具或资源：Claude desktop app 官网安装包 [1]

- [ ] **创建 Claude desktop 配置文件** [3]
  - 目的：配置和添加不同的 MCP servers，使 Claude 知道该连接哪些服务器来执行特定任务 [3]
  - 难度：未明确提及
  - 预估时间：未明确提及
  - 相关工具或资源：终端 (Terminal)、IDE 或文本编辑器 (如 Cursor IDE)、claude_desktop_config.json [3, 4]

- [ ] **注册 Brave search API 并配置该 MCP server** [4, 5]
  - 目的：赋予 Claude desktop 执行网页搜索和查询网络信息的能力 [4, 5]
  - 难度：未明确提及
  - 预估时间：未明确提及
  - 相关工具或资源：Brave search 官网、Brave search API key [4, 5]

- [ ] **重启 Claude desktop 应用程序** [6]
  - 目的：确保在配置文件（claude_desktop_config.json）中新增或修改的 MCP server 配置能够生效 [6]
  - 难度：未明确提及
  - 预估时间：未明确提及
  - 相关工具或资源：Claude desktop [6]

- [ ] **配置 File system MCP server 并设定允许访问的本地路径** [7, 8]
  - 目的：允许 Claude 读取、写入、列出目录或移动本地特定文件夹（如 Downloads 或 Desktop）内的文件 [7, 8]
  - 难度：未明确提及
  - 预估时间：未明确提及
  - 相关工具或资源：File system MCP server [7]

- [ ] **安装 Python 3.10+ 与 UV** [9]
  - 目的：满足从头构建自定义 MCP server（如天气服务）所需的基础环境依赖 [9]
  - 难度：未明确提及
  - 预估时间：未明确提及
  - 相关工具或资源：Python 3.10+、UV（Mac 用户可通过 Homebrew 安装）[9]

- [ ] **注册 OpenWeatherMap 并配置 API key 环境变量** [9, 10]
  - 目的：获取并验证 API key 以便自定义的天气 MCP server 能够调取并返回实时的天气预报数据 [9, 10]
  - 难度：未明确提及
  - 预估时间：未明确提及
  - 相关工具或资源：openweathermap.org、.env 文件 [9, 10]

## 附件

- 思维导图：[[_附件/mindmaps/MlXTzhZkKGY.json]]
- 学习指南：[[_附件/MlXTzhZkKGY_study_guide.md]]

---
*自动生成于 2026-03-19 22:06 | [原始视频](https://www.youtube.com/watch?v=MlXTzhZkKGY)*

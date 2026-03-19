---
type: youtube
title: "LangGraph + CrewAI: Crash Course for Beginners [Source Code Included]"
channel: "[[aiwithbrandon]]"
url: https://www.youtube.com/watch?v=5eYg1OcHm5k
video_id: 5eYg1OcHm5k
date_watched: 2026-03-19
date_published: 2024-05-01
duration: "53:34"
content_type: tech_tutorial
one_line_summary: "本教程展示了如何结合 [[LangGraph]] 和 [[CrewAI]] 构建连接 [[Gmail]] 自动读取并草拟回复的本地自动化工具。"
rating: 4
rating_detail:
  信息密度: 4
  实用性: 5
  新颖性: 4
related_concepts:
  - "[[LangGraph]]"
  - "[[Graph]]"
  - "[[CrewAI]]"
  - "[[Agent]]"
  - "[[Node]]"
  - "[[Edge]]"
  - "[[Conditional Edges]]"
  - "[[State]]"
  - "[[Task]]"
  - "[[Tool]]"
  - "[[Tavily]]"
has_actions: true
tags:
  - aiagents
  - chatgpt4
  - artificialintelligencenews
  - bestautonomousaiagents
  - artificialintelligence
  - crewai
  - crewaitutorial
  - crewailangchain
  - crewagents
  - crewassistant
  - autonomousagents
  - stockagent
  - autonomousaiagents
  - autogen
  - autogentutorial
  - autogencreateaiagents
  - aiagent
  - autogenstepbystepguide
  - chatgptprompts
  - langgraphtutorial
  - langgraphagents
  - langgraphmultiagent
  - langgraphrag
  - langgraphvscrewai
  - langgraphollama
---

# LangGraph + CrewAI: Crash Course for Beginners [Source Code Included]

---
tags:
  - 视频笔记
  - tech_tutorial
信息密度: 4/5
实用性: 5/5
新颖性: 4/5
---

## 一句话总结
本教程展示了如何结合 [[LangGraph]] 和 [[CrewAI]] 构建连接 [[Gmail]] 自动读取并草拟回复的本地自动化工具。

## 目标受众与前置知识
- **适合谁看**：AI 开发者、希望实现邮件处理自动化的人员（推断）。
- **前置知识**：[[Python]] 基础、基本的图论（Graph Theory）概念、[[CrewAI]] 基础操作。

## 核心观点
1. **[[LangGraph]] 使 [[CrewAI]] 能够基于特定条件智能启动**
   - 为什么重要：开发者可以构建无需人工干预、在后台响应特定条件（如市场变化、新推文、新邮件）的自动化工具。
   - 依据：讲者举例说明，若监控到 [[Apple]] 股票价格上涨 5%（讲者原话），条件触发后便可启动金融分析 Crew 去撰写报告并建议买卖。

2. **理解图论（Graph Theory）是提升 AI 开发者能力的关键**
   - 为什么重要：掌握图的基础运作逻辑，能打开开发者的思路，为以前没有工具解决的问题提供新的解决路径。
   - 依据：讲者提到大学计算机科学中数据结构与算法会教授图论，理解节点与边的交互能为开发者增加一个新的强大工具。

3. **[[State]]（状态）管理是跨节点安全共享与更新信息的基石**
   - 为什么重要：允许程序记住过去执行过的操作（例如已查看过哪些邮件、已写了哪些草稿），从而避免重复处理冗余任务。
   - 依据：讲者在代码演示中展示了使用双星号（**）扩展操作，严格只覆盖更新特定属性（如新增的邮件 ID），而不干扰其他状态数据。

## 概念关系
- [[LangGraph]] → [[CrewAI]]：[[LangGraph]] 作为工作流编排引擎，通过条件判断触发并管理整个 [[CrewAI]] 代理团队的执行。
- [[Node]] ↔ [[Edge]]：[[Node]] 代表要执行的具体动作，[[Edge]] 代表节点之间的单向或双向连接，决定工作流的移动路径。
- [[Node]] → [[State]]：[[Node]] 负责在执行完自身逻辑后，更新当前工作流的 [[State]] 并传递给下一个节点。

## 详细笔记
### 1. 简介与演示
- 讲者 Brandon 介绍如何结合 [[LangGraph]] 和 [[CrewAI]] 构建邮件自动化工具。
- 工具连接到 [[Gmail]]，提取新邮件并自动起草回复。
- 效果演示：针对询问工具和 [[YouTube]] 赞助的两封测试邮件，系统自动阅读并生成了相关的待发送草稿。

### 2. LangGraph 的应用场景
- **股票分析**：当监控到 [[Apple]] 股票出现如 5% 的上涨（讲者原话），触发 Crew 进行分析并发出警报；条件不满足则继续等待。
- **实时 Newsletter**：监控 Elon Musk 在 [[X]] 上的最新推文，一旦有新推文则触发 Crew 撰写新闻简报，否则等待 30 秒（讲者原话）。
- **邮件自动化**：监控收件箱，有新邮件则执行起草流程。

### 3. LangGraph 核心架构与可视化
- 借助 [[Excalidraw]]，讲者可视化了构建图的四个核心术语：
  - **[[Node]]（节点）**：执行的动作（检查邮件、等待、写入草稿）。
  - **[[State]]（状态）**：记忆过去操作的能力（已读邮件 ID、待办邮件）。
  - **[[Edge]]（边）**：节点间的连接。
  - **[[Graph]]（图）**：节点与边的集合。
- 引入“条件边（Conditional Edges）”作为决策树，判断如“是否有新邮件”，决定分支走向。
- 演示了 [[Python]] 中使用 `**` 语法覆盖更新状态数据。

### 4. CrewAI 代理与任务解析
- 代理（Agents）由代码贡献者 xia 设计提示词与结构：
  - **Filter Agent**：过滤非必要邮件（如推广、新闻通讯），只保留真实邮件，不允许委派任务给其他代理。
  - **Action Agent**：分析邮件上下文风格，提取线索 ID、总结、沟通风格和发送对象。
  - **Writer Agent**：被赋予三个工具（联网搜索的 [[Tali]] 工具/也称 tavali.com、重新获取邮件线程工具、自定义的 Create Draft 工具）以执行最终邮件起草。

### 5. Google 认证与环境配置
- 必须在 [[Google Cloud Platform]] 中创建新项目（演示中命名为 "YouTube crew Ai and Lang graph"），并生成 OAuth 2.0 桌面应用程序凭证。
- 下载凭证必须重命名为 `credentials.json`，并严格强调必须将其加入 `.gitignore`，防止泄露到 [[GitHub]]。
- 需要在云平台手动启用 [[Gmail API]]。
- 配置 `.env` 文件填入自身邮箱、[[Tali]] API 密钥（讲者原话：免费版每月 1000 次调用）以及 [[OpenAI]] 密钥。提及搜索工具也可换为 [[Serper]] 或 [[DuckDuckGo]]。

### 6. 环境安装与系统运行
- 建议无论是 [[Linux]] 还是 [[Windows]] 系统，都使用 [[Conda]] 创建环境以方便管理。
- 演示使用 [[Conda]] 创建名为 `crew AI Lang graph` 的环境，并指定 [[Python]] 3.11 版本（讲者原话）。
- 使用 [[Pip]] 安装 `requirements.txt` 中的依赖。
- 运行 `python main.py` 时，首次需在浏览器授权 Google 访问，随后系统将在终端打印分析、过滤、[[Tali]] 检索及在 [[Gmail]] 中创建草稿的全过程，完成单次流转后自动进入 30 秒等待循环。

## 金句亮点
- “instead of you and I manually kicking off our crew every time we want to do this support we could actually have this crew respond to market conditions” — 知识点提取 / 阐明了结合两款工具实现自动化响应的核心价值。
- “once you kind of understand graph Theory your mind opens up to understanding a bunch of different problems that you might not have already had like a tool to solve” — 观点表达 / 强调了底层理论对扩展开发者解题思维的价值。

## 行动建议
- **做项目凭证配置**：在 [[Google Cloud Platform]] 中创建一个新项目并启用 [[Gmail API]]，生成 OAuth 2.0 桌面应用客户端 ID，下载后重命名为 `credentials.json` 并立即将其添加到 `.gitignore` 文件中。
- **关联观点**：1
- **验证标准**：本地项目目录中存在正确命名的凭证文件，且通过 Git 状态检查确认该文件未被版本控制系统追踪。

- **做环境初始化部署**：使用终端运行 `conda create -n crewAILangGraph python=3.11` 创建新环境，激活后执行 `pip install -r requirements.txt` 安装所需依赖库。
- **关联观点**：1
- **验证标准**：终端能成功激活对应环境，并且在运行 `python main.py` 时不会因缺少库而报错，成功弹出 Google 授权验证页面。

## 技术栈与环境要求
- **核心技术**：`[[LangGraph]]`、`[[CrewAI]]`、`[[Python]]`、`[[Gmail API]]`、`[[Tavily]]`、`[[OpenAI]]`、`[[Conda]]` [1-5]。
- **环境要求**：操作系统未明确提及具体版本（仅提到可以通过 Linux 或 Windows 运行 `[[Conda]]`），软件版本要求 Python 3.11，依赖项通过 `requirements.txt` 管理 [4, 6, 7]。
- **前置技能**：基础软件开发知识（如图论中节点与边的基础概念）、`[[Python]]` 基础语法、`[[CrewAI]]` 基础操作经验 [8-10]。

## 步骤拆解
1. **获取并配置 Google 凭证**
   - 具体操作描述：在 Google Cloud Platform 中创建新项目，选择创建 OAuth 2.0 桌面端客户端 ID（Desktop application）。生成后下载 JSON 文件，将其重命名为 `credentials.json`，并手动启用 `[[Gmail API]]` [1, 11-18]。
   - 关键代码/命令：未明确提及
   - 注意事项：切勿将该 JSON 文件上传至 GitHub，必须将其加入 `.gitignore` 文件中 [16]。

2. **配置环境变量**
   - 具体操作描述：在项目的 `.env` 文件中更新发件人的电子邮箱地址；在 `[[Tavily]]` 官网注册获取免费的 API Key 并填入；生成并配置 `[[OpenAI]]` 的 API Key [2, 3, 18, 19]。
   - 关键代码/命令：未明确提及
   - 注意事项：环境变量文件包含了极其敏感的信息，必须妥善保管以防凭证泄露 [20]。

3. **搭建本地运行环境**
   - 具体操作描述：使用 `[[Conda]]` 创建指定 Python 版本的虚拟环境，切换进入该新环境，并通过 pip 命令安装项目中列出的所有依赖包 [4, 6, 7, 21, 22]。
   - 关键代码/命令：`conda create -n crewAI-LangGraph python=3.11`，`pip install -r requirements.txt` [4, 7]。
   - 注意事项：未明确提及

4. **运行与授权验证**
   - 具体操作描述：通过命令行执行主程序以启动 `[[LangGraph]]` 工作流和 `[[CrewAI]]`。首次运行时会自动触发谷歌的 OAuth 授权拦截，需要手动授权允许工具操作邮箱 [7, 23, 24]。
   - 关键代码/命令：`python main.py` [7]。
   - 注意事项：初次运行必须在弹出的授权页面点击同意许可，允许本地工具访问 Google 账号，否则无法拉取或写入邮件草稿 [23, 24]。

## 常见坑与解决方案
- **问题描述**：将用于验证的谷歌凭证文件意外泄露给公众 [15, 16]。
  - 解决方案：必须确保在 `.gitignore` 文件中包含 `credentials.json` 的文件名 [16]。
- **问题描述**：本地项目没有权限调用拉取邮件和写入草稿的功能 [1, 18]。
  - 解决方案：必须在 Google Cloud Console 中主动搜索并启用（Enable） `[[Gmail API]]` [1, 18]。
- **问题描述**：第一次运行应用时流程卡住，提示需要访问 Gmail 账号 [23]。
  - 解决方案：按照应用或浏览器提示手动点击同意（Consent），允许该工具访问 Google 账号权限 [23, 24]。

## 最佳实践
- **推荐做法**：在编写 `[[LangGraph]]` 代码前，先使用可视化工具（如 Excalidraw）绘制出图（Graph）的节点（nodes）与边（edges），理清整体流程后再将其翻译为实际代码 [25, 26]。
- **推荐做法**：在节点中更新状态（State）时，利用 Python 的 `**state` 语法对当前状态字典进行解包，仅向后追加并覆盖需要变动的特定属性（如 `emails`），从而安全地保留并向后传递无需修改的其余属性 [27-32]。
- **反模式**：未明确提及

## 关键概念

### [[LangGraph]]
- **定义**：一个允许在特定条件满足时智能地启动 AI 团队（Crew）的工作流框架 [1]。
- **视频上下文**：作者使用它来持续监控用户的 Gmail 收件箱，设定流程以便在发现新邮件时触发自动化草拟回复的动作 [2, 3]。
- **为什么重要**：它使得开发者能够构建可以根据实时条件（如股票变化、新推文或新邮件）在后台自动运行并响应的“设置后即忘”（set and forget）的工具 [4, 5]。
- **关联概念**：扩展 → [[Graph]]

### [[CrewAI]]
- **定义**：一个通过组合多个代理（Agents）、任务（Tasks）和工具（Tools）来协同处理复杂业务的 AI 框架 [6]。
- **视频上下文**：在视频中，它被用作核心引擎，去分析从 Gmail 拉取的邮件内容、过滤垃圾信息、提取关键需求并自动写出草稿 [7-9]。
- **为什么重要**：通过让拥有不同职责的多个 AI 代理协作，能够显著提升自动化流程的处理逻辑和生成质量 [10]。
- **关联概念**：包含 → [[Agent]]

### [[Graph]]
- **定义**：由多个节点（Nodes）和边（Edges）组成的集合 [11]。
- **视频上下文**：作者在代码中实例化并编译它（workflow），用于定义和运转整个邮件处理应用的状态流转逻辑 [12-14]。
- **为什么重要**：它提供了一种类似数据结构中图论的思维模型，帮助开发者结构化地定义复杂应用的执行路径 [15, 16]。
- **关联概念**：包含 → [[Node]]

### [[Node]]
- **定义**：在图（Graph）中代表我们想要执行的不同操作或动作（Actions） [17, 18]。
- **视频上下文**：例如“检查新邮件（check emails）”、“等待下一次运行（wait for next run）”以及“启动 CrewAI 草拟回复（draft responses）”都被设定为工作流中的具体节点 [19-21]。
- **为什么重要**：它是构成工作流执行逻辑的基础功能单元，并且负责在执行动作后更新系统的状态（State） [22, 23]。
- **关联概念**：属于 → [[Graph]]

### [[Edge]]
- **定义**：两个节点之间的连接，用于定义从一个动作移动到另一个动作的路径 [17, 24]。
- **视频上下文**：作者通过定义单向或双向的边，例如从“草拟回复”节点连接到“等待下一次运行”节点，来控制代码的流转方向 [24-26]。
- **为什么重要**：它决定了节点操作之间的执行先后顺序，是建立整个工作流闭环的关键通信渠道 [25, 27]。
- **关联概念**：扩展 → [[Conditional Edges]]

### [[Conditional Edges]]
- **定义**：基于特定条件判断（如布尔值）来决定下一步连接到哪个节点的特殊连接边 [28, 29]。
- **视频上下文**：视频中用它在“检查邮件”节点后做判断：如果有新邮件（True），则跳转到“草拟回复”节点；如果没有（False），则跳转到“等待”节点 [28, 29]。
- **为什么重要**：它使工作流具备了像决策树一样的动态分支判断能力，能根据当前状况做出不同反应 [29, 30]。
- **关联概念**：属于 → [[Edge]]

### [[State]]
- **定义**：在工作流中用于记忆过去已执行操作和存储当前数据的能力 [17, 31]。
- **视频上下文**：在应用中，它被用来记录“已检查的邮件ID”、“当前抓取的新邮件”以及“需要采取行动的邮件” [31]。状态会在各个节点之间传递，并在节点执行完毕后被覆盖和更新 [32-34]。
- **为什么重要**：它是不同孤立节点之间共享信息、维持工作流上下文并避免重复处理（如重复读取同一封邮件）的核心机制 [35-37]。
- **关联概念**：未明确提及

### [[Agent]]
- **定义**：在 CrewAI 中具有特定角色设定、目标和背景故事的执行代理 [38, 39]。
- **视频上下文**：视频创建了过滤代理（Filter Agent）、动作提取代理（Action Agent）和回复撰写代理（Writer Agent）来分工处理收件箱 [38-40]。
- **为什么重要**：通过赋予明确的人设与职能限制，可以引导大语言模型更专注、更专业地完成被分配的特定工作阶段 [39]。
- **关联概念**：执行 → [[Task]]

### [[Task]]
- **定义**：分配给 Agent 去执行的具体工作指令和格式要求 [41, 42]。
- **视频上下文**：例如分配给过滤代理的“过滤邮件任务”，任务中会动态传入抓取到的邮件列表，并明确要求输出相关的线程 ID 和发件人列表 [40, 43, 44]。
- **为什么重要**：它将复杂的整体自动化目标拆解为可被单个 Agent 明确理解和执行的具体步骤 [42, 45]。
- **关联概念**：分配给 → [[Agent]]

### [[Tool]]
- **定义**：赋予 Agent 与外部世界交互或获取额外信息的功能代码 [39, 46]。
- **视频上下文**：视频为撰写回复的 Agent 提供了互联网搜索工具、重新读取邮件线程工具以及调用 Gmail API 创建草稿的自定义工具 [46, 47]。
- **为什么重要**：它打破了语言模型无法联网或操作实际应用的限制，使其能动态研究主题并执行真实的外部操作（如生成实际的邮件草稿） [48-50]。
- **关联概念**：属于 → [[CrewAI]]

### [[Tavily]]
- **定义**：一个专门让大型语言模型能够智能搜索互联网的 API 搜索引擎服务 [51]。
- **视频上下文**：被配置成一种 Tool 交给 Writer Agent 使用，以便其在写回复前可以上网搜索背景资料（例如搜索用户邮件中提到的不懂的术语） [48, 51-53]。
- **为什么重要**：增强了代理的上下文知识获取能力，让生成的邮件内容更具事实依据 [50, 53]。
- **关联概念**：属于 → [[Tool]]

## 概念关系图
- [[LangGraph]] → 包含 → [[Graph]]
- [[Graph]] → 包含 → [[Node]]
- [[Graph]] → 包含 → [[Edge]]
- [[Edge]] → 扩展 → [[Conditional Edges]]
- [[Node]] → 依赖 → [[State]]
- [[Node]] → 依赖 → [[CrewAI]]
- [[CrewAI]] → 包含 → [[Agent]]
- [[Agent]] → 执行 → [[Task]]
- [[Agent]] → 依赖 → [[Tool]]
- [[Tavily]] → 属于 → [[Tool]]

## 行动项

- [ ] **下载项目源代码** [1, 2]
  - 目的：获取视频中展示的邮件自动化工具的完整基础代码供本地运行 [1, 2]
  - 难度：未明确提及
  - 预估时间：未明确提及
  - 相关工具或资源：视频下方描述栏中的链接 [1, 2]

- [ ] **在 Google Cloud Platform 中创建新项目并设置 OAuth 2.0 client ID** [3-5]
  - 目的：为本地桌面应用程序生成用于身份验证的凭证，以便连接本地应用到 Gmail 账户 [3, 5, 6]
  - 难度：未明确提及
  - 预估时间：未明确提及
  - 相关工具或资源：Google Cloud Platform [4]

- [ ] **下载包含凭证的 JSON 文件并重命名为 `credentials.json`** [7-9]
  - 目的：将 OAuth 凭证保存在本地项目目录中供代码读取 [7, 9]
  - 难度：未明确提及
  - 预估时间：未明确提及
  - 相关工具或资源：下载的 JSON 文件 [7]

- [ ] **将 `credentials.json` 文件添加进 `.gitignore` 文件中** [10]
  - 目的：防止敏感凭证文件被意外保存并推送到 GitHub 导致信息泄露 [10]
  - 难度：未明确提及
  - 预估时间：未明确提及
  - 相关工具或资源：`.gitignore` 文件 [10]

- [ ] **在 Google Cloud 中搜索并启用 Gmail API** [9, 11]
  - 目的：允许本地项目调用 Gmail API 以下拉邮件并写入草稿 [11]
  - 难度：未明确提及
  - 预估时间：未明确提及
  - 相关工具或资源：Google Cloud Platform 中的 Gmail API 页面 [9]

- [ ] **在 `.env` 文件中配置环境变量** [11-14]
  - 目的：配置个人邮箱地址，并填入从 Tavily 和 OpenAI 获取的 API key 供智能体调用 [11, 12, 14]
  - 难度：未明确提及
  - 预估时间：未明确提及
  - 相关工具或资源：`.env` 文件、Tavily.com、OpenAI [11, 12, 14]

- [ ] **使用 Conda 创建并激活指定为 3.11 版本的 Python 环境** [15, 16]
  - 目的：为项目创建隔离且包含所有依赖项的独立运行环境 [15-17]
  - 难度：未明确提及
  - 预估时间：未明确提及
  - 相关工具或资源：Conda、终端/命令行 [15, 17]

- [ ] **通过 pip 安装 `requirements.txt` 中的依赖包** [16, 18]
  - 目的：下载并安装项目运行所需的特定版本 Python 库 [16, 18]
  - 难度：未明确提及
  - 预估时间：未明确提及
  - 相关工具或资源：pip 工具、`requirements.txt` 文件 [16, 18]

- [ ] **运行 `python main.py` 并在弹出的授权页面中同意 Google 账户访问** [18-20]
  - 目的：启动 LangGraph 和 CrewAI 工作流，允许本地工具访问 Gmail 以下拉邮件并生成草稿 [18-20]
  - 难度：未明确提及
  - 预估时间：未明确提及
  - 相关工具或资源：终端/命令行、Google 授权页面 [18, 19]

## 附件

- 思维导图：[[_附件/mindmaps/5eYg1OcHm5k.json]]
- 学习指南：[[_附件/5eYg1OcHm5k_study_guide.md]]

---
*自动生成于 2026-03-19 22:08 | [原始视频](https://www.youtube.com/watch?v=5eYg1OcHm5k)*

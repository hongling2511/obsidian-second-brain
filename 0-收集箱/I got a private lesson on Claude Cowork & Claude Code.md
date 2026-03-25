---
type: youtube
title: "I got a private lesson on Claude Cowork & Claude Code"
channel: "[[Greg Isenberg]]"
url: https://www.youtube.com/watch?v=DW4a1Cm8nG4
video_id: DW4a1Cm8nG4
date_watched: 2026-03-25
date_published: 2026-01-23
duration: "42:07"
content_type: tech_tutorial
one_line_summary: "Boris 演示了面向非技术用户的 [[Claude Co-work]] 工具，并分享了最大化利用 [[Claude Code]] 的高阶实践指南与未来预测。"
rating: 4
rating_detail:
  信息密度: 4
  实用性: 5
  新颖性: 4
related_concepts:
  - "[[Claude Co-work]]"
  - "[[Claude Code]]"
  - "[[Agentic AI]]"
  - "[[Reverse elicitation]]"
  - "[[Alignment]]"
  - "[[Skills]]"
  - "[[Claude.md]]"
  - "[[Compound engineering]]"
  - "[[Plan mode]]"
has_actions: true
tags:
  - startupideas
  - sip
  - entrepreneurpodcast
  - businessideas
  - businesstrends
  - entrepreneuradvice
  - businessadvice
  - gregisenberg
  - myfirstmillion
  - a16z
  - starterstory
  - 1millionbusiness
  - saasstartup
  - startupadvice
  - aistartup
  - aibusiness
  - aistartupidea
  - nocodetools
  - AICode
  - googleaistudio
  - googleai
  - googleaistudiotutorial
  - aitechstack
  - gemini
  - nanobanana
  - ai
  - claudeopus45
  - opus45
  - claudecode
  - claude
  - claudeskills
  - claudecowork
  - cowork
  - mcp
---

# I got a private lesson on Claude Cowork & Claude Code

---
tags:
  - 视频笔记
  - podcast / tech_tutorial
信息密度: 4/5
实用性: 5/5
新颖性: 4/5
---

## 一句话总结
Boris 演示了面向非技术用户的 [[Claude Co-work]] 工具，并分享了最大化利用 [[Claude Code]] 的高阶实践指南与未来预测。

## 目标受众与前置知识
- **适合谁看**：希望通过 AI 自动化繁杂日常任务（如文件管理、数据录入）的普通用户，以及追求极高编程效率的软件工程师。
- **前置知识**：[[Agentic AI]]（了解 AI 代理不仅能聊天，还能直接控制电脑）、[[终端 (terminal)]]（推断：有助于理解工程师为何需要界面化的工具）。

## 核心观点
1. **标题**：[[Claude Co-work]] 将代理能力民主化，打破了技术壁垒。
   - 为什么重要：终端界面阻碍了许多非技术用户使用强大的 AI 代理能力。
   - 依据：讲者原话提到，这款带有简单 UI 的产品能让“你爸爸、你妈妈”等普通人轻松使用底层的 [[Claude Code]] 能力 [1]。
2. **标题**：AI 代理时代的工作流核心是“并行任务管理”。
   - 为什么重要：相较于单线执行，并行处理能极大提升人类在 AI 协助下的生产力。
   - 依据：讲者原话称目前他通常会同时并行运行 5 到 10 个 Claude 任务，并在不同窗口间切换来监督它们 [2-4]。
3. **标题**：使用更智能的大模型实际上成本更低。
   - 为什么重要：打破了“小模型更省钱”的常规直觉认知。
   - 依据：讲者原话指出，像带思考功能的 [[Opus 4.5]] 这样的聪明模型，由于不需要过多的引导且工具使用极佳，最终消耗的 token 远少于小模型，因此综合成本反而更低 [5]。

## 概念关系
- [[Claude agent SDK]] → [[Claude Code]] ↔ [[Claude Co-work]]：底层 SDK 相同，但在交互形式上形成对比。前者面向技术人员（最初基于终端），后者面向普通用户（提供可视化 UI）[6, 7]。
- [[reverse elicitation]] → [[Agentic AI]]：逆向启发技术使得 AI 代理在不确定时会主动向用户提问求证，从而确保执行动作的安全与准确 [8]。
- [[Claude.md]] → [[compounding engineering]]：通过在代码仓库中维护统一的团队知识库文件，让模型不再重复犯同样的错误，实现复利式工程积累 [9, 10]。

## 详细笔记
### 引入与 [[Claude Co-work]] 概览
- 主持人 Greg Isenberg 介绍本期播客探讨了 Anthropic 推出的新产品 [[Claude Co-work]]。它用简单的 UI 封装了爆火的 [[Claude Code]]。
- 嘉宾 Boris（产品创建者）表示，[[Claude Code]] 原本设计用于编程，但用户将其用于各种非预期任务。
- Boris 认为目前代理平台处于早期，就像苹果推出 App Store 早期只有喝啤酒之类的恶搞应用，没人能预测后来会诞生 Uber、Door Dash 或 Tik Tok [11, 12]。

### 桌面端架构与 [[Agentic AI]] 原理
- [[Claude Co-work]] 桌面应用目前仅支持 Mac OS（Windows 版本即将推出），界面包含 Chat、Co-work 和 Code 三个标签 [6]。
- 底层直接调用 [[Claude agent SDK]]。Boris 澄清了真正的 [[Agentic AI]] 定义：不仅是文字聊天或网页搜索，而是能够使用计算机上的工具并采取实际行动 [7, 13]。

### 演示一：本地文件操作与逆向启发
- Boris 授予 Co-work 特定“receipts”文件夹的访问权限，要求按日期重命名收据文件。
- 演示了 [[reverse elicitation]]（逆向启发）：当模型发现某张收据没有日期时，主动暂停并询问人类如何处理，而非盲目操作 [8, 14]。

### 演示二：浏览器控制与安全机制
- 要求 Co-work 将收据数据整理进电子表格。模型自动唤起带有内置支持的 Chrome 浏览器，请求权限后操作 Google sheet [15, 16]。
- Boris 回忆了早期使用 [[Sonnet]] 3.5/3.6 测试计算机操作的趣事：模型成功为办公室点了一份菠萝披萨 [16, 17]。
- 强调安全性：Anthropic 从 [[alignment]]（对齐）和 [[mechanistic interpretability]]（机械可解释性）入手研究。底层通过运行虚拟机隔离操作，具备防文件误删保护，并对提示词注入（prompt injection）有防御机制 [15, 18]。

### 演示三：跨应用自动化工作流
- 要求 Co-work 打开 Gmail 并将上述电子表格发送给 Amy。模型自动读取屏幕并完成草稿填报 [2, 19]。
- Boris 提到他也用它在 Slack 上自动检查工作状态表，并向未填写的工程师发送催促消息 [20]。
- Co-work 支持处理特定软件格式。如果有特殊工具（如 AutoCAD 或 Salesforce），用户可编写特定的 [[技能 (Skills)]] 或通过 MCP 协议让模型掌握 [21]。

### 终端以外的普及化与行业预测
- [[Claude Code]] 已经扩展到 iOS 移动端、Android 端、网页端、IDE 和 GitHub [22-24]。
- 令 Boris 惊讶的是，Anthropic 内部一半的销售/GTM 团队、PM、数据科学家和设计师每天都在使用它 [22]。
- 回顾 Dario 之前的预测，现在模型写代码能力呈指数级增长。Boris 表示（讲者原话）在过去两个月中，他 100% 的代码都由模型编写 [25, 26]。

### 爆款经验：最大化利用 [[Claude Code]] 的技巧
- Greg 展示了 Boris 在 X/Twitter 上的爆款推文（屏幕展示：99,000 个书签）[27]。
- **多开与多平台协作**：在终端、手机 App、Web 端同时开启 5-10 个并行会话（推断：避免等待模型思考的时间）[4, 23]。
- **使用最强模型**：强烈建议始终使用带思考功能的 [[Opus 4.5]] [5]。
- **计划驱动**：在开始前使用“计划模式（Plan mode）”沟通。只要计划通过，模型通常能一次性（oneshot）完美生成代码 [28-30]。
- **工程复利与共享知识库**：团队共享一个简单的文本文件 [[Claude.md]]。结合 GitHub action，在代码审查阶段（借鉴了 Dan Chipper 提到的 [[compounding engineering]] 概念，此前在 Meta 工作时也有类似手动表格记录习惯），直接 @Claude 修正并将其记入文档，保证团队不重复指出同一个错误 [5, 9, 10, 24]。
- **闭环验证**：必须给模型提供验证输出的方法（如让它运行测试、启动服务器或使用 Chrome 扩展查看结果），这能大幅提高准确率 [31, 32]。

### 尾声花絮
- 针对 Claude 的发音，来自法裔加拿大的 Greg 倾向于读作 "Clo"（类比 Jean Claude Van Damme），Boris 幽默地表示同意并在办公室尝试推广该发音 [33, 34]。

## 金句亮点
- "Once the plan is good the code is good." — 经验总结 / 揭示了基于大模型开发的核心已从写代码转移到需求计划。
- "It uses so many less tokens it's often cheaper than using a smaller less intelligent model even though the per token cost for that model is lower." — 意译：使用单价更高、更智能的模型，因为整体消耗的 token 更少，实际上往往比小模型更省钱。 — 事实纠偏 / 提供了反直觉的成本优化策略。

## 行动建议
- **做什么**：将特定工作文件夹的读取权限授予 [[Claude Co-work]]，并下达指令要求其按规则整理或重命名文件。
  - **关联观点**：1
  - **验证标准**：文件夹中的文件被正确重命名，并且在遇到规则覆盖不到的异常文件时，模型主动向你提问。
- **做什么**：在下一次使用 [[Claude Code]] 时，强制开启并停留在“计划模式（Plan mode）”，直到与模型彻底对齐执行步骤后再允许其写代码。
  - **关联观点**：3（推断：更聪明的模型需要充分的规划以展现最大价值）
  - **验证标准**：模型首次生成的代码无需二次返工即可正确运行（oneshot）。
- **做什么**：在项目根目录创建一个没有任何特殊格式要求的文本文件并命名为 [[Claude.md]]，把模型常犯的错误写进去。
  - **关联观点**：2（推断：在并行管理大量任务时，该文件能作为自动化防错的核心基座）
  - **验证标准**：在后续的代码生成或审查中，模型不再犯该文件中记录过的错误。

## 技术栈与环境要求
- **核心技术**：[[Claude Cowork]], [[Claude Code]], [[MCP]], [[Chrome]], [[Google Sheets]], [[Gmail]], [[Slack]], [[Excel]], [[GitHub]], [[Opus 4.5]] [1-9]。
- **环境要求**：当前桌面端应用仅支持 [[Mac OS]]（Windows 尚未明确发布时间，仅提及 coming soon） [2]。软件版本、依赖项：未明确提及。
- **前置技能**：未明确提及（视频明确指出产品设计面向非技术人员和初学者） [1, 6]。

## 步骤拆解
1. **授权访问本地文件夹**
   - 具体操作描述：在桌面应用中选择进入 Co-work 标签页。必须手动选择并挂载特定本地文件夹（如 receipts 文件夹），以授予工具访问权限，默认状态下它无法看到任何文件 [2, 10]。
   - 关键代码/命令：未明确提及
   - 注意事项：操作前需了解这是一个具有系统级文件操作权限的工具，必须显式（opt-in）授予权限 [10]。

2. **执行指令与反向启发（Reverse Elicitation）**
   - 具体操作描述：向工具下发自然语言指令（例如“重命名文件以匹配日期”）。当模型对指令或文件内容不确定时，它会暂停并向用户提问以请求澄清，用户需进行确认或补充说明 [3, 10, 11]。
   - 关键代码/命令：未明确提及
   - 注意事项：所有操作均在底层虚拟机中运行，且具备删除保护（deletion protection）机制；当涉及意外删除等敏感操作时会优先弹出提示 [12]。

3. **接管浏览器执行网页任务**
   - 具体操作描述：下达跨应用任务指令（例如建表并发送邮件）。工具会调起内置的基于 [[Chrome]] 的浏览器，请求对应站点的控制权限（用户可选择 always allow 或 allow once），随后自动操控浏览器完成在 [[Google Sheets]] 中建表和在 [[Gmail]] 中发送邮件的操作 [3-5, 13, 14]。
   - 关键代码/命令：未明确提及
   - 注意事项：模型可以读取屏幕内容并与元素交互，如果遇到格式未对齐等问题，它通常会自动识别并尝试自我修正 [14, 15]。

4. **配置自动化代码审查**
   - 具体操作描述：在代码仓库中安装专用的 Action，随后在 PR（Pull Request）或 Issue 中通过 @ 提及机器人，让其自动执行代码修改或更新团队知识库 [9, 16]。
   - 关键代码/命令：`/command/install GitHub action` [9]。
   - 注意事项：未明确提及。

## 常见坑与解决方案
- **问题描述**：模型可能会意外删除重要文件或执行危险操作 [11, 12]。
  - 解决方案：底层通过完整的虚拟机（Virtual Machine）隔离运行环境，并在上周的更新中加入了删除保护（deletion protection）功能，删除文件前会进行二次提示确认 [12]。
- **问题描述**：对特定格式或非常规软件（如特定业务线工具）的支持不佳 [7, 17-19]。
  - 解决方案：通过预先打包或编写 Skills（技能插件）来告知工具如何操作特定软件（例如系统预置了处理 [[Excel]] 的 Skill） [7, 17]。
- **问题描述**：网络交互时面临提示词注入（Prompt Injection）的风险 [4]。
  - 解决方案：系统已内置了相应的防注入保护机制（针对该问题正在持续迭代） [4]。

## 最佳实践
- **保持初始配置简单**：对于 [[Claude Cowork]] 新手，初期不要过度定制。只需挂载文件夹并安装 [[Chrome]] 扩展即可满足大部分需求，直到发现工具不擅长某项任务时再去考虑编写 Skills [18, 19]。
- **多任务并行工作流（Parallelism）**：不要阻塞等待单一任务完成，推荐同时开启 5 到 10 个会话或终端选项卡。让多个 Agent 并行处理不同的任务，开发者只需在各个选项卡间来回切换、检查进度（tending to your claudes）并解答 Agent 的疑问 [20-24]。
- **优先使用包含 Thinking 的 Opus 4.5 模型**：即使单次 Token 成本更高且速度较慢，但因为它更聪明、擅长工具使用且需要的人工引导更少，最终消耗的 Token 总量反而更少，整体使用成本更低、效率更高 [8, 25, 26]。
- **维护团队级知识库（CloudMD）**：团队应共享一个 `cloud.md` 文本文件并签入 [[Git]] 仓库。一旦发现工具犯错，立刻将其正确做法补充进该文件，确保工具后续不会重复犯错（Compounding Engineering） [8, 16, 27]。
- **采用 Plan Mode（计划模式）驱动开发**：建议所有会话从 plan mode 开始，不断与模型交互直至确认其给出的计划是完美的。只要计划无误，切换到 auto accept edits（自动接受编辑）模式后，模型通常能完美地一次性写出正确代码（One-shot） [23, 25, 28]。
- **赋予模型验证闭环的能力**：必须给工具提供验证其自身输出的手段。例如让其使用 [[Chrome]] 扩展检查生成的网页、自行运行测试代码、或者启动本地服务器查看结果，这将极大提升最终产出的质量 [26, 29]。

## 关键概念

### [[Claude Co-work]]
- **定义**：一款将 Claude Code 的能力封装在简单 UI 中的新产品，允许非技术人员通过 AI 代理操作电脑文件和应用 [1]。
- **视频上下文**：作者展示了它如何直接重命名桌面收据文件、创建电子表格，并接管浏览器控制权发送电子邮件 [2-5]。
- **为什么重要**：它大幅降低了使用 AI 代理的门槛，被认为是引导非技术人员接触底层代码代理的“入门毒药”（gateway drug） [1, 6]。
- **关联概念**：依赖 → [[Claude Code]]

### [[Claude Code]]
- **定义**：一款最初为终端构建的 AI 编程助手和代理工具，支持高度定制和并行任务处理 [7-9]。
- **视频上下文**：作者在过去两个月里 100% 的代码都由其编写；团队每天在终端、网页端甚至手机 App 上同时运行多个并行任务 [10-12]。
- **为什么重要**：它代表了前沿的 AI 自动化执行能力，并且作为底层引擎驱动了 Claude Co-work 的运行 [7, 10]。
- **关联概念**：扩展 → [[Claude Co-work]]

### [[Agentic AI]]
- **定义**：不仅限于文本聊天或网络搜索，而是能在计算机上采取行动、使用工具并与现实世界互动的 AI [13]。
- **视频上下文**：作者澄清了 Agent 的具体含义，指出许多过去被称为 agentic 的产品名不副实，而真正的代理能够像人类操作者一样管理文件系统并控制浏览器 [2, 13, 14]。
- **为什么重要**：它代表了 AI 从单纯的“对话系统”向能够自主规划并执行复杂任务的数字队友的范式转变 [4, 13]。
- **关联概念**：未明确提及

### [[Reverse elicitation]]
- **定义**：当 AI 模型对某事不确定时，主动向用户请求澄清，而不是自行假设的行为 [15]。
- **视频上下文**：在整理收据文件的演示中，代理发现某张收据缺失日期，于是暂停执行并向用户提问该如何处理这一特例 [3, 15]。
- **为什么重要**：这是一种关键的安全与交互机制，能有效防止 AI 代理在系统级别进行意外的破坏性操作 [15]。
- **关联概念**：未明确提及

### [[Alignment]]
- **定义**：研究如何确保 AI 模型能够安全地按照用户意图执行操作的领域 [16]。
- **视频上下文**：作者提到 Anthropic 通过类似研究人类神经元的方式（机制可解释性）将模型作为黑盒进行研究，以确保代理操作计算机时的底层安全性 [16]。
- **为什么重要**：这是赋予 AI 代理（如 Co-work）直接修改文件、使用本地虚拟机和防删除保护功能的安全基础 [15, 16]。
- **关联概念**：未明确提及

### [[Skills]]
- **定义**：为 AI 代理预先打包或由用户自定义的，用于执行特定软件任务的模块化方法 [17, 18]。
- **视频上下文**：当生成电子表格时，Co-work 自动加载了 Excel skill；作者建议用户在遇到 AI 不擅长的特定软件（如 AutoCAD）时自行编写技能 [17, 18]。
- **为什么重要**：用户可以通过前期投入创建技能来教导 AI 处理垂直领域的任务，从而极大地扩展代理的自动化能力 [18]。
- **关联概念**：属于 → [[Claude Co-work]]

### [[Claude.md]]
- **定义**：一个无需特殊格式的纯文本文件，作为团队的共享知识库，记录 AI 应该遵守的规则和需避免的错误 [19, 20]。
- **视频上下文**：作者团队将其保存在代码库中，一旦发现代理做错事，便会在代码审查环节将其记录在案，供代理下次参考 [19, 20]。
- **为什么重要**：它是低成本维护和迭代 AI 代理行为表现的核心工具，确保 AI 不会重复犯错 [20, 21]。
- **关联概念**：依赖 → [[Compound engineering]]

### [[Compound engineering]]
- **定义**：通过将代码审查中的反馈不断积累并转化为自动化规则，使得工程效率随时间复利增长的理念 [20, 21]。
- **视频上下文**：作者借用 Dan Shipper 的概念，解释团队如何通过 GitHub Action 在合并请求中直接 @Claude，让其自动更新知识库文件 [20, 22]。
- **为什么重要**：它打造了一种高效的工作流，确保团队“永远不需要对同一件事评论两次”，沉淀了组织架构的工程经验 [21, 22]。
- **关联概念**：依赖 → [[Claude.md]]

### [[Plan mode]]
- **定义**：在使用 AI 代理执行代码前，先让其输出计划文本并与用户进行往复确认的交互模式 [11, 23]。
- **视频上下文**：作者在编写复杂请求时通常从此模式开始，一旦确认计划无误，便切换至自动接受模式让代理一次性完成任务 [11, 23]。
- **为什么重要**：得益于最新模型的强大规划能力，只要明确了良好的计划，代理的代码执行几乎总是完美的，这是确保高质量输出的诀窍 [11, 24]。
- **关联概念**：未明确提及

## 概念关系图
- [[Claude Co-work]] → 依赖 → [[Claude Code]]
- [[Claude Code]] ↔ 对比 ↔ [[Claude Co-work]]
- [[Compound engineering]] → 依赖 → [[Claude.md]]

## 行动项

- [ ] **下载并安装 Claude desktop app** [1]
  - 目的：获取 Co-work 功能的使用权限以实现日常任务自动化。
  - 难度：未明确提及
  - 预估时间：未明确提及
  - 相关工具或资源：Claude desktop app、Mac OS

- [ ] **在 Co-work 中挂载本地文件夹并授予访问权限** [2, 3]
  - 目的：允许 Co-work 读取和操作本地文件，用于清理、重命名或整理（如收据）。
  - 难度：未明确提及
  - 预估时间：未明确提及
  - 相关工具或资源：Claude Co-work

- [ ] **安装 Chrome extension** [4, 5]
  - 目的：使 Co-work 和 Claude Code 能够控制浏览器执行网页操作，并允许 Claude 测试和验证其自身的输出结果。
  - 难度：未明确提及
  - 预估时间：未明确提及
  - 相关工具或资源：Chrome extension、Chrome-based browser

- [ ] **创建并更新 `claude.md` 文件** [6, 7]
  - 目的：作为项目的知识库，每次发现 Claude 做错时将其记录在内，以防下次再犯。
  - 难度：未明确提及
  - 预估时间：未明确提及
  - 相关工具或资源：`claude.md`、Git

- [ ] **在 GitHub repo 中运行 `/command/install GitHub action`** [8]
  - 目的：在 GitHub 仓库中安装 Claude app，以便在 pull requests (PRs) 或 issues 中通过 `@Claude` 快速修复代码或更新 `claude.md`。
  - 难度：未明确提及
  - 预估时间：未明确提及
  - 相关工具或资源：GitHub action、Claude Code、GitHub

- [ ] **使用 plan mode 启动 Claude Code 会话** [9, 10]
  - 目的：在编写代码前先让 Claude 生成计划，通过沟通修改直至计划完善。
  - 难度：未明确提及
  - 预估时间：未明确提及
  - 相关工具或资源：Claude Code

- [ ] **在确认计划后切换至 auto accept edits 模式** [9, 10]
  - 目的：让 Claude 自动并完美地执行已经制定好的计划，无需每次手动确认。
  - 难度：未明确提及
  - 预估时间：未明确提及
  - 相关工具或资源：Claude Code

- [ ] **将模型配置为 Opus 4.5 with Thinking** [5, 6]
  - 目的：获得最佳的编码和工具使用效果；由于其更智能、需要更少的人工引导，最终能减少总 token 使用量。
  - 难度：未明确提及
  - 预估时间：未明确提及
  - 相关工具或资源：Opus 4.5 with Thinking 模型

## 附件

- 思维导图：[[_附件/mindmaps/DW4a1Cm8nG4.json]]
- 学习指南：[[_附件/DW4a1Cm8nG4_study_guide.md]]

---
*自动生成于 2026-03-25 11:01 | [原始视频](https://www.youtube.com/watch?v=DW4a1Cm8nG4)*

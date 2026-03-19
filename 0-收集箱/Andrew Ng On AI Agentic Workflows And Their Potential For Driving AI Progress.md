---
type: youtube
title: "Andrew Ng On AI Agentic Workflows And Their Potential For Driving AI Progress"
channel: "[[Snowflake Developers]]"
url: https://www.youtube.com/watch?v=q1XFm21I-VQ
video_id: q1XFm21I-VQ
date_watched: 2026-03-19
date_published: 2024-06-11
duration: "30:54"
content_type: tech_tutorial
one_line_summary: "吴恩达在 Snowflake 大会探讨 [[AI Agentic Workflows]] 的优势，并首发演示开源自动编程工具 [[Vision Agent]]。"
rating: 4
rating_detail:
  信息密度: 4
  实用性: 4
  新颖性: 4
related_concepts:
  - "[[Agentic Workflow]]"
  - "[[Zero-shot Prompting]]"
  - "[[Vision Agent]]"
  - "[[Coder Agent]]"
  - "[[Tester Agent]]"
  - "[[Tools]]"
  - "[[Reflection]]"
has_actions: true
tags:[]
---

# Andrew Ng On AI Agentic Workflows And Their Potential For Driving AI Progress

---
tags:
  - 视频笔记
  - knowledge / tech_tutorial / business
信息密度: 4/5
实用性: 4/5
新颖性: 4/5
---

## 一句话总结
吴恩达在 Snowflake 大会探讨 [[AI Agentic Workflows]] 的优势，并首发演示开源自动编程工具 [[Vision Agent]]。

## 目标受众与前置知识
- **适合谁看**：AI 开发者、初创企业创始人、数据与计算机视觉领域从业者。
- **前置知识**：[[Large Language Models]]、[[Zero-shot prompting]]、[[Computer Vision]]。

## 核心观点
1. **[[AI Agentic Workflows]] 带来的性能提升远超单一模型的代际升级**
   - 为什么重要：它证明了通过系统性框架，较小或较旧的模型可以产生超越最新大模型的输出结果。
   - 依据：在 [[HumanEval]] 编码基准测试中，[[GPT-3.5]] 的零样本提示准确率为 48%（讲者原话），[[GPT-4]] 为 67%（讲者原话）；但包裹在 Agentic 工作流中的 GPT-3.5 的提升幅度远超从 3.5 到 4 的提升（讲者原话），甚至表现非常优异。
2. **严苛的 AI 监管可能会扼杀开源创新**
   - 为什么重要：如果通用技术开发者需要为滥用承担法律责任，技术生态将被摧毁。
   - 依据：讲者举例加州的 [[s1047]] 法案，表示如果规定任何计算机制造商都要对他人用计算机做坏事负责，那么唯一的理性做法是不再制造计算机（讲者原话）。
3. **视觉代理（[[Vision Agent]]）能大幅降低图像/视频应用的开发门槛**
   - 为什么重要：原本需要花费数小时手写的视觉分析和检测代码，现在可以通过自然语言指令全自动生成和执行。
   - 依据：现场演示该工具自动生成代码计算冲浪者与鲨鱼的距离、检测人群是否戴口罩、以及识别视频中是否发生车祸（屏幕展示）。

## 概念关系
- [[Zero-shot prompting]] ↔ [[AI Agentic Workflows]]：前者是单次从头到尾的线性输出，后者是包含思考、研究、写草稿、自我反思和重写的迭代循环，效果远优于前者。
- [[Coder Agent]] → [[Tester Agent]]：在 Vision Agent 架构中，前者负责规划并调用工具生成代码，后者负责执行生成的测试代码，并将错误信息反馈给前者以进行反思和重写。
- [[Snowflake]] → [[Landing Lens]]：后者是 [[Landing AI]] 在前者的平台上构建的计算机视觉原生应用程序，有助于通过监督学习纠正检测错误。

## 详细笔记
### Snowflake 开发者生态与初创支持
- 主持人欢迎参加开发者大会。大会旨在连接社区，分享如何利用数据和 AI 进行构建。
- **技术与工具应用**：主持人提到作为一个开发者，对技术的可能性感到兴奋。例如编写仅10行的 [[Streamlit]] 应用即可在 [[Snowflake]] 内部开箱即用（曾向 Adrian 分享）；产品总监 Jeff Holland 仅用几小时就利用容器服务、视频转录工具和 [[Cortex]] 搜索构建了支持对话框的应用。
- **开源与初创支持**：
  - Snowflake 正在向带有开源成分的平台演进，举办了基于其开源大模型 [[Arctic]] 的 AI 黑客松。
  - 数千开发者在 Snowflake 构建数据密集型应用。[[Maxa]]、[[My Data Outlet]] 和 [[Relational AI]] 等初创公司在市场上分发应用获得了数百万美元收入。
  - 大会现场颁布了第四届初创挑战赛：Big Geo、Scientific Financial Systems 和获胜者 [[Signal Flare]] 竞争最高 100 万美元投资（讲者原话）。
  - Snowflake 与 10 家风投公司合作，投资高达 1 亿美元（讲者原话）支持构建原生应用。
  - 推出 NSTAR 教育计划以及在 [[Coursera]] 上的免费课程。

### 吴恩达访谈：AI 历程、算力依赖与监管
- 主持人邀请 [[Landing AI]] CEO、[[Coursera]] 联合创始人、前 [[Google]] 同事吴恩达（Andrew Ng）上台。
- **AI 启蒙点**：吴恩达在青少年时期做办公室管理员时需要大量复印，希望将其自动化，因此选择了计算机科学和 AI。
- **大模型与算力**：主持人提问是否必须需要 50,000 个 H100（讲者原话）才能起步。吴恩达认为除了基于缩放定律的大模型外，也应当有低成本、低能耗路径。他赞赏 Snowflake 开源 [[Arctic]] 模型，认为技术广泛传播能够避免被少数人垄断。
- **AI 监管争议**：吴恩达最近在 [[US capital]]（华盛顿 DC）参与监管辩论。他支持 [[White House]] 的部分意见和 [[House and Senate]]（尤其是 Schumer gang）更注重投资而非关停的立场。但他强烈反对加州（California）正在推进的 [[s1047]] 法案（推断全称为 SB 1047），认为在技术层要求通用技术防范所有恶意应用是不现实的，这会严重破坏开源创新。

### Agentic Workflow 概念与影响
- 吴恩达指出 [[AI Agentic Workflows]] 是当前 AI 领域最值得关注的趋势之一。
- 对比人类写作，[[Zero-shot prompting]] 类似于要求人从头到尾打字不准退格；而 Agentic 工作流允许大模型（如通过自然语言提示）执行生成大纲、搜索网页获取信息、写草稿、阅读并修改草稿的迭代过程。
- **实验数据**：在 [[OpenAI]] 发布的基准测试 [[HumanEval]] 中，搭配 Agentic 工作流的低版本模型（[[GPT-3.5]]）不仅比其自身零样本效果好，甚至远超零样本提示的最新模型（[[GPT-4]]）。

### Vision Agent（视觉代理）技术演示与开源发布
- 首次公开介绍团队刚开源的 [[Vision Agent]] 工具（团队成员 Dylan Lad 和 Asian Shanka 出席）。
- **演示案例**：
  - 冲浪视频：Dylan 是冲浪爱好者。系统通过提示语（如假设 30 像素为 1 米），自动识别冲浪板和鲨鱼的距离，并在超过安全距离时将标记线由红变绿。
  - 口罩检测：生成一个包含识别出 8 个戴口罩和 2 个未戴口罩（讲者原话屏幕展示推断）人员结果的 Python 字典。
  - 车祸检测：每 2 秒分析一次监控视频，输出标记车祸时间的 JSON 文件。
- **工作原理拆解**：
  1. 输入指令。
  2. [[Coder Agent]] 运行 planner 构建步骤计划（如加载图像、检测对象）。
  3. 检索提取需要的函数/工具（如 `save_video`）。
  4. 自动生成并执行代码。
  - 结合了 [[Tester Agent]] 技术：大模型编写测试代码（如类型检查），执行失败时将报错信息（如 Traceback）反馈给 Coder Agent 重新生成。
  - 在处理 CCTV 录像找 10 辆以上汽车的片段时，代码第三次报错提示缺少模块，模型自动通过 `pip install Pi tube`（推断为 pytube 库）修复了错误。
  - 论文参考：Hang 等人的 Agent Coder 论文，以及 Hong 等人的 Data Interpreter 论文。

### 局限性与行业趋势预测
- **当前限制**：[[Vision Agent]] 远未完美，对提示词措辞敏感。经常出现工具失败，例如底层的通用对象检测系统 [[Grounding DINO]] 漏掉了黄番茄（讲者原话口误提及 YOLO，随后纠正为 yellow tomatoes）；系统也不擅长复杂推理，如提示系统计算栏杆上鸟的重量时，未能主动排除正在飞行的鸟，必须通过修改提示词说明“忽略飞行的鸟”才能算对。
- **解决方案**：在 Snowflake 上构建的 [[Landing Lens]] 监督学习功能可帮助纠正这类错误。
- **问答环节**：来自 [[Weights and Biases]] 的 Lucas 接续演讲前，有观众提问 Agentic AI 的应用范围。
  - 吴恩达回复：智能代理正在快速突破“玩具”阶段变得高度实用。并提及代码代理领域的 [[Devin]] 和开源版 [[Open Devin]]，法律文书代理工具，以及斯坦福 Monica Lam 开发的研究代理 [[STORM]]。吴本人也在使用 [[Crew AI]]、[[AutoGen]] 和 [[Land draft]]（推断为 LangGraph）等代理框架。

## 金句亮点
- "If you say that any computer manufacturer is liable if anyone uses your computer for something bad then the only rational move is that no one should make any more computers." — 意译 / 监管观点
- "While there was a huge improvement from gbd 3.5 to gbd 4, that improvement is actually dwarfed by the improvement from GP 3.5 with an agentic workflow." — 讲者原话 / 技术洞察
- "Good things happen when technology spreads broadly when lots of people can do the same thing." — 讲者原话 / 行业价值

## 行动建议
- **阅读学术文献**：查阅 Hang 等人的 Agent Coder 论文和 Hong 等人的 Data Interpreter 论文。
  - **关联观点**：1
  - **验证标准**：理解并能复述 Tester Agent 如何通过执行测试代码将反馈回传给 Coder Agent 的工作流机制。
- **尝试复现演示**：在代码环境中通过自然语言指令（如计算特定图像中两个对象的距离），测试刚开源的 [[Vision Agent]] 核心引擎。
  - **关联观点**：3
  - **验证标准**：成功跑通提示到代码生成的流程，并输出带有检测标记的结果图像或视频。
- **用自己的数据重做**：使用 Snowflake 平台的原生应用 [[Landing Lens]] 处理自定义的图像数据集并运行计算机视觉监督学习。
  - **关联观点**：3
  - **验证标准**：在自有数据上训练模型，减少因通用检测系统漏检造成的错误。

## 技术栈与环境要求
- **核心技术**：[[Snowflake]]、[[Streamlit]]、[[GPT-3.5]]、[[GPT-4]]、[[Arctic]]、[[Vision Agent]]、[[Coder Agent]]、[[Tester Agent]]、[[Grounding DINO]]、[[LandingLens]]、[[CrewAI]]、[[AutoGen]]、[[LangGraph]]、[[OpenDevin]]、[[STORM]] [1-9]。
- **环境要求**：未明确提及。
- **前置技能**：未明确提及。

## 步骤拆解
1. **输入 Prompt**
   - 具体操作描述：向 [[Vision Agent]] 输入自然语言提示词以说明具体需求（例如计算鲨鱼和最近冲浪板之间的距离，或分析视频中是否发生车祸）[10-12]。
   - 关键代码/命令：未明确提及。
   - 注意事项：有时需要调整提示词，以更具体地说明分步操作过程 [13]。
2. **Planner 制定计划**
   - 具体操作描述：[[Coder Agent]] 运行 Planner，将输入任务拆解为所需的步骤序列（如提取视频帧、加载图像、使用工具检测对象、计算距离等）[14, 15]。
   - 关键代码/命令：未明确提及。
   - 注意事项：未明确提及。
3. **检索工具 (Retrieve tools)**
   - 具体操作描述：根据拆解的步骤，系统会检索并提取对应工具（函数）的详细描述（例如 `save_video` 等实用功能）[14, 15]。
   - 关键代码/命令：未明确提及。
   - 注意事项：未明确提及。
4. **生成代码**
   - 具体操作描述：大模型根据提示词和工具描述，全自动生成用于执行该视觉任务的 Python 代码 [11, 15]。
   - 关键代码/命令：未明确提及。
   - 注意事项：未明确提及。
5. **执行与测试反馈 (Reflection)**
   - 具体操作描述：系统或 [[Tester Agent]] 编写并执行测试代码（通常为类型检查）。如果代码执行失败或报错，会将错误信息（如 Traceback）反馈给 [[Coder Agent]] 进行反思重写代码，此过程可多次迭代直至成功 [16-19]。
   - 关键代码/命令：`pip install pytube` [19]。
   - 注意事项：未明确提及。

## 常见坑与解决方案
- **问题描述**：自动生成代码运行时可能遇到缺少第三方模块（如 `no module named pytube`）或引发索引错误（Index error traceback）[18, 19]。
  - 解决方案：系统捕获错误信息反馈给模型后，模型会自主找出并执行依赖安装命令（如 `pip install pytube`），并修正代码以完成任务 [19]。
- **问题描述**：底层通用目标检测系统（如 [[Grounding DINO]]）有时会漏检物体（例如漏掉黄色的西红柿）[5]。
  - 解决方案：使用监督学习计算机视觉系统（如 [[LandingLens]]）来帮助减少此类识别错误 [6]。
- **问题描述**：模型缺乏复杂的逻辑推理能力（例如计算篱笆上鸟的重量时，未能意识到飞在空中的鸟不会对篱笆产生重量）[6]。
  - 解决方案：修改 Prompt，直接在提示词中补充明确的排除逻辑条件（如“忽略飞行的鸟”）[13]。
- **问题描述**：[[Vision Agent]] 在处理任务时表现不稳定（finicky），对提示词的措辞极其敏感 [13]。
  - 解决方案：不断调整和优化 Prompt，让其对操作的步骤（step-by-step process）表述更为具体 [13]。

## 最佳实践
- **使用 Agentic 工作流替代 Zero-shot Prompting**：将大语言模型（如 [[GPT-3.5]]）封装进包含思考、研究、生成、测试和修改的迭代式 Agentic 工作流中，其代码生成的准确率及表现远高于让模型直接从头到尾生成代码的 Zero-shot 方式 [3, 20-22]。
- **批量处理策略优化计算效率**：在处理视觉应用时，先利用提示词生成一段能在少量图像上跑通的代码，然后利用这段自动生成的代码高效地去批量处理大量图像或视频帧，而不是逐个让模型重新处理 [4, 23]。
- **利用测试代理构建反思机制**：引入 [[Tester Agent]] 来编写和执行测试代码，将失败的运行结果反馈给 [[Coder Agent]] 以促发“反思（Reflection）”并重写代码，能为应用带来显著的性能提升 [16, 17]。

## 关键概念

### [[Agentic Workflow]]
- **定义**：一种使大型语言模型能够通过计划、研究、编写草稿、审查和修改等迭代循环来完成任务的流程 [1]。
- **视频上下文**：Andrew Ng 将其视为当前极具潜力的趋势，指出即使是 GPT-3.5 加上 Agentic Workflow，在编程基准测试上的表现也能大幅超越纯粹使用 GPT-4 的零样本提示 [2, 3]。
- **为什么重要**：它代表了人工智能从单次对话向自动、迭代执行复杂任务的范式转变，能够大幅扩展现有语言模型的能力边界 [4, 5]。
- **关联概念**：对比 → [[Zero-shot Prompting]]

### [[Zero-shot Prompting]]
- **定义**：要求大型语言模型在不进行任何修改或迭代的情况下，一次性从头到尾完成任务的提示方法 [6]。
- **视频上下文**：Andrew Ng 用“要求一个人从头到尾一次性写完一篇文章且不允许使用退格键”来生动比喻这种提示方式，并将其作为 Agentic Workflow 的对照组 [6]。
- **为什么重要**：这是当前大多数人使用 LLM 的默认方式，理解其局限性有助于认识到引入 Agentic Workflow 的必要性 [2, 6]。
- **关联概念**：对比 ↔ [[Agentic Workflow]]

### [[Vision Agent]]
- **定义**：由 Landing AI 开源的一种专门用于处理视觉任务的智能体，能够将自然语言提示自动转化为处理图像和视频的计算机视觉代码 [3, 7, 8]。
- **视频上下文**：Andrew Ng 演示了向其输入“检测冲浪者和鲨鱼并计算距离”的提示词后，系统如何自动拆解任务、检索工具、编写并运行代码，最终输出带标注的视频 [7-9]。
- **为什么重要**：它免除了开发者手动记忆各种计算机视觉函数语法的麻烦，将耗时数小时的视觉应用开发缩短至极短时间，展示了智能体在垂直领域的巨大价值 [10, 11]。
- **关联概念**：依赖 → [[Coder Agent]] / 依赖 → [[Tester Agent]]

### [[Coder Agent]]
- **定义**：在 Vision Agent 系统内部，负责生成计划并编写具体代码的子智能体 [12]。
- **视频上下文**：当接收到提示时，Coder Agent 会先运行一个规划器（Planner）列出完成任务所需的步骤，然后检索详细的工具描述，并最终生成所需代码 [12, 13]。
- **为什么重要**：它是将用户的自然语言意图转化为机器可执行的逻辑序列的核心引擎 [12, 13]。
- **关联概念**：属于 → [[Vision Agent]] / 依赖 → [[Tools]]

### [[Tester Agent]]
- **定义**：在 Vision Agent 系统内部，负责编写和执行测试代码以验证生成结果，并在失败时将错误信息反馈给系统的子智能体 [11, 12, 14]。
- **视频上下文**：在监控视频高亮任务的演示中，生成的代码因缺少模块多次报错，Tester Agent 捕获这些错误并不断反馈，直到系统最终学会自动安装缺失的依赖项（如 pip install）并成功运行 [15, 16]。
- **为什么重要**：赋予了智能体自我验证和自动纠错的能力，显著提升了生成代码的成功率和系统的鲁棒性 [11, 14]。
- **关联概念**：属于 → [[Vision Agent]] / 依赖 → [[Reflection]]

### [[Tools]]
- **定义**：智能体在执行任务时可以检索和调用的具体实用函数集 [7, 13]。
- **视频上下文**：视频中提到 Vision Agent 在生成代码前，会检索例如“提取视频帧”、“保存视频”或“计算边界框距离”等工具（函数调用）的详细描述 [7, 13]。
- **为什么重要**：它是大型语言模型与外部环境交互、执行特定计算和处理复杂多媒体数据的抓手 [7]。
- **关联概念**：未明确提及

### [[Reflection]]
- **定义**：当测试失败时，将报错的输出结果反馈回代码生成模型，要求其根据错误重新编写代码的自我反省过程 [14]。
- **视频上下文**：在使用 Tester Agent 评估代码时，Andrew Ng 提到如果测试代码执行失败，系统会进行 reflection 并重写代码 [14]。
- **为什么重要**：这是智能体工作流中实现“迭代”和“自我改进”的关键机制，能够直接带来性能提升 [14]。
- **关联概念**：依赖 → [[Tester Agent]]

## 概念关系图
- [[Agentic Workflow]] ↔ 对比 ↔ [[Zero-shot Prompting]]
- [[Vision Agent]] → 依赖 → [[Coder Agent]]
- [[Vision Agent]] → 依赖 → [[Tester Agent]]
- [[Coder Agent]] → 依赖 → [[Tools]]
- [[Tester Agent]] → 依赖 → [[Reflection]]

## 行动项

- [ ] **查看并学习 Snowflake 相关的 Coursera 课程** [1]
  - 目的：学习如何在 Snowflake 平台上进行开发与构建 [1]
  - 难度：未明确提及
  - 预估时间：未明确提及
  - 相关工具或资源：Coursera, Snowflake [1]

- [ ] **查看并测试开源的 Vision Agent 代码及 prompts** [2, 3]
  - 目的：了解 Vision Agent 的实际代码实现和特定的 prompts 写法，并提供反馈以帮助改进 [2, 3]
  - 难度：未明确提及
  - 预估时间：未明确提及
  - 相关工具或资源：Vision Agent 开源代码, va.landing.ai [2, 4]

- [ ] **阅读 Agentic Workflow 相关的核心学术论文** [5]
  - 目的：深入学习和了解 Agent 技术的底层机制和详细技术背景 [5]
  - 难度：未明确提及
  - 预估时间：未明确提及
  - 相关工具或资源：《Agent Coder》论文 (Huang et al.), 《Data Interpreter》论文 (Hong et al.) [5]

- [ ] **尝试使用主流 Agentic 平台框架进行开发** [6]
  - 目的：亲自动手实践，在现有框架平台之上构建自己的 Agent 应用程序 [6]
  - 难度：未明确提及
  - 预估时间：未明确提及
  - 相关工具或资源：Crew AI, AutoGen, LangChain [6]

- [ ] **测试并使用 STORM 开源研究工具** [7]
  - 目的：体验能够自动进行网络深度搜索、提取信息并生成长文档的 AI research agents 工具 [7]
  - 难度：未明确提及
  - 预估时间：未明确提及
  - 相关工具或资源：STORM (Stanford 发布的开源软件) [7]

## 附件

- 思维导图：[[_附件/mindmaps/q1XFm21I-VQ.json]]
- 学习指南：[[_附件/q1XFm21I-VQ_study_guide.md]]

---
*自动生成于 2026-03-19 21:56 | [原始视频](https://www.youtube.com/watch?v=q1XFm21I-VQ)*

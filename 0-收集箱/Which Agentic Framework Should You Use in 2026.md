---
type: youtube
title: "Which Agentic Framework Should You Use in 2026"
channel: "[[AI Depth School]]"
url: https://www.youtube.com/watch?v=8Lf_3CxdLlM
video_id: 8Lf_3CxdLlM
date_watched: 2026-03-19
date_published: 2025-12-12
duration: "11:15"
content_type: knowledge
one_line_summary: "解析 2026 年五大主流 [[Agentic AI frameworks]] 的演进、技术特点、适用场景及其走向互操作性的发展趋势。[1][2][3]"
rating: 4
rating_detail:
  信息密度: 4
  实用性: 5
  新颖性: 4
related_concepts:
  - "[[Langchain]]"
  - "[[Llama Index]]"
  - "[[RAG (Retrieval Augmented Generation)]]"
  - "[[Semantic Kernel]]"
  - "[[Agent Framework]]"
  - "[[Multi-agent orchestration]]"
  - "[[OpenAI Agents SDK]]"
  - "[[Agentic AI Foundation]]"
has_actions: true
tags:
  - aiagents
  - agenticai
  - langchain
  - llamaindex
  - semantickernel
  - microsoftagentframework
  - openaiagentssdk
  - aiframeworks
  - llmdevelopment
  - artificialintelligence
  - machinelearning
  - rag
  - retrievalaugmentedgeneration
  - multiagentsystems
  - aiprogramming
  - pythonai
  - aitutorial
  - aidevelopment
  - enterpriseai
  - openai
  - anthropic
  - aiautomation
  - aitools2025
  - softwaredevelopment
  - aiengineering
  - autonomousagents
  - aiorchestration
  - functioncalling
  - aiintegration
---

# Which Agentic Framework Should You Use in 2026

---
tags:
  - 视频笔记
  - knowledge
信息密度: 4/5 （推断）
实用性: 5/5 （推断）
新颖性: 4/5 （推断）
---

## 一句话总结
解析 2026 年五大主流 [[Agentic AI frameworks]] 的演进、技术特点、适用场景及其走向互操作性的发展趋势。[1][2][3]

## 目标受众与前置知识
- **适合谁看**：构建 [[AI agents]] 系统的开发者、架构师及企业技术决策者（推断）。
- **前置知识**：[[LLM]]、[[AI agents]]、[[rag]]、[[API]]、[[function calling]]。

## 核心观点
1. **智能体框架已高度细分且各具专长**
   - 为什么重要：开发者需要根据具体用例选择最匹配的工具以提高效率。
   - 依据：视频对比了五大框架（讲者原话），例如 [[Langchain]] 适合快速原型设计，而 [[Llama Index]] 是知识密集型工作（[[rag]]）的绝对冠军（讲者原话）。[4][2]
2. **企业级部署对安全性与可控性要求极高**
   - 为什么重要：决定了 AI 技术能否在企业生产环境中稳定、合规地运行。
   - 依据：[[Microsoft]] 的 [[semantic kernel]] 从底层设计了遥测、安全钩子和治理功能，并支持 [[C]]、[[Python]] 和 [[Java]] 等多语言（讲者原话）。[5][2]
3. **多智能体协同是处理复杂任务的演进方向**
   - 为什么重要：单体智能体能力有限，分工协作能完成更复杂的链条任务。
   - 依据：[[Microsoft's agent framework]] 使用 [[graphbased workflow system]]，支持多个专门的智能体（如规划、编码、审查）进行交流甚至辩论（讲者原话）。[6]
4. **框架生态正走向互操作性与标准化**
   - 为什么重要：开发者不会被单一框架锁定，可以自由组合最佳组件。
   - 依据：2025 年（讲者原话）[[OpenAI]]、[[Microsoft]]、[[Anthropic]] 等巨头成立了 [[Agentics AI Foundation]] 制定开放协议，不同框架（如 [[Llama Index]] 与 [[Langchain]]）可以组合使用。[7][3]

## 概念关系
- [[LLM]] → [[Agentic AI frameworks]]：框架通过将大语言模型调用与工具链接，赋予 AI 执行多步操作解决问题的能力。[1]
- [[kernel functions]] → [[plugins]]：在 [[semantic kernel]] 中，代码或提示词的封装（函数）被组合成代表完整 [[API]] 或服务的插件，供 AI 通过 [[function calling]] 调用。[5]
- [[Autogen]] → [[Microsoft's agent framework]]：后者是前者的演进版本，专注于基于事件驱动（[[event driven]]）的多智能体编排。[6]
- [[Llama Index]] ↔ [[Langchain]]：前者是专精于检索的“精准手术刀”，后者是高度模块化的“瑞士军刀”，两者互不排斥且可结合使用。[4][3]

## 详细笔记

### 智能体框架的历史演进（由 [[AI Depth School]] 频道发布）
- 2022 年（讲者原话）：[[Langchain]] 登场，开创了将 [[LLM]] 调用与工具链接的先河。[1]
- 2023 年（讲者原话）：[[Llama Index]] 出现（专注 [[rag]]）；[[Microsoft]] 推出 [[semantic kernel]]。[1][7]
- 2024 年（讲者原话）：[[OpenAI]] 推出官方 SDK；晚些时候 [[Microsoft]] 统一其产品线推出 [[Microsoft's agent framework]]。[7]
- 2025 年（讲者原话）：[[OpenAI]]、[[Microsoft]]、[[Anthropic]] 及其他主要参与者成立 [[Agentics AI Foundation]]，致力于开放协议。[7]

### 框架一：[[Langchain]] (模块化先驱)
- **核心特点**：极致的模块化，类似 AI 的乐高。包含操作链、决策智能体、记忆系统以及用于复杂编排的 [[Lang graph]]。[7][4]
- **优势**：
  - 极易上手：不到 10 行代码（讲者原话）即可启动一个工作智能体。[7]
  - 集成丰富：连接数百种模型和工具（讲者原话），支持 [[OpenAI]]、[[Anthropic]]、开源模型（[[open-source models]]）及自定义 [[API]]。[4]
- **适用场景**：聊天机器人、多步推理、快速原型设计。高阶用法学习曲线较陡。[4]

### 框架二：[[Llama Index]] (检索与数据专家)
- **核心特点**：专攻知识密集型任务和 [[rag]]（检索增强生成）。[4]
- **能力**：能够处理成千上万的文档、PDF、数据库或研究论文（讲者原话），让 AI 真正理解庞大的上下文数据。[4]

### 框架三：[[semantic kernel]] (企业级中间件)
- **核心特点**：[[Microsoft]] 专为企业级部署设计的轻量级 SDK。内置遥测、安全钩子和治理功能。[5]
- **架构与多语言**：将代码封装为 [[kernel functions]] 和 [[plugins]]。全面支持 [[C]]、[[Python]] 和 [[Java]]。模型不可知，可在 [[OpenAI]]、[[Azure]]、[[Anthropic]] 和开源模型间无缝切换。[5]
- **适用场景**：企业工作流、[[API]] 集成、业务流程自动化。对简单原型来说偏重，学习曲线较陡。[5][6]

### 框架四：[[Microsoft's agent framework]] (多智能体编排)
- **核心特点**：[[Autogen]] 的演进，专注多智能体协同团队作战。API 仍在演进中。[6][8]
- **技术机制**：采用基于图的工作流系统（[[graphbased workflow system]]），通过定义节点（[[nodes]]）和边缘（[[edges]]）控制信息流。具备事件驱动（[[event driven]]）特性。[6]
- **高级功能**：支持群聊（[[group chat]]）、检查点（[[checkpointing]]，可暂停/恢复长流程）、人类在环（[[human in the loop]]）。[6][8]

### 框架五：[[OpenAI's official agents SDK]] (轻量级生产利器)
- **核心特点**：极简抽象，最大化能力。提供 5 个核心原语（讲者原话）：智能体、交接、护栏（[[guard rails]]）、会话和内置追踪（[[tracing]]）。[8]
- **优势**：自动管理智能体循环（包含 [[LLM]] 调用、工具处理和无缝交接）。支持快速从零到运行智能体（几分钟内，讲者原话）。[9][2]
- **生态限制**：目前仅支持 [[Python]]，即将支持 [[JavaScript]]。虽在技术上支持多供应商，但高度针对 [[OpenAI]] 优化。[9]

### 框架横向对比与选型指南
- **易用性与速度**：[[Langchain]] 和 [[OpenAI's official agents SDK]] 胜出。[2]
- **知识检索 ([[rag]])**：[[Llama Index]] 是无可争议的冠军。[2]
- **企业级特性**：[[semantic kernel]] 是首选。[2]
- **多智能体编排**：选择 [[Microsoft's agent framework]]。[2]
- **最终结论**：框架互不排斥，生态系统正在通过 [[Agentics AI Foundation]] 等标准走向互操作性。选择应基于具体用例的属性驱动。[2][3]

## 金句亮点
- "If lang chain is the Swiss Army knife llama index is the precision scalpel for knowledge inensive work." — 概念类 / 通过生动的隐喻精准界定不同框架的核心定位。[4]
- "The ecosystem is moving toward interoperability especially with standards like the agentic AI foundations protocols."（意译） — 行业洞察类 / 揭示了框架孤岛即将打破、走向标准化的未来发展方向。[3]

## 行动建议
- **做什么**：用讲者提供的“五问评估法”（构建什么、是否知识密集、需不需要多智能体、是否面向企业部署、是原型还是生产）分析自己的 AI 需求，以选择单一或组合框架。[3]
- **关联观点**：1
- **验证标准**：产出一份基于这五个问题回答的架构选型文档，并明确得出应采用的框架名称。

## 概念图谱
- **上位概念**：[[Agentic AI]]（或 [[AI agents]]、[[autonomous systems]]）[1]
- **核心概念**：[[Agentic AI frameworks]] [1]
- **下位概念**：[[Langchain]]、[[Llama Index]]、[[Semantic Kernel]]、[[Agent framework]]、[[OpenAI agents SDK]]、[[RAG]] (retrieval augmented generation)、[[Multi-agent orchestration]] [2-6]

## 因果关系链
- 追求快速原型设计或多步推理（条件） → 使用 [[Langchain]] 拼接 LLM 调用与工具（过程） → 实现10行代码内快速构建智能体（结果）[1, 2]
- 需要处理海量文档与数据（条件） → 应用 [[Llama Index]] 进行语义搜索和数据管道构建（过程） → 实现精准的知识检索与问答（结果）[3, 7]
- 部署需要遥测、安全和治理的企业级应用（条件） → 采用 [[Semantic Kernel]] 封装插件和集成 API（过程） → 建立稳健且多语言支持的生产环境（结果）[4, 5, 7]
- 面对复杂的协同工作场景（条件） → 使用 [[Agent framework]] 构建事件驱动的图基工作流（过程） → 实现不同专长智能体的讨论、决策与人工干预（结果）[5, 6]
- 追求极简抽象与最高控制力（条件） → 使用 [[OpenAI agents SDK]] 自动化智能体循环（过程） → 实现无缝的智能体移交（handoffs）与内置追踪（后果）[6, 8]
- 行业建立开放协议与互操作性标准（原因） → 不同框架的优势能力互相结合（过程） → 开发者可混合调用不同框架（结果）[2, 9, 10]

## 历史背景与发展脉络
- 2022年：[[Langchain]] 面世，开创了将 LLM 调用与工具进行链式组合（chaining）的概念 [1]。
- 2023年：专注 [[RAG]] 的 [[Llama Index]] 出现；微软推出企业级中间件 [[Semantic Kernel]] [1, 2]。
- 2024年：OpenAI 发布官方 agents SDK；同年晚些时候，微软整合其早期工作（如 Autogen的演进）推出了统一的 [[Agent framework]] [2, 5]。
- 2025年：OpenAI、微软、Anthropic 及其他主要参与者共同成立了 Agentics AI Foundation，致力于开发开放协议以实现不同智能体的协同工作 [2]。

## 常见误解澄清
- **误解：** 不同的 Agentic AI 框架是互斥的，开发者只能在其中选择一个使用。
- **澄清：** 这些框架并非互斥（not mutually exclusive），生态系统正在朝着互操作性发展。开发者可以将它们组合使用，例如使用 [[Llama Index]] 进行检索并将其结果输入给 [[Langchain]] 智能体，或者在 [[Agent framework]] 工作流中调用 [[Semantic Kernel]] 的插件 [9, 10]。

## 类比与通俗解释
- **[[Langchain]] 的模块化**：视频将其类比为“AI的乐高积木（Lego blocks for AI）”，可以通过各种链（chains）、智能体（agents）和记忆系统组装出所需的功能 [2]。
- **[[Langchain]] 与 [[Llama Index]] 的定位对比**：如果说 Langchain 是功能全面的“瑞士军刀（Swiss Army knife）”，那么 Llama Index 就是专门用于知识密集型工作的“精密手术刀（precision scalpel）” [3]。
- **[[Semantic Kernel]] 的工作原理**：将 Kernel functions 通俗解释为围绕代码或提示词的“包装器（wrappers）”，这些包装器进一步被组织为代表整个 API 或服务的插件 [4]。
- **[[Agent framework]] 的多智能体协作**：将其类比为“一个团队（a team）”，在这个团队中，一个智能体负责计划，一个负责编写代码，另一个负责审查，它们彼此之间实时沟通和协作 [5]。

## 关键概念

### [[Langchain]]
- **定义**：一个通过将大型语言模型调用与工具链接在一起，赋予 AI 多步骤解决问题能力的模块化框架 [1]。
- **视频上下文**：作者将其形容为“AI 的乐高积木”，具有强大的集成能力，能与数百种不同的模型和自定义 API 连接 [2, 3]。
- **为什么重要**：它是最流行、最容易上手的框架之一，能够让开发者在不到 10 行代码内快速构建代理 [2]。
- **关联概念**：对比 → [[Llama Index]] 

### [[Llama Index]]
- **定义**：一个专为处理大规模数据集语义搜索和知识密集型工作而设计的框架 [3, 4]。
- **视频上下文**：视频将其与 Langchain 的“瑞士军刀”相对比，称其为知识检索的“精准手术刀”，并强调了其索引、向量库和数据管道能力 [3, 4]。
- **为什么重要**：在知识检索方面具有无可争议的统治地位，支持任意数据源的智能检索和理解 [4, 5]。
- **关联概念**：依赖 → [[RAG (Retrieval Augmented Generation)]]

### [[RAG (Retrieval Augmented Generation)]]
- **定义**：一种检索增强生成技术，用于在 AI 需要处理特定文档和私有数据时提供支持 [1, 3]。
- **视频上下文**：视频在回顾 2023 年 Llama Index 的崛起时重点提到该术语，将其作为该框架的核心专长 [1, 3]。
- **为什么重要**：它是构建文档问答系统、研究助手以及数据驱动型聊天机器人的核心技术基础 [4]。
- **关联概念**：属于 → [[Llama Index]] 

### [[Semantic Kernel]]
- **定义**：微软推出的一款内置遥测、安全和治理功能的企业级中间件解决方案 [2, 6]。
- **视频上下文**：视频提到它通过封装代码的“内核函数”（kernel functions）和插件体系工作，支持多语言和模型无关的设计 [6]。
- **为什么重要**：它是为生产环境和企业级部署量身定制的框架，适合将 AI 嵌入到现有的公司应用程序中 [6, 7]。
- **关联概念**：未明确提及

### [[Agent Framework]]
- **定义**：微软基于图工作流系统（graphbased workflow system）构建的事件驱动型框架，专注于多代理协同 [7]。
- **视频上下文**：作者指出它是 Autogen 的演进版，通过节点和边缘定义代理间的信息流，并支持群聊、检查点和人类在环反馈等功能 [7, 8]。
- **为什么重要**：它代表了前沿的复杂协作模式，适用于需要代理进行沟通、协商或具备不同专长的复合型任务 [8]。
- **关联概念**：依赖 → [[Multi-agent orchestration]] 

### [[Multi-agent orchestration]]
- **定义**：多智能体编排，指让多个专业化的 AI 代理像团队一样沟通并协作完成任务的机制 [7]。
- **视频上下文**：视频以“编写代码的代理和审查代码的代理”协同工作为例，说明了这种模式的实际应用场景 [7]。
- **为什么重要**：它打破了单一 AI 代理的限制，使得处理高度复杂的分布式场景成为可能 [7, 8]。
- **关联概念**：属于 → [[Agent Framework]]

### [[OpenAI Agents SDK]]
- **定义**：OpenAI 官方提供的一个具有最少抽象、专为快速原型设计和生产就绪打造的轻量级开发包 [2, 8]。
- **视频上下文**：视频强调它自动化了代理循环，仅提供代理交接（handoffs）、护栏、会话追踪等核心原语，让系统开发异常简单 [8, 9]。
- **为什么重要**：在纯粹的性能、轻量化和生产就绪度方面表现优异，尤其适合快速构建基于 OpenAI 模型的应用 [5, 9]。
- **关联概念**：未明确提及

### [[Agentic AI Foundation]]
- **定义**：由 OpenAI、Microsoft、Anthropic 等主要公司于 2025 年共同成立的致力于制定开放协议的组织 [2]。
- **视频上下文**：视频在介绍生态系统互操作性时提到，该基金会正在制定协议让不同的代理能跨框架合作 [2, 10]。
- **为什么重要**：它推动了不同框架与系统之间的生态互操作性，塑造了 AI 代理协同的未来标准 [10]。
- **关联概念**：未明确提及

## 概念关系图
- [[Llama Index]] → 依赖 → [[RAG (Retrieval Augmented Generation)]]
- [[Agent Framework]] → 依赖 → [[Multi-agent orchestration]]
- [[Langchain]] ↔ 对比 ↔ [[Llama Index]]

## 行动项

- [ ] **回答项目用例的具体问题** [1]
  - 目的：明确项目是否为知识密集型、是否需要多 Agent、用于企业部署还是原型设计，从而选择最合适的 AI 框架 [1]
  - 难度：未明确提及
  - 预估时间：未明确提及
  - 相关工具或资源：未明确提及

- [ ] **使用少于 10 行代码启动 Agent** [2]
  - 目的：利用模块化的组件快速构建原型，测试多步推理或 RAG 工作流 [2, 3]
  - 难度：简单 [2]
  - 预估时间：几分钟 [4]
  - 相关工具或资源：Langchain [2]

- [ ] **通过 Llama Hub 连接外部数据源** [3, 5]
  - 目的：为 Agent 接入海量文档、PDF 或数据库，实现精确的检索增强生成（RAG）和语义搜索 [3, 5]
  - 难度：未明确提及
  - 预估时间：未明确提及
  - 相关工具或资源：Llama Index, Llama Hub [3, 5]

- [ ] **创建 kernel functions 并组织成 plugins** [6]
  - 目的：在企业级应用中将代码或 prompt 封装为 API 或服务，让 AI 可以进行智能调用并实现业务流程自动化 [6]
  - 难度：困难 [7]
  - 预估时间：未明确提及
  - 相关工具或资源：Semantic kernel [6]

- [ ] **定义 nodes 和 edges 构建图基工作流（graphbased workflow）** [7]
  - 目的：规定信息在多个专业 Agent 之间的流向及触发条件，实现复杂的团队协作、讨论和代码审查 [7, 8]
  - 难度：困难 [8]
  - 预估时间：未明确提及
  - 相关工具或资源：Agent framework [7]

- [ ] **使用 instructions 和 tools 定义 Agent** [9]
  - 目的：利用官方 SDK 自动处理大语言模型调用、工具执行以及不同 Agent 之间的无缝切换（handoffs） [8, 9]
  - 难度：简单 [8]
  - 预估时间：未明确提及
  - 相关工具或资源：OpenAI agents SDK [8, 9]

- [ ] **在评论区留言** [1]
  - 目的：分享自己最期待的 AI 框架并与创作者互动 [1]
  - 难度：未明确提及
  - 预估时间：未明确提及
  - 相关工具或资源：未明确提及

## 附件

- 思维导图：[[_附件/mindmaps/8Lf_3CxdLlM.json]]
- 学习指南：[[_附件/8Lf_3CxdLlM_study_guide.md]]

---
*自动生成于 2026-03-19 23:15 | [原始视频](https://www.youtube.com/watch?v=8Lf_3CxdLlM)*

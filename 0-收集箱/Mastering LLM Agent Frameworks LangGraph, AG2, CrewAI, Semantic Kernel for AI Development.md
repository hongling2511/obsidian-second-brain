---
type: youtube
title: "Mastering LLM Agent Frameworks: LangGraph, AG2, CrewAI, Semantic Kernel for AI Development"
channel: "[[Shane | LLM Implementation]]"
url: https://www.youtube.com/watch?v=VC2uDeJg98s
video_id: VC2uDeJg98s
date_watched: 2026-03-19
date_published: 2025-05-30
duration: "1:33:31"
content_type: tech_tutorial
one_line_summary: "本视频演示并对比了构建多智能体系统的四大核心框架（[[LangGraph]]、[[AG2]]、[[CrewAI]]、[[Semantic Kernel]]）的代码实现与底层机制。"
rating: 4
rating_detail:
  信息密度: 4
  实用性: 5
  新颖性: 4
related_concepts:
  - "[[LangGraph]]"
  - "[[Time travel]]"
  - "[[Human in the loop]]"
  - "[[Conversable Agent]]"
  - "[[Group Chat Pattern]]"
  - "[[Structured Outputs]]"
  - "[[Crews]]"
  - "[[Flows]]"
  - "[[Semantic Kernel]]"
  - "[[Plugins]]"
has_actions: true
tags:
  - LLM
  - AIAgents
  - AgentFrameworks
  - LangGraph
  - AutoGen
  - CrewAI
  - SemanticKernel
  - AIDevelopment
  - Python
  - AITutorial
  - Multi-AgentSystems
  - Chatbots
  - AIOrchestration
  - Human-in-the-loop
  - StateManagement
  - AIWorkflow
  - GenerativeAI
  - GoogleGemini
  - OpenAI
  - APIIntegration
  - LangGraphTutorial
  - AutoGenTutorial
  - CrewAITutorial
  - SemanticKernelTutorial
  - BuildAIAgents
  - FinancialComplianceAI
  - Tavily
  - SerperDev
  - TimeTravel
  - StructuredOutputs
  - Checkpointer
  - AG2
---

# Mastering LLM Agent Frameworks: LangGraph, AG2, CrewAI, Semantic Kernel for AI Development

---
tags:
  - 视频笔记
  - tech_tutorial
信息密度: 4/5 （推断）
实用性: 5/5 （推断）
新颖性: 4/5 （推断）
---

## 一句话总结
本视频演示并对比了构建多智能体系统的四大核心框架（[[LangGraph]]、[[AG2]]、[[CrewAI]]、[[Semantic Kernel]]）的代码实现与底层机制。

## 目标受众与前置知识
- **适合谁看**：希望学习如何构建多智能体工作流、对比不同智能体框架优劣的 AI 开发者（推断）。
- **前置知识**：[[Python]] 编程基础、大型语言模型（[[LLM]]）与智能体（Agent）的基础运行逻辑（推断）。

## 核心观点
1. **[[LangGraph]] 专注于细粒度、有状态的底层编排**
   - 为什么重要：它允许开发者通过节点和边精确控制长时间运行的任务，并保持智能体间的共享记忆。
   - 依据：视频演示了如何通过状态图（State Graph）构建聊天机器人，支持中途暂停的人类在环（Human-in-the-loop）审查以及“时间旅行”状态回溯。
2. **[[AG2]] 提供开箱即用的生产级多智能体协作**
   - 为什么重要：基于自动化的群聊（Group Chat）模式和结构化输出，非常适合复杂的企业级业务流。
   - 依据：视频演示了包含财务助手和总结助手的财务合规审核系统，能够自动依据条件交接任务并输出 JSON 格式的审查报告。
3. **[[CrewAI]] 提供高度独立的“基于角色”的工作流控制**
   - 为什么重要：通过精细分工的团队（Crews）和事件驱动的执行流（Flows），平衡了智能体的自主性与确定性控制。
   - 依据：视频展示了给智能体分配特定的角色（如高级数据研究员）和目标，并使用基于事件监听的 Flows 进行条件路由。
4. **[[Semantic Kernel]] 是连接模型与外部插件的核心枢纽**
   - 为什么重要：它提供了一个统一的标准来管理聊天补全服务，并能无缝触发外部代码函数。
   - 依据：讲者通过一个“菜单助手”示例，演示了内核如何自动拦截用户查询并调用对应的获取特价菜和计算价格（9.99 美元，讲者原话）的 Python 插件函数。

## 概念关系
- [[LangGraph]] → [[LangChain]]：依赖（LangGraph 建立在 LangChain 之上，为其扩展了构建有状态多参与者应用的能力）。
- [[CrewAI]] ↔ [[LangChain]]：对比（CrewAI 是完全从头使用定制代码构建的独立 Python 框架，不依赖 LangChain）。
- [[Crews]] ↔ [[Flows]]：对比（在 [[CrewAI]] 中，Crews 适合开放式探索任务，Flows 适合需要精准控制的确定性流程）。
- [[Plugins]] → [[Semantic Kernel]]：依赖（插件或内核函数为 Semantic Kernel 提供了执行具体外部任务和获取数据的能力）。

## 详细笔记
### 导言
- Shane（讲者频道名 Shane | LLM Implementation）介绍本期视频目标：通过官网示例了解主流智能体框架的运作原理，为未来实现“智能体间通信”等高级概念打下基础。

### [[LangGraph]] 基础与实战
- **核心概念**：底层编排框架，核心是状态图（State Graph）。节点（Nodes）代表工作单元（如大模型调用），边（Edges）代表节点间的流转。
- **构建聊天机器人**：
  - 引入核心库并接入 [[Google]] 的 [[Gemini]] 模型。
  - **工具集成**：接入名为 [[Tavily]] 的网络搜索工具API。使用条件边（Conditional edges）让模型自主判断是否需要调用该工具。
  - **记忆持久化**：使用 Checkpointer 记录对话线程（Thread ID）。演示中，讲者告诉机器人“我的名字叫 Will”，系统能在后续交互中准确回忆起该名字。
  - **人类在环（Human-in-the-loop）**：通过 `interrupt` 函数在关键节点暂停执行。演示场景为审查某个库的发布日期，讲者手动通过命令对象修改并纠正日期为“2024 年 1 月 17 日”（讲者原话），随后系统恢复运行并输出正确结果。
  - **时间旅行（Time travel）**：依赖检查点记录的步骤状态，允许开发者传入特定的状态 ID，将对话回溯到过去的特定节点，探索不同的对话分支。

### [[AG2]] (Agent OS) 基础与实战
- **核心概念**：基于 [[Autogen]] 团队开发，以 Conversable Agent 为核心构建块。
- **财务合规助手实战**：
  - 引入 [[OpenAI]] 的 [[GPT-4o mini]] 模型，并将温度（Temperature）设为 0.2 以确保输出的一致性（讲者原话）。
  - **人类输入模式**：设置财务助理在遇到异常大额（如超过 10,000，讲者原话）或可疑供应商交易时，暂停请求人类审批。
  - **群聊模式（Group Chat）**：配置一个经理（Manager）调度财务助手与总结助手。财务助手处理交易并调用模拟的“重复支付检查数据库”工具；处理完毕后，触发标记将对话移交给总结助手。
  - **结构化输出**：强制总结助手遵循预设的数据模型，直接输出格式化的 JSON 审计日志，而非无结构的文本。

### [[CrewAI]] 基础与实战
- **项目初始化**：
  - 工具链：环境要求高于 [[Python]] 3.10 且低于 3.13（讲者原话）。强烈推荐使用 [[Rust]] 构建的包管理器 [[UV]]，讲者指出它旨在替代 [[pip]] 和 [[pip-tools]]，速度比传统 pip 快 10 到 100 倍（讲者原话）。讲者在 [[macOS]] 环境下演示了建构过程。
  - 默认配置：创建项目，依然使用 [[Gemini]] 的 2.5 flash 模型（讲者原话）。
- **Crews（团队）工作流**：
  - 使用 YAML 模板定义角色。演示创建了“高级数据研究员”与“报告分析师”。
  - 任务分配：研究员使用 [[Serper Dev Tool]] 网络搜索工具寻找 2025 年当月的最新 AI 模型资讯，分析师负责扩写并输出 Markdown 报告。
- **Flows（事件驱动流程）工作流**：
  - 使用 `@start` 和 `@listen` 装饰器控制方法执行顺序。
  - **状态管理**：默认使用本地的 [[SQLite]] 数据库存储流状态（讲者原话）。支持无结构状态（灵活追加属性）与结构化状态（受限于数据模型，提供类型安全）。
  - **高级逻辑控制**：演示了 `OR` 条件（任何一个前置任务完成即触发）、`AND` 条件（等待所有前置任务完成）以及使用 `router` 装饰器进行 True/False 分支路由控制。

### [[Semantic Kernel]] 基础与实战
- **核心架构**：作为枢纽，连接外部 AI 服务（支持 [[OpenAI]]、[[Azure]]、[[Hugging Face]]、[[Mistral]] 以及 [[Google]] 模型）与插件。
- **构建菜单助手**：
  - 实例化代理并分配大模型服务（讲者在代码示例中使用了 [[Gemini]] 模型）。
  - **插件注册**：定义两个 Kernel Function（带有装饰器的 Python 函数）。一个是获取特价菜单（包含 Clam chowder, Cob salad, Chai tea），另一个是查询价格（返回 9.99 美元，讲者原话）。
  - **执行与回调**：当用户询问特价汤及其价格时，内核自动拦截对话，调用 Python 代码执行，并利用回调函数在控制台打印工具调用的底层细节。
- **展望**：讲者提及自己曾使用 [[Google Agent Development Kit]] 构建过多智能体工作流来优化 [[YouTube]] 视频的标题与描述，并表示 Semantic Kernel 内部的智能体编排功能（Agent Orchestration）尚在实验阶段，未来再做深入探讨。

## 金句亮点
- “think of it as a conductor for a symphony it helps organize multiple agents to work together” — 意译：[[LangGraph]] 就像交响乐的指挥，负责协调多个智能体协同工作、共享内存并解决复杂任务。（知识类 / 核心比喻）

## 行动建议
- **做什么**：使用 [[UV]] 工具包初始化一个新的 [[CrewAI]] 项目，并在 YAML 文件中自定义两个角色（如编写者与审核者）。
- **关联观点**：3
- **验证标准**：通过终端运行命令，成功看到两个智能体自动交互并输出最终协作文本文件。
- **做什么**：在 [[LangGraph]] 环境中复现“时间旅行”演示代码，提取某次对话中间步骤的 Checkpoint ID 并重新触发运行。
- **关联观点**：1
- **验证标准**：控制台输出证明系统准确地从该 Checkpoint ID 对应的历史节点恢复了对话状态，而非重新开始。

## 技术栈与环境要求
- **核心技术**：[[LangGraph]], [[LangChain]], [[Google Gemini]], [[Tavily]], [[AG2]], [[AutoGen]], [[OpenAI]], [[CrewAI]], [[uv]], [[Python]], [[Semantic Kernel]], [[Azure OpenAI]] [1-8]。
- **环境要求**：
  - 操作系统：包含 MacOS 演示 [7]。
  - 软件版本：[[Python]] 版本需大于 3.10 且小于 3.13（视频演示环境为 3.11.8）[7, 9]。
  - 依赖配置：[[AG2]] 演示使用的 [[OpenAI]] 模型为 GPT-4 mini，且配置 temperature 为 0.2 [10]；[[CrewAI]] 演示配置了 Gemini 2.5 flash 模型 [11]。
- **前置技能**：未明确提及。

## 步骤拆解
1. **构建 [[LangGraph]] 状态图与代理**
   - 具体操作描述：安装核心库与 Google 扩展并重启环境；定义 `state` 类以追加（而非覆盖）对话消息；初始化 `state graph` 并通过 Google Studio API key 接入 [[Google Gemini]] 节点；编译状态图并设置边（edges）控制执行流；接入 [[Tavily]] 工具并通过条件边（conditional edges）建立循环；利用 `checkpointer` (MemorySaver) 绑定 unique thread ID 实现记忆和状态持久化；通过 `interrupt` 函数植入 human in the loop 暂停执行等待人类反馈；利用 thread ID 传入历史检查点实现 Time travel 状态回溯 [2, 3, 12-19]。
   - 关键代码/命令：未明确提及。
   - 注意事项：设置工具调用时，必须设置条件边将流程从 chatbot 节点路由到 tool 节点，完成后再循环回 chatbot 节点 [14]。

2. **构建 [[AG2]] 金融合规多智能体系统**
   - 具体操作描述：安装带有 OpenAI 扩展的 [[AG2]]；配置 LLM 参数；通过修改 `human input mode` 参数引入人工审批环节；使用 `group chat pattern` 配置 Manager 代理根据上下文自动选择下一个发言者（如 Finance bot 或 Summary bot）；通过 mock 函数注册 duplicate payment checker 外部工具；定义数据模型并为特定代理启用 `structured outputs`（如 JSON 格式输出）[5, 10, 20-24]。
   - 关键代码/命令：未明确提及。
   - 注意事项：配置终止条件时，可以设定在聊天中检测到特定标记（如“summary generated”）时自动终止会话 [21]。

3. **初始化与运行 [[CrewAI]] 项目**
   - 具体操作描述：创建虚拟环境并激活；使用依赖管理器 [[uv]] 安装 [[CrewAI]] CLI；使用命令创建项目，录入提供商（Gemini）、模型及 API key；在自动生成的 `agents.yaml` 和 `tasks.yaml` 中配置角色属性与任务要求；运行环境安装命令并执行 Crew。在 Flows 模块中，利用装饰器标记起点、监听器和路由，并通过 kickoff 启动执行流 [7, 11, 25-30]。
   - 关键代码/命令：`crewai install` [30], `crewai flow kickoff` [30]。
   - 注意事项：在 Flow 中传递状态时，每个状态实例会自动分配唯一的 identifier 供追踪，无需手动管理 [31]。

4. **配置 [[Semantic Kernel]] 代理环境**
   - 具体操作描述：安装包并创建虚拟空间；配置 [[Google Gemini]] 的 chat completion 服务；使用 `kernel_function` 装饰器定义插件（如菜单查询工具）；配置 callback function 遍历内部步骤，追踪工具调用、工具结果和信息发送者角色；使用异步函数初始化代理并绑定插件，最后建立 chat history thread 保持多轮对话的上下文 [32-36]。
   - 关键代码/命令：未明确提及。
   - 注意事项：如果 Kernel 中配置了多个聊天完成服务，可以通过 selector 显式指定代理应使用哪一个服务；若不指定则应用默认规则 [37]。

## 常见坑与解决方案
- **问题描述**：运行 [[CrewAI]] flow 时遇到 [[OpenAI]] 身份验证错误（Authentication error for OpenAI）[30]。
  - 解决方案：检查环境文件（.env），将占位符替换为真实的 API key [30]。

## 最佳实践
- **降低大模型发散性**：在配置 [[AG2]] 的金融分析等要求严谨的代理时，推荐将 LLM 的 temperature 设置为 0.2，以确保结果的一致性和可靠性 [10]。
- **解耦结构化输出配置**：在 [[AG2]] 中使用结构化输出时，推荐为需要特定格式的代理（如总结代理）单独创建 LLM 配置（指定 data models），而其他不强制要求格式的代理继续使用标准配置，使系统指令更简洁 [23, 24]。
- **项目结构分离**：在构建 [[CrewAI]] 项目时，推荐将代理和任务分离，使用 YAML 模板进行配置 [11]。
- **Crews 与 Flows 选型**：在 [[CrewAI]] 框架下，若进行开放式解决问题、创造性协作或探索性任务，推荐使用 Crews；若需要确定性结果、可审计性或对执行路径的精确控制，推荐使用 Flows [9]。
- **Flow 状态管理选型**：在 [[CrewAI]] flows 中，如果工作流状态简单、变化频繁或在制作原型，推荐使用非结构化状态（unstructured state management）；当需要一致性、明确类型定义验证或利用代码补全特性时，推荐使用结构化状态（structured state management）[38]。

## 关键概念

### [[LangGraph]]
- **定义**：构建在LangChain之上，充当编排和管理长时间运行的、具有状态的AI代理的底层框架 [1]。
- **视频上下文**：作者将其比作交响乐的指挥，通过节点（nodes）、边（edges）和状态图（state graph）来组织聊天机器人的运行流程 [1, 2]。
- **为什么重要**：它解决了简单线性模型应用无法处理的复杂逻辑，能够管理状态、处理条件逻辑并支持迭代和自我纠错行为 [3]。
- **关联概念**：扩展 → [[Time travel]]

### [[Human in the loop]]
- **定义**：一种在AI执行流程中引入人类监督的机制，允许人类在关键时刻进行指导或审批 [4, 5]。
- **视频上下文**：在LangGraph中，作者通过 `interrupt` 函数暂停工作流以获取人类的反馈和纠错 [4, 6]；在AG2中，用于让金融助手在遇到大额或可疑交易时请求人类审批 [7, 8]。
- **为什么重要**：它能有效应对AI代理的不可预测性，确保复杂或敏感任务在执行前得到人类确认，保证系统平稳运行 [4, 9]。
- **关联概念**：未明确提及

### [[Time travel]]
- **定义**：LangGraph中的一项内置功能，允许用户回溯到对话历史中的特定状态节点（检查点），并尝试不同的对话路径 [10, 11]。
- **视频上下文**：作者展示了如何利用保存了线程ID的检查点，精确加载历史对话中的某个时刻（如包含4条消息的状态），从该点重新开始交互 [12, 13]。
- **为什么重要**：为调试应用、修正AI错误、探索新策略以及开发自主软件工程等复杂应用提供了极大的灵活性 [11, 13]。
- **关联概念**：依赖 → [[LangGraph]]

### [[Conversable Agent]]
- **定义**：AG2框架的核心构建块，用于配置大型语言模型，使其能够与其他代理或人类无缝交互 [5, 14]。
- **视频上下文**：作者在构建金融合规系统时，使用它初始化了具备不同角色提示词的代理（如金融助手和总结助手），并将其与AI模型绑定 [7, 15, 16]。
- **为什么重要**：它是AG2中搭建多代理协作网络和人类介入机制的最基础单元 [5, 14]。
- **关联概念**：未明确提及

### [[Group Chat Pattern]]
- **定义**：AG2中协调多个专业代理协同工作的一种高级编排模式 [17]。
- **视频上下文**：作者配置了一个带有组管理器（group manager）的自动选择模式，使金融助手在处理完交易后，自动将对话控制权移交给总结助手生成报告 [17-19]。
- **为什么重要**：它使多代理系统能够自主协作和管理对话流转，实现高度自动化的复杂任务处理 [17]。
- **关联概念**：依赖 → [[Conversable Agent]]

### [[Structured Outputs]]
- **定义**：强制AI代理输出一致且格式定义明确的响应（如结构化的JSON字符串）的功能 [5, 20, 21]。
- **视频上下文**：在AG2示例中，作者为总结助手的语言模型单独配置了数据模型格式（审计日志摘要），以确保输出符合预期格式，并以此作为聊天终止的条件 [20, 21]。
- **为什么重要**：它消除了在系统消息中编写冗长格式指令的需求，是确保AI与其他软件系统可靠集成的关键 [20, 21]。
- **关联概念**：未明确提及

### [[Crews]]
- **定义**：CrewAI框架中管理AI代理团队的顶层组织结构，优化自主性和协作智能 [22, 23]。
- **视频上下文**：作者通过一个“最新AI发展研究”示例，展示了如何用Crews管理高级数据研究员和报告分析师协同完成开放式任务 [24-26]。
- **为什么重要**：它是处理开放式研究、自主问题解决和创造性协作任务的推荐结构 [27]。
- **关联概念**：对比 → [[Flows]]

### [[Flows]]
- **定义**：CrewAI中用于构建结构化、事件驱动流程的编排机制，可以连接不同的任务或AI团队 [28]。
- **视频上下文**：作者演示了如何通过装饰器（如 `@start` 和 `@listen`）串联任务，实现状态管理、条件路由以及不同任务间的输出传递 [29-31]。
- **为什么重要**：当项目需要确定性结果、流程可审计或对执行路径需要精确控制（如决策工作流）时，Flows是必不可少的 [27]。
- **关联概念**：对比 → [[Crews]]

### [[Semantic Kernel]]
- **定义**：一个充当中央枢纽的AI应用框架，负责无缝管理和连接AI服务与插件 [32]。
- **视频上下文**：作者解释了它如何作为中间人，接收用户请求，调用配置的AI模型（如OpenAI或Azure），处理结果并触发应用事件 [32]。
- **为什么重要**：提供了一种高度模块化的方式，将各种语言模型服务和外部操作工具整合到一个流线型的应用流程中 [32, 33]。
- **关联概念**：依赖 → [[Plugins]]

### [[Plugins]]
- **定义**：Semantic Kernel框架中，AI服务和提示可以调用的附加组件或外部工具 [33]。
- **视频上下文**：作者构建了一个菜单助手示例，其中的插件包含了获取特价菜和查询价格的内核函数（Kernel Function），AI会在对话中按需调用这些函数 [34-36]。
- **为什么重要**：它赋予了AI模型突破文本生成限制的能力，使其能够拉取外部系统数据或执行特定的实际操作 [33]。
- **关联概念**：依赖 → [[Semantic Kernel]]

## 概念关系图
- [[Time travel]] → 依赖 → [[LangGraph]]
- [[Group Chat Pattern]] → 依赖 → [[Conversable Agent]]
- [[Crews]] ↔ 对比 ↔ [[Flows]]
- [[Plugins]] → 依赖 → [[Semantic Kernel]]

## 行动项

- [ ] **检查并配置 Python 虚拟环境**
  - 目的：确保满足 CrewAI 的版本要求，并在隔离的空间中保持开发环境整洁 [1, 2]。
  - 难度：未明确提及
  - 预估时间：未明确提及
  - 相关工具或资源：Python（版本需高于 3.10 且低于 3.13） [1]

- [ ] **安装并使用 UV 包管理器**
  - 目的：替代 pip 和 pip tools，从而以 10 到 100 倍的速度更高效地安装项目依赖 [2]。
  - 难度：未明确提及
  - 预估时间：未明确提及
  - 相关工具或资源：UV [2]

- [ ] **注册并配置大模型与搜索工具的 API Key**
  - 目的：为 Agent 框架接入底层语言模型和网络搜索能力提供身份认证凭证 [3-5]。
  - 难度：未明确提及
  - 预估时间：未明确提及
  - 相关工具或资源：Google Studio（用于获取 Geminy 密钥） [3]、OpenAI [5]、Tavali（用于 Web 搜索，提供 1000 个免费额度） [4]

- [ ] **将大语言模型的 Temperature 参数调至 0.2**
  - 目的：降低模型生成的随机性，确保在 AG2 框架中处理财务合规等任务时获得更加一致和可靠的结果 [6]。
  - 难度：未明确提及
  - 预估时间：未明确提及
  - 相关工具或资源：AG2 框架、OpenAI GPT-4 mini [6]

- [ ] **使用命令行初始化 CrewAI 项目结构**
  - 目的：生成项目模板，自动建立包含 `agents.yaml`、`tasks.yaml` 配置文件及主要逻辑脚本的目录结构 [7, 8]。
  - 难度：未明确提及
  - 预估时间：未明确提及
  - 相关工具或资源：CrewAI CLI [2]

- [ ] **查阅 LangGraph 进阶官方文档**
  - 目的：在熟悉基础功能后，进一步探索如何进行项目部署及使用高级平台功能 [9]。
  - 难度：未明确提及
  - 预估时间：未明确提及
  - 相关工具或资源：Langraph server quick start、Langraph platform quickart [9]

## 附件

- 思维导图：[[_附件/mindmaps/VC2uDeJg98s.json]]
- 学习指南：[[_附件/VC2uDeJg98s_study_guide.md]]

---
*自动生成于 2026-03-19 22:01 | [原始视频](https://www.youtube.com/watch?v=VC2uDeJg98s)*

---
type: youtube
title: "Andrew Ng Explores The Rise Of AI Agents And Agentic Reasoning | BUILD 2024 Keynote"
channel: "[[Snowflake Inc.]]"
url: https://www.youtube.com/watch?v=KrRD7r7y7NY
video_id: KrRD7r7y7NY
date_watched: 2026-03-19
date_published: 2024-11-19
duration: "26:52"
content_type: knowledge
one_line_summary: "[[Andrew Ng]] 在 [[Snowflake]] 演讲中解析了 [[AI agents]] 的崛起，强调应用层机遇并拆解了提升模型性能的四种 [[Agentic workflows]] 模式。"
rating: 4
rating_detail:
  信息密度: 4
  实用性: 4
  新颖性: 4
related_concepts:
  - "[[Agentic AI workflows]]"
  - "[[Zero-shot prompting]]"
  - "[[Reflection]]"
  - "[[Tool use]]"
  - "[[Planning]]"
  - "[[Multi-agent collaboration]]"
  - "[[Large Multimodal Model (LMM)]]"
  - "[[Agentic orchestration layer]]"
has_actions: true
tags:
  - Snowflake
  - Snowflakedatawarehouse
  - Snowflakecomputing
  - Snowflakecompany
  - Snowflakedatabase
  - Snowflakecloud
  - Datawarehouse
  - Businesssoftware
  - Datawarehousing
  - Cloudstorage
  - cloudcomputing
  - DataScience
  - DataEngineering
  - TheDataCloud
  - bigdata
  - artificialintelligence
  - datascientist
  - predictiveanalytics
  - businessintelligence
  - dataeconomy
  - Datadriveneconomy
  - Datacloud
  - datalake
  - DataWarehouse
---

# Andrew Ng Explores The Rise Of AI Agents And Agentic Reasoning | BUILD 2024 Keynote

---
tags:
  - 视频笔记
  - knowledge / business
信息密度: 4/5
实用性: 4/5
新颖性: 4/5
---

## 一句话总结
[[Andrew Ng]] 在 [[Snowflake]] 演讲中解析了 [[AI agents]] 的崛起，强调应用层机遇并拆解了提升模型性能的四种 [[Agentic workflows]] 模式。

## 目标受众与前置知识
- **适合谁看**：AI 开发者、产品经理、企业技术决策者（推断）。
- **前置知识**：[[Generative AI]]、[[LLM]]、[[Zero shot prompting]]、[[Supervised learning]]。

## 核心观点
1. **AI 应用层蕴含最大的商业机遇**
   - 为什么重要：必须有应用层来创造价值和收入，以此负担底层技术提供商的成本。
   - 依据：讲者明确指出，虽然媒体炒作多集中在半导体和基础模型层，但应用层是必须取得更好发展的环节（讲者原话）。
2. **[[Generative AI]] 极大地加速了机器学习应用的开发速度**
   - 为什么重要：大幅降低了构建原型和发布新 AI 产品的门槛。
   - 依据：传统的 [[Supervised learning]]（如构建情绪分析模型）需要 6-12 个月（收集数据、训练、部署），而现在写提示词并在几天内（约 10 天）即可完成部署（讲者原话）。
3. **[[Agentic workflows]] 能够跨代际提升大模型的能力**
   - 为什么重要：打破了人类常用的 [[Zero shot prompting]] 的局限性，通过迭代产出更高质量的成果。
   - 依据：在 [[OpenAI]] 的 [[HumanEval]] 编码基准测试中，零样本的 [[GPT-3.5]] 准确率为 48%，零样本的 [[GPT-4]] 为 67%，而使用 Agentic workflow 的 [[GPT-3.5]] 准确率飙升至约 95%（讲者原话/屏幕展示）。
4. **视觉 AI 与 Agentic workflow 结合将解锁企业沉睡数据的价值**
   - 为什么重要：过去很难从存储在 blob storage 中的大量图像和视频中获取价值。
   - 依据：演示了使用 [[Vision Agent]] 自动执行诸如“在 5 秒片段中寻找足球进球（输出 True 10-15）”以及“寻找带彩虹背带的黑色行李箱”等复杂视觉任务（屏幕展示）。

## 概念关系
- [[Zero shot prompting]] ↔ [[Agentic workflows]]：前者是让 AI 从头到尾一次性输出（不修改），后者是类似人类写作的循环迭代（大纲→研究→起草→审查→修改）。
- [[Agentic workflows]] → [[LLM]] 性能提升：通过系统化的流程（如反思和多智能体协作），即使是较弱的基础模型（如 [[GPT-3.5]]）也能超越更强模型（如 [[GPT-4]]）的零样本表现。
- [[Generative AI]] → AI 产品开发速度：由于无需从头标注数据和训练模型，应用开发周期从数月缩短至几天。

## 详细笔记
### 开场与 AI 技术栈的新机遇
- [[Andrew Ng]] 提出 AI 是一种通用技术（General purpose technology），就像电力一样，将创造大量前所未有的应用机会。
- **AI 技术栈**：底层是半导体，往上是云基础设施（明确提及 [[Snowflake]]），再往上是基础模型训练者和模型，顶层是应用层。
- 虽然技术层的声量很大，但应用层是讲者认为最有潜力的领域，因为需要应用来产生收入反哺底层生态。

### [[Generative AI]] 加快开发周期
- 在传统的 [[Supervised learning]] 工作流中，开发一个声誉监控的情绪分析模型可能需要 6 到 12 个月（收集标签数据需 1 个月，训练需几个月，部署需几个月）。
- 借助生成式 AI，可以在几天内写好提示词并完成部署（整体约 10 天左右）。
- 这种范式的改变使得聪明的团队能够以前所未有的速度构建、实验和发布负责任的 AI 产品。

### 最重要的技术趋势：[[Agentic workflows]]
- 讲者认为目前 AI 领域最重要的技术趋势是 [[Agentic AI workflows]]（智能体 AI 工作流）或称 [[AI agents]]。
- 目前多数人使用大模型的方式是 [[Zero shot prompting]]，类似于让人类从头写到尾且不能用退格键。
- **Agentic workflow 流程**：要求 AI 先写大纲 → 决定是否需要网络研究并获取上下文 → 写初稿 → 审查初稿并提供批评 → 修改草稿并不断循环。
- 该工作流已被用于处理棘手的法律文件、医疗诊断辅助以及复杂的政府合规文书。
- **量化提升**：在 [[HumanEval]] 编码基准测试中，基于工作流的 [[GPT-3.5]]（原字幕记为 GB 3.5）准确率（~95%）远超零样本的 [[GPT-4]]（原字幕记为 GBD 4）（67%）。

### Agentic Workflows 的四种设计模式
1. **[[Reflection]]（反思）**：
   - 提示 [[LLM]] 充当程序员生成代码。
   - 将生成的代码复制回提示词中，要求同一个 [[LLM]] 充当批评者进行检查和挑错。
   - 使用反馈（或单元测试的结果）再次提示 [[LLM]] 改进代码。
2. **[[Tool use]]（工具使用）**：
   - 提示 [[LLM]] 生成 API 调用请求，使其能搜索网络、执行代码、处理客户退款、发送邮件或调用日历。
3. **[[Planning]]（规划/推理）**：
   - 面对复杂任务（如“生成一个女孩看书的图片”），[[LLM]] 能够规划执行步骤：先调用姿势检测模型（open pose model），再生成图片，最后用 TTS（文本转语音）生成音频（案例改编自 [[HuggingGPT]] 论文，原字幕记为 hugging GTP paper）。
4. **[[Multi-agent collaboration]]（多智能体协作）**：
   - 提示 [[LLM]] 在不同时间扮演不同角色（如编码员和审查员），这些模拟的智能体相互交互以解决任务。
   - 讲者类比这就像在 CPU 上运行多个进程，是帮助开发者将大任务分解为子任务的有用抽象。

### [[Vision Agent]] 与视觉 AI 应用
- 视觉 AI 能力结合 Agentic workflow 能够处理企业沉睡的图像/视频数据。
- 演示了 [[Vision Agent]] 的实际案例：
  - 提取足球比赛的进球片段（模型分析后输出特定时间戳）。
  - 在夜晚的场景中识别狼。
  - 在众多黑色行李箱中准确识别出“带有彩虹背带的黑色行李箱”。
- 讲者总结 AI 技术栈正在演进，涌现出类似 [[LangChain]]（原字幕记为 L chain）这样的新兴 **[[Agentic orchestration layer]]（智能体编排层）**。

## 金句亮点
- "I think AI is the new electricity." — 观点 / 强调 AI 作为通用技术的广泛影响力（讲者原话，意译）。
- "The improvement from GPT-3.5 to GPT-4 is dwarfed by the improvement from GPT-3.5 using an agentic workflow." — 价值 / 揭示了智能体工作流在提升模型能力上超越模型自身迭代的巨大潜力（讲者原话，意译）。

## 行动建议
- **做什么**：在代码生成或文本写作任务中，引入 [[Reflection]]（反思）模式，即将单次提示修改为“生成代码/文本 -> 将结果发回给模型要求其进行批评 -> 根据批评意见生成修改版”。
- **关联观点**：对应核心观点 3（Agentic workflows 能够跨代际提升大模型的能力）。
- **验证标准**：观察最终输出的代码或文本质量是否比一次性（Zero shot）生成的质量更高，错误率是否降低。

## 概念图谱
- **上位概念**：[[AI Stack]]（AI技术栈）、[[Generative AI]]（生成式AI） [1, 2]
- **核心概念**：[[Agentic AI workflows]]（智能体工作流/Agentic reasoning） [3]
- **下位概念**：[[Reflection]]（反思）、[[Tool use]]（工具调用）、[[Planning]]（规划）、[[Multi-agent collaboration]]（多智能体协作）、[[Large multimodal model]]（大型多模态模型/LMM）、[[Vision agent]]（视觉智能体） [4-6]

## 因果关系链
- 使用 [[Generative AI]] 缩短原型开发周期 → 团队采取快速迭代与多方案并行测试（Fast experimentation） → 创造出新的应用与用户体验 [7, 8]
- 模型生成与迭代速度远快于软件工程其他环节 → 给组织的运维与评估环节（Evals/Dev Ops）带来压力 → 促使开发者将测试数据收集从串行转变为并行构建 [9, 10]
- [[Agentic AI workflows]] 采用循环迭代（思考、搜索、评估、修改）机制 → 执行时间变长且消耗更多计算资源 → 显著提升复杂任务的输出质量与基准测试（如 HumanEval）得分 [4, 11, 12]
- 在 [[Multi-agent collaboration]] 中让模型扮演不同角色（如编码员和评论员）相互交互 → 复杂任务被拆解并由特定专长处理 → 在多种任务上获得大幅超越单一提示词的性能 [13]

## 历史背景与发展脉络
- 时间线上的关键节点：
  - **传统监督学习时代**：构建有价值的 AI 系统通常需要耗费 6 到 12 个月来收集标记数据、训练模型和部署 [7]。
  - **[[Generative AI]] 时代（当前）**：能够通过编写 Prompt 在几天内构建原型并部署，大幅降低试错成本 [7]。
  - **近期演进节点**：基础模型开始从“优化以回答人类问题”转向“专门为 [[Tool use]] 和智能体工作流优化” [14]。
- 重要人物和事件的作用：Anthropic 在几周前发布了支持计算机使用（computer use）的模型，这一事件标志着大语言模型专门针对智能体迭代工作流进行调整，大幅提升了相关应用的上限 [14]。

## 常见误解澄清
- **对“快速行动”的误解**：由于“Move fast and break things”（快速行动，打破常规）的口号曾带来负面破坏，人们误以为 AI 开发不应追求速度。澄清：更合理的原则是“Move fast and be responsible”，优秀的团队完全可以在不向外界发布有害内容的前提下，进行负责任的快速原型构建与稳健测试 [10]。
- **对 [[Agentic AI workflows]] 的神秘化认知**：人们常觉得智能体工作流很神秘。澄清：这并非魔法，当实际阅读其底层代码时，会发现它仅仅是基于简单的代码逻辑和 Prompt 循环（如自动反馈和修改机制） [4, 15]。
- **对 [[Multi-agent collaboration]] 必要性的质疑**：人们疑惑既然底层调用的是同一个大模型，为何还要虚构出多个智能体角色。澄清：让单一模型在不同阶段扮演具有特定专长的角色进行交互，是帮助开发者拆解子任务的极其有效的抽象方法，已被证明能大幅提升任务表现 [13]。

## 类比与通俗解释
- **将 AI 类比为电力（Electricity）**：用于解释 AI 是一种难以穷尽用途的“通用目的技术”（General purpose technology），它能创造海量过去不可能实现的新应用 [1]。
- **将 Zero-shot prompting（零样本提示）类比为“不按退格键写文章”**：生动解释了要求 AI 一口气从第一个词写到最后一个词且完全不回退修改的局限性和难度 [11]。
- **将 [[Agentic AI workflows]] 类比为人类的真实写作与研究过程**：通俗解释其运作逻辑就像人类写作时先拟大纲、查阅网页资料、写初稿、自我批判，最后反复修改的循环 [11, 12]。
- **将 [[Multi-agent collaboration]] 类比为 CPU 的多进程/多线程**：解释了虽然物理上是同一个处理器（同一个大模型），但划分多个进程（多智能体）能为开发者提供拆解复杂任务的有效抽象方式 [13]。
- **将 [[Multi-agent collaboration]] 类比为雇佣不同专长的员工**：通俗解释面对庞大任务时，就像雇佣一群智能体来分别完成不同的子任务，并通过协作交付更好的整体成果 [5]。

## 关键概念

### [[Agentic AI workflows]]
- **定义**：一种通过让 AI 进行思考、研究、反思和迭代来处理任务的复杂工作流，而非一次性生成输出 [1, 2]。
- **视频上下文**：作者将其视为当前最重要的 AI 技术趋势，并指出该工作流能大幅提升大语言模型在编程等基准测试中的表现 [2-4]。
- **为什么重要**：它打破了传统模型单次生成的局限性，在处理复杂的法律、医疗或编程任务时能产生好得多的结果 [1, 2]。
- **关联概念**：对比 → [[Zero-shot prompting]]

### [[Zero-shot prompting]]
- **定义**：要求 AI 仅通过一次提示从头到尾直接生成最终输出，中途不进行修改或迭代的方法 [1]。
- **视频上下文**：作者将其比作让人在不使用退格键的情况下从第一个词直接写到最后一个词，以此反衬 Agentic 工作流的优势 [1]。
- **为什么重要**：这是目前大多数人使用大语言模型的默认方式，但由于缺乏迭代，限制了模型输出的质量 [1]。
- **关联概念**：对比 → [[Agentic AI workflows]]

### [[Reflection]]
- **定义**：一种设计模式，指让大语言模型检查并批评自己生成的输出，随后根据自我批评的反馈进行改进 [5, 6]。
- **视频上下文**：作者举例说明可以先让 AI 扮演程序员写代码，再将生成的代码发回给它让其自我审查并提出改进建议，循环迭代以提升代码质量 [5]。
- **为什么重要**：它能有效提升基础模型的性能表现，且是构建更复杂的多智能体工作流的基础 [6]。
- **关联概念**：属于 → [[Agentic AI workflows]]

### [[Tool use]]
- **定义**：一种允许大语言模型生成 API 调用请求以执行外部动作的设计模式 [6]。
- **视频上下文**：作者提到大语言模型现在常被专门优化以支持工具使用，借此自主决定何时需要进行网络搜索、执行代码、办理客户退款或发送邮件等 [6-8]。
- **为什么重要**：它让 AI 不再局限于纯文本生成，而是能够与外部世界交互并极大地扩展其能够完成的任务范围 [6-8]。
- **关联概念**：属于 → [[Agentic AI workflows]]

### [[Planning]]
- **定义**：指大语言模型在面对复杂请求时，能够主动选择并规划出一系列按顺序执行的动作来完成任务的设计模式 [7]。
- **视频上下文**：作者以处理图片为例，说明 AI 如何能够自主规划出先检测姿势、再生成图像、接着描述图像、最后生成音频的具体执行步骤 [7]。
- **为什么重要**：赋予了 AI 将复杂目标自动拆解为有序且可操作步骤的高级推理能力 [7]。
- **关联概念**：属于 → [[Agentic AI workflows]]

### [[Multi-agent collaboration]]
- **定义**：通过提示大语言模型在不同时间扮演不同的角色，让这些模拟出的智能体相互交互以共同解决任务的设计模式 [7, 9]。
- **视频上下文**：作者将其类比为 CPU 上的多进程运行，指出让 AI 分别扮演不同专家角色（如程序员和批评家）并相互协作，能显著提升多种任务的表现 [9]。
- **为什么重要**：它为开发者提供了一种将庞大任务分解为子任务的有效抽象方式，便于构建并交付复杂系统 [9, 10]。
- **关联概念**：属于 → [[Agentic AI workflows]]

### [[Large Multimodal Model (LMM)]]
- **定义**：能够同时处理文本和图像、视频等视觉数据的大型基础模型 [10]。
- **视频上下文**：作者展示了将 Agentic 工作流应用于此类模型，以完成统计足球场球员数量或提取视频中进球片段等复杂的视觉任务 [10-13]。
- **为什么重要**：它的演进预示着图像处理革命的到来，使得企业能够从大量被搁置的非结构化视觉数据中挖掘出实际价值 [13, 14]。
- **关联概念**：未明确提及

### [[Agentic orchestration layer]]
- **定义**：在 AI 技术栈中新涌现的一个技术层，用于协助和简化代理式（Agentic）应用的开发与编排 [15]。
- **视频上下文**：作者提到像 LangChain 这样的框架正变得越来越 Agentic（例如通过 LangGraph），使得开发者更容易在基础模型之上构建上层应用 [15, 16]。
- **为什么重要**：它正在改变现有的 AI 技术栈结构，大幅降低了构建复杂 AI 代理工作流的技术门槛 [15, 16]。
- **关联概念**：依赖 → [[Agentic AI workflows]]


## 概念关系图
- [[Agentic AI workflows]] ↔ 对比 ↔ [[Zero-shot prompting]]
- [[Reflection]] → 属于 → [[Agentic AI workflows]]
- [[Tool use]] → 属于 → [[Agentic AI workflows]]
- [[Planning]] → 属于 → [[Agentic AI workflows]]
- [[Multi-agent collaboration]] → 属于 → [[Agentic AI workflows]]
- [[Agentic orchestration layer]] → 依赖 → [[Agentic AI workflows]]

## 行动项

- [ ] **访问 va.landing.ai 体验 Vision Agent 演示并获取代码** [1]
  - 目的：亲自在线测试 visual AI 功能，获取生成的代码并在自己的应用程序中运行以处理图像和视频数据 [1]。
  - 难度：未明确提及
  - 预估时间：未明确提及
  - 相关工具或资源：va.landing.ai [1]

- [ ] **为 LLM 配置 Reflection (反思) 工作流以优化代码** [2, 3]
  - 目的：通过构建 prompt，将 LLM 生成的代码及批判该代码的指令再次输入给 LLM，或结合 unit tests (单元测试) 的反馈，使其迭代并提升代码质量 [2, 3]。
  - 难度：未明确提及
  - 预估时间：未明确提及
  - 相关工具或资源：未明确提及

- [ ] **使用 Vision Agent 处理视频并提取 metadata (元数据)** [4]
  - 目的：将视频分割为小片段（如每 6 秒一个 chunk），生成描述信息，将这些非结构化视觉数据转化为结构化数据以供搜索和应用开发 [4, 5]。
  - 难度：未明确提及
  - 预估时间：几分钟 [6]
  - 相关工具或资源：Vision Agent、Pandas DataFrame、Snowflake [4]

- [ ] **采用快速实验 (Fast experimentation) 模式并行构建多个 prototypes (原型)** [7, 8]
  - 目的：改变耗时数月的传统开发路径，通过在短时间内编写 prompt 快速构建多个原型（例如构建 20 个原型并淘汰失败的 18 个），以测试和寻找高价值的用户体验 [7, 8]。
  - 难度：未明确提及
  - 预估时间：几天或一个周末 [7, 8]
  - 相关工具或资源：未明确提及

## 附件

- 思维导图：[[_附件/mindmaps/KrRD7r7y7NY.json]]
- 学习指南：[[_附件/KrRD7r7y7NY_study_guide.md]]

---
*自动生成于 2026-03-19 21:55 | [原始视频](https://www.youtube.com/watch?v=KrRD7r7y7NY)*

---
标题: pi设计艺术 — 设计哲学
创建日期: 2026-04-12
类型: 书籍
作者: ZhangHanDong
关键词: 极简核心, 能力外置, 反主流选择, 设计边界, 架构决策
复习间隔: 1, 7, 21, 60
复习日期: 2026-04-12
tags: #资源 #书籍 #Agent架构 #设计思想 #架构决策
---

## 📄 概述

本部分涵盖第30-32章，是整部pi设计艺术的哲学内核。从极简核心的架构原则出发，到四个反主流的"不做"决策，再到应用边界的理性评估。这三章回答了最根本的问题：**为什么pi这样设计？适用在什么场景？不适用在什么场景？**

---

## 📑 主要内容

### 第30章：极简核心，能力外置

**核心的三件事：**

pi内核极简，仅做三件事：

1. **调模型**（Call LLM）
   ```typescript
   const response = await provider.chat.completions.create({
     model: config.model,
     messages: context.messages,
     tools: skills.map(toToolDefinition)
   })
   ```

2. **跑循环**（Agent Loop）
   ```typescript
   while (true) {
     const response = await callModel()
     if (response.stop_reason === 'end_turn') break
     if (response.stop_reason === 'tool_use') {
       const result = await executeTools(response.tool_calls)
       context.messages.push({ role: 'user', content: result })
     }
   }
   ```

3. **管状态**（Manage State）
   ```typescript
   interface AgentContext {
     messages: Message[]
     memory: Memory
     skills: Tool[]
   }
   ```

代码行数统计：
- 核心Agent循环 & 状态管理：~3000行（抽象代码）
- 整个pi项目：~120000行
- **核心占比：2.5%**

**一个核心驱动12万行项目意味着什么？**

其他97.5%分布在：
- UI层（tui、web、RPC）：30%
- 工具集与扩展（Skills、Extensions）：25%
- 产品适配（mom、pods、plugins）：20%
- 测试与文档：15%
- 其他（build、infra）：7.5%

这样的配比说明：
- 核心设计足够通用，支撑广泛场景
- 大量工作在**周边系统**，而非核心优化
- 新功能通过**外置模块**而非改核心

**协议式 vs 框架式设计：三个例子**

**例子1：添加新工具**

*框架式做法（Langchain示范）：*
```python
# 在框架内实现新工具，需要继承抽象基类
from langchain.tools import Tool

class MyCustomTool(Tool):
    def _run(self, *args, **kwargs):
        # 工具逻辑
        pass
```

需要了解：Tool基类、生命周期、错误处理约定

*协议式做法（pi）：*
```typescript
interface Skill {
  name: string
  description: string
  execute(params: any): Promise<any>
}

// 任何对象实现Skill接口即可
const mySkill: Skill = {
  name: 'search',
  description: '搜索文档',
  execute: async (query) => {
    // 工具逻辑，无需继承、无需生命周期
    return results
  }
}
```

好处：
- 无需学习框架内部
- 支持混合多个库的工具（A库的工具+B库的工具+自写工具）
- 工具对pi框架零依赖

**例子2：实现压缩（Context压缩）**

*框架式：在框架内硬编码压缩策略*
```python
class Agent:
    def compress_memory(self):
        if len(self.memory) > MAX_TOKENS:
            # 仅支持Summary策略
            self.memory = summarize(self.memory)
```

后来产品需要：
- Selective：只保留关键对话
- 用户自定义规则
- Token粒度的增量压缩

每个需求都需要改框架。

*协议式：transformContext钩子*
```typescript
config = {
  transformContext: (context) => {
    // 用户完全自定义
    if (context.messages.length > 100) {
      return {
        ...context,
        messages: customCompress(context.messages)
      }
    }
    return context
  }
}
```

用户可以：
- 使用pi自带的压缩器
- 使用第三方压缩库
- 自己写一个压缩函数
- 甚至和其他工具链式组合

框架只提供**钩子**，实现交给用户。

**例子3：多产品复用**

*框架式：不同产品各自fork一份*
```
langchain-core/
├── langchain_chatgpt/   (OpenAI特定优化)
├── langchain_claude/    (Anthropic特定优化)
├── langchain_slack/     (Slack集成特定)
```

每个fork：
- 代码重复
- 更新时需要多次cherry-pick
- 分支发散，最终无法同步

*协议式：同一核心+配置/adapter*
```
pi-core/
├── index.ts  (通用Agent循环)

mom-slack/     (Slack adapter）
├── executor.ts  (SlackExecutor实现)

pods-gpu/      (GPU adapter)
├── executor.ts  (GpuExecutor实现)

pi-web/        (Web adapter)
├── executor.ts  (RemoteExecutor实现)
```

同一份核心，三个Executor，三种完全不同的产品。

**判断标准：什么应该外置？**

pi团队总结了三个判断标准：

| 判断标准 | 外置 | 内建 |
|----------|------|------|
| **是否产品相关？** | 搜索UI、文件格式 | 模型调用、循环逻辑 |
| **是否有多种合理实现？** | 压缩策略、权限检查 | 状态格式、消息协议 |
| **是否需要系统级一致性？** | 权限系统、用户认证 | Agent循环、LLM集成 |

**与Claude Code/Cursor/Aider的对比：**

三个竞品的架构选择：

| 项目 | 核心范围 | 策略 |
|------|---------|------|
| Claude Code | 小（主要是编辑器+RPC） | UI为中心，核心辅助 |
| Cursor | 中（IDE集成的Agent）| IDE优先，Agent能力绑定IDE |
| Aider | 小（CLI+编辑循环） | CLI优先，协议开放 |
| **pi** | **很小（纯Agent循环）** | **协议优先，UI/产品完全外置** |

pi的区别：
- Claude Code：Agent能力和编辑器紧耦合
- Cursor：Agent嵌入IDE，需要IDE启动
- Aider：设计简洁，但功能相对单一
- pi：核心最小，最大化可复用性（mom、pods都是证明）

---

### 第31章：反主流选择——四个"不做"决策

pi说"不"的四个重要决策，都违反业界常见做法，但对设计有关键影响。

**决策1：不内建Sub-Agents（不内建递归Agent调用）**

主流做法（Langchain、AutoGPT）：
```python
class Agent:
    def delegate_to_sub_agent(self, task):
        sub_agent = Agent(model=self.model, tools=subset_tools)
        return sub_agent.run(task)  # 递归创建Agent
```

好处：简化agent-of-agents编程
坏处：
- 增加核心复杂度（每个Agent都要实现相同的循环逻辑）
- 难以控制递归深度和资源消耗
- sub-agent的状态管理复杂

pi的做法：**用tool call + Agent循环**
```typescript
// Agent不创建sub-agent
// 而是：如果工具需要递归处理，工具自己调用Agent

interface Tool {
  name: 'delegateTask'
  execute: async (task) => {
    const session = new AgentSession(config)
    return await session.execute(task)  // 工具层调Agent，不是Agent内调
  }
}
```

对比：
```
框架式：        协议式：
Agent          Agent
├─Sub-Agent    └─Tool: delegateTask
├─Sub-Agent      └─(工具内创建Session)
└─Sub-Agent
```

协议式的好处：
- Agent核心无需知道sub-agent存在
- 每个recursion可以有独立的配置（model、skills、context）
- 堆栈完全可见（每个Session都是top-level）
- 资源控制容易（Session级别的timeout、token limit）

**决策2：不内建MCP（不内建Model Context Protocol）**

背景：Claude ecosystem推荐用MCP扩展AI应用。好处是：
- 标准化工具定义
- 复用性强
- 有生态支持

pi为什么不用？

```
MCP模型：
pi-core → MCP-Server → 外部服务
           │
           └─protocol overhead（序列化、反序列化）

pi的Skill模型：
pi-core → Skill（直接调用）
         └─无protocol overhead
```

pi的选择：**Skill接口 + Extension系统**

```typescript
// Skill：轻量级工具集
interface Skill {
  name: string
  execute(params): Promise<result>
}

// Extension：重型定制
interface Extension {
  hooks: {
    beforeToolCall?: (tool, params) => params
    afterToolCall?: (tool, result) => result
    transformContext?: (context) => context
  }
}
```

区别：
- MCP：适合远程服务，需要标准化接口
- Skill：适合本地工具，性能第一
- Extension：适合深度定制，修改Agent行为

pi认为：
- 远程工具用HTTP或RPC（直接，无需MCP）
- 本地工具用Skill（简洁，性能好）
- MCP增加了一层"标准"的复杂度，对于单个Agent应用不必要

**决策3：不内建Permission Popup（不内建权限确认UI）**

主流做法（很多Agent应用）：
```
Agent说："我要修改文件"
→ UI弹权限确认框
→ 用户同意
→ Agent执行
```

pi的做法：**beforeToolCall钩子**
```typescript
config = {
  beforeToolCall: (toolName, params) => {
    if (toolName === 'editFile' && params.path.includes('.git')) {
      throw new Error('Cannot edit .git directory')
    }
    return params  // 允许执行
  }
}
```

好处：
- 权限控制逻辑完全由使用方定义
- 不同产品可以有不同的权限模型
  - CLI：静默执行（信任度最高）
  - Slack：记录日志但不弹窗（信息化）
  - Web：弹窗确认（最谨慎）
- 减少框架的UI假设

这体现了pi的哲学：**数据流+钩子，比弹窗+对话框更通用**

**决策4：不内建Plan Mode（不内建"思考"模式）**

主流做法（o1, Claude Thinking模式）：
```
Agent进入"思考模式"
→ 花2-3倍时间思考
→ 然后执行Action
```

pi的做法：**transformContext钩子**
```typescript
config = {
  transformContext: (context) => {
    // 用户决定是否需要"思考"步骤
    if (needsDeepThinking) {
      context.messages.push({
        role: 'user',
        content: 'Think step by step for 30 seconds before responding'
      })
    }
    return context
  }
}
```

好处：
- 不是所有任务都需要思考（简单查询不需要）
- 思考深度可以动态调整（基于任务复杂度）
- 支持任何"思考"格式（chain-of-thought、树探索、自问自答）

**三个回调，控制Agent全部行为：**

这四个"不做"决策都指向同一个设计模式：**用钩子而不是弹窗/模式**

```typescript
interface AgentConfig {
  // 执行什么
  executeFunction: (toolName: string) => boolean

  // 能不能做
  beforeToolCall: (toolName: string, params: any) => any | Error

  // 看到什么
  transformContext: (context: Context) => Context
}
```

用户用这三个钩子可以实现：
- 权限控制 ✓
- Plan Mode ✓
- 自定义Sub-Agents ✓
- 自定义压缩策略 ✓
- 自定义工具发现 ✓
- 自定义成本追踪 ✓

**在大多数框架中，这些都需要单独的内建特性。pi通过三个钩子，优雅地将复杂度外置。**

---

### 第32章：适用边界——清晰的评估清单

pi的设计极其适合某些场景，但完全不适合另一些。

**pi适合的场景：**

| 场景 | 原因 |
|------|------|
| 多形态Agent系统 | 同一核心支撑多个产品 |
| 深度定制需求 | 钩子机制支持任意定制 |
| 团队技术强 | 需要能读源码、扩展框架 |
| 长期投资 | 框架核心稳定，维护成本低 |
| 高性能要求 | 极简意味着开销最小 |

**pi不适合的场景：**

| 场景 | 原因 |
|------|------|
| 简单单体chatbot | 过度设计 |
| 快速MVP验证 | 需要写adapter和executor |
| 非技术人员 | 无图形化配置 |
| 需要开箱即用 | 大量定制才能投入生产 |
| 依赖生态工具 | MCP、RAG框架等都要自己集成 |

**评估清单（决定是否用pi）：**

```
□ 你有2个或以上的Agent产品形态吗？
  ├─ 例：网页 + Slack + CLI
  ├─ 例：团队助手 + 代码助手 + 运维助手
  └─ 如果只有1个形态 → 不需要pi

□ 你的团队能读懂3000行TypeScript源码吗？
  ├─ 能 → 可以用pi
  ├─ 不能 → 考虑Langchain这样更成熟的框架
  └─ （这不是贬低，只是实话）

□ 你需要2个或以上的LLM Provider吗？
  ├─ 例：OpenAI + Anthropic + 自部署模型
  ├─ 例：开发用GPT-4，生产用开源模型
  └─ 如果只用1个provider → Langchain够用

□ 权限控制/审计需求是否定制化程度高？
  ├─ 例：不同团队、不同channel有不同权限
  ├─ 例：某些工具审计，某些工具不审计
  └─ 如果是标准的RBAC → 用通用框架

□ 你是否需要在生产运行多个独立Agent实例？
  ├─ 例：100+ mom频道，各自独立运行
  ├─ 例：pods上多个模型并发服务
  └─ 如果只有1个Agent实例 → 简单框架足够

评估结论：
全是"□" → pi完美适配
2-3个"□" → pi合适，有学习成本
0-1个"□" → 选择更简洁的框架
```

**与Langchain、Claude SDK、Aider的对标：**

| 维度 | Langchain | Claude SDK | Aider | pi |
|------|-----------|-----------|-------|-----|
| **学习曲线** | 中等 | 低 | 低 | 中等→高 |
| **单体chatbot** | ✓ | ✓✓ | ✓ | - |
| **多产品支持** | ✓ | - | ✓ | ✓✓✓ |
| **深度定制** | ✓ | △ | △ | ✓✓✓ |
| **生态丰富度** | ✓✓✓ | ✓✓ | △ | △ |
| **核心代码行数** | ~50000 | ~10000 | ~5000 | ~3000 |
| **生产案例** | 众多 | 众多 | 中等 | mom、pods |

**pi的核心优势集中在：**
1. 极简核心（最小依赖）
2. 极高可扩展性（钩子体系）
3. 多形态支持（协议式设计）

**pi的主要劣势：**
1. 学习曲线较陡
2. 生态工具少（需要自己集成RAG、vector DB等）
3. 社区小（遇到问题需要看源码）

---

## 💡 关键洞见

### 1. **极简核心 = 最大灵活性**

3000行代码看起来很少，但为什么能驱动120000行项目？

答案：**每删除一行不必要的代码，都为扩展打开一扇门**

- 不内建UI → 支持任何UI框架
- 不内建权限 → 支持任何权限模型
- 不内建sub-agent → 支持任何递归策略
- 不内建MCP → 支持任何工具集成方式

这是**模块化设计**的最高境界：尽可能少的假设，尽可能多的扩展点。

### 2. **钩子体系的威力**

三个钩子（execute、beforeToolCall、transformContext）看似简单，但能实现：

- **权限控制**：beforeToolCall检查权限
- **审计追踪**：beforeToolCall + afterToolCall记录
- **成本计算**：transformContext查看token消耗
- **压缩策略**：transformContext修改messages
- **A/B测试**：beforeToolCall返回不同参数
- **重试逻辑**：execute重新调用
- **监控告警**：任何钩子都可以上报指标

一套钩子体系，支撑了传统框架中需要10+个内建特性才能做到的事。

### 3. **协议优于继承**

很多框架用继承和抽象基类来扩展：
```python
class BaseTool:
    def execute(self): pass

class MyTool(BaseTool):
    def execute(self): ...
```

pi用协议（接口）：
```typescript
interface Skill {
  execute(params): Promise<any>
}

const mySkill: Skill = { ... }
```

区别：
- 继承：强制单一父类，子类必须学习父类API
- 协议：任何对象满足接口即可，与父类无关

这就是"鸭子类型"思想在架构中的体现：**你不需要继承框架，只需符合约定**

### 4. **三层递进的决策**

书的最后三章形成了递进关系：

- Ch30：**设计原则**（极简核心、能力外置）
- Ch31：**应用原则**（不做什么、怎么用钩子实现）
- Ch32：**应用边界**（什么场景用、什么场景不用）

这个递进很重要：**强大的框架需要强有力的自我限制**

很多框架的失败是因为：
- 一开始承诺全能
- 后来什么都要支持
- 最后陷入feature creep的泥沼

pi通过"明确说不"，保持了核心的清晰性。

### 5. **团队风格和设计匹配**

pi的设计风格体现了作者的工程品味：
- **理性**：有原则、有边界、清楚自己的局限
- **克制**：做该做的，坚决不做多余的
- **信任使用者**：相信用户能读代码、能扩展

这样的设计不是对所有团队都适合。合适的团队需要：
- 技术品味相近
- 愿意读源码而非依赖文档
- 能容忍一定程度的"未完成"

---

## 🔍 个人思考

**思考1：钩子体系 vs 事件驱动的对比**

我一开始想，为什么pi用钩子而不用事件系统（EventEmitter）？

后来想清楚了：
- 钩子：同步、有返回值、可修改数据
- 事件：异步、无返回值、仅通知
- Agent循环需要同步控制权，所以钩子更合适

**思考2：极简核心的成本**

极简意味着没有batteries included（没有开箱即用的工具）。
- 快速MVP需要写大量胶水代码
- 但是长期维护成本极低（核心稳定）

这对不同规模的项目影响不同：
- 小项目（<1人-年投入）：Langchain更快
- 大项目（>5人-年投入）：pi更省成本

**思考3：团队技术栈的重要性**

pi的学习曲线不陡峭，但陡峭的地方在**思维方式**：
- 必须理解"协议"的概念
- 必须能读懂3000行核心代码
- 必须能自己实现executor、skill等扩展

这筛选了合适的用户。某种程度上，pi的"局限"成了"过滤器"。

**思考4：开源维护的现实**

pi目前主要由ZhangHanDong维护。核心代码少（3000行）意味着：
- 维护成本低（一个人能hold住）
- 但社区贡献难度高（需要理解设计理念）

这和Langchain不同。Langchain大（50000行），吸引众多贡献者，但维护成本也高。

pi选择了"小而精"的路线，这对开源项目的长期生存反而可能更有利。

---

## ⚙️ 实践应用

### 场景1：评估是否迁移到pi
使用第32章的评估清单：
1. 列出当前所有Agent产品形态
2. 评估团队技术能力
3. 计算维护多个框架的成本
4. 如果清单打勾>3个，考虑迁移

### 场景2：用钩子实现自定义功能
参考第31章的三个钩子：

```typescript
// 例子：实现成本追踪
const agent = new AgentSession({
  transformContext: (context) => {
    context.estimatedCost = calculateTokens(context.messages)
    return context
  }
})

// 例子：实现权限控制
const agent = new AgentSession({
  beforeToolCall: (toolName, params) => {
    if (!hasPermission(user, toolName)) {
      throw new PermissionError(toolName)
    }
    return params
  }
})
```

### 场景3：决定什么外置，什么内建
用第30章的三个判断标准：

```
新需求：支持不同的上下文压缩策略

问题1：是否产品相关？
  → 是（不同产品压缩需求不同）
  → 外置为钩子

问题2：是否有多种合理实现？
  → 是（summary、selective、recency等）
  → 外置为钩子

问题3：需要系统级一致性？
  → 否（每个Agent独立压缩无影响）
  → 外置为钩子

结论：实现transformContext钩子支持用户自定义
```

---

## 🔗 相关内容

- [[pi的设计艺术]] — 全书导览与总体框架
- [[极简核心-能力外置]] — 本章核心概念的详细解读
- [[协议式设计 vs 框架式设计]] — 设计模式的对比分析
- [[Agent循环引擎]] — pi核心的3000行代码讲解
- [[pi设计艺术 — UI层]] — 能力外置在UI层的体现
- [[pi设计艺术 — 产品化实证]] — 能力外置在产品层的体现
- [[设计决策与权衡]] — Agent框架设计的通用思考

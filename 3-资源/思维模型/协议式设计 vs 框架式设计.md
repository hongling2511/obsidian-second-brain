---
创建日期: 2026-04-12
别名: Protocol Design vs Framework Design, 协议 vs 框架, 设计哲学对比
相关概念: [[极简核心-能力外置]], [[洋葱架构]], [[插件注册表模式]], [[pi的设计艺术]]
标签: #概念 #设计哲学 #架构对比 #关键决策
---

# 协议式设计 vs 框架式设计

## 定义

这是两种根本不同的系统设计哲学：

- **协议式（Protocol）**：定义接口和契约，让使用者自由组合和实现。工具是满足接口的数据结构，系统不管理工具的生命周期。
- **框架式（Framework）**：提供完整的骨架和生命周期管理，使用者在约束中填充。工具由框架创建、初始化、调用、销毁。

pi采用协议式，但大多数竞品（Claude Code、Cursor、Aider）采用框架式。这个选择深刻影响了整个系统的可维护性、可复用性和上手难度。

## 核心原理

### 1. 工具管理的差异

#### 框架式：生命周期由框架管理
```typescript
// 框架式（Cursor）
class Agent {
  private tools: Tool[] = []
  
  // 工具通过decorator注册
  @registerTool('bash')
  async bash(command: string) {
    // 框架处理：初始化、权限检查、执行、清理
  }
  
  // 框架管理调用
  async useTool(name: string, args: any) {
    const tool = this.findTool(name)
    const validated = await this.validatePermissions(tool, args)
    const result = await this.execute(validated)
    await this.cleanup(result)
    return result
  }
}

// 使用：自动化程度高，学习曲线平缓
const agent = new Agent()
```

#### 协议式：工具是数据结构
```typescript
// 协议式（pi）
interface Tool {
  name: string
  description: string
  inputSchema: JSONSchema
  execute: (input: any) => Promise<ToolResult>
}

// 工具就是一个数据结构，可自由组合
const bashTool: Tool = {
  name: 'bash',
  description: '执行shell命令',
  inputSchema: { ... },
  execute: (input) => executeCommand(input.command)
}

const readTool: Tool = {
  name: 'read',
  description: '读取文件',
  inputSchema: { ... },
  execute: (input) => fs.readFile(input.path)
}

// 使用：需要自己组装，灵活但需要手动处理
const config = {
  tools: [bashTool, readTool],
  beforeToolCall: (call) => validatePermissions(call)
}
const agent = createAgent(config)
```

### 2. 可扩展性的差异

#### 框架式：内建最佳实践
```typescript
// 框架已经内建了：
// - 权限管理（annotation）
// - 工具缓存（@cached）
// - 工具超时（@timeout）
// - 工具日志（@logged）

@registerTool('database')
@permission('admin')
@cached(duration: 300)
@timeout(30000)
@logged
async query(sql: string) {
  // ...
}

// 优点：开箱即用，代码整洁
// 缺点：不支持的功能无法添加
```

#### 协议式：用回调扩展
```typescript
// 协议式通过callbacks支持灵活的扩展

const config = {
  beforeToolCall: async (call) => {
    // 权限检查
    if (!hasPermission(call.name)) return null
    
    // 速率限制
    if (isRateLimited(call.name)) return null
    
    // 成本估算
    const cost = estimateCost(call)
    if (totalCost + cost > budget) return null
    
    // 日志记录
    logger.info(`Calling ${call.name}`)
    
    return call
  },
  
  executeToolFn: async (call) => {
    try {
      const cached = cache.get(call.id)
      if (cached) return cached
      
      const result = await actuallyExecute(call)
      
      cache.set(call.id, result)
      return result
    } catch (e) {
      logger.error(`Tool failed: ${e}`)
      throw e
    }
  }
}

// 优点：完全灵活，支持任意组合
// 缺点：需要手动编写逻辑，容易出错
```

### 3. pi的选择与原因

pi采用协议式的原因不是偶然，而是基于一个核心观察：

**pi需要支持多种产品形态（Web、CLI、Slack等），共用同一个Agent内核。**

```
┌──────────────────────────────────────────────────┐
│  pi-agent-core（Agent循环引擎）                   │
│  - 无产品特性                                    │
│  - 协议：工具只需满足Tool接口                    │
│  - 工具由使用者提供                              │
└──────────────────────────────────────────────────┘
    ↑           ↑           ↑
    │           │           │
 Claude Code   pi-cli     Slack Bot
 (Web IDE)    (CLI工具)   (聊天机器人)
  
 每个产品都有自己的：
 - 权限策略（IDE：防止修改生产代码；CLI：成本限制；Slack：速率限制）
 - 工具集（IDE：LSP工具；CLI：bash；Slack：发送消息）
 - 提示词（IDE：讲解代码；CLI：任务导向；Slack：简洁回复）
```

**如果采用框架式**，每个产品都要改框架代码或使用decorator，导致：
1. 框架代码膨胀（为了支持所有产品特性）
2. 各产品工具重复（无法共用）
3. 版本管理复杂（产品A需要新功能，产品B不需要，怎么版本化？）

**协议式的优势**：
- 核心不知道产品，只定义接口
- 三个产品都能用同一个内核
- 产品特性在产品层实现，不污染内核

### 4. 对比矩阵：pi vs 竞品

| 维度 | pi（协议式） | Claude Code | Cursor | Aider |
|------|-----------|-----------|--------|-------|
| **架构** | 内核 + 协议 | 集成框架 | 集成框架 | 集成框架 |
| **工具管理** | 使用者提供 | 框架内建 | 框架内建 | 框架内建 |
| **多产品复用** | 完全复用 | 部分复用 | 部分复用 | 部分复用 |
| **上手难度** | 高（需理解协议） | 低（框架隐藏复杂性） | 低 | 低 |
| **可定制性** | 极高（任意修改） | 中等（框架约束） | 中等 | 中等 |
| **代码量** | 少（内核3K行） | 多（框架+产品） | 多 | 多 |
| **编码能力** | 专精深度任务 | 通用全能 | 通用全能 | 通用全能 |

## 何时选择协议式

### 条件1：多产品共用内核
如果你有两个以上的产品都需要同一个Agent内核，协议式能显著降低成本。

示例：pi的三个产品形态（Web IDE、CLI、API）共用pi-agent-core。

### 条件2：工程纪律强的团队
协议式需要明确的接口定义和严格的遵循。如果团队允许"随意改"，就不适合。

### 条件3：需要深度定制
如果用户需要支持自定义工具、自定义权限、自定义调用策略，协议式能直接支持。

### 条件4：长期维护需求
协议式的小内核意味着更少的bug、更低的维护成本。

## 何时选择框架式

### 条件1：单一产品
只有一个产品形态，不需要复用。框架式可以为这个产品优化。

示例：Cursor只是一个IDE，不需要CLI或Web版本。

### 条件2：快速上手优先
如果用户是普通开发者（不是框架维护者），框架式的"开箱即用"更友好。

### 条件3：内建最佳实践
如果你想强制执行某些最佳实践（如权限检查、日志记录），框架式能通过强制的生命周期做到。

### 条件4：稳定性优先
框架式通过减少变异性来提高稳定性。所有产品都用框架的同一套逻辑，bug更少。

## 历史决策回顾

pi最初采用框架式（借鉴LangChain和LLamaIndex的流行模式），后来演进到协议式。

**转折点**：需要在Claude Code（Web IDE）中集成Agent能力时，发现：
- 框架式工具不适合IDE（IDE有自己的权限模型、LSP协议等）
- 强行适配框架，导致代码过度工程化

**决策**：把框架式的好处（结构、接口）提取出来，变成协议式的接口定义。去掉框架的强制性，保留灵活性。

结果：
- 代码量从8000行降到3000行
- 支持的产品形态从1个变成3个
- 定制难度实际上下降了（因为更清晰）

## 混合方案

实际上，不是非此即彼。可以在协议式的基础上，提供框架式的便利：

```typescript
// 协议式的底层
interface Tool { ... }

// 框架式的便利层（可选）
class ToolBuilder {
  @permission('admin')
  @timeout(30000)
  @cached()
  async query(sql: string) { ... }
  
  toProtocol(): Tool {
    // 转换为协议式的Tool
    return {
      name: 'query',
      execute: ...,
      // ... 应用所有decorator
    }
  }
}

// 用户可以选：
// - 直接用协议式Tool（灵活）
// - 用ToolBuilder的decorator语法（方便）
```

## 相关取舍

**协议式的代价**：
- 用户需要学习接口契约
- 无"魔法"，需要手动编排
- 重复劳动（多个产品都想要权限检查）
- 文档负担重（需要解释每个扩展点）

**框架式的代价**：
- 框架代码膨胀（支持所有用例）
- 灵活性受限（框架没提供的功能无法自己加）
- 产品之间难以复用（每个产品有自己的框架定制）

## 实践建议

1. **早期判断**：在系统设计初期，就明确是单产品还是多产品。这个决策很难后改。

2. **接口优先**：无论选择哪种，定义清晰的接口。框架式的decorator、协议式的Protocol都要明确。

3. **文档很关键**：协议式尤其需要好文档。用户需要理解"工具应该怎么写"。

4. **提供示例**：给出典型场景的参考实现（权限检查、工具缓存、日志记录）。

5. **考虑演进**：即使选择框架式，也要预留协议式的扩展点。未来可能有新产品形态。

## pi的最终立场

> pi相信：**正确的抽象比完整的功能更重要。**
> 
> 一个好的协议能支撑无限的定制；一个再完整的框架也会有缺失的需求。
> 
> 代价是用户需要更强的工程思维，但这正是pi的目标受众。

## 相关概念

- [[极简核心-能力外置]] — 协议式的实践体现
- [[洋葱架构]] — 如何通过分层实现协议隔离
- [[插件注册表模式]] — 协议式扩展的具体机制

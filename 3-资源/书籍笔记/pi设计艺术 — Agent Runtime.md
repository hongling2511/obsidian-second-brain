---
标题: pi设计艺术 — Agent Runtime与执行引擎
创建日期: 2026-04-12
类型: 书籍
作者: ZhangHanDong
关键词: Agent循环引擎, 无状态纯函数, 工具执行策略, Agent状态机
复习间隔: 1, 7, 21, 60
复习日期: 2026-04-12
tags: #资源 #书籍 #Agent架构 #系统设计
---

## 📄 概述

第8-10章深入Agent执行的"心脏"——agentLoop及其周围的状态管理机制。这三章回答了三个递进的问题：

1. **第8章**：循环本身应该如何设计？（agentLoop的纯函数设计）
2. **第9章**：循环内如何执行工具？（Tool execution pipeline）
3. **第10章**：循环外如何管理状态？（Agent state machine）

这三层共同构成了pi的"Agent Runtime"——一个无状态核心加有状态壳的设计。

---

## 📑 主要内容

### 第8章：agentLoop是无状态纯函数

**第一个关键决定**：agentLoop不管理任何状态。它不持有message历史、不追踪循环次数、不维护tool执行上下文。

```typescript
// agentLoop的极简签名
async function agentLoop(
  config: AgentLoopConfig
): Promise<void> {
  const { model, messages, tools, llmCall, eventStream } = config;
  
  // 输入：一份完整的消息历史 + 配置
  // 处理：调用LLM，处理响应，执行工具
  // 输出：全部通过eventStream发射
  // 副作用：零（除了事件发射）
}
```

**纯函数的含义**：
- 相同的输入（messages、model、tools）永远得到相同的行为
- 不读取全局变量、不修改外部状态
- 所有需要的信息都通过AgentLoopConfig显式传入
- 所有输出都通过EventStream显式发射

**双层循环结构**：

```
外层循环（Follow-up）：
  while (user还需要继续交互) {
    ┌─────────────────────────────────────┐
    │  内层循环（Tool Call + Steering）   │
    │  ┌───────────────────────────────┐  │
    │  │ 1. 调用LLM                     │  │
    │  │ 2. 解析响应                    │  │
    │  │ 3. 有tool call?                │  │
    │  │    ├─ 是：执行工具，添加result │  │
    │  │    │     回messages，goto 1    │  │
    │  │    └─ 否：响应完成，break     │  │
    │  └───────────────────────────────┘  │
    │                                     │
    │ 事件发射：message_complete          │
    └─────────────────────────────────────┘
    
    用户输入新消息 → messages.push(userMessage)
    goto 外层循环
  }
```

**内层循环的steering逻辑**：

```typescript
while (true) {
  const response = await llmCall(messages);
  eventStream.emit({ type: 'message_complete', response });
  
  if (!hasToolCall(response)) {
    // 模型输出了最终响应，不需要工具
    break;
  }
  
  // 有tool call，执行工具，添加result回messages
  for (const toolCall of response.toolCalls) {
    const result = await executeTool(toolCall);
    messages.push({
      role: 'tool',
      toolCallId: toolCall.id,
      content: result,
    });
  }
  
  // 继续循环，再次调用LLM处理工具结果
}
```

**消息变换管道只在LLM调用边界发生**：

```
┌──────────────────┐
│ Application Code │ (使用者提供的消息)
└────────┬─────────┘
         │
         ▼
┌──────────────────────────┐
│ Message Transform Layer  │  (pi-ai层)
│ - 归一化消息格式          │
│ - 验证模型兼容性          │
└────────┬─────────────────┘
         │
         ▼
┌──────────────────────────┐
│ LLM Call (Provider)      │  (具体的HTTP调用)
└────────┬─────────────────┘
         │
         ▼
┌──────────────────────────┐
│ Response Transform       │  (pi-ai层)
│ - Provider特定格式→通用  │
│ - Tool call ID归一化     │
└────────┬─────────────────┘
         │
         ▼
┌──────────────────┐
│ agentLoop处理    │  (纯函数)
│ (steering logic) │
└──────────────────┘
```

**只在边界发生变换的意义**：agentLoop内部的工具执行、消息拼接等操作都是在"已经标准化的消息格式"上进行的，完全不感知具体是哪个Provider。

**AgentLoopConfig定义循环的全部外部依赖**：

```typescript
interface AgentLoopConfig {
  // 输入数据
  model: Model<TApi>;
  messages: Message[];
  tools: Tool[];
  
  // 执行函数
  llmCall: (messages: Message[]) => Promise<Response>;
  executeTool: (toolCall: ToolCall) => Promise<string>;
  
  // 输出通道
  eventStream: EventStream;
  
  // 行为配置
  maxIterations?: number;
  toolExecutionMode?: 'parallel' | 'sequential';
  onToolCallError?: 'continue' | 'fail-fast';
}
```

这个config就是**"定义一次循环的全部细节"**的方式——不需要修改agentLoop代码，只需改变config。

**"Must not throw"契约的体现**：

```typescript
async function agentLoop(config: AgentLoopConfig): Promise<void> {
  try {
    // 主循环
    while (shouldContinue(config)) {
      const response = await config.llmCall(config.messages);
      // 处理响应...
    }
  } catch (e) {
    // 不能让异常逃逸！
    // 必须转换为事件
    config.eventStream.emit({
      type: 'loop_error',
      error: e,
      recoverable: isRecoverable(e),
    });
  }
}
```

**极致可组合性的收获**：因为agentLoop是纯函数且"不说谎"（所有输出都通过eventStream），使用者可以：
- 在同一个Event Handler中监听来自多个Agent的事件（无需担心状态冲突）
- 动态改变config重新运行循环（等价于"重新编排工作流"）
- 完整记录每次循环的输入和事件流（便于重放和调试）

**收益与放弃的权衡**：
- 收益：无状态化 → 高度可测试、可组合、可重放
- 放弃：不能在循环内部自己管理会话历史（必须由外层状态管理）
- 放弃：不能在循环内部自己做context压缩或message去重（必须提前准备好messages）

---

### 第9章：工具执行三阶段——Prepare, Execute, Finalize

**为什么分三阶段**？工具执行不是"调用一个函数"那么简单。在真实系统中，工具可能有副作用、可能失败、可能需要权限检查。

**Prepare阶段——参数验证与权限检查**：

```typescript
interface BeforeToolCall {
  toolCall: ToolCall;
  schema: TypeBox.TSchema; // 参数schema
  
  // 使用者可以在这里：
  // 1. 验证参数是否符合schema
  // 2. 检查用户是否有权限调用这个工具
  // 3. 修改参数（如注入context）
  // 4. 决定是否继续执行（返回false则跳过）
}

async function beforeToolCall(config: BeforeToolCall): Promise<boolean> {
  // TypeBox schema验证
  const valid = Type.Check(config.schema, config.toolCall.input);
  if (!valid) {
    eventStream.emit({
      type: 'tool_validation_error',
      toolCall: config.toolCall,
      errors: Type.Errors(config.schema, config.toolCall.input),
    });
    return false; // 不执行这个工具
  }
  
  // 权限检查
  const hasPermission = await checkToolPermission(
    currentUser,
    config.toolCall.name
  );
  if (!hasPermission) {
    eventStream.emit({
      type: 'tool_permission_denied',
      toolCall: config.toolCall,
    });
    return false;
  }
  
  return true; // 继续执行
}
```

**Execute阶段——并行vs顺序策略**：

```typescript
// 策略1：顺序执行（默认）
for (const toolCall of response.toolCalls) {
  const result = await executeTool(toolCall);
  messages.push({
    role: 'tool',
    toolCallId: toolCall.id,
    content: result,
  });
}

// 策略2：并行执行（可选）
const results = await Promise.all(
  response.toolCalls.map(toolCall =>
    executeTool(toolCall)
  )
);
results.forEach((result, index) => {
  messages.push({
    role: 'tool',
    toolCallId: response.toolCalls[index].id,
    content: result,
  });
});

// 策略3：分组并行（高级）
const grouped = groupToolCalls(response.toolCalls, 
  (a, b) => canExecuteInParallel(a, b)
);
for (const group of grouped) {
  const results = await Promise.all(
    group.map(executeTool)
  );
  // 添加到messages...
}
```

**并行vs顺序的选择标准**：
- **顺序执行**：默认、安全。适合有依赖关系的工具（如"文件读取"依赖"目录列表"）
- **并行执行**：快速。需要确保工具间无依赖，或依赖在上一轮迭代已解决

**Finalize阶段——清理与副作用处理**：

```typescript
interface AfterToolCall {
  toolCall: ToolCall;
  result: string;
  error?: Error;
  
  // 使用者可以在这里：
  // 1. 记录审计日志
  // 2. 更新外部系统状态
  // 3. 决定result是否需要修改（如脱敏）
  // 4. 触发其他通知
}

async function afterToolCall(config: AfterToolCall): Promise<string> {
  // 审计日志
  await auditLog.record({
    toolName: config.toolCall.name,
    input: config.toolCall.input,
    result: config.result,
    timestamp: new Date(),
    userId: currentUser.id,
  });
  
  // 脱敏敏感结果
  if (config.toolCall.name === 'query_database') {
    return maskSensitiveData(config.result);
  }
  
  // 如果有错误，可能需要告警
  if (config.error) {
    await alerting.notify({
      severity: 'warning',
      message: `Tool ${config.toolCall.name} failed: ${config.error.message}`,
    });
  }
  
  return config.result;
}
```

**TypeBox schema参数验证**：

```typescript
// 工具定义
const writeFileTool = {
  name: 'write_file',
  schema: Type.Object({
    path: Type.String({ minLength: 1 }),
    content: Type.String(),
    mode: Type.Enum({ write: 'w', append: 'a' }),
  }),
  execute: async (input) => {
    // input已经过验证，类型为 {path, content, mode}
    await fs.writeFile(input.path, input.content, input.mode);
    return 'File written successfully';
  },
};

// 在beforeToolCall中使用
const errors = Type.Errors(writeFileTool.schema, toolCall.input);
if (errors.length > 0) {
  return false; // 参数无效，不执行
}
```

**三阶段的灵活性**：不是所有工具都需要三个阶段。简单的工具可以跳过before/after钩子，直接执行。但框架提供了这些钩子，让复杂的工具（如文件操作、数据库修改）可以在两端进行防护。

---

### 第10章：Agent是循环上的有状态壳

**第二个关键决定**：agentLoop是无状态的，但真实的应用需要状态。所以在agentLoop上套一个有状态的壳——Agent类。

**Agent的五类状态**：

```typescript
class Agent {
  // 类别1：可变消息历史
  private messages: Message[] = [];
  
  // 类别2：事件监听器
  private listeners: Map<EventType, Listener[]> = new Map();
  
  // 类别3：消息队列（用于外部输入）
  private messageQueue: Message[] = [];
  
  // 类别4：中止控制
  private abortController: AbortController;
  
  // 类别5：互斥锁（防止并发循环）
  private loopMutex: Mutex;
}
```

**Copy-on-assign保护messages**：

```typescript
// 不能直接修改messages
get messages(): Message[] {
  // 返回一份深拷贝，不允许直接修改内部状态
  return structuredClone(this._messages);
}

// 只能通过addMessage方法
addMessage(message: Message): void {
  this._messages = [...this._messages, message];
  // 或：
  this._messages.push(message); // 内部修改
  this.notifyListeners('message_added', message);
}

// 其他代码如果拿到messages的引用，修改它不会影响Agent内部状态
const msgs = agent.messages;
msgs[0].content = 'hacked'; // 不影响agent内部
```

这样做的目的是**防止accidental mutation**——外部代码不小心修改了消息，导致Agent状态不一致。

**CustomAgentMessages声明合并**：某个应用可能需要扩展Agent支持的消息类型。

```typescript
// pi-agent-core定义的基础消息类型
interface Message {
  role: 'user' | 'assistant' | 'tool';
  content: string;
}

// 应用层可以扩展
declare global {
  namespace pi.agent {
    interface CustomAgentMessages {
      'annotation': {
        role: 'annotation';
        content: string;
        metadata?: Record<string, unknown>;
      };
      'thinking': {
        role: 'thinking';
        content: string;
      };
    }
  }
}

// 之后Agent可以接受这些自定义消息类型
agent.addMessage({
  role: 'annotation',
  content: 'This is important',
  metadata: { importance: 'high' },
});
```

**MutableAgentState与事件驱动**：

```typescript
class Agent {
  async run(config: AgentRunConfig): Promise<void> {
    // 获取循环锁，防止并发
    await this.loopMutex.lock();
    
    try {
      // 调用无状态的agentLoop
      await agentLoop({
        model: this.model,
        messages: this._messages,
        tools: this.tools,
        llmCall: this.llmCall.bind(this),
        executeTool: this.executeTool.bind(this),
        eventStream: this.eventStream,
      });
    } finally {
      this.loopMutex.unlock();
    }
  }
  
  // 监听事件
  on(eventType: EventType, listener: Listener): void {
    if (!this.listeners.has(eventType)) {
      this.listeners.set(eventType, []);
    }
    this.listeners.get(eventType)!.push(listener);
  }
  
  // 内部：驱动事件流
  private notifyListeners(eventType: EventType, event: Event): void {
    const listeners = this.listeners.get(eventType) || [];
    for (const listener of listeners) {
      listener(event);
    }
  }
}
```

**五类状态的生命周期**：

| 状态类别 | 创建时机 | 修改时机 | 销毁时机 |
|---------|--------|--------|--------|
| messages | Agent构造时 | addMessage | Agent销毁或clear() |
| listeners | Agent构造时 | on/off | Agent销毁时自动清理 |
| messageQueue | 需要队列输入时 | 外部pushMessage或内部消费 | 循环结束时清空 |
| abortController | Agent构造时 | 用户调用abort() | Agent销毁时 |
| loopMutex | Agent构造时 | 循环进行中持有锁 | Agent销毁时 |

**互斥锁的必要性**：如果同时调用`agent.run()`两次会发生什么？

```typescript
// 没有互斥锁（错误）
async function runTwice() {
  agent.run(); // 第一次运行，开始修改messages
  agent.run(); // 第二次运行，同时在修改messages！
  // 竞态条件：两个循环同时读写messages
}

// 有互斥锁（正确）
async function runTwice() {
  const run1 = agent.run(); // 获取锁，开始运行
  const run2 = agent.run(); // 等待锁释放（阻塞）
  await Promise.all([run1, run2]);
  // run1完成 → run2开始
}
```

**Agent类作为"有状态壳"的设计目的**：
- agentLoop保持无状态（纯粹、可测试）
- Agent类在循环上套一层状态管理（方便应用使用）
- 两者分离，让既能享受纯函数的好处，又能满足实际应用的需求

---

## 💡 关键洞见

1. **无状态循环 + 有状态壳的二分法**：这是pi最优雅的设计。核心逻辑(agentLoop)完全纯粹，但应用界面(Agent)包含必要的状态。两者通过EventStream解耦。

2. **双层循环的精妙之处**：外层处理用户交互，内层处理模型反复调整（self-correction）。这个分层让代码清晰地区分了"用户驱动"和"模型自驾"的两种循环模式。

3. **三阶段工具执行**：看似复杂，实则提供了"在执行前后插入权限、审计、脱敏等逻辑"的标准方式。这比"工具执行就是一行代码"的简单方案，在生产环境中更实用。

4. **消息变换只在边界**：agentLoop内部完全不感知provider，所有适配工作都在循环外完成。这让循环代码高度可复用。

5. **Copy-on-assign保护**：看似严格，实则防止了"外部代码修改messages导致状态不一致"这一常见bug。代价是每次读messages都是拷贝，但这个性能开销可以接受。

---

## 🔍 个人思考

- [ ] 互斥锁限制了并发调用，但是否可以支持"多个Agent各自独立运行"的场景？
- [ ] Copy-on-assign在大消息历史下会不会有显著的性能影响？是否需要优化为惰性拷贝？
- [ ] CustomAgentMessages的declare global方式是否足够灵活？会不会在多个库同时扩展时产生冲突？
- [ ] 如果工具执行本身就是异步的（如RPC调用），三阶段设计是否仍然适用？

---

## ⚙️ 实践应用

1. **自定义Agent行为**：
   - 通过beforeToolCall钩子实现权限检查
   - 通过afterToolCall钩子实现审计日志
   - 通过监听特定事件驱动UI更新（如流式显示消息）

2. **处理工具执行错误**：
   - 在executeTool中catch错误并转为事件
   - 在afterToolCall中根据错误类型决定是否继续
   - 应用可以设置`onToolCallError: 'continue'`让某个失败的工具不中断整个流程

3. **实现custom message类型**：
   - 如果需要除了user/assistant/tool之外的消息类型（如annotation、thinking等）
   - 使用CustomAgentMessages声明扩展
   - Agent自动支持新类型，无需修改核心代码

4. **并行执行工具**：
   - 在toolExecutionMode设为'parallel'
   - 注意工具间的依赖（某个工具的输入依赖另一个工具的输出时，不能并行）
   - 可选：实现custom grouping逻辑来做更细粒度的并行控制

5. **中止长时间运行**：
   - 调用`agent.abort()`主动停止循环
   - agentLoop会监听abortController信号并优雅退出
   - 已发射的事件继续处理，未来的循环不启动

---

## 🔗 相关内容

- [[Agent循环引擎]]
- [[极简核心-能力外置]]
- [[洋葱架构]]
- [[pi的设计艺术]]
- [[事件驱动架构]]
- [[无状态设计的收益]]

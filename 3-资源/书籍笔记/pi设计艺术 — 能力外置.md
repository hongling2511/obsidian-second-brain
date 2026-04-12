---
标题: pi设计艺术 — 能力外置
创建日期: 2026-04-12
类型: 书籍
作者: ZhangHanDong
关键词: Extension系统, Skill机制, Resource Loader, Model Registry, 插件架构
复习间隔: 1, 7, 21, 60
复习日期: 2026-04-12
tags: #资源 #书籍 #Agent架构 #插件系统
---

## 📄 概述

第15-18章阐述了pi的**极简核心 + 能力外置**架构哲学。Runtime本身极其精简，所有扩展能力通过Extension系统注入。Skill机制让LLM按需调用代码，Resource Loader统一管理资源加载，Model Registry支持模型的灵活切换和扩展。这四章共同构建了一个**开放而有边界、灵活而可控**的插件生态。

---

## 📑 主要内容

### 第15章 — Extension系统：五维能力注入

#### Extension的核心职责

Extension是pi的主要扩展机制。每个Extension可在五个维度上增强系统能力：

**1. 事件订阅（26种事件）**

```
生命周期事件：
  - beforeConversationStart
  - afterConversationEnd
  - onMessageReceived
  - onMessageSent
  
模型事件：
  - beforeModelCall
  - afterModelCall
  - onModelError
  
工具事件：
  - beforeToolCall
  - afterToolCall
  - onToolError
  
对话事件：
  - beforeBranch
  - onCompaction
  - onSessionStateChange
  ...（共26种）
```

Extension注册监听器，在关键时刻执行自定义逻辑。这是**反演控制（Inversion of Control）** 的典型实现。

**2. 工具注册**

```typescript
extension.registerTool({
  name: "database_query",
  description: "Query database with SQL",
  schema: TypeBox.Object({
    sql: TypeBox.String(),
    limit: TypeBox.Optional(TypeBox.Integer())
  }),
  execute: async (params) => { ... }
})
```

工具通过TypeBox schema定义，运行时注入到Runtime的tool registry。

**3. 命令/快捷键**

Extension可注册自定义命令，供CLI或IDE使用。

**4. 消息/状态持久化**

Extension可实现custom storage backend，例如数据库、Redis、云存储等。

**5. Provider注册**

注册新的模型provider（除了OpenAI、Claude还可支持本地Llama、企业LLM等）。

#### 三层架构

```
Loader 层
  ↓ 发现、加载Extension文件
Runtime 层
  ↓ Runtime核心，暴露注册接口
Wrapper 层
  ↓ Extension持有Runtime引用，可反向操作
```

#### 两阶段初始化

1. **Throwing Stubs** — Extension代码加载，但工具/命令等返回"not ready"错误
2. **真实实现** — Runtime初始化完毕，Extension获得真实Runtime引用，替换stub实现

这保证了Extension能访问完整的Runtime功能，同时避免了循环依赖。

#### 开放但有边界的设计

**开放**：Extension可以注册任何工具、订阅任何事件、持久化任何数据。

**边界**：Extension不能修改Runtime的核心规则（例如不能改变会话树的存储格式、不能改变消息路由逻辑）。

这种"能力可扩展，规则不可修改"的设计确保了系统的核心稳定性。

#### 权衡分析

**得到**：
- 无限扩展性 — 任何第三方都可贡献Extension
- 关注点分离 — Runtime关注核心，Extension关注特定能力
- 插件生态 — 激励社区建设和共享

**放弃**：
- 代码简洁 — Runtime内需要预留26个hook点
- 性能 — 事件订阅有调用开销

---

### 第16章 — Skill机制：Markdown形式的Agent能力

#### Skill的本质

Skill是**带frontmatter的markdown文件**，描述一个特定的Agent能力或工作流。LLM可以通过read工具加载并执行Skill。

#### 核心特性：6字段接口

```markdown
---
name: write_essay
description: Write a well-structured essay on a given topic
input:
  topic: string
  length: "short" | "medium" | "long"
output:
  essay: string
tags: [writing, content]
---

# Essay Writing Skill

## 功能说明
This skill helps you write essays...

## 使用步骤
1. 定义主题
2. 收集资料
...
```

注意：**没有execute()方法**。Skill的逻辑由markdown内容本身（给LLM的指导）和embedded的工具调用组成。

#### 发现和加载规则

1. **SKILL.md为入口** — 目录名即skill名
   ```
   /skills/write_essay/
     ├── SKILL.md (必须)
     ├── templates/
     └── examples/
   ```

2. **三层优先级**
   ```
   全局Skill库（~/.pi/skills/）
     ↓ 被覆盖
   项目Skill（项目目录 /skills/ 或 /agents/）
     ↓ 被覆盖
   npm包内Skill
   ```
   同名Skill后层级覆盖前层级。

3. **disable-model-invocation控制**
   
   在frontmatter添加`disable-model-invocation: true`，该Skill对模型不可见。用于内部Skill或特定场景。

#### Skill vs 其他扩展方式的对比

| 维度 | Skill | MCP | Extension |
|------|-------|-----|-----------|
| 定义方式 | Markdown | JSON Schema | TypeScript |
| 执行者 | LLM决策 | 工具直接调用 | 系统事件 |
| 能力类型 | 高级工作流 | 原子操作 | 核心功能 |
| 学习成本 | 低（写Markdown） | 中 | 高（写code） |
| 性能 | 中（LLM推理） | 高（直接调用） | 高（系统级） |
| 扩展范围 | 业务逻辑 | 系统工具 | Runtime行为 |

#### 关键设计思想

**不在Skill中注入执行逻辑，而只注入元数据**。

Skill对应的markdown内容通过`name + description + location`注入到System Prompt。LLM根据需要用read工具加载并理解Skill的完整内容。这样做的好处：

1. **Skill library可以超大** — 无需全部加入context
2. **LLM有决策权** — 是否使用某个Skill由模型判断
3. **动态更新** — 无需重启就能修改Skill

#### 权衡分析

**得到**：
- 易维护 — Markdown比代码简洁
- LLM友好 — 自然语言描述便于模型理解
- 零启动成本 — 新用户可快速写Skill

**放弃**：
- 执行性能 — 需要LLM推理决策，不如直接API调用快
- 精确控制 — LLM可能误用或不用某个Skill

---

### 第17章 — Resource Loader：统一的资源加载

#### 加载的三种资源

1. **Extensions** — TypeScript代码，提供系统级能力
2. **Skills** — Markdown文件，提供业务级工作流
3. **Prompts/Themes** — 通用资源，可被多个Extension或命令引用

#### 三层来源

```
全局资源（~/.pi/）
  ↓ 加载
项目资源（项目根目录）
  ↓ 加载
npm包资源（node_modules/中的@pi-related包）
  ↓
资源统一注册表
```

#### 宽容加载 + 诊断报告

核心原则：**加载失败不crash，而是warning + diagnostics**。

```typescript
const result = await loader.load({
  tolerance: 'warn', // 'error' | 'warn' | 'ignore'
  verbose: true
});

// 输出示例
{
  loaded: { extensions: 3, skills: 12, prompts: 5 },
  warnings: [
    { path: "extensions/broken.ts", error: "SyntaxError" },
    { path: "skills/old_skill/SKILL.md", error: "Missing frontmatter" }
  ],
  diagnostics: {
    totalSize: "2.3MB",
    loadTime: "450ms",
    conflictingNames: ["write_essay"] // 多个来源定义了同名资源
  }
}
```

这使得系统启动更健壮，开发者能精确定位问题。

#### 命名冲突处理

后加载的资源优先级更高（项目级 > 全局级）。诊断报告会列出所有冲突，开发者可明确删除或重命名。

#### 权衡分析

**得到**：
- 集中管理 — 所有资源通过同一接口加载
- 灵活来源 — 全局 + 项目 + npm三层支持
- 鲁棒性 — 单个资源加载失败不影响整体

**放弃**：
- 快速启动 — 加载三层资源有开销
- 严格验证 — 宽容策略可能隐藏问题

---

### 第18章 — Model Registry：灵活的模型切换

#### 构建时生成 + 运行时覆盖

```
编译阶段
  ↓
models.generated.ts
  ↓ 应用启动时
models.json (从文件或env读取)
  ↓ 覆盖
最终使用的模型列表
```

`models.generated.ts`包含所有已知的模型定义（OpenAI GPT系列、Claude系列等），由构建脚本生成。

`models.json`允许用户添加自定义模型或覆盖默认配置：

```json
{
  "models": [
    {
      "id": "gpt-4-turbo",
      "provider": "openai",
      "temperature": 0.7,
      "maxTokens": 4096
    },
    {
      "id": "my-local-llm",
      "provider": "custom",
      "endpoint": "http://localhost:8000/v1",
      "apiKey": "${LLM_API_KEY}"
    }
  ]
}
```

#### Extension动态注册

Extension初始化时可注册新provider和模型：

```typescript
extension.registerModelProvider('mistral', new MistralProvider({
  apiKey: process.env.MISTRAL_API_KEY
}));

extension.registerModel('mistral-7b', {
  provider: 'mistral',
  config: { ... }
});
```

#### Fuzzy Model Lookup

用户输入`gpt-4`，系统会匹配到最新的GPT-4版本（gpt-4-turbo-preview或gpt-4o，取决于registry）。避免了版本号硬编码。

#### Provider架构

```typescript
interface ModelProvider {
  call(model: string, messages: Message[]): Promise<ModelResponse>;
  listModels(): Promise<string[]>;
  validateConfig(config: object): boolean;
}
```

每个provider实现统一接口，Runtime透明地支持多provider。

#### 权衡分析

**得到**：
- 模型无关性 — Runtime不绑定特定模型
- 灵活切换 — 无需修改代码即可换模型
- 自定义支持 — 可集成本地LLM或企业模型

**放弃**：
- 统一管理 — 多provider导致配置复杂
- 性能优化 — 无法针对单一模型做深度优化

#### 运行时行为

```typescript
// 用户代码
const response = await runtime.callModel('gpt-4');

// Runtime内部
const model = registry.resolve('gpt-4'); // fuzzy匹配
const provider = registry.getProvider(model.provider);
return provider.call(model.id, ...);
```

---

## 💡 关键洞见

1. **Extension的26个hook点** — 几乎覆盖了系统的所有关键时刻。这说明设计者充分理解了Agent系统的生命周期。

2. **Skill作为Markdown而非代码** — 这是对LLM特性的深刻理解。Markdown对LLM天生友好，而让LLM自己决定调用某个Skill，比硬编码工具流程更灵活。

3. **三层配置的一致性** — Extension、Skill、Resources都遵循"全局→项目→npm"的三层加载规则，形成高度一致的心智模型。

4. **宽容加载 + 诊断** — 生产级系统的标志。不是简单的try-catch，而是结构化的报告。

5. **Model Registry的fuzzy lookup** — 向后兼容性的妙招。模型版本不断更新，但用户的代码无需改动。

---

## 🔍 个人思考

*（本部分预留给读者按需填写）*

- Extension的26个hook点在实际使用中的频率分布如何？
- Skill的LLM决策vs硬编码工具流程，在什么场景下各有优劣？
- 三层Resource Loader的命名冲突在大型项目中有多频繁？

---

## ⚙️ 实践应用

### Extension系统

- **日志和监控** — 订阅afterToolCall和onModelError，统计工具成功率和模型异常
- **自定义存储** — 实现custom storage provider，支持数据库或Redis持久化
- **成本控制** — 订阅beforeModelCall，计算token成本，设定使用额度限制
- **审计日志** — 订阅所有user-facing操作，记录who-what-when用于合规

### Skill机制

- **业务流程库** — 为每个常见任务（写报告、分析数据、代码审查）构建Skill
- **最佳实践编码** — Skill中嵌入公司规范和checklist
- **A/B测试** — 为同一任务维护多个Skill版本，观察LLM的选择倾向

### Resource Loader

- **开发效率** — 支持热加载Skill，无需重启就能迭代
- **多人协作** — 全局Skill为团队共用，项目Skill为特定项目定制
- **灰度发布** — npm包中的资源可控制发布版本，实现金丝雀部署

### Model Registry

- **成本优化** — 为不同任务选择合适的模型（简单任务用fast cheap model，复杂任务用strong model）
- **多region部署** — 为不同地区注册本地模型provider，降低延迟
- **模型实验** — 为同一功能注册多个模型，通过Extension的beforeModelCall进行A/B路由

---

## 🔗 相关内容

- [[pi的设计艺术]] — 全书导览
- [[极简核心-能力外置]] — 此章的核心理念
- [[pi设计艺术 — 从Runtime到产品]] — Extension如何与会话树、Compaction交互
- [[pi设计艺术 — 工具设计]] — Skill和工具的配合使用
- [[插件注册表模式]] — Model Registry的设计模式

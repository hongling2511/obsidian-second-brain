---
标题: pi设计艺术 — 从Runtime到产品
创建日期: 2026-04-12
类型: 书籍
作者: ZhangHanDong
关键词: 会话树, Compaction, 配置系统, System Prompt, Runtime架构
复习间隔: 1, 7, 21, 60
复习日期: 2026-04-12
tags: #资源 #书籍 #Agent架构 #pi设计艺术
---

## 📄 概述

第11-14章涵盖了pi从Runtime核心向产品层升级的关键机制。从会话树数据结构的设计，到对话压缩策略，再到三级配置系统和System Prompt装配，这些模块共同构建了一个**高效、可配置、可观测**的Agent产品框架。

核心思想是：**将复杂度分层管理**——Runtime提供最小集合，配置系统提供灵活覆盖，Compaction处理长对话，Prompt装配驱动行为定制。

---

## 📑 主要内容

### 第11章 — 会话树：结构化对话历史

#### 数据结构设计

pi采用**JSONL + parentId树形结构**存储会话。每行一条Entry，通过parentId建立层级关系，形成一个多分支的对话树。

```
Entry 类型（9种）:
  1. message      → 用户或助手消息
  2. compaction   → 压缩后的摘要
  3. branch_summary → 分支标签和描述
  4. model_change → 切换模型
  5. thinking_level_change → 改变思考深度
  6. custom       → 扩展类型
  7. custom_message → 自定义消息格式
  8. label        → 给节点打标签
  9. session_info → 会话元数据
```

#### Branch vs Fork

- **Branch**：从某条消息创建分支，保留上文，追加新的对话路径。适合"重新尝试"、"换个方向"的场景。
- **Fork**：完全复制整条路径，用于版本控制和对比实验。

#### 核心权衡分析

**得到**：
- O(1)存储开销 — 新增分支无需复制历史
- 完美回溯能力 — 任意时刻可跳转到历史节点
- 灵活的对话导航 — 图论结构支持复杂场景

**放弃**：
- JSONL无随机访问 — 必须流式读取全部entries后才能定位特定节点
- 实时查询性能 — 大规模对话树需要内存索引优化
- 简单性 — 线性日志比树形结构更易理解和维护

#### 设计决策

为什么选择树而不是线性？Agent需要支持回溯和试错，分支能力是必需的。JSONL格式保证了零依赖的数据可移植性——无数据库锁定，纯文本即可备份和版本控制。

---

### 第12章 — Compaction压缩策略：长对话的有损变换

#### 问题背景

对话越来越长时，context window爆炸成本急剧上升。简单截断会丢失关键信息，naive的全量保留会导致token浪费。

#### 压缩机制

用LLM对旧对话进行**有损压缩总结**。关键设计点：

1. **token估算触发** — 检测当前context大小，超过阈值时触发压缩
2. **LLM总结** — 保留原始消息最后N条，将N条之前的对话总结为一条compaction entry
3. **文件操作追踪** — readFiles、modifiedFiles列表不丢失，embedded在总结中

#### 配置位置

**压缩在产品层而非runtime层**。Runtime不关心何时触发，由Extension通过`fromHook`接管：

```typescript
fromHook: async (runtime, conversation) => {
  if (estimateTokens(conversation) > THRESHOLD) {
    return runtime.compact(conversation, options);
  }
}
```

这种设计给了用户完全的控制权——可关闭、可自定义阈值、可选择何种压缩策略。

#### 权衡分析

**得到**：
- 长对话持续可用 — 不受context window限制
- 灵活的压缩时机 — 产品层决策，不强制
- 有损变换的信息保留 — 总结包含关键操作

**放弃**：
- 无限精度 — 压缩导致信息丢失（接受的）
- 原始对话完整性 — 压缩后无法恢复原始细节
- 压缩成本 — 需要额外的LLM调用

#### 实施建议

对于重交互的产品（coding assistant），建议激进压缩；对于推理密集的产品，保守压缩。压缩摘要质量直接影响后续模型理解，应选择高质量模型执行。

---

### 第13章 — 三级配置覆盖：从全局到局部

#### 配置层级体系

```
全局配置（~/.pi/agent/）
  ↓ 被覆盖
项目级配置（项目根目录 .pi/）
  ↓ 被覆盖
目录级配置（AGENTS.md）
  ↓ 最终配置
```

#### 三种配置文件的合并策略

1. **settings（YAML/JSON）** — deep merge
   - 低层级配置递归合并到高层级
   - 数组append，对象merge

2. **AGENTS.md** — 拼接
   - 多个agent定义连接在一起
   - 同名agent后者覆盖前者

3. **SYSTEM.md** — 替换
   - 后层级完全替换前层级
   - 无merge，纯覆盖机制

#### 零配置启动

关键特性：**缺失配置不报错，使用内置defaults**。这给新用户完全的友好体验——装好pi即可用，无需配置文件。

#### 权衡分析

**得到**：
- 灵活性 — 全局通用配置 + 项目定制 + 目录专项
- 易用性 — 零配置启动，高层级defaults兜底
- 渐进式深化 — 新手用defaults，高手自定义每个层级

**放弃**：
- 简单性 — 三层机制比单层复杂
- 优先级清晰度 — 需文档明确说明覆盖顺序

#### 配置示例

全局 `~/.pi/agent/settings.json` 定义通用模型和超参，项目 `.pi/AGENTS.md` 定义此项目特有的agent，目录 `AGENTS.md` 针对某个功能模块做微调。

---

### 第14章 — System Prompt装配：五层叠加

#### Prompt构建管道

System Prompt并非静态文本，而是**纯函数运行结果**，由五个来源动态组装：

```
1. Base Prompt（核心指令集）
  ↓ 追加
2. Append Sections（用户追加的通用指令）
  ↓ 附加
3. Context Files（.md/.txt文档内容）
  ↓ 注入
4. Skills List（skill的name+description）
  ↓ 追加
5. Environment Info（当前上下文信息）
  ↓ 最终结果
完整的System Prompt
```

#### 环境信息的特殊地位

关键设计：**环境信息始终追加，即使用户自定义SYSTEM.md也不例外**。

这保证了pi永远知道自己的运行环境（当前文件、可用工具、模型名称等），不会被用户Prompt压制。

#### 纯函数设计的好处

```typescript
systemPrompt = buildSystemPrompt(
  basePrompt,
  appendSections,
  contextFiles,
  skillsList,
  environmentInfo
)
```

- **可测试** — 给定输入，输出确定
- **可缓存** — 如果输入不变，跳过重新计算
- **可观测** — 可打印每层的贡献

#### 权衡分析

**得到**：
- 极高的可定制性 — 五层都可自定义
- 关键信息保护 — 环境信息强制保留
- 组件化维护 — 每层独立，易修改

**放弃**：
- 简洁性 — Base Prompt比全部自定义复杂
- prompt size — 五层叠加导致token消耗更多

#### 实践建议

Base Prompt保持精简（200-300词），核心行为指导。Append Sections放置项目通用规范。Context Files用于注入特定domain知识或公司指南。Skills List自动生成，无需手工维护。环境信息确保后续工具调用正确。

---

## 💡 关键洞见

1. **树形结构 vs 线性日志** — Agent需要支持试错和回溯，树形的成本在JSONL这种纯文本格式下相当低廉，是合理的架构选择。

2. **Compaction的有损变换** — 接受信息丢失，换取长对话可持续。这体现了工程权衡：无法同时拥有完整性和成本效益。

3. **三级配置的渐进式** — 从全局到项目到目录，每级都有明确职责。用户可以全不配置（使用内置default），也可以细粒度定制。这是API设计的高级范式。

4. **System Prompt的五层装配** — 不仅是拼接，而是**有序的信息注入**。Base作骨架，Append为肌肉，Context为血液，Skills为神经，Environment为感官。缺少任何一层都不完整。

5. **环境信息的强制追加** — 保护Agent的"自我感知"，即使用户尝试用Prompt工程压制，系统仍然知道自己是谁、在哪、能做什么。这是防御过度Prompt工程的妙招。

---

## 🔍 个人思考

*（本部分预留给读者按需填写）*

- Runtime vs Product层的职责划分带来哪些收益？
- 在实际项目中，三级配置覆盖实施的难点是什么？
- Compaction策略对模型能力有什么要求？

---

## ⚙️ 实践应用

### 会话树

- 实现multi-turn对话的分支UI——用户可视化回溯和选择分支
- 构建对话版本控制系统——git-like的diff和merge
- 支持对话导出和分享——JSON树可序列化

### Compaction

- 长文档编辑场景——压缩早期编辑历史，保留最后的修改
- 多轮调试会话——压缩失败的尝试，保留成功路径
- 知识库构建——压缩学习过程，保留关键结论

### 三级配置

- 企业部署——全局配置安全策略和模型路由，项目级针对技术栈，目录级针对特定任务
- 开源项目——提供社区常用config在全局，维护者可覆盖，贡献者可精细化

### System Prompt装配

- Prompt A/B测试——变换Base或Append Section，观察行为差异
- 能力版本管理——通过Skills List的启用/禁用控制功能可见性
- 多语言支持——Context Files注入语言指南

---

## 🔗 相关内容

- [[pi的设计艺术]] — 全书导览
- [[极简核心-能力外置]] — Extension系统如何实现Compaction集成
- [[有损变换策略]] — 压缩的理论基础
- [[pi设计艺术 — 能力外置]] — Extension如何钩入会话树
- [[pi设计艺术 — 工具设计]] — System Prompt如何驱动工具调用

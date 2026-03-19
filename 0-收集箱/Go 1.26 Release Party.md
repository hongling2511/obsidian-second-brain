---
type: youtube
title: "Go 1.26 Release Party"
channel: "[[JetBrains]]"
url: https://www.youtube.com/watch?v=MxPjWSsgsiM
video_id: MxPjWSsgsiM
date_watched: 2026-03-20
date_published: 2026-02-19
duration: "1:38:49"
content_type: tech_tutorial
one_line_summary: "[[Go 1.26]] 发布派对全面解析了新版特性、垃圾回收优化及诊断工具，并演示了如何利用 IDE 与 AI 现代化旧代码。"
rating: 4
rating_detail:
  信息密度: 4
  实用性: 5
  新颖性: 4
related_concepts:
  - "[[new built-in]]"
  - "[[errors.AsType]]"
  - "[[errors.As]]"
  - "[[Green tea]]"
  - "[[go fix]]"
  - "[[go vet]]"
  - "[[runtime/secret]]"
  - "[[goroutine leak profile]]"
  - "[[Multi-handler]]"
  - "[[bytes.Buffer.Peek]]"
has_actions: true
tags:[]
---

# Go 1.26 Release Party

---
tags:
  - 视频笔记
  - tech_tutorial
信息密度: 4/5
实用性: 5/5
新颖性: 4/5
---

## 一句话总结
[[Go 1.26]] 发布派对全面解析了新版特性、垃圾回收优化及诊断工具，并演示了如何利用 IDE 与 AI 现代化旧代码。

## 目标受众与前置知识
- **适合谁看**：使用 [[Go]] 语言的后端开发者、关注性能优化和语言特性演进的软件工程师。
- **前置知识**：[[Go]] 基础语法、[[垃圾回收]]（GC）原理、并发编程（[[goroutine]]）、性能剖析（[[pprof]]）。

## 核心观点
1. **[[Go 1.26]] 引入了大量减少样板代码的实用语言特性**
   - 为什么重要：使代码更简洁、类型更安全，提升开发效率。
   - 依据：带有表达式的 `new` 内置函数可以直接赋值指针；泛型的 `errors.AsType` 函数利用编译期检查替代了易错且使用反射的 `errors.As`，且分配内存更少、速度更快（讲者原话）。
2. **新型垃圾回收器 [[green tea]] 显著降低了 CPU 的缓存未命中率**
   - 为什么重要：适应了现代多核高并发服务器环境，减少了 CPU 等待内存读取的时间。
   - 依据：旧版 [[mark and sweep]] GC 因跨堆跳跃导致 CPU 高达 35% 的时间用于等待内存（讲者原话）；新版基于 [[span]] 的线性扫描设计，能使分配大量小对象的应用整体 CPU 使用率降低约 5%（讲者原话）。
3. **借助原生工具链和 AI 插件能够安全高效地现代化旧代码库**
   - 为什么重要：降低了版本升级和代码重构带来的心智负担和风险。
   - 依据：视频演示了使用复活的 [[go fix]] 命令、[[Goland]] IDE 的内置语法升级检查，以及集成 [[Go Modern Guidelines]] 插件的 [[Claude Code]] 和 [[Juny]] 等 AI 助手，实现了代码向 Go 1.26 新语法的自动迁移。

## 概念关系
- [[errors.As]] ↔ [[errors.AsType]]：前者使用运行时反射进行错误解包，后者是 Go 1.26 推出的泛型方法，在编译期执行类型安全检查且无需反射，两者为性能和安全性的对比（迭代替代关系）。
- [[mark and sweep]] GC → [[green tea]] GC：旧的标记清除法在不连续的 [[heap]] 内存中跳跃，导致 [[CPU cache]] 命中率低；新 GC 利用分配器的线性内存块 [[span]] 连续扫描对象，提升缓存效率（优化演进关系）。
- [[secret mode]] → 加密会话安全：密码学库利用 `runtime/secret` 提供的方法，在离开作用域时强制清零（Zero out）临时密钥的栈和堆内存，防止内存泄漏导致的密钥被窃取（依赖/保障关系）。

## 详细笔记
### 欢迎环节与嘉宾引言
- 主持人开启直播，表明自己只知道 [[Go]] 的拼写，引导观众在聊天室互动。
- 嘉宾 Alex Hughes 自我介绍是来自巴西的软件工程师，参与社区并撰写关于 [[Go]] 和 [[Zigg]] 的书籍，同时表达了自版本 1.16 以来对 [[Google]] 的满意度。
- 嘉宾 Anton 自我介绍为 Go 版本交互式教程的制作者。
- 预热讨论中，主持人调侃希望 [[JavaScript]] 能有更多 [[TypeScript]] 的特性；Anton 表示最喜欢错误类型检查的更新；Alex 则偏爱实验性的 [[goroutine leaks]] 检测、[[SIMD]]（视频字幕记作 cmd/SAMD）能力提升以及信号原因排查。

### Anton 详解 Go 1.26 四大核心更新
- **含表达式的 `new` 函数**：现在可以在分配内存的同时为变量（甚至结构体和函数返回值）赋初值。在处理具有可选字段的 [[JSON]] 和 [[protobuff]] 结构体时尤为有用，可淘汰项目中自定义的 `ptr()` 辅助函数。
- **`errors.AsType` 泛型函数**：替代原有的 `errors.As`。能够将变量范围限定在 `if` 分支内，写法类似 `switch`。提供编译时类型检查（必须实现 error 接口），不使用 `reflect` 包，分配更少且更快。官方建议全面改用此函数。
- **新型垃圾回收器 [[green tea]]**：与 [[Java]] 等语言不同，Go 仅有单一 GC。旧的 [[mark and sweep]] 机制在 [[heap]] 内存中跳跃，导致高达 35%（讲者原话）的 [[CPU]] 时间耗费在等待主存数据到达 [[CPU cache]]。新 GC 利用分配器现有的 8KB 线性连续内存块（[[span]]）结构，使 CPU 能一并加载相邻对象，大幅减少缓存未命中。面向小对象分配密集的应用，可降低约 5%（讲者原话）的 CPU 使用率。
- **重新启用的 [[go fix]]**：曾经在 Go 早期使用，现以与 [[go vet]] 相同的后端框架回归。[[go vet]] 用于指出问题，[[go fix]] 用于安全地、自动地重写和现代化代码（如将手动操作 `sync.WaitGroup` 替换为新版本方法）。

### 互动问答第一环：GC 与平台支持
- **关于 [[Rust]] 与并发**：Anton 指出新 GC 主要是为了适应现代拥有 64 核等多核 CPU 的高性能服务器，减少缓存未命中。
- **关于百万对象 Map**：如果是位于 [[heap]]（通过 [[escape analysis]] 确认）上的半 KB 以下小对象，新 GC 会有明显帮助。
- **关于实验性向量化支持**：目前仅支持 [[MD64]] / [[AMD64]]，暂时不支持 [[ARM]] / [[ARM 64]] 或是 RCB risky（推断为 [[RISC-V]]）。Go 团队希望先收集反馈。

### Anton 演示进阶语言特性与监控能力
- **[[secret mode]] (`runtime/secret`)**：专为加密通信库设计。其 `secret.Do()` 方法内的匿名函数执行完毕后，Go 运行时会立刻将作用域内的 [[stack]] 变量和不可达的堆变量内存直接填零（不是标记为空闲），防止内存被攻击者提取。
- **生产环境 [[goroutine leaks]] 分析**：此前主要靠 [[sync test]] 在测试阶段排查。现在利用 `runtime pprof` 提供的 `pprof.Lookup("goroutine leak")` 可以在生产环境中直接输出导致泄漏（如发送阻塞）的具体代码行号。
- **Go routines 运行时指标增强**：新增细粒度的指标（执行系统调用、可运行但未运行、正在执行、等待同步等）和活跃线程数。可以通过 [[Prometheus]] 或 [[otel]]（[[Open Telemetry]]）收集，用于在系统崩溃前排查潜在负载与 Bug 异常。
- **标准库 [[iterators]] 扩展**：展示了 `reflect` 包中的 `Fields()`、`Methods()`、`In()`、`Out()` 等支持 for-range 语法的迭代器。
- **[[VS log]] / [[slog]] 的多路由**：新增 `slog.MultiHandler`，可以轻松将日志同时路由到标准输出和文件处理程序，替代了有缺陷的 `io.MultiWriter`。
- **`bytes.Buffer` 的 `Peek` 方法**：读取时不改变内部指针偏移，返回底层数据的直接视图而不是副本（修改切片会改动原 buffer）。
- **`fmt.Errorf` 性能优化**：内部实现若发现无 `%` 占位符，会直接回退到 `errors.New`，使得未格式化的错误字符串创建具有单次分配的极高性能。

### 互动问答第二环
- 内存分配从未释放的疑问：Anton 澄清内存未释放属于常规内存泄漏，与 [[secret mode]] 无关，GC 必须先判断对象不可达，才会将其清零。
- 与 [[zap]] 的性能对比：Anton 表示不熟悉其性能，但自己用 [[slog]] 很满意。
- 评论区 Alv Pro 询问神秘词汇 "string slide"，讲者表示不知情。

### Alex 演示：旧项目迁移 Go 1.26 实战
- **准备工作与环境配置**：展示了一个用于并发检测目标（如 [[GitHub]] 和 [[Google]]）的 Go 1.25 项目。首先在 [[Goland]] 调整 Go SDK 路径。
- **语法检查与修复**：利用 IDE 的 syntax updates 检查，批量修复了项目中的旧语法，盲态应用了从 `errors.As` 到 `errors.AsType` 的转换。
- **运行 [[go fix]] 自动化重构**：讲者表示放弃了传统的 [[Make]]，改用 M taskus/Miz（推断为 [[Mage]] 任务工具）。运行 `go fix` 自动将旧的 `sort` 替换为 `slices.Sort`，`strings.Split` 替换为 `strings.SplitSeq`。
- **基准测试构建**：编写带 500 个并发检查器的测试以验证新 GC 性能，为了防止编译器优化剔除，特意保留了临时 Slice（讲者原话）。
- **飞行记录器模式**：借助第三方库 `log flight recorder` 模仿 [[Grafana]] 的 [[Flight recorder]] 功能。使用 IDE 的实时模板（Live Templates）快速生成 HTTP 的 `handleFunc` 代码，将环形缓冲日志结合 `slog.MultiHandler` 暴露为接口。
- **AI 赋能代码生成**：
  - 使用 IDE 内置工具 [[Juny]]（推断为 [[LLMs]] 助手）自动实现了 `metrics` 接口点，肯定了其生成基础代码的能力。
  - 在生成包含 Go 1.26 特定结构的代码（错误状态检查）时，最初调用了 [[Claude Code]] (视频读作 clot code) 但生成了过时的写法。
  - **安装外挂优化**：通过在 [[Jet Brains]] 安装启用 [[Go Modern Guidelines]] 插件，并重启应用后，成功指引 [[Claude Code]] 写出了符合最新 Go 1.26 标准（如完美使用了泛型方法）的高质量代码。

## 金句亮点
- "Adding huge new features can be easy and they make product management happy. But what makes us happy is that the team really cares about the language and the standard library." — 观点 / 表达了开发者对 Go 核心团队持续钻研底层基础细节（如 `fmt.Errorf` 的微小优化）的极高认同感。（意译）
- "I don't like my tooling in my editor drag me and or slow me down during the development. So if it's snappy, it's good enough." — 经验 / 强调了 IDE 和自动化工具在代码现代化过程中必须保持轻量、无感且响应迅速的核心价值。（意译）

## 行动建议
- **执行自动化代码升级**：在旧有的 Go 项目中运行 `go fix` 命令，或使用 IDE 提供的语法检测面板，自动将 `errors.As` 替换为 `errors.AsType`，以及升级过时的循环和排序方法。
  - **关联观点**：1, 3
  - **验证标准**：代码库成功通过编译，且通过静态代码分析不再报出旧语法相关的重构警告。
- **收集生产环境 Goroutine 泄漏报告**：在应用的 HTTP 调试或诊断路由中，集成并拉取 `runtime/pprof.Lookup("goroutine leak")` 生成的配置文件。
  - **关联观点**：1
  - **验证标准**：通过分析工具查看到导致泄漏的具体堆栈信息和准确的代码行号。
- **配置与引入新指标仪表盘**：使用 Open Telemetry 或 Prometheus 的客户端，导出并监控新增的 Go routine 详细状态指标（如 runnable 等待数量、执行中数量）。
  - **关联观点**：2
  - **验证标准**：监控大盘能够可视化展示 Go routines 各子状态随时间的变化曲线，以帮助提前识别负载异常。

## 技术栈与环境要求
- **核心技术**：`[[Go]]`、`[[Goland]]`、`[[go fix]]`、`[[log/slog]]`、`[[runtime/secret]]`、`[[runtime/pprof]]`、`[[runtime/metrics]]`、`[[bytes]]`、`[[Mise]]`、`[[Juni]]`、`[[Claude Code]]`、`[[Prometheus]]`、`[[OpenTelemetry]]`
- **环境要求**：支持 `[[Go]]` 1.26 的机器（新垃圾回收器支持 MD64 架构），安装最新版 `[[Goland]]` IDE（自带 1.26 语法支持），其余操作系统、软件版本未明确提及。
- **前置技能**：未明确提及。

## 步骤拆解
1. **升级项目 SDK 与模块版本**
   - 在 `[[Goland]]` 中将 Go Root 设置为 `[[Go]]` 1.26，随后在 `go.mod` 中更新版本号。
   - 关键代码/命令：未明确提及
   - 注意事项：需确保本地环境已安装新版 Go。

2. **分析并应用语法更新（Syntax Updates）**
   - 触发 IDE 的 "Analyze code for syntax updates" 功能，扫描出可以替换为 Go 1.26 新特性的代码片段（如将 `errors.As` 替换为泛型的 `errors.AsType`、更新 `new` 表达式等），通过 "Apply all fixes" 一键修复。
   - 关键代码/命令：未明确提及
   - 注意事项：在批量修复前，如果项目包含自动生成的代码（Generated Code），应将其排除以免破坏生成逻辑。

3. **运行 go fix 进行代码现代化**
   - 使用任务执行工具（如 `[[Mise]]`）查看变更差异，随后运行 `[[go fix]]` 将旧代码重构为现代写法（例如将 `sort` 包替换为 `slices.Sort`，简化数字的 `range` 遍历等）。
   - 关键代码/命令：`go fix`
   - 注意事项：`go fix` 的执行是确定性的（Deterministic），所有变更宣称是安全的。

4. **进行 GC 性能基准测试**
   - 编写 Benchmarks，强制分配并在内存中保留 Slice 数据以增加垃圾回收压力，以此对比新（Green Tea）旧垃圾回收器的 p50 与 p99 耗时表现。
   - 关键代码/命令：未明确提及
   - 注意事项：Benchmark 测试结果极易受机器噪音等环境影响，需执行多次循环（warm-up），并借助 benchstat 工具分析才具有统计学意义。

5. **配置 slog 多路输出与环形缓冲日志**
   - 引入飞行记录器（Flight recorder）概念的包，使用 `[[log/slog]]` 包的 `Multi-handler` 将日志路由到标准输出和最新的 5 条日志内存环形队列中。遇到依赖缺失时，使用 IDE 上下文菜单解决。
   - 关键代码/命令：未明确提及（IDE 后台自动运行 `go mod tidy`）
   - 注意事项：在写入 HTTP Response 响应头时要小心处理 Error 逻辑，避免引发无限循环的日志记录。

6. **利用 AI 助手生成现代 Go 代码**
   - 使用 `[[Juni]]` 提示生成业务代码。为了让 `[[Claude Code]]` 也能输出符合 Go 1.26 规范的代码，安装并启用 JetBrains 的 Go Modern Guidelines 插件。
   - 关键代码/命令：未明确提及
   - 注意事项：若不希望 AI 擅自运行测试妨碍开发节奏，需在 Prompt 中明确添加指令要求“不要运行测试”；启用插件后需重启 IDE 并输入特定提示词“use modern go”才能生效。

## 常见坑与解决方案
- **问题描述**：使用 IDE 批量应用语法更新时，可能会意外修改项目中自动生成的代码。
  - 解决方案：在 "Apply all fixes" 前，手动剔除或忽略自动生成的代码文件。
- **问题描述**：在执行加解密会话时，临时密钥变量哪怕不再使用，数据也会在堆/栈内存中驻留（直至被覆盖），若遭遇内存泄露会被攻击者读取。
  - 解决方案：使用 `[[runtime/secret]]` 包的 `Secret.Do()` 函数，该函数会在离开作用域后强制将栈内存、CPU寄存器以及随后的堆内存对应区域清零（Zero out）。
- **问题描述**：Goroutine 泄漏（例如卡在 channel 同步操作上）在生产环境中通常静默发生，不像 Deadlock 会直接触发 panic 报错。
  - 解决方案：调用 `[[runtime/pprof]]` 包的 `Lookup("goroutine_leak")` 生成并分析性能剖析文件，精准定位到发生泄漏的代码行。
- **问题描述**：`[[Claude Code]]` 等 AI 工具生成的代码可能仍使用过时的 Go 语法（如依旧生成 `errors.As`）。
  - 解决方案：在 `[[Goland]]` 中安装启用 Go Modern Guidelines 插件，重启 IDE 后使用强调语气的 Prompt 指导 AI。

## 最佳实践
- 推荐使用新版的泛型函数 `errors.AsType` 来替代旧版的 `errors.As`（代码可读性更强，类型更安全，且零内存分配）。
- 推荐使用包含初始值的 `new` 表达式进行内联的内存分配和指针赋值（特别是针对具有可选字段的结构体）。
- 推荐将 `[[go fix]]` 检查集成到项目的 CI 流程或 pre-commit hook 中，确保团队内即使用记事本写代码的人也能保持代码的现代化。
- 推荐在监控系统（如 `[[Prometheus]]` 或 `[[OpenTelemetry]]`）中收集 `[[runtime/metrics]]` 中的 Runnable Goroutines 数量，通过观测这一指标的动态趋势，可以在应用层面暴露症状之前提早发现故障或并发过载情况。
- 推荐在批量应用 `[[go fix]]` 之前，先运行 Diff 查看底层改动。
- 反模式：绝不要修改由 `[[bytes]]` 包的 `Buffer.Peek()` 返回的切片（Slice）数据内容，因为该切片并没有执行数据拷贝，只是对底层缓冲区的视图映射，修改它将直接污染原始的缓冲区数据。

## 关键概念

### [[new built-in]]
- **定义**：Go 1.26 中允许接收任意表达式并直接完成变量分配与赋值的内置函数 [1, 2]。
- **视频上下文**：讲者解释了过去需要先分配再赋值的繁琐过程，现在通过传入具体值、结构体或函数调用结果即可一步完成操作 [1, 2]。
- **为什么重要**：极大简化了处理 JSON 或 Protobuf 中包含可选字段的结构体时的代码冗余，开发者可直接摒弃过去专门为此编写的指针辅助函数 [2-4]。
- **关联概念**：未明确提及

### [[errors.AsType]]
- **定义**：Go 1.26 引入的泛型错误检查函数，用于完全替代旧的 `errors.As` 函数 [5, 6]。
- **视频上下文**：该函数被用于演示检查特定类型错误，它能将获取到的特定错误变量安全地限制在对应的 if 分支作用域内，表现得类似于处理错误类型的 switch 语句 [5, 7-9]。
- **为什么重要**：由于采用了泛型设计，它能在编译时提供类型安全检查，且运行时速度更快、不再使用反射并减少了内存分配 [6, 9, 10]。
- **关联概念**：对比 → [[errors.As]]

### [[Green tea]]
- **定义**：Go 1.26 默认启用的新一代垃圾回收器 [11, 12]。
- **视频上下文**：讲者指出旧 GC 会跨内存区域随机跳转导致大量 CPU 缓存未命中，而 Green tea 则通过线性扫描被称为 span 的连续内存块来大幅提升 CPU 缓存效率 [11, 13-16]。
- **为什么重要**：它专门针对频繁分配大量小对象的应用程序进行了优化，在此类场景下可降低约 5% 的 CPU 整体使用率 [17-19]。
- **关联概念**：未明确提及

### [[go fix]]
- **定义**：利用现代分析框架重构后回归的自动化代码更新与现代化重构工具 [20, 21]。
- **视频上下文**：它被描述为一种安全的自动重写工具，讲者演示了如何利用其内建的启发式规则，自动将旧式的 `sync.WaitGroup` 操作重写为新的语法 [21-23]。
- **为什么重要**：其提供的安全重构特性使得开发者可以直接将其集成到 CI 工作流中，以确保代码库自动采用最新语言和标准库的写法 [21, 22]。
- **关联概念**：对比 → [[go vet]]

### [[runtime/secret]]
- **定义**：一个提供 `secret.Do` 函数的包，能在离开闭包作用域时自动将相关的 CPU 寄存器和堆栈内存彻底清零 [24, 25]。
- **视频上下文**：主要被描述为密码学库开发者使用的底层机制，用于处理现代安全协议通信会话中生成的临时密钥 [26-28]。
- **为什么重要**：它通过硬件和垃圾回收层面的归零操作保证了内存的绝对安全，防止攻击者在私钥泄露或接触内存后解密历史通讯数据 [27, 29]。
- **关联概念**：未明确提及

### [[goroutine leak profile]]
- **定义**：`runtime/pprof` 标准库中新增的实验性性能分析类型，专门用于追踪泄露（卡住）的 Goroutine [30-32]。
- **视频上下文**：讲者利用一个阻塞在通道发送端而永久卡住的测试程序，演示了如何通过该功能精准定位到发生泄漏的代码行号 [31, 33]。
- **为什么重要**：使得过去难以发觉且不同于死锁的“隐形”并发泄漏问题，终于有了可在生产环境中直接使用的排查与诊断手段 [33-35]。
- **关联概念**：未明确提及

### [[Multi-handler]]
- **定义**：标准库 `log/slog` 中新增的处理程序，能够包裹并将单一的日志记录自动分发路由到多个其他的子处理程序中 [36, 37]。
- **视频上下文**：代码示例中展示了如何将同一个应用的日志记录，同时输出为控制台的普通文本格式以及文件中的 JSON 格式 [37, 38]。
- **为什么重要**：直接弥补了标准库日志包难以优雅兼顾多个输出目标的缺陷，让开发者不再需要依赖繁琐且有副作用的 `io.MultiWriter` [36-38]。
- **关联概念**：未明确提及

### [[bytes.Buffer.Peek]]
- **定义**：`bytes.Buffer` 类型提供的新方法，允许读取指定长度的字节但不前移缓冲区的当前读取位置 [39, 40]。
- **视频上下文**：演示代码利用该方法读取了接下来的 4 个字节而不推进内部指针，讲者特别提醒它返回的是指向原始缓冲区的切片视图（view）而非数据副本 [40, 41]。
- **为什么重要**：提供了一种高效前瞻数据的方法，但使用时需极其谨慎，因为直接修改其返回的切片内容会破坏底层缓冲区的原始数据 [41, 42]。
- **关联概念**：未明确提及

## 概念关系图
- [[errors.AsType]] ↔ 对比 ↔ [[errors.As]]
- [[go fix]] ↔ 对比 ↔ [[go vet]]

## 行动项

- [ ] **升级至 Go 1.26 并在应用中监控 observability 指标** [1, 2]
  - 目的：观察 `green tea` 垃圾收集器对应用整体 CPU 使用率的改善情况，特别是针对存在大量小对象分配的应用 [2-4]。
  - 难度：未明确提及
  - 预估时间：未明确提及
  - 相关工具或资源：Go 1.26，现有的 observability 监控工具 [1, 2]

- [ ] **使用 `runtime/pprof` 收集 goroutine leak profile** [5, 6]
  - 目的：在生产环境中检测并追踪因卡在同步对象（如 channel）上而导致的 goroutine 泄漏 [5-7]。
  - 难度：未明确提及
  - 预估时间：未明确提及
  - 相关工具或资源：`runtime/pprof` 包，`pprof` 分析工具 [5, 6]

- [ ] **在项目中运行 `go fix` 命令行工具** [8, 9]
  - 目的：自动将旧代码重构为现代语言和标准库特性，例如将 `errors.As` 替换为新的泛型 `errors.As` type 函数，或自动化更新 `sync.WaitGroup` 的计数器调用 [8, 10, 11]。
  - 难度：未明确提及
  - 预估时间：未明确提及
  - 相关工具或资源：`go fix` 命令，可结合 CI 或 pre-commit hook 使用 [8, 12]

- [ ] **在 GoLand 中执行“Analyze code for syntax updates”操作** [13, 14]
  - 目的：直接在 IDE 内部快速识别并批量应用 Go 1.26 语法更新，如优化 `new` 表达式及 `errors.As` 类型解包 [15, 16]。
  - 难度：未明确提及
  - 预估时间：未明确提及
  - 相关工具或资源：GoLand 1.26 [13, 17]

- [ ] **安装并启用 `go modern guidelines` 插件并重启 IDE** [18, 19]
  - 目的：使 Cloud Code 等 AI 工具在生成代码时，能够写出符合 Go 1.26 现代规范语法的代码（而非过时的老旧模式） [18, 20]。
  - 难度：未明确提及
  - 预估时间：未明确提及
  - 相关工具或资源：JetBrains IDE，`go modern guidelines` 插件，Cloud Code [18, 19]

- [ ] **访问链接完成 Go 1.26 interactive tour** [21, 22]
  - 目的：在一个安全的临时项目中，通过实际动手测试和练习来深入学习 Go 1.26 的各项新特性 [21, 22]。
  - 难度：未明确提及
  - 预估时间：未明确提及
  - 相关工具或资源：Go 1.26 interactive tour 链接 [21]

- [ ] **扫描屏幕二维码并使用促销代码 `go release party`** [23, 24]
  - 目的：获取为期 6 个月的 GoLand extended trial（扩展试用）许可 [23, 25]。
  - 难度：未明确提及
  - 预估时间：未明确提及
  - 相关工具或资源：二维码，优惠码 `go release party`，GoLand [23-25]

## 附件

- 思维导图：[[_附件/mindmaps/MxPjWSsgsiM.json]]
- 学习指南：[[_附件/MxPjWSsgsiM_study_guide.md]]

---
*自动生成于 2026-03-20 00:33 | [原始视频](https://www.youtube.com/watch?v=MxPjWSsgsiM)*

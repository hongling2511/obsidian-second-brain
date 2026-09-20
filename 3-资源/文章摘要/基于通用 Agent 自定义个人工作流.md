---
"创建日期": 2026-07-29
"类型": 文章
"作者": OpenAI、Anthropic、Pi 项目与开放规范维护者
"关键词": AI Agent, Codex, Claude Code, Pi, Agent Skills, MCP, 工作流, Hooks, Subagents, CI
"复习间隔": 1, 7, 21, 60
"复习日期": 2026-07-30
tags: #资源
---

# 基于通用 Agent 自定义个人工作流

## 一句话总结

**不要把个人工作流绑定在某个 Agent 的一份超长提示词里。** 更稳的做法是把它拆成七层：项目事实、可复用技能、确定性脚本、工具接入、生命周期策略、任务编排、自动化入口。以 `AGENTS.md` 和 Agent Skills 作为可移植核心，再为 Codex、Claude Code、Pi 写薄适配层。

> 通用 Agent 更像“可编程执行环境”，而不是一位需要背下所有规矩的万能员工。稳定工作流来自明确的输入输出契约、最小权限、确定性验证和可审计的触发点，而不是更长的提示词。

这也是 [[协议式设计 vs 框架式设计]] 在 Agent 工作流里的实际应用：先定义跨工具协议，再把平台能力当作可替换适配器。规划与验收仍应遵循 [[AI Agent开发工作流实践：AFK与HITL]] 中的边界划分。

## 先区分七种定制对象

| 层 | 解决的问题 | 推荐载体 | 是否应跨平台 |
|---|---|---|---|
| 项目事实 | 这个仓库是什么、怎么构建、有哪些硬约束 | `AGENTS.md`，Claude 用薄 `CLAUDE.md` 导入 | 是 |
| 可复用技能 | 某类任务应按什么步骤完成 | `SKILL.md` + `scripts/` + `references/` | 是，优先遵循 Agent Skills |
| 确定性脚本 | 哪些动作不应交给模型自由发挥 | Shell、Python、项目已有命令 | 是 |
| 工具接入 | Agent 如何访问数据库、浏览器、工单系统 | MCP、CLI、原生工具或 Pi Extension | 接口可移植，配置不完全可移植 |
| 生命周期策略 | 何时拦截、检查、记录、通知 | Hooks 或 Pi 事件扩展 | 概念可移植，事件名和配置专属 |
| 任务编排 | 何时拆分子任务、如何汇总 | Subagents、Pi 扩展或外部调度器 | 角色与契约可移植，实现专属 |
| 自动化入口 | 如何在 CI、定时任务、脚本中运行 | headless/print/JSON/RPC、GitHub Actions | 概念可移植，命令专属 |

## 三个平台的可定制表面

### 对照表

| 能力 | Codex | Claude Code | Pi |
|---|---|---|---|
| 项目指令 | 原生读取分层 `AGENTS.md`；从全局到项目根再到当前目录合并，近目录指令优先 | 原生读取 `CLAUDE.md`；可用 `@AGENTS.md` 导入公共指令，另加 Claude 专属内容 | 原生读取 `AGENTS.md` 或 `CLAUDE.md`，合并全局、父目录和当前目录文件 |
| Skills / Commands | Agent Skills：`SKILL.md`、脚本、参考资料、资产；可显式 `$skill` 或由描述匹配 | Agent Skills；`/skill-name`，旧 `.claude/commands/*.md` 仍兼容；另有调用控制、动态上下文、`context: fork` | Agent Skills；`/skill:name` 或自动匹配；另有独立 prompt templates，以 `/name` 展开 |
| Hooks | 原生声明式生命周期 Hooks，可覆盖工具调用、权限请求、压缩、会话和子 Agent 等事件 | 原生 Hooks；处理器可为命令、HTTP、MCP tool、prompt 或 agent | 没有同名的独立声明层；TypeScript Extension 的事件系统可拦截输入、工具调用、会话生命周期等 |
| 工具 / MCP | 原生 MCP，支持 STDIO 和 Streamable HTTP；也有本地 Shell 等能力 | 原生 MCP，权限规则也可约束 MCP 工具 | Extension 可注册、替换工具；核心刻意不内置 MCP，但可通过扩展或包实现 |
| Subagents | 原生并行子 Agent；可定义不同模型、推理强度和指令的自定义 Agent | 原生自定义 subagents；可配置 tools、model、permissions、skills；skill 也可用 `context: fork` 隔离执行 | 核心刻意不内置 subagents；官方建议通过 Extension、第三方包、tmux 或启动其他 Pi 实例自定义 |
| 无头与自动化 | `codex exec`；JSONL；官方 `openai/codex-action` | `claude -p`；text/JSON/stream-json；Agent SDK；官方 GitHub Action | `-p`、JSON mode、RPC mode、SDK，可嵌入自己的进程 |
| 权限边界 | 沙箱、审批模式、命令 `.rules`、Hooks 信任审查 | tool permissions + OS 级 Bash sandbox；支持文件和域名边界 | 默认继承启动用户与进程权限；没有内置权限系统，应容器化或自己实现 gate |

### Codex：平台能力最适合做“治理与自动化适配器”

Codex 在任务开始前按层级发现 `AGENTS.md`：先全局，再从项目根走到当前目录；后加载的近目录指令覆盖前面的通用指令。[OpenAI：AGENTS.md](https://developers.openai.com/codex/guides/agents-md)

Codex Skills 遵循 Agent Skills 开放格式，一个技能目录至少包含 `SKILL.md`，还可包含 `scripts/`、`references/`、`assets/`；运行时先暴露名称和描述，命中后再加载完整指令。[OpenAI：Build skills](https://developers.openai.com/codex/skills)

Hooks 是确定性治理面：可在 `PreToolUse`、`PermissionRequest`、`PostToolUse`、`Stop`、`SessionStart`、`SubagentStart` 等节点运行脚本。项目 Hooks 只有在 `.codex/` 层被信任后才加载，非托管命令 Hook 的内容发生变化后需要重新审查和信任。[OpenAI：Hooks](https://learn.chatgpt.com/docs/hooks)

Codex 原生连接 STDIO 与 Streamable HTTP MCP server，并可把配置放在用户级或受信任项目的 `.codex/config.toml`。[OpenAI：MCP](https://developers.openai.com/codex/mcp) 子 Agent 适合并行的探索、测试、日志分析和总结；官方同时提醒，并行写入容易产生冲突，应更谨慎。[OpenAI：Subagents](https://learn.chatgpt.com/docs/agent-configuration/subagents)

自动化时用 `codex exec`：默认只读沙箱，可显式升到 `workspace-write`，支持 JSONL 事件输出；官方 GitHub Action 本质上也是按指定权限运行 `codex exec`。[OpenAI：Non-interactive mode](https://developers.openai.com/codex/noninteractive) [OpenAI：Codex GitHub Action](https://learn.chatgpt.com/docs/github-action)

### Claude Code：平台能力最适合做“精细触发与角色配置适配器”

Claude Code 的项目指令文件是 `CLAUDE.md`，但官方明确给出了跨 Agent 方案：在薄 `CLAUDE.md` 中写 `@AGENTS.md`，公共规则只维护一份，再附加 Claude 专属规则。[Anthropic：Memory / CLAUDE.md](https://code.claude.com/docs/en/memory)

Claude Skills 同样基于 Agent Skills；旧 `.claude/commands/` 已合并到 Skills 机制并继续兼容。Claude 的专属扩展包括：禁止模型自动调用、限定路径、注入动态命令输出、用 `context: fork` 在隔离子 Agent 中执行等。[Anthropic：Skills](https://code.claude.com/docs/en/slash-commands)

Claude Hooks 是固定生命周期上的确定性控制，可执行 shell、HTTP、MCP tool、prompt 或 agent；适合格式化、通知、命令拦截和验收。[Anthropic：Hooks guide](https://code.claude.com/docs/en/hooks-guide) 自定义 subagent 可预加载 skills、限制 tools 和允许派生的 Agent 类型，但当前官方文档说明 subagent 不能继续派生 subagent。[Anthropic：Subagents](https://code.claude.com/docs/en/sub-agents)

Claude 原生支持 MCP。[Anthropic：MCP](https://code.claude.com/docs/en/mcp) 自动化入口是 `claude -p`，可设 `--max-turns`、预算、允许工具和结构化输出；官方 GitHub Action 可由 issue/PR 评论或标准 GitHub 事件触发。[Anthropic：CLI reference](https://code.claude.com/docs/en/cli-reference) [Anthropic：GitHub Actions](https://code.claude.com/docs/en/github-actions)

安全上，Claude 的 permissions 控制工具、文件和域名访问，sandbox 则对 Bash 及其子进程做 OS 级文件系统与网络隔离；两者应叠加使用。[Anthropic：Permissions](https://code.claude.com/docs/en/permissions) [Anthropic：Sandboxing](https://code.claude.com/docs/en/sandboxing)

### Pi：平台能力最适合做“自定义 Agent Harness”

截至访问日，原 `badlogic/pi-mono` GitHub 地址会跳转到 `earendil-works/pi`；仓库 README 将其称为 Pi Agent Harness 的主页，因此本文以该跳转后的仓库作为当前官方上游，而不是镜像或第三方教程。[Pi 官方仓库](https://github.com/earendil-works/pi)

Pi 的设计取向与前两者不同：核心保持极简，把工作流交给 TypeScript Extensions、Skills、Prompt Templates 和 Packages。它原生读取 `AGENTS.md` 或 `CLAUDE.md`；Extension 可以注册或替换工具、注册命令、监听生命周期事件、实现权限 gate、subagent、plan mode 和 MCP 接入。[Pi coding-agent README](https://github.com/earendil-works/pi/tree/main/packages/coding-agent)

Pi 的 Skill 也采用 Agent Skills，支持从 `~/.agents/skills/` 与项目 `.agents/skills/` 发现技能，还能显式加载 Claude Code 或 Codex 的 skills 目录。[Pi：Skills](https://github.com/earendil-works/pi/blob/main/packages/coding-agent/docs/skills.md) 对于只需手动展开的短提示，Pi 另有 Prompt Templates，项目位置是 `.pi/prompts/*.md`。[Pi：Prompt Templates](https://github.com/earendil-works/pi/blob/main/packages/coding-agent/docs/prompt-templates.md)

Pi 核心明确不内置 MCP、subagents、plan mode 和权限弹窗；这些能力可由 Extension 或包实现。它提供 print、JSON、RPC 和 SDK 四种集成方式。[Pi coding-agent README](https://github.com/earendil-works/pi/tree/main/packages/coding-agent) 还要特别注意：Pi 默认没有文件、进程、网络或凭证的内置权限隔离，官方建议需要强边界时使用微虚拟机、Docker 或策略沙箱。[Pi 官方仓库：Permissions & Containerization](https://github.com/earendil-works/pi#permissions--containerization)

## 哪些抽象稳定，哪些不要强行统一

### 跨工具稳定抽象

1. **项目上下文文件**：仓库目标、构建命令、领域词汇、禁止事项、验收命令都可以用普通 Markdown 表达。公共真源建议为 `AGENTS.md`，Claude 用 `CLAUDE.md` 导入它。
2. **Agent Skills**：三者都能消费以 `SKILL.md` 为核心的能力包。开放规范规定了 `name`、`description`，以及可选的 `scripts/`、`references/`、`assets/`，并采用渐进式加载。[Agent Skills 规范](https://agentskills.io/specification)
3. **任务契约**：`输入 → 前置条件 → 步骤 → 输出 → 验收 → 失败处理` 不依赖具体 Agent。
4. **确定性 verifier**：测试、lint、schema 校验、链接检查、diff 限制应做成脚本；Agent 负责选择和解释，脚本负责给出可复现事实。
5. **工具契约**：工具都应有明确名称、参数 schema、结果和错误语义。MCP 把外部数据、prompts、resources、tools 标准化，但 Pi 核心需要适配层。[MCP 规范](https://modelcontextprotocol.io/specification/2025-11-25)
6. **最小权限与 HITL**：读、写、联网、发布、删除、付费和生产变更应是不同权限级别。MCP 规范也要求用户理解数据访问与操作，并建议工具调用保留人类拒绝能力。[MCP 安全原则](https://modelcontextprotocol.io/specification/2025-11-25/server/tools)
7. **无头运行契约**：固定输入、机器可读输出、退出码、预算/轮次上限、日志和产物路径，是 CI 适配的公共接口。

### 平台专属，不应放进可移植核心

- Hooks 的事件名、匹配器、信任模型和返回值。
- Skills 的扩展 frontmatter。`allowed-tools` 在开放规范中仍是实验字段，各实现支持程度不同；Claude 的 `context: fork` 等也属于平台扩展。
- Subagent 的配置格式、是否允许嵌套、并发上限、模型和权限继承规则。
- MCP 配置文件位置、认证方式和工具命名；Pi 是否通过 Extension 接入。
- 沙箱与审批模型。尤其不能把 Codex/Claude 的权限假设直接复制到 Pi。
- 会话存储、压缩、后台任务、UI、插件/包分发方式。

## 推荐的分层目录

下面是“可移植核心 + 薄适配器”的参考结构，不要求三个工具都原生识别每个目录：

```text
repo/
├── AGENTS.md                         # 公共项目事实、边界、验证命令
├── CLAUDE.md                         # 只写 @AGENTS.md + Claude 专属差异
├── .agents/
│   └── skills/
│       └── pr-readiness/
│           ├── SKILL.md              # 跨工具工作流真源
│           ├── scripts/
│           │   ├── collect-diff.sh
│           │   └── verify.sh
│           ├── references/
│           │   └── 审查标准.md
│           └── assets/
│               └── 报告模板.md
├── .agent-workflows/
│   ├── contracts/                    # 输入/输出 JSON Schema、状态定义
│   ├── evals/                        # 固定样例、回归集、预期结果
│   └── runs/                         # 可忽略或上传的运行产物
├── .codex/
│   ├── config.toml                   # MCP、profile、沙箱等 Codex 适配
│   └── hooks.json                    # Codex 生命周期适配
├── .claude/
│   ├── settings.json                 # 权限、MCP、Hooks 等 Claude 适配
│   └── agents/                       # Claude 专属角色
├── .pi/
│   ├── settings.json                 # Pi 资源发现与 trust 配置
│   ├── extensions/                   # Pi 事件、工具和权限适配
│   └── prompts/                      # 仅 Pi 使用的短命令
└── .github/workflows/
    └── agent-pr-review.yml           # CI 触发器，调用确定性脚本和 Agent
```

目录原则：

- **公共事实只写一次**：不要同时维护三份内容近似的项目规则。
- **Skill 描述负责触发，正文负责编排，脚本负责确定性**。
- **输出先定义 schema，再写 prompt**：没有输出契约，就很难做回归测试或替换 Agent。
- **平台目录只放差异**：如果 `.codex/` 或 `.claude/` 里出现大段业务流程，说明适配层正在吞掉核心。
- **密钥永不进入技能或项目指令**：只引用环境变量名或凭证提供机制。

## 触发方式设计

同一工作流最好同时支持三种触发：

1. **显式交互触发**：用户点名技能。适合高风险、低频或参数复杂的任务。
2. **语义自动触发**：用清楚的 `description` 让 Agent 在匹配任务时加载。适合低风险、边界清楚的知识型流程。
3. **事件/自动化触发**：GitHub 事件、定时任务、文件变化、Hook。适合输入稳定、可以无头验收的流程。

风险越高，触发越应显式。生产部署、退款、删除、权限授予等工作流，即使封装为 Skill，也应禁止模型自行触发，并要求人类确认最终动作。

## 可复用范例：PR Readiness 检查

### 工作流契约

```yaml
名称: pr-readiness
输入:
  - 基准分支或 PR
  - 可选关注领域
前置条件:
  - 工作区可读
  - 确定性测试结果已生成
步骤:
  - 收集 diff、变更文件和测试结果
  - 按正确性、安全、兼容性、测试缺口分类
  - 每条发现必须附文件位置与证据
  - 不直接修改代码，不发布评论
输出:
  - Markdown 摘要
  - findings.json
验收:
  - findings.json 通过 schema 校验
  - 每个 P0/P1 都有证据和建议动作
失败:
  - 输入不足时返回 needs_input，不猜测
```

### 可移植 `SKILL.md` 骨架

```markdown
---
name: pr-readiness
description: 检查 PR 或当前分支是否可合并。用于发布前审查、PR review、风险扫描；默认只读，不修改代码或发布评论。
---

# PR Readiness

1. 阅读 `references/审查标准.md`。
2. 运行 `scripts/collect-diff.sh`，不得扩大扫描范围。
3. 读取 CI 已生成的测试结果；不要自行跳过失败测试。
4. 按正确性、安全、兼容性、测试缺口分类。
5. 每条发现附文件路径、证据、严重级别、建议动作。
6. 用 `assets/报告模板.md` 生成 Markdown，并输出符合
   `.agent-workflows/contracts/pr-readiness.schema.json` 的 JSON。
7. 没有证据时写“未发现”，不要写“确认安全”。
```

### 三个平台的薄适配

- **Codex**：显式调用 `$pr-readiness`；CI 用只读的 `codex exec --json`，只有修复型工作流才升到 `workspace-write`。在 `Stop` Hook 校验 JSON schema，但不在审查流程里自动发 PR 评论。
- **Claude Code**：调用 `/pr-readiness`；无头运行使用 `claude -p`、`--output-format json`、`--permission-mode plan` 和合理的 `--max-turns`。若需要隔离上下文，可在 Claude 专属 Skill frontmatter 加 `context: fork`，不要写回公共 Skill。
- **Pi**：调用 `/skill:pr-readiness`；用 `-p` 或 JSON mode 输出。审查阶段限制为 `read,grep,find,ls` 等只读工具；若需要跑测试，优先让 CI 先运行脚本并把结果作为输入。需要 schema gate 时写一个小 Extension，或让外层 CI 直接校验。

这个例子的关键不是审查提示词，而是四个边界：**默认只读、证据化输出、确定性 schema 校验、发布动作与分析动作分离**。

## 从最小可用到成熟工作流

### 阶段 0：先证明任务值得固化

- 连续手动执行 3～5 次。
- 记录稳定输入、重复步骤、常见失败和真正的验收标准。
- 不急着写 Hook、MCP 或多 Agent。

### 阶段 1：建立公共项目指令

- 创建精简 `AGENTS.md`，只放长期有效的事实和硬约束。
- Claude 添加只含 `@AGENTS.md` 与少量差异的 `CLAUDE.md`。
- 把操作流程从项目指令移出，避免每轮都占上下文。

### 阶段 2：固化一个高频 Skill

- 选一个只读、可验证、每周至少使用一次的任务。
- 写清 trigger、输入、步骤、输出、失败处理。
- 把长资料放入 `references/`，把可执行检查放入 `scripts/`。

### 阶段 3：加入 verifier 与回归集

- 为结构化输出加 JSON Schema。
- 保存 5～20 个真实样例，覆盖正常、空输入、脏工作区、超大 diff、测试失败。
- 记录成功率、人工修改量、误报、漏报、耗时和成本。

### 阶段 4：建立权限与信任边界

- 把读、写、网络、外部消息、生产动作分级。
- Codex/Claude 使用平台沙箱与 deny 规则；Pi 放进容器或策略沙箱。
- 第三方 Skill、Hook、Extension、MCP server 在安装或变更后重新审查。

### 阶段 5：再加 Hooks 和工具

- 只有“必须在固定事件发生”的规则才做 Hook。
- 只有需要稳定结构化访问外部系统时才引入 MCP/工具。
- Hook 保持快速、幂等、可观察；失败时明确 fail-open 还是 fail-closed。

### 阶段 6：无头化与 CI

- 先用只读检查运行一段时间，不直接改代码或发布。
- 固定模型/版本、轮次或预算、权限、输入来源、输出路径和超时。
- 通过 verifier 后再允许评论、建分支或提 PR；生产变更仍保留人工批准。

### 阶段 7：最后考虑多 Agent

- 只拆真正独立、可汇总的子任务。
- 给每个角色明确输入、只写区域和返回格式。
- 主 Agent 负责决策与整合，子 Agent 负责有限探索或验证。
- 并行读通常安全；并行写需要 worktree、文件所有权或串行合并。

## 验证清单

- [ ] 项目公共规则是否只有一个真源？
- [ ] Skill 是否明确写了“何时用”和“何时不用”？
- [ ] 输入、输出、退出状态是否机器可检查？
- [ ] 能用脚本确定的事情是否仍交给模型猜？
- [ ] 默认权限是否只覆盖完成任务所需的最小范围？
- [ ] 自动化失败时是停止、重试还是降级，是否明确？
- [ ] 外部消息、发布、删除、付费、生产变更是否保留 HITL？
- [ ] 第三方 MCP、Skill、Hook、Extension 是否固定版本并审查源码？
- [ ] 是否有真实回归样例，而不只靠一次“看起来不错”？
- [ ] 能否在不改核心工作流的情况下，把 Codex 换成 Claude Code 或 Pi？

## 核心判断

**最值得投资的不是某个平台的配置技巧，而是工作流自身的协议质量。** 项目事实决定 Agent 知道什么，Skill 决定它按什么步骤做，脚本和 schema 决定怎样证明做对了，权限决定最坏情况下能造成多大影响，平台适配器只负责把这些能力接入 Codex、Claude Code 或 Pi。

当工作流达到这个结构后，更换 Agent 通常只需要重写触发命令、Hooks、权限和工具配置，不需要重写业务方法本身。这与 [[从LLM到Agent Skill底层逻辑拆解]] 的核心方向一致：把模型的不确定推理包在可复用上下文、确定性工具和反馈闭环之中。

## 来源与研究范围

仅使用一手资料：OpenAI/Codex 官方文档，Anthropic Claude Code 官方文档，Pi 当前官方上游仓库与仓库内文档，以及 Agent Skills、MCP 官方规范。未采用社区教程、聚合文章或第三方功能对比。

访问日期：2026-07-29。

- [OpenAI Codex：AGENTS.md](https://developers.openai.com/codex/guides/agents-md)
- [OpenAI Codex：Build skills](https://developers.openai.com/codex/skills)
- [OpenAI Codex：Hooks](https://learn.chatgpt.com/docs/hooks)
- [OpenAI Codex：MCP](https://developers.openai.com/codex/mcp)
- [OpenAI Codex：Subagents](https://learn.chatgpt.com/docs/agent-configuration/subagents)
- [OpenAI Codex：Non-interactive mode](https://developers.openai.com/codex/noninteractive)
- [OpenAI Codex：GitHub Action](https://learn.chatgpt.com/docs/github-action)
- [Anthropic Claude Code：Memory / CLAUDE.md](https://code.claude.com/docs/en/memory)
- [Anthropic Claude Code：Skills](https://code.claude.com/docs/en/slash-commands)
- [Anthropic Claude Code：Hooks](https://code.claude.com/docs/en/hooks-guide)
- [Anthropic Claude Code：Subagents](https://code.claude.com/docs/en/sub-agents)
- [Anthropic Claude Code：MCP](https://code.claude.com/docs/en/mcp)
- [Anthropic Claude Code：CLI reference](https://code.claude.com/docs/en/cli-reference)
- [Anthropic Claude Code：Permissions](https://code.claude.com/docs/en/permissions)
- [Anthropic Claude Code：Sandboxing](https://code.claude.com/docs/en/sandboxing)
- [Anthropic Claude Code：GitHub Actions](https://code.claude.com/docs/en/github-actions)
- [Pi 当前官方上游仓库](https://github.com/earendil-works/pi)
- [Pi coding-agent README](https://github.com/earendil-works/pi/tree/main/packages/coding-agent)
- [Pi：Skills](https://github.com/earendil-works/pi/blob/main/packages/coding-agent/docs/skills.md)
- [Pi：Prompt Templates](https://github.com/earendil-works/pi/blob/main/packages/coding-agent/docs/prompt-templates.md)
- [Pi：Extensions](https://github.com/earendil-works/pi/blob/main/packages/coding-agent/docs/extensions.md)
- [Agent Skills specification](https://agentskills.io/specification)
- [Model Context Protocol specification](https://modelcontextprotocol.io/specification/2025-11-25)
- [MCP Tools 与人类确认原则](https://modelcontextprotocol.io/specification/2025-11-25/server/tools)

---
创建日期: 2026-04-22
类型: 文章
作者: OpenAI Developer Docs
来源: https://developers.openai.com/api/docs/guides/prompt-caching
分类: OpenAI API 文档
tags: #资源 #openai #prompt-caching #api #性能优化
备注: 英文原文由中文翻译整理；developers.openai.com 无官方中文版
---

# 提示缓存（Prompt Caching）指南

> 来源：https://developers.openai.com/api/docs/guides/prompt-caching
> 说明：该页为 OpenAI 开发者文档原文（英文），此处为译文整理版。

模型提示词中经常包含重复内容，例如系统提示和通用指令。OpenAI 会将 API 请求路由到最近处理过相同提示的服务器上，相比从头开始处理一个提示，这种方式既便宜又快速。**提示缓存（Prompt Caching）可将延迟降低最多 80%，输入 Token 成本降低最多 90%。** 提示缓存会在所有 API 请求上自动启用（无需改动任何代码），且不会产生额外费用。提示缓存已在所有较新的 [模型](https://developers.openai.com/api/docs/models)（gpt-4o 及以后）上启用。

本指南将详细说明提示缓存的工作原理，帮你针对更低延迟与更低成本对提示进行优化。

## 提示结构化（Structuring prompts）

只有当一个提示内部存在**完全一致的前缀匹配**时，才可能命中缓存。为了获得缓存收益，请把**静态内容**（如指令、示例）放在提示**开头**，把**可变内容**（如用户特定信息）放在提示**末尾**。这一规则同样适用于图像和工具，它们在各次请求之间也必须完全相同。

## 工作原理（How it works）

提示长度达到 **1024 Token 或以上** 时会自动启用缓存。每次 API 请求发生时，流程如下：

- **缓存路由（Cache Routing）**：
  - 请求会根据提示**初始前缀的哈希值**路由到某台机器。该哈希通常基于前 256 个 Token，具体长度因模型而异。
  - 如果你提供了 [`prompt_cache_key`](https://developers.openai.com/api/docs/api-reference/responses/create#responses-create-prompt_cache_key) 参数，它会与前缀哈希组合，从而影响路由并提升缓存命中率。当大量请求共享较长的公共前缀时，此参数尤为有用。
  - 如果同一 prefix 和 `prompt_cache_key` 组合的请求速率超过某一阈值（约**每分钟 15 次**），部分请求可能会"溢出"并被路由到额外机器，降低缓存有效性。
- **缓存查找（Cache Lookup）**：系统在选定的机器上检查提示的前缀是否已存在于缓存中。
- **缓存命中（Cache Hit）**：如找到匹配的前缀，系统直接使用缓存结果，可显著降低延迟并减少成本。
- **缓存未命中（Cache Miss）**：如未找到匹配的前缀，系统会处理完整提示，并随后将该前缀缓存到这台机器，以供将来请求使用。

## 缓存保留策略（Prompt cache retention）

提示缓存可以使用**内存保留（in-memory）** 或 **延长保留（extended retention）** 两种策略。在可用的情况下，延长提示缓存会让缓存保留更久，这样后续请求更有可能命中缓存。

两种保留策略的价格相同。

要配置提示缓存保留策略，在 `Responses.create` 请求（或使用 Chat Completions 时的 `chat.completions.create`）上设置 `prompt_cache_retention` 参数即可。

### 内存保留（In-memory prompt cache retention）

内存保留策略在**所有支持提示缓存的模型**上都可用。

使用内存策略时，缓存的前缀通常在**空闲 5 到 10 分钟**后仍保持活跃，最长**不超过 1 小时**。内存缓存的前缀仅保存在 GPU 的易失内存中。

### 延长保留（Extended prompt cache retention）

延长提示缓存保留可用于以下模型：

- gpt-5.4
- gpt-5.2
- gpt-5.1-codex-max
- gpt-5.1
- gpt-5.1-codex
- gpt-5.1-codex-mini
- gpt-5.1-chat-latest
- gpt-5
- gpt-5-codex
- gpt-4.1

延长提示缓存会让缓存的前缀保持更长时间，**最长可达 24 小时**。其实现方式是：当 GPU 内存写满时，将 key/value tensors 卸载（offload）到 GPU 本地存储上，从而显著扩大可用于缓存的存储容量。

key/value tensors 是模型注意力层在 prefill 阶段生成的中间表示。**只有 key/value tensors 可能被持久化到本地存储**；原始的客户内容（例如提示文本）仍仅保留在内存中。

### 按请求配置

如果你没有显式指定保留策略，默认值为 `in_memory`。允许的取值为 `in_memory` 和 `24h`。

```json
{
  "model": "gpt-5.1",
  "input": "Your prompt goes here...",
  "prompt_cache_retention": "24h"
}
```

## 要求（Requirements）

缓存适用于**包含 1024 Token 或以上**的提示。

所有请求（包括少于 1024 Token 的请求）都会在响应中返回一个 `cached_tokens` 字段，位于 [Response 对象](https://developers.openai.com/api/docs/api-reference/responses/object) 或 [Chat 对象](https://developers.openai.com/api/docs/api-reference/chat/object) 的 `usage.prompt_tokens_details` 内，表示其中有多少提示 Token 命中了缓存。对于不足 1024 Token 的请求，`cached_tokens` 值将为 0。

```json
"usage": {
  "prompt_tokens": 2006,
  "completion_tokens": 300,
  "total_tokens": 2306,
  "prompt_tokens_details": {
    "cached_tokens": 1920
  },
  "completion_tokens_details": {
    "reasoning_tokens": 0,
    "accepted_prediction_tokens": 0,
    "rejected_prediction_tokens": 0
  }
}
```

### 哪些内容可以被缓存

- **消息（Messages）**：完整的 messages 数组，包括 system、user 和 assistant 的交互。
- **图像（Images）**：用户消息中携带的图像（链接或 base64 编码形式），也可以发送多张图像。请确保 `detail` 参数在各次请求之间保持一致，因为它会影响图像的 Token 化结果。
- **工具调用（Tool use）**：messages 数组与可用的 `tools` 列表都可以被缓存，并共同计入 1024 Token 的最低要求。
- **结构化输出（Structured outputs）**：结构化输出 schema 会作为系统消息的前缀，同样可以被缓存。

## 最佳实践（Best practices）

- **把静态或重复内容放在开头**，把动态、用户特定的内容放在末尾。
- 在共享公共前缀的请求之间**一致地使用 [`prompt_cache_key`](https://developers.openai.com/api/docs/api-reference/responses/create#responses-create-prompt_cache_key) 参数**。选择合适的粒度，让每个唯一的 prefix + `prompt_cache_key` 组合保持在 **每分钟 15 次请求以内**，以避免缓存溢出。
- **监控缓存性能指标**，包括命中率、延迟以及缓存 Token 占比，以便持续优化策略。你可以通过记录上面展示的 `usage` 字段结果，或通过 OpenAI Usage 仪表盘来监控缓存 Token 数量。
- **维持稳定的、带有相同前缀的请求流**，以减少缓存驱逐（eviction），最大化缓存收益。

## 常见问题（FAQ）

**Q：缓存如何保证数据隐私？**
提示缓存**不会在不同组织之间共享**。只有同一组织内的成员才能访问相同提示的缓存。

**Q：提示缓存会影响输出 Token 的生成或 API 的最终响应吗？**
不会。提示缓存不会影响输出 Token 的生成或 API 最终返回的内容。无论是否使用缓存，生成的输出都会完全相同。因为只有 prompt 本身会被缓存，而实际的响应每次都会基于被缓存的 prompt 重新计算。

**Q：有办法手动清除缓存吗？**
目前不支持手动清除缓存。未被近期访问的提示会被自动从缓存中清除。典型的缓存驱逐在**空闲 5–10 分钟后**发生，在非高峰时段最长可保留约 1 小时。

**Q：写入缓存会额外收费吗？**
不会。缓存会自动发生，无需显式操作，也不会为使用缓存功能支付额外费用。

**Q：已缓存的提示 Token 是否计入 TPM 速率限制？**
计入。缓存不影响速率限制。

**Q：提示缓存在 Zero Data Retention（ZDR，零数据保留）项目上可用吗？**
- 内存保留不会将任何数据写入磁盘。
- 延长提示缓存可能将 key/value tensors 存储到 GPU 本地存储，这些张量是由客户内容派生得出。该数据不会在缓存过期后继续保留 — 大多数使用场景下 key/value tensors 只保留 1–2 小时，最多 24 小时。
- 即便你的项目启用了 ZDR，延长提示缓存的请求也**不会被阻拦**。其它 ZDR 规则仍然适用，例如将客户内容排除在滥用日志之外，以及禁止使用 `store=True`。
- 关于 ZDR 的更多背景请参见 [Your data](https://developers.openai.com/api/docs/guides/your-data) 指南。

**Q：提示缓存与数据驻留（Data Residency）兼容吗？**
内存型提示缓存与所有数据驻留区域兼容。

延长提示缓存会临时将数据存储在 GPU 机器上；只有在使用 **Regional Inference（区域推理）** 的情况下，数据才会保持在区域内。

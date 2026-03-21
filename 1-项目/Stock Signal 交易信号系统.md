---
创建日期: 2026-03-21
状态: 进行中
截止日期: 
tags: #项目 #投资 #自动化
---

# Stock Signal — 基于 RSS 新闻的交易信号系统

## 项目概述
- **目标**：自动采集持仓股票相关新闻，通过 LLM 分析生成每日交易信号
- **背景**：手动跟踪 7 只持仓股票的新闻太耗时，需要自动化工具辅助投资决策
- **关键指标**：每日生成信号报告，覆盖所有持仓，信号准确率随时间迭代提升

## 持仓覆盖
| 股票 | 类型 | 持仓数量 |
|------|------|----------|
| AAPL | 科技/消费电子 | 20 |
| BABA | 中概/电商 | 11 |
| PDD | 中概/电商 | 30 |
| VOO | S&P 500 ETF | 10 |
| META | 科技/社交 | 5 |
| TSLA | 新能源/AI | 10 |
| NVDA | 半导体/AI | 43 |

## 技术架构
- **数据源**：Google News RSS（按 ticker 和公司名搜索）
- **分析引擎**：LLM（GPT-4o-mini via gptsapi.net）
- **输出**：JSON 信号 + Markdown 报告
- **参考项目**：[[autoresearch-media]]（同一架构思路）

## 项目计划
- [x] #任务 搭建项目框架和仓库 📅 2026-03-21
- [x] #任务 确认 RSS 数据源可用性 📅 2026-03-21
- [x] #任务 实现 fetch_rss.py 新闻采集 📅 2026-03-21
- [x] #任务 实现 analyze.py 信号生成 📅 2026-03-21
- [ ] #任务 首次完整运行并发送报告
- [ ] #任务 根据反馈优化信号质量
- [ ] #任务 接入定时任务（cron/heartbeat）

## 项目资源
- GitHub 仓库：https://github.com/hongling2511/stock-signal
- 代码位置：`/Users/hongling/clawd/stock-signal/`
- 聚合 API：`https://api.gptsapi.net`（GPT-4o-mini）

## 项目笔记
- 2026-03-21：项目启动，Google News RSS 验证通过，Yahoo Finance RSS 已失效
- CNBC RSS 被 403 拒绝，主要依赖 Google News RSS
- VOO 作为 ETF 用宏观经济新闻覆盖

## 项目回顾
> 此部分项目完成后填写

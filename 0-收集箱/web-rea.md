> [!quote] YOU

/var/folders/cq/8lrhj3ys4cq9cdm_k19syw_00000gn/T/pi-clipboard-2bbb52f4-0118-4920-abf3-661c6e3dbf9c.png
我们来学习web逆向相关的知识，上面图片有相关主题


> [!quote] YOU

我想系统性的学习web和协议逆向相关知识


> [!question] Question
> 你学习 web 和协议逆向的主要目标是什么？
>
> 1. 爬虫/数据采集 — 绕过反爬、分析加密请求参数、逆向 JS 签名算法 (Recommended)
> 2. 安全研究/漏洞挖掘 — 分析 App/Web 的通信协议找安全问题
> 3. CTF/竞赛 — 逆向题型、协议分析类赛题
> 4. 更底层的网络协议逆向 — 私有二进制协议、嵌入式设备通信分析
> 5. 还没想清楚，想要一个全面覆盖的学习地图


> [!example] Answer
> 1. 爬虫/数据采集 — 绕过反爬、分析加密请求参数、逆向 JS 签名算法 (Recommended)


> [!question] Question
> 你当前的技术背景大概是什么水平？这会决定我们从哪里开始。
>
> 1. 已经会写爬虫（requests/Scrapy等），但没做过 JS 逆向，不熟悉浏览器 DevTools 调试技巧 (Recommended)
> 2. 会基础 JS 和浏览器调试，但没系统学过混淆/加密算法分析或 AST 工具
> 3. 已经有一定 JS 逆向经验，想补全知识体系并深入对抗/App 端（抓包、脱壳）
> 4. 几乎零基础，连 HTTP/前端基本概念都还不熟悉


> [!example] Answer
> 1. 已经会写爬虫（requests/Scrapy等），但没做过 JS 逆向，不熟悉浏览器 DevTools 调试技巧 (Recommended)


> [!question] Question
> 你希望我以什么形式帮你搭建这套系统性学习内容？
>
> 1. 一份完整的学习路线图/大纲文档，我自己按节奏学，你先研究整理成一篇系统文章 (Recommended)
> 2. 逐步交互式教学 — 你现在就开始用闹钟法等教学技巧带我学第一个模块，边讲边实战
> 3. 先输出一份学习路线大纲，我确认后再决定每个模块怎么学


> [!example] Answer
> 1. 一份完整的学习路线图/大纲文档，我自己按节奏学，你先研究整理成一篇系统文章 (Recommended)


> [!abstract] PI

已经派出一个研究子代理去收集资料了，覆盖这几个模块：

1. **前置基础**：HTTP/HTTPS 细节、DevTools 网络面板、JS 执行环境基础
2. **抓包与调试**：Chrome DevTools 断点技巧、mitmproxy/Charles、HTTPS 中间人原理
3. **JS 逆向核心**：常见混淆手法、AST 反混淆工具、扣代码/补环境
4. **加密签名识别**：常见算法在前端请求中的典型用法、如何在混淆代码里定位加密函数
5. **反爬对抗现状**：商业反爬方案原理、TLS 指纹、无头浏览器检测与反检测
6. **App/协议逆向延伸**：抓包、SSL Pinning 绕过思路、Frida 入门（只给概览）
7. **法律边界**：国内外典型案例和风险提示

它会把结果整理成一份带来源链接、关键概念和工具推荐的研究笔记，保存到 `research/web-protocol-reverse-engineering-notes.md`。等它跑完我会拿到笔记自动继续,把这些整理成一篇系统的学习路线文章（Canonical Article 模式）。你可以先去忙别的,我这边收到结果会继续处理。


> [!abstract] PI

Convention: project folder with `README.md` as the final article + `sources/` for raw materials. I'll follow it.


> [!abstract] PI

已经整理完成一份系统学习路线文档：

📄 **`/Users/hongling/learn/web-reverse-engineering/README.md`**（主文章）
📄 `/Users/hongling/learn/web-reverse-engineering/sources/research-notes.md`（原始调研笔记，含所有来源链接）

## 结构概览

7 个层级，按依赖关系排列，每层都有「核心概念 + 延伸阅读 + 工具 + 常见错误」：

- **第0层** 合规与实验环境 — 先划边界、建自己的测试环境
- **第1层** HTTP/浏览器/JS 运行时基础 — 共同语言（含闭包/原型链/事件循环这三个读混淆代码的关键抓手）
- **第2层** DevTools 调试 + 抓包 — 核心技能是「从 Network 反向走进 Sources」定位代码位置
- **第3层** Bundle/混淆/AST — 区分压缩/打包/混淆三个概念，AST 优先于正则，以及"补环境"最容易踩的坑
- **第4层** 签名与加密算法定位 — 纠正"编码≠加密"的常见误区，强调用测试向量验证而非猜
- **第5层** 反爬检测面认知 — 多层信号模型、JA3/JA4、headless 检测的正确理解
- **第6层（延伸）** App/协议逆向入门概览 — Frida、证书固定，只给地图不深入
- **第7层** 法律与伦理边界 — 这节认真写了，不是免责声明，包含 Van Buren、hiQ v. LinkedIn 判例和国内网络安全法条款

结尾附带推荐学习顺序图和一份可复用的练习记录模板。

来源以 IETF/W3C/MDN/Chrome/OWASP/Frida 等一手官方文档为主，商业反爬产品细节和"通过率"类博客被明确标注为不可靠/未采纳。

你可以先通读一遍，哪部分想深入练习（比如想先上手 DevTools 断点，还是先补 JS 运行时基础)，告诉我,我可以用 teach 技能带你逐步实操第一个模块。

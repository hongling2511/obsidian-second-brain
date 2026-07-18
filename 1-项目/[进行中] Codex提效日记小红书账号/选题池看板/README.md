# 小红书账号选题池看板

一个独立静态 Web 工具，用来把「一句话产品想法 + 目标用户 + 使用场景」生成 5 张小红书选题卡片。

## 功能范围

- 调用 OpenAI Responses API 生成 5 张选题卡片
- 每张卡片包含：小红书标题、目标用户、可做成的原型、内容栏目、可复制资产、状态
- 状态支持切换：想法 / 制作中 / 已发布
- 卡片、API Key、Base URL 和模型保存到浏览器 localStorage
- 不包含登录、数据库、支付和后端代理

## 本地运行

```bash
cd "1-项目/[进行中] Codex提效日记小红书账号/选题池看板"
python3 -m http.server 5173
```

然后打开：

```text
http://localhost:5173
```

## 安全说明

当前版本为了快速演示，API Key 由浏览器直接调用 OpenAI API 或兼容 OpenAI 协议的 Base URL。只填写域名根路径时会默认补 `/v1`，例如 `https://api.gptsapi.net` 会规范化为 `https://api.gptsapi.net/v1`。Key 和 Base URL 只保存在本机浏览器 localStorage。公开部署时应改为后端代理，避免把 API Key 暴露给访问者。

const STORAGE_KEY = "codex-topic-board-cards";
const API_KEY_STORAGE_KEY = "codex-topic-board-openai-key";
const BASE_URL_STORAGE_KEY = "codex-topic-board-openai-base-url";
const MODEL_STORAGE_KEY = "codex-topic-board-model";
const STATUSES = ["想法", "制作中", "已发布"];

const form = document.querySelector("#generator-form");
const productIdeaInput = document.querySelector("#product-idea");
const targetUserInput = document.querySelector("#target-user");
const useCaseInput = document.querySelector("#use-case");
const apiKeyInput = document.querySelector("#api-key");
const baseUrlInput = document.querySelector("#base-url");
const modelInput = document.querySelector("#model");
const generateButton = document.querySelector("#generate-button");
const clearButton = document.querySelector("#clear-button");
const errorMessage = document.querySelector("#error-message");
const cardsContainer = document.querySelector("#cards");
const emptyState = document.querySelector("#empty-state");
const cardCount = document.querySelector("#card-count");
const cardTemplate = document.querySelector("#card-template");

let cards = loadCards();

apiKeyInput.value = localStorage.getItem(API_KEY_STORAGE_KEY) || "";
baseUrlInput.value =
  localStorage.getItem(BASE_URL_STORAGE_KEY) || baseUrlInput.value;
modelInput.value = localStorage.getItem(MODEL_STORAGE_KEY) || modelInput.value;

render();

form.addEventListener("submit", async (event) => {
  event.preventDefault();
  hideError();

  const payload = {
    productIdea: productIdeaInput.value.trim(),
    targetUser: targetUserInput.value.trim(),
    useCase: useCaseInput.value.trim(),
    apiKey: apiKeyInput.value.trim(),
    baseUrl: normalizeBaseUrl(baseUrlInput.value.trim()),
    model: modelInput.value.trim() || "gpt-5",
  };

  if (!payload.apiKey) {
    showError("请先在 OpenAI 设置里填写 API Key。");
    return;
  }

  localStorage.setItem(API_KEY_STORAGE_KEY, payload.apiKey);
  localStorage.setItem(BASE_URL_STORAGE_KEY, payload.baseUrl);
  localStorage.setItem(MODEL_STORAGE_KEY, payload.model);

  setLoading(true);
  try {
    const generatedCards = await generateCards(payload);
    cards = [...normalizeCards(generatedCards), ...cards];
    saveCards();
    render();
  } catch (error) {
    const message =
      error.name === "AbortError"
        ? "生成超时，请稍后重试，或换一个响应更快的模型。"
        : error.message || "生成失败，请检查 API Key、模型名称或网络连接。";
    showError(message);
  } finally {
    setLoading(false);
  }
});

clearButton.addEventListener("click", () => {
  if (!cards.length) {
    return;
  }

  const shouldClear = window.confirm("确定清空当前看板的所有选题卡片吗？");
  if (!shouldClear) {
    return;
  }

  cards = [];
  saveCards();
  render();
});

function loadCards() {
  try {
    const raw = localStorage.getItem(STORAGE_KEY);
    return raw ? JSON.parse(raw) : [];
  } catch {
    return [];
  }
}

function saveCards() {
  localStorage.setItem(STORAGE_KEY, JSON.stringify(cards));
}

function render() {
  cardsContainer.innerHTML = "";
  emptyState.hidden = cards.length > 0;
  cardCount.textContent = `${cards.length} 张卡片`;

  cards.forEach((card) => {
    const node = cardTemplate.content.cloneNode(true);
    const article = node.querySelector(".topic-card");
    article.dataset.id = card.id;
    node.querySelector(".column").textContent = card.column;
    node.querySelector("h3").textContent = card.title;
    node.querySelector(".target").textContent = card.targetUser;
    node.querySelector(".prototype").textContent = card.prototype;
    node.querySelector(".asset").textContent = card.asset;

    node.querySelector(".delete-card").addEventListener("click", () => {
      cards = cards.filter((item) => item.id !== card.id);
      saveCards();
      render();
    });

    node.querySelectorAll("[data-status]").forEach((button) => {
      const status = button.dataset.status;
      button.classList.toggle("active", status === card.status);
      button.addEventListener("click", () => {
        cards = cards.map((item) =>
          item.id === card.id ? { ...item, status } : item,
        );
        saveCards();
        render();
      });
    });

    cardsContainer.appendChild(node);
  });
}

async function generateCards({
  productIdea,
  targetUser,
  useCase,
  apiKey,
  baseUrl,
  model,
}) {
  const requestBody = {
    model,
    store: false,
    input: [
      {
        role: "system",
        content:
          "你是一个小红书产品内容策划助手。你只输出严格 JSON，不输出 Markdown，不解释。",
      },
      {
        role: "user",
        content: buildPrompt({ productIdea, targetUser, useCase }),
      },
    ],
    text: {
      format: {
        type: "json_schema",
        name: "xiaohongshu_topic_cards",
        strict: true,
        schema: {
          type: "object",
          additionalProperties: false,
          required: ["cards"],
          properties: {
            cards: {
              type: "array",
              minItems: 5,
              maxItems: 5,
              items: {
                type: "object",
                additionalProperties: false,
                required: [
                  "title",
                  "targetUser",
                  "prototype",
                  "column",
                  "asset",
                ],
                properties: {
                  title: { type: "string" },
                  targetUser: { type: "string" },
                  prototype: { type: "string" },
                  column: {
                    type: "string",
                    enum: [
                      "案例实战",
                      "搭建过程",
                      "失败复盘",
                      "模板分享",
                      "上线迭代",
                    ],
                  },
                  asset: { type: "string" },
                },
              },
            },
          },
        },
      },
    },
  };

  const { response, data } = await postResponsesRequest({
    apiKey,
    baseUrl,
    body: requestBody,
  });

  if (!response.ok) {
    const detail = data?.error?.message ? `：${data.error.message}` : "";
    throw new Error(`OpenAI API 请求失败${detail}`);
  }

  const outputText = data.output_text || extractOutputText(data);
  if (!outputText) {
    throw new Error("API 已返回，但没有找到可解析的 JSON 文本。");
  }

  const parsed = parseJson(outputText);
  if (!Array.isArray(parsed.cards) || parsed.cards.length !== 5) {
    throw new Error("AI 返回格式不符合预期：需要正好 5 张选题卡片。");
  }

  return parsed.cards;
}

async function postResponsesRequest({ apiKey, baseUrl, body }) {
  const urls = buildResponsesUrls(baseUrl);
  let lastResult;

  for (const url of urls) {
    const controller = new AbortController();
    const timeoutId = window.setTimeout(() => controller.abort(), 90000);
    const response = await fetch(url, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${apiKey}`,
      },
      body: JSON.stringify(body),
      signal: controller.signal,
    }).finally(() => window.clearTimeout(timeoutId));

    const data = await response.json().catch(() => null);
    lastResult = { response, data };

    if (response.ok || response.status !== 404) {
      return lastResult;
    }
  }

  return lastResult;
}

function normalizeBaseUrl(value) {
  const baseUrl = value || "https://api.openai.com/v1";
  const normalized = baseUrl.replace(/\/+$/, "");

  try {
    const url = new URL(normalized);
    if (url.pathname === "" || url.pathname === "/") {
      url.pathname = "/v1";
      return url.toString().replace(/\/+$/, "");
    }
  } catch {
    return normalized;
  }

  return normalized;
}

function buildResponsesUrls(baseUrl) {
  const urls = [`${baseUrl}/responses`];

  if (!/\/v1$/i.test(baseUrl)) {
    urls.push(`${baseUrl}/v1/responses`);
  }

  return urls;
}

function buildPrompt({ productIdea, targetUser, useCase }) {
  return [
    "请根据下面输入，生成 5 张小红书选题卡片。",
    "",
    `产品想法：${productIdea}`,
    `目标用户：${targetUser}`,
    `使用场景：${useCase}`,
    "",
    "硬约束：",
    "1. 标题必须像小红书标题，不能像技术文档标题。",
    "2. 每张卡片都必须有一个可做成的 Web/SaaS 原型。",
    "3. 可复制资产必须具体，比如“需求描述模板”“验收清单”“报价页结构”，不能写“方法论”。",
    "4. 内容栏目只能从固定选项中选：案例实战 / 搭建过程 / 失败复盘 / 模板分享 / 上线迭代。",
    "5. 输出必须是严格 JSON，方便前端渲染。",
    "",
    "字段要求：",
    "- title：小红书标题，短、有结果感、有点击欲。",
    "- targetUser：这条内容最适合谁看。",
    "- prototype：这条内容能继续做成什么 Web/SaaS 原型。",
    "- column：从固定栏目中选择一个。",
    "- asset：读者能复制走的具体资产。",
  ].join("\n");
}

function normalizeCards(generatedCards) {
  return generatedCards.map((card) => ({
    id: crypto.randomUUID(),
    title: card.title.trim(),
    targetUser: card.targetUser.trim(),
    prototype: card.prototype.trim(),
    column: card.column.trim(),
    asset: card.asset.trim(),
    status: "想法",
  }));
}

function extractOutputText(data) {
  const output = data?.output;
  if (!Array.isArray(output)) {
    return "";
  }

  return output
    .flatMap((item) => item.content || [])
    .map((content) => content.text || "")
    .join("")
    .trim();
}

function parseJson(text) {
  try {
    return JSON.parse(text);
  } catch {
    const match = text.match(/\{[\s\S]*\}/);
    if (!match) {
      throw new Error("AI 返回内容不是合法 JSON。");
    }
    return JSON.parse(match[0]);
  }
}

function setLoading(isLoading) {
  generateButton.disabled = isLoading;
  generateButton.textContent = isLoading ? "生成中..." : "生成选题";
}

function showError(message) {
  errorMessage.textContent = message;
  errorMessage.hidden = false;
}

function hideError() {
  errorMessage.textContent = "";
  errorMessage.hidden = true;
}

#!/usr/bin/env bash
# blog-publish.sh — 从第二大脑发布博客文章到 Next.js 博客
# 用法：
#   ./blog-publish.sh                # 扫描就绪文章，显示预览
#   ./blog-publish.sh --dry-run      # 同上
#   ./blog-publish.sh --publish      # 转换并复制到博客目录
#   ./blog-publish.sh --deploy       # 转换、复制并触发部署
#   ./blog-publish.sh --list         # 列出所有博客文章及状态
#   ./blog-publish.sh --file <路径>  # 发布指定文件

set -euo pipefail

VAULT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
BLOG_SRC="$VAULT_DIR/3-资源/博客文章"
HOMEPAGE_DIR="$HOME/homepage"
BLOG_CONTENT="$HOMEPAGE_DIR/src/content/blog"

# ── 颜色 ──────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# ── 参数解析 ──────────────────────────────────────────────
MODE="dry-run"
TARGET_FILE=""
while [[ $# -gt 0 ]]; do
    case "$1" in
        --publish)  MODE="publish"; shift ;;
        --deploy)   MODE="deploy"; shift ;;
        --dry-run)  MODE="dry-run"; shift ;;
        --list)     MODE="list"; shift ;;
        --file)     TARGET_FILE="$2"; shift 2 ;;
        -h|--help)
            echo "用法：$0 [选项]"
            echo ""
            echo "选项："
            echo "  --dry-run       （默认）扫描就绪文章，预览转换结果"
            echo "  --publish       转换并复制到博客目录（不部署）"
            echo "  --deploy        转换、复制并触发部署到服务器"
            echo "  --list          列出所有博客文章及其状态"
            echo "  --file <路径>   指定要发布的文件（忽略状态检查）"
            echo ""
            echo "工作流："
            echo "  1. 在 Obsidian 中用博客文章模板创建新笔记"
            echo "  2. 撰写内容，设置 frontmatter（slug、分类、标签等）"
            echo "  3. 将「博客状态」改为「就绪」"
            echo "  4. 运行 $0 --publish 发布"
            echo "  5. 运行 $0 --deploy 部署到服务器"
            exit 0
            ;;
        *) echo -e "${RED}未知参数：$1${NC}"; exit 1 ;;
    esac
done

# ── 辅助函数 ──────────────────────────────────────────────

# 从 frontmatter 提取字段值
get_frontmatter_field() {
    local file="$1"
    local field="$2"
    local frontmatter
    frontmatter="$(sed -n '/^---$/,/^---$/p' "$file")"

    # 检查是否为 YAML 多行列表格式（字段后无值，下一行以 "  - " 开头）
    local line_value
    line_value="$(echo "$frontmatter" | grep -E "^${field}:" | sed "s/^${field}:[[:space:]]*//" | sed 's/^"\(.*\)"$/\1/' | head -1)"

    if [[ -z "$line_value" ]]; then
        # 尝试读取 YAML 列表格式：提取 "  - item" 行并转为 JSON 数组
        local items=()
        local in_field=false
        while IFS= read -r line; do
            if [[ "$line" =~ ^${field}: ]]; then
                in_field=true
                continue
            fi
            if $in_field; then
                if [[ "$line" =~ ^[[:space:]]+- ]]; then
                    local item
                    item="$(echo "$line" | sed 's/^[[:space:]]*-[[:space:]]*//' | sed 's/^"\(.*\)"$/\1/')"
                    items+=("\"$item\"")
                else
                    break
                fi
            fi
        done <<< "$frontmatter"
        if [[ ${#items[@]} -gt 0 ]]; then
            local IFS=','
            echo "[${items[*]}]"
            return
        fi
    fi

    echo "$line_value"
}

# 从中文标题生成 slug（使用拼音风格或直接用英文）
generate_slug() {
    local title="$1"
    local slug="$2"

    # 如果已有 slug 则使用
    if [[ -n "$slug" ]]; then
        echo "$slug"
        return
    fi

    # 从文件名生成：去掉扩展名，转小写，空格/特殊字符变连字符
    local filename
    filename="$(basename "$title" .md)"
    echo "$filename" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9\u4e00-\u9fff]/-/g' | sed 's/-\+/-/g' | sed 's/^-\|-$//g'
}

# 转换 Obsidian Markdown 为 MDX 兼容格式
convert_to_mdx() {
    local file="$1"
    local content

    # 读取 frontmatter 之后的正文
    content="$(awk 'BEGIN{c=0} /^---$/{c++; if(c==2){found=1; next}} found{print}' "$file")"

    # 移除 Obsidian 特有语法
    # 1. 移除 [[链接]] → 保留显示文本
    content="$(echo "$content" | sed 's/\[\[\([^]|]*\)|\([^]]*\)\]\]/\2/g')"   # [[target|display]] → display
    content="$(echo "$content" | sed 's/\[\[\([^]]*\)\]\]/\1/g')"               # [[target]] → target

    # 2. 移除 Obsidian callout → 转为引用块
    content="$(echo "$content" | sed 's/^> \[!.*\].*//' )"

    # 3. 移除 Obsidian 嵌入 ![[...]]
    content="$(echo "$content" | sed 's/!\[\[\([^]]*\)\]\]/<!-- 嵌入: \1 -->/g')"

    # 4. 移除 「待办」和「链接」等模板占位段落
    content="$(echo "$content" | sed '/^## 待办$/,/^## /{ /^## 待办$/d; /^## /!d; }' )"
    content="$(echo "$content" | sed '/^## 链接$/,/^## /{ /^## 链接$/d; /^## /!d; }' )"

    echo "$content"
}

# 生成 MDX frontmatter
generate_mdx_frontmatter() {
    local file="$1"
    local title date excerpt category tags

    title="$(get_frontmatter_field "$file" "标题")"
    date="$(get_frontmatter_field "$file" "创建日期")"
    excerpt="$(get_frontmatter_field "$file" "摘要")"
    category="$(get_frontmatter_field "$file" "分类")"
    tags="$(get_frontmatter_field "$file" "标签")"

    # 标题回退：使用文件名
    if [[ -z "$title" ]]; then
        title="$(basename "$file" .md)"
    fi

    cat <<EOF
---
title: "${title}"
date: "${date}"
excerpt: "${excerpt}"
category: "${category}"
tags: ${tags}
---
EOF
}

# ── 列表模式 ──────────────────────────────────────────────

list_articles() {
    echo "# 博客文章列表"
    echo ""
    printf "%-40s %-8s %-12s %-10s\n" "标题" "状态" "分类" "创建日期"
    printf "%-40s %-8s %-12s %-10s\n" "----" "----" "----" "--------"

    local count=0
    while IFS= read -r -d '' file; do
        local title status category date
        title="$(get_frontmatter_field "$file" "标题")"
        [[ -z "$title" ]] && title="$(basename "$file" .md)"
        status="$(get_frontmatter_field "$file" "博客状态")"
        category="$(get_frontmatter_field "$file" "分类")"
        date="$(get_frontmatter_field "$file" "创建日期")"

        # 状态颜色
        local status_colored
        case "$status" in
            就绪)   status_colored="${GREEN}${status}${NC}" ;;
            已发布) status_colored="${BLUE}${status}${NC}" ;;
            草稿)   status_colored="${YELLOW}${status}${NC}" ;;
            *)      status_colored="${status}" ;;
        esac

        printf "%-40s " "$title"
        echo -e "${status_colored}\t${category}\t${date}"
        (( count++ )) || true
    done < <(find "$BLOG_SRC" -name '*.md' -print0 2>/dev/null | sort -z)

    echo ""
    echo "共 ${count} 篇文章"
}

# ── 发布处理 ──────────────────────────────────────────────

process_file() {
    local file="$1"
    local fname
    fname="$(basename "$file")"

    local title slug status category
    title="$(get_frontmatter_field "$file" "标题")"
    slug="$(get_frontmatter_field "$file" "slug")"
    status="$(get_frontmatter_field "$file" "博客状态")"
    category="$(get_frontmatter_field "$file" "分类")"

    [[ -z "$title" ]] && title="$(basename "$file" .md)"

    # slug 处理
    if [[ -z "$slug" ]]; then
        echo -e "${RED}错误：${fname} 缺少 slug 字段，请在 frontmatter 中设置${NC}"
        return 1
    fi

    # 验证必填字段
    local missing=()
    [[ -z "$(get_frontmatter_field "$file" "摘要")" ]] && missing+=("摘要")
    [[ -z "$category" ]] && missing+=("分类")
    [[ -z "$(get_frontmatter_field "$file" "标签")" ]] && missing+=("标签")

    if [[ ${#missing[@]} -gt 0 ]]; then
        echo -e "${RED}错误：${fname} 缺少必填字段：${missing[*]}${NC}"
        return 1
    fi

    local target_dir="$BLOG_CONTENT/$slug"
    local target_file="$target_dir/index.zh.mdx"

    echo -e "${GREEN}文章：${NC}${title}"
    echo -e "  slug：${slug}"
    echo -e "  分类：${category}"
    echo -e "  目标：${target_file}"

    if [[ "$MODE" == "dry-run" ]]; then
        echo -e "  ${YELLOW}[预览] 以下为转换后的 frontmatter：${NC}"
        generate_mdx_frontmatter "$file" | sed 's/^/    /'
        echo ""
        return 0
    fi

    # 创建目标目录
    mkdir -p "$target_dir"

    # 生成 MDX 文件
    {
        generate_mdx_frontmatter "$file"
        echo ""
        convert_to_mdx "$file"
    } > "$target_file"

    echo -e "  ${GREEN}✅ 已发布到 ${target_file}${NC}"

    # 更新 Obsidian 中的状态为「已发布」
    if [[ "$MODE" == "publish" || "$MODE" == "deploy" ]]; then
        sed -i '' "s/^博客状态:.*/博客状态: 已发布/" "$file"
        echo -e "  ${GREEN}✅ 状态已更新为「已发布」${NC}"
    fi

    echo ""
}

# ── 主流程 ────────────────────────────────────────────────

echo "# 博客发布工具"
echo "时间：$(date '+%Y-%m-%d %H:%M')"
MODE_LABEL=""
case "$MODE" in
    dry-run)  MODE_LABEL="预览（dry-run）" ;;
    publish)  MODE_LABEL="发布（仅复制）" ;;
    deploy)   MODE_LABEL="发布并部署" ;;
    list)     MODE_LABEL="列表" ;;
esac
echo "模式：${MODE_LABEL}"
echo ""

# 检查目录
if [[ ! -d "$BLOG_SRC" ]]; then
    echo -e "${RED}错误：博客文章目录不存在：${BLOG_SRC}${NC}"
    echo "请先创建目录或使用博客文章模板创建文章"
    exit 1
fi

if [[ ! -d "$HOMEPAGE_DIR" ]]; then
    echo -e "${RED}错误：博客项目目录不存在：${HOMEPAGE_DIR}${NC}"
    exit 1
fi

# 列表模式
if [[ "$MODE" == "list" ]]; then
    list_articles
    exit 0
fi

# 收集待处理文件
files=()
if [[ -n "$TARGET_FILE" ]]; then
    if [[ ! -f "$TARGET_FILE" ]]; then
        echo -e "${RED}错误：文件不存在：${TARGET_FILE}${NC}"
        exit 1
    fi
    files+=("$TARGET_FILE")
else
    # 扫描「就绪」状态的文章
    while IFS= read -r -d '' file; do
        local_status="$(get_frontmatter_field "$file" "博客状态")"
        if [[ "$local_status" == "就绪" ]]; then
            files+=("$file")
        fi
    done < <(find "$BLOG_SRC" -name '*.md' -print0 2>/dev/null)
fi

if [[ ${#files[@]} -eq 0 ]]; then
    echo -e "${YELLOW}没有找到状态为「就绪」的文章${NC}"
    echo ""
    echo "提示："
    echo "  1. 在 3-资源/博客文章/ 中创建博客文章"
    echo "  2. 将 frontmatter 中的「博客状态」改为「就绪」"
    echo "  3. 重新运行此脚本"
    echo ""
    echo "使用 --list 查看所有文章状态"
    echo "使用 --file <路径> 发布指定文件（跳过状态检查）"
    exit 0
fi

echo "找到 ${#files[@]} 篇待发布文章"
echo ""

# 处理每篇文章
PUBLISHED=0
FAILED=0
for file in "${files[@]}"; do
    if process_file "$file"; then
        (( PUBLISHED++ )) || true
    else
        (( FAILED++ )) || true
    fi
done

# 部署
if [[ "$MODE" == "deploy" && $PUBLISHED -gt 0 ]]; then
    echo "---"
    echo -e "${GREEN}开始部署...${NC}"
    echo ""

    if [[ -f "$HOMEPAGE_DIR/deploy-simple.sh" ]]; then
        cd "$HOMEPAGE_DIR"
        bash deploy-simple.sh
    elif [[ -f "$HOMEPAGE_DIR/deploy.sh" ]]; then
        cd "$HOMEPAGE_DIR"
        bash deploy.sh
    else
        echo -e "${RED}错误：找不到部署脚本${NC}"
        exit 1
    fi
fi

# 汇总
echo "---"
echo "## 汇总"
echo "- 处理文章：${#files[@]} 篇"
echo "- 成功发布：${PUBLISHED} 篇"
if [[ $FAILED -gt 0 ]]; then
    echo -e "- ${RED}发布失败：${FAILED} 篇${NC}"
fi
if [[ "$MODE" == "dry-run" ]]; then
    echo ""
    echo "提示：使用 --publish 执行发布，使用 --deploy 发布并部署"
fi

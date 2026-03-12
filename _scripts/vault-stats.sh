#!/bin/bash
# 知识库统计仪表盘
# 用法: ./vault-stats.sh

VAULT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
NOW=$(date "+%Y-%m-%d %H:%M")

echo "# 知识库统计仪表盘"
echo "生成时间：$NOW"
echo ""

# --- 笔记分布 ---
echo "## 笔记分布"
echo ""
echo "| 文件夹 | 笔记数 |"
echo "|--------|--------|"

TOTAL=0
for folder in "0-收集箱" "1-项目" "2-领域" "3-资源" "4-归档" "MOC" "日记"; do
    dir="$VAULT_DIR/$folder"
    if [ -d "$dir" ]; then
        count=$(find "$dir" -name "*.md" ! -name "README.md" | wc -l | tr -d ' ')
    else
        count=0
    fi
    echo "| $folder | $count |"
    TOTAL=$((TOTAL + count))
done
echo "| **总计** | **$TOTAL** |"
echo ""

# --- 活跃度 ---
echo "## 活跃度"
echo ""

week_new=$(find "$VAULT_DIR" -name "*.md" -not -path "*/.obsidian/*" -not -path "*/_scripts/*" -not -name "README.md" -newer "$VAULT_DIR" -ctime -7 2>/dev/null | wc -l | tr -d ' ')
week_mod=$(find "$VAULT_DIR" -name "*.md" -not -path "*/.obsidian/*" -not -path "*/_scripts/*" -not -name "README.md" -mtime -7 | wc -l | tr -d ' ')
month_new=$(find "$VAULT_DIR" -name "*.md" -not -path "*/.obsidian/*" -not -path "*/_scripts/*" -not -name "README.md" -ctime -30 2>/dev/null | wc -l | tr -d ' ')
month_mod=$(find "$VAULT_DIR" -name "*.md" -not -path "*/.obsidian/*" -not -path "*/_scripts/*" -not -name "README.md" -mtime -30 | wc -l | tr -d ' ')

echo "- 本周修改：$week_mod 篇"
echo "- 本月修改：$month_mod 篇"

# Use git for more accurate new file tracking
if [ -d "$VAULT_DIR/.git" ]; then
    git_week_new=$(cd "$VAULT_DIR" && git log --since="7 days ago" --diff-filter=A --name-only --pretty=format:"" -- "*.md" 2>/dev/null | grep -v '^$' | wc -l | tr -d ' ')
    git_month_new=$(cd "$VAULT_DIR" && git log --since="30 days ago" --diff-filter=A --name-only --pretty=format:"" -- "*.md" 2>/dev/null | grep -v '^$' | wc -l | tr -d ' ')
    echo "- 本周新建（git）：$git_week_new 篇"
    echo "- 本月新建（git）：$git_month_new 篇"
fi
echo ""

# --- 标签 Top 20 ---
echo "## 标签 Top 20"
echo ""
echo "| 排名 | 标签 | 出现次数 |"
echo "|------|------|---------|"

# Extract tags from frontmatter (tags: #xxx) and body (#xxx)
find "$VAULT_DIR" -name "*.md" -not -path "*/.obsidian/*" -not -path "*/_scripts/*" -not -path "*/_模板/*" -print0 | \
    xargs -0 grep -hoE '#[a-zA-Z\u4e00-\u9fff][a-zA-Z0-9_/\u4e00-\u9fff]*' 2>/dev/null | \
    grep -v '^##' | \
    sort | uniq -c | sort -rn | head -20 | \
    awk '{printf "| %d | %s | %d |\n", NR, $2, $1}'

echo ""

# --- 链接密度 ---
echo "## 链接密度"
echo ""

total_links=$(find "$VAULT_DIR" -name "*.md" -not -path "*/.obsidian/*" -not -path "*/_scripts/*" -not -path "*/_模板/*" -print0 | \
    xargs -0 grep -coE '\[\[[^\]]+\]\]' 2>/dev/null | \
    awk -F: '{s+=$NF} END {print s}')
total_notes=$(find "$VAULT_DIR" -name "*.md" -not -path "*/.obsidian/*" -not -path "*/_scripts/*" -not -path "*/_模板/*" -not -name "README.md" | wc -l | tr -d ' ')

if [ "$total_notes" -gt 0 ]; then
    density=$(echo "scale=1; $total_links / $total_notes" | bc 2>/dev/null || echo "N/A")
else
    density="0"
fi

echo "- 总链接数：$total_links"
echo "- 笔记总数：$total_notes"
echo "- 平均链接密度：$density 链接/篇"
echo ""

# --- 收集箱吞吐 ---
if [ -d "$VAULT_DIR/.git" ]; then
    echo "## 收集箱吞吐（近30天）"
    echo ""
    inbox_in=$(cd "$VAULT_DIR" && git log --since="30 days ago" --diff-filter=A --name-only --pretty=format:"" -- "0-收集箱/*.md" 2>/dev/null | grep -v '^$' | wc -l | tr -d ' ')
    inbox_out=$(cd "$VAULT_DIR" && git log --since="30 days ago" --diff-filter=D --name-only --pretty=format:"" -- "0-收集箱/*.md" 2>/dev/null | grep -v '^$' | wc -l | tr -d ' ')
    inbox_renamed=$(cd "$VAULT_DIR" && git log --since="30 days ago" --diff-filter=R --name-only --pretty=format:"" -- "0-收集箱/*.md" 2>/dev/null | grep -v '^$' | wc -l | tr -d ' ')
    processed=$((inbox_out + inbox_renamed))
    echo "- 新增：$inbox_in 篇"
    echo "- 处理（移出/删除）：$processed 篇"
fi

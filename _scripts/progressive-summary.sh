#!/bin/bash
# 渐进式总结进度扫描
# 用法: ./progressive-summary.sh

VAULT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
RESOURCE_DIR="$VAULT_DIR/3-资源"
NOW=$(date "+%Y-%m-%d %H:%M")
TODAY_TS=$(date +%s)

echo "# 渐进式总结进度报告"
echo "生成时间：$NOW"
echo ""

need_l2=()
need_l3=()
need_l4=()
complete=()

while IFS= read -r -d '' file; do
    name=$(basename "$file")
    [[ "$name" == "README.md" || "$name" == "笔记模板.md" ]] && continue

    relpath="${file#$VAULT_DIR/}"
    basename_noext=$(basename "$file" .md)

    # Get creation date from frontmatter
    create_date=$(grep -m1 '创建日期:' "$file" 2>/dev/null | sed 's/.*创建日期:[[:space:]]*//' | tr -d ' ')
    if [ -z "$create_date" ]; then
        if [[ "$(uname)" == "Darwin" ]]; then
            create_date=$(stat -f "%Sm" -t "%Y-%m-%d" "$file")
        else
            create_date=$(stat -c "%y" "$file" | cut -d' ' -f1)
        fi
    fi

    # Calculate age for priority
    if [[ "$(uname)" == "Darwin" ]]; then
        file_ts=$(stat -f %m "$file")
    else
        file_ts=$(stat -c %Y "$file")
    fi
    age_days=$(( (TODAY_TS - file_ts) / 86400 ))

    if [ "$age_days" -ge 30 ]; then
        priority="高（>${age_days}天）"
    elif [ "$age_days" -ge 14 ]; then
        priority="中"
    else
        priority="低"
    fi

    # Check progressive summary levels
    # Strip frontmatter before checking
    content=$(sed '1{/^---$/,/^---$/d}' "$file" 2>/dev/null)

    has_bold=$(echo "$content" | grep -c '\*\*' 2>/dev/null)
    has_quote=$(echo "$content" | grep -c '^>' 2>/dev/null)
    has_task=$(echo "$content" | grep -c '\- \[ \]' 2>/dev/null)

    if [ "$has_bold" -eq 0 ]; then
        need_l2+=("| $basename_noext | $create_date | $priority |")
    elif [ "$has_quote" -eq 0 ]; then
        need_l3+=("| $basename_noext | $create_date | $priority |")
    elif [ "$has_task" -eq 0 ]; then
        need_l4+=("| $basename_noext | $create_date | $priority |")
    else
        complete+=("$basename_noext")
    fi

done < <(find "$RESOURCE_DIR" -name "*.md" -print0 2>/dev/null)

total=$((${#need_l2[@]} + ${#need_l3[@]} + ${#need_l4[@]} + ${#complete[@]}))

# --- L2 ---
echo "## 需要 L2 处理（加粗关键点）— ${#need_l2[@]} 篇"
echo ""
if [ ${#need_l2[@]} -gt 0 ]; then
    echo "| 文件 | 创建日期 | 优先级 |"
    echo "|------|---------|--------|"
    for item in "${need_l2[@]}"; do echo "$item"; done
else
    echo "全部完成！"
fi
echo ""

# --- L3 ---
echo "## 需要 L3 处理（个人总结）— ${#need_l3[@]} 篇"
echo ""
if [ ${#need_l3[@]} -gt 0 ]; then
    echo "| 文件 | 创建日期 | 优先级 |"
    echo "|------|---------|--------|"
    for item in "${need_l3[@]}"; do echo "$item"; done
else
    echo "全部完成！"
fi
echo ""

# --- L4 ---
echo "## 需要 L4 处理（行动清单）— ${#need_l4[@]} 篇"
echo ""
if [ ${#need_l4[@]} -gt 0 ]; then
    echo "| 文件 | 创建日期 | 优先级 |"
    echo "|------|---------|--------|"
    for item in "${need_l4[@]}"; do echo "$item"; done
else
    echo "全部完成！"
fi
echo ""

# --- Complete ---
echo "## 已完成所有层级 — ${#complete[@]} 篇"
echo ""
for item in "${complete[@]}"; do echo "- $item"; done
echo ""

# --- Summary ---
echo "## 总结"
echo ""
echo "- 总资源笔记：$total"
if [ "$total" -gt 0 ]; then
    l2_done=$(( total - ${#need_l2[@]} ))
    l3_done=$(( total - ${#need_l2[@]} - ${#need_l3[@]} ))
    l4_done=${#complete[@]}
    echo "- L2 完成率：$(( l2_done * 100 / total ))%"
    echo "- L3 完成率：$(( l3_done * 100 / total ))%"
    echo "- L4 完成率：$(( l4_done * 100 / total ))%"
fi

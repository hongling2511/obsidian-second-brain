#!/bin/bash
# 复习提醒 — 识别需要复习的笔记
# 用法: ./review-reminder.sh

VAULT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
NOW=$(date "+%Y-%m-%d %H:%M")
TODAY=$(date "+%Y-%m-%d")
TODAY_TS=$(date +%s)

echo "# 复习提醒"
echo "生成时间：$NOW"
echo ""

# --- 1. 过期复习 ---
echo "## 过期复习"
echo ""

overdue=()
find "$VAULT_DIR" -name "*.md" \
    -not -path "*/.obsidian/*" \
    -not -path "*/_scripts/*" \
    -not -path "*/_模板/*" \
    -not -name "README.md" -print0 | while IFS= read -r -d '' file; do

    review_date=$(grep -m1 '复习日期:' "$file" 2>/dev/null | sed 's/.*复习日期:[[:space:]]*//' | tr -d ' ')
    [ -z "$review_date" ] && continue

    # Validate date format
    if ! echo "$review_date" | grep -qE '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'; then
        continue
    fi

    # Compare dates
    if [[ "$review_date" < "$TODAY" ]]; then
        if [[ "$(uname)" == "Darwin" ]]; then
            review_ts=$(date -j -f "%Y-%m-%d" "$review_date" "+%s" 2>/dev/null)
        else
            review_ts=$(date -d "$review_date" "+%s" 2>/dev/null)
        fi
        if [ -n "$review_ts" ]; then
            overdue_days=$(( (TODAY_TS - review_ts) / 86400 ))
            basename_noext=$(basename "$file" .md)
            echo "| $basename_noext | $review_date | $overdue_days |"
        fi
    fi
done > /tmp/vault_overdue.txt

overdue_count=$(wc -l < /tmp/vault_overdue.txt | tr -d ' ')
echo "共 $overdue_count 篇"
echo ""
if [ "$overdue_count" -gt 0 ]; then
    echo "| 文件 | 复习日期 | 过期天数 |"
    echo "|------|---------|---------|"
    sort -t'|' -k4 -rn /tmp/vault_overdue.txt
fi
echo ""

# --- 2. 需要回顾的笔记 (#需要回顾 且 30+ 天未修改) ---
echo "## 需要回顾的笔记"
echo ""

review_count=0
review_items=""
find "$VAULT_DIR" -name "*.md" \
    -not -path "*/.obsidian/*" \
    -not -path "*/_scripts/*" \
    -not -path "*/_模板/*" \
    -not -name "README.md" \
    -mtime +30 -print0 | while IFS= read -r -d '' file; do

    if grep -q '#需要回顾' "$file" 2>/dev/null; then
        basename_noext=$(basename "$file" .md)
        if [[ "$(uname)" == "Darwin" ]]; then
            last_mod=$(stat -f "%Sm" -t "%Y-%m-%d" "$file")
            mtime=$(stat -f %m "$file")
        else
            last_mod=$(stat -c "%y" "$file" | cut -d' ' -f1)
            mtime=$(stat -c %Y "$file")
        fi
        age=$(( (TODAY_TS - mtime) / 86400 ))
        echo "| $basename_noext | $last_mod | $age |"
    fi
done > /tmp/vault_review.txt

review_count=$(wc -l < /tmp/vault_review.txt | tr -d ' ')
echo "共 $review_count 篇"
echo ""
if [ "$review_count" -gt 0 ]; then
    echo "| 文件 | 最后修改 | 未更新天数 |"
    echo "|------|---------|-----------|"
    cat /tmp/vault_review.txt
fi
echo ""

# --- 3. 停滞项目 ---
echo "## 停滞项目"
echo ""

stale_count=0
find "$VAULT_DIR/1-项目" -name "*进行中*" -name "*.md" -mtime +14 -print0 2>/dev/null | while IFS= read -r -d '' file; do
    basename_noext=$(basename "$file" .md)
    if [[ "$(uname)" == "Darwin" ]]; then
        last_mod=$(stat -f "%Sm" -t "%Y-%m-%d" "$file")
        mtime=$(stat -f %m "$file")
    else
        last_mod=$(stat -c "%y" "$file" | cut -d' ' -f1)
        mtime=$(stat -c %Y "$file")
    fi
    age=$(( (TODAY_TS - mtime) / 86400 ))
    echo "| $basename_noext | $last_mod | $age |"
done > /tmp/vault_stale.txt

stale_count=$(wc -l < /tmp/vault_stale.txt | tr -d ' ')
echo "共 $stale_count 个"
echo ""
if [ "$stale_count" -gt 0 ]; then
    echo "| 项目 | 最后修改 | 停滞天数 |"
    echo "|------|---------|---------|"
    cat /tmp/vault_stale.txt
fi
echo ""

# --- 4. 长期未更新领域 ---
echo "## 长期未更新领域"
echo ""

echo "| 领域 | 最后活动 | 未更新天数 |"
echo "|------|---------|-----------|"

for area_dir in "$VAULT_DIR/2-领域"/*/; do
    [ ! -d "$area_dir" ] && continue
    area_name=$(basename "$area_dir")

    # Find most recently modified file in the area
    latest_file=$(find "$area_dir" -name "*.md" -not -name "README.md" -print0 | \
        xargs -0 stat -f "%m %N" 2>/dev/null | sort -rn | head -1)

    if [ -n "$latest_file" ]; then
        latest_ts=$(echo "$latest_file" | awk '{print $1}')
        age=$(( (TODAY_TS - latest_ts) / 86400 ))
        last_date=$(date -r "$latest_ts" "+%Y-%m-%d" 2>/dev/null)

        if [ "$age" -ge 30 ]; then
            echo "| $area_name | $last_date | $age |"
        fi
    else
        echo "| $area_name | 无笔记 | - |"
    fi
done

# Cleanup temp files
rm -f /tmp/vault_overdue.txt /tmp/vault_review.txt /tmp/vault_stale.txt

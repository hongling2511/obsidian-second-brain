#!/bin/bash
# 周报数据生成器
# 用法: ./weekly-review.sh

VAULT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
NOW=$(date "+%Y-%m-%d %H:%M")
TODAY=$(date "+%Y-%m-%d")
WEEK_NUM=$(date "+%W")
YEAR=$(date "+%Y")

# Calculate week start (Monday)
if [[ "$(uname)" == "Darwin" ]]; then
    DOW=$(date "+%u")
    WEEK_START=$(date -v-$((DOW-1))d "+%Y-%m-%d")
    WEEK_END=$(date -v+$((7-DOW))d "+%Y-%m-%d")
    SINCE_DATE=$(date -v-7d "+%Y-%m-%d")
else
    DOW=$(date "+%u")
    WEEK_START=$(date -d "-$((DOW-1)) days" "+%Y-%m-%d")
    WEEK_END=$(date -d "+$((7-DOW)) days" "+%Y-%m-%d")
    SINCE_DATE=$(date -d "-7 days" "+%Y-%m-%d")
fi

echo "# ${YEAR}年第${WEEK_NUM}周 周报数据"
echo "生成时间：$NOW"
echo "统计周期：$WEEK_START ~ $WEEK_END"
echo ""

# --- 统计摘要 ---
echo "## 本周统计"
echo ""

if [ -d "$VAULT_DIR/.git" ]; then
    new_count=$(cd "$VAULT_DIR" && git log --since="7 days ago" --diff-filter=A --name-only --pretty=format:"" -- "*.md" 2>/dev/null | grep -v '^$' | grep -v 'README.md' | wc -l | tr -d ' ')
    mod_count=$(cd "$VAULT_DIR" && git log --since="7 days ago" --diff-filter=M --name-only --pretty=format:"" -- "*.md" 2>/dev/null | grep -v '^$' | grep -v 'README.md' | sort -u | wc -l | tr -d ' ')
else
    new_count=$(find "$VAULT_DIR" -name "*.md" -not -path "*/.obsidian/*" -not -name "README.md" -ctime -7 2>/dev/null | wc -l | tr -d ' ')
    mod_count=$(find "$VAULT_DIR" -name "*.md" -not -path "*/.obsidian/*" -not -name "README.md" -mtime -7 | wc -l | tr -d ' ')
fi

# Count completed tasks in recently modified files
task_count=$(find "$VAULT_DIR" -name "*.md" -not -path "*/.obsidian/*" -mtime -7 -print0 | \
    xargs -0 grep -c '\- \[x\]' 2>/dev/null | \
    awk -F: '{s+=$NF} END {print s+0}')

echo "- 新建笔记：$new_count 篇"
echo "- 修改笔记：$mod_count 篇"
echo "- 完成任务：$task_count 项"
echo ""

# --- 本周变动按文件夹 ---
echo "## 本周变动（按文件夹）"
echo ""

if [ -d "$VAULT_DIR/.git" ]; then
    changes=$(cd "$VAULT_DIR" && git log --since="7 days ago" --name-status --pretty=format:"" -- "*.md" 2>/dev/null | grep -v '^$' | sort -u)

    for folder in "0-收集箱" "1-项目" "2-领域" "3-资源" "4-归档" "MOC" "日记"; do
        folder_changes=$(echo "$changes" | grep "$folder/" 2>/dev/null)
        if [ -n "$folder_changes" ]; then
            echo "### $folder"
            echo "$folder_changes" | while IFS=$'\t' read -r status filepath; do
                case "$status" in
                    A*) label="新建" ;;
                    M*) label="修改" ;;
                    D*) label="删除" ;;
                    R*) label="移动" ;;
                    *) label="变更" ;;
                esac
                basename=$(basename "$filepath" .md)
                echo "- [$label] $basename"
            done
            echo ""
        fi
    done
else
    echo "（未检测到 git 仓库，无法获取变动历史）"
    echo ""
fi

# --- 收集箱积压 ---
INBOX="$VAULT_DIR/0-收集箱"
inbox_items=()
if [ -d "$INBOX" ]; then
    while IFS= read -r -d '' file; do
        name=$(basename "$file")
        if [[ "$name" == "README.md" || "$name" == "收集箱清理清单.md" ]]; then
            continue
        fi
        if [[ "$(uname)" == "Darwin" ]]; then
            mtime=$(stat -f %m "$file")
            now_ts=$(date +%s)
        else
            mtime=$(stat -c %Y "$file")
            now_ts=$(date +%s)
        fi
        age_days=$(( (now_ts - mtime) / 86400 ))
        inbox_items+=("| $(basename "$file" .md) | $age_days |")
    done < <(find "$INBOX" -maxdepth 1 -name "*.md" -print0)
fi

echo "## 收集箱积压（${#inbox_items[@]} 项）"
echo ""
if [ ${#inbox_items[@]} -gt 0 ]; then
    echo "| 文件 | 滞留天数 |"
    echo "|------|---------|"
    for item in "${inbox_items[@]}"; do
        echo "$item"
    done
else
    echo "收集箱为空，做得好！"
fi
echo ""

# --- 停滞项目 ---
echo "## 停滞项目"
echo ""

stale_projects=()
while IFS= read -r -d '' file; do
    name=$(basename "$file")
    if echo "$name" | grep -q '\[进行中\]'; then
        if [[ "$(uname)" == "Darwin" ]]; then
            mtime=$(stat -f %m "$file")
            now_ts=$(date +%s)
        else
            mtime=$(stat -c %Y "$file")
            now_ts=$(date +%s)
        fi
        age_days=$(( (now_ts - mtime) / 86400 ))
        if [ "$age_days" -ge 14 ]; then
            last_mod=$(date -r "$mtime" "+%Y-%m-%d" 2>/dev/null || date -d "@$mtime" "+%Y-%m-%d")
            stale_projects+=("| $(basename "$file" .md) | $last_mod | $age_days |")
        fi
    fi
done < <(find "$VAULT_DIR/1-项目" -name "*.md" -print0 2>/dev/null)

if [ ${#stale_projects[@]} -gt 0 ]; then
    echo "| 项目 | 最后修改 | 停滞天数 |"
    echo "|------|---------|---------|"
    for item in "${stale_projects[@]}"; do
        echo "$item"
    done
else
    echo "没有停滞项目。"
fi
echo ""

# --- 建议 ---
echo "## 下周建议"
echo ""
[ ${#inbox_items[@]} -gt 0 ] && echo "- 处理收集箱积压 ${#inbox_items[@]} 项"
[ ${#stale_projects[@]} -gt 0 ] && echo "- 关注停滞项目 ${#stale_projects[@]} 个"
echo "- 运行 \`progressive-summary.sh\` 检查渐进式总结进度"
echo "- 运行 \`review-reminder.sh\` 检查待复习笔记"

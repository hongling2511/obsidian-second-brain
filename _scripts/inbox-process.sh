#!/usr/bin/env bash
# inbox-process.sh — 扫描并分类收集箱中的笔记
# 用法：
#   ./inbox-process.sh            # 默认 dry-run，仅报告建议
#   ./inbox-process.sh --dry-run  # 同上
#   ./inbox-process.sh --move     # 实际移动文件

set -euo pipefail

VAULT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
INBOX="$VAULT_DIR/0-收集箱"

# ── 参数解析 ──────────────────────────────────────────────
MODE="dry-run"
while [[ $# -gt 0 ]]; do
    case "$1" in
        --move)  MODE="move"; shift ;;
        --dry-run) MODE="dry-run"; shift ;;
        -h|--help)
            echo "用法：$0 [--dry-run | --move]"
            echo "  --dry-run  （默认）仅输出分类建议，不移动文件"
            echo "  --move     根据分类建议实际移动文件"
            exit 0
            ;;
        *) echo "未知参数：$1"; exit 1 ;;
    esac
done

# ── 辅助函数 ──────────────────────────────────────────────

# 计算文件年龄（天）
file_age_days() {
    local filepath="$1"
    local mtime
    if [[ "$(uname)" == "Darwin" ]]; then
        mtime=$(stat -f '%m' "$filepath")
    else
        mtime=$(stat -c '%Y' "$filepath")
    fi
    local now
    now=$(date +%s)
    echo $(( (now - mtime) / 86400 ))
}

# 在库中搜索相关笔记标题（排除收集箱自身）
find_related_notes() {
    local keyword="$1"
    local results=()
    while IFS= read -r -d '' f; do
        local basename
        basename="$(basename "$f" .md)"
        if [[ "$basename" == *"$keyword"* ]]; then
            results+=("$basename")
        fi
    done < <(find "$VAULT_DIR" -name '*.md' -not -path "$INBOX/*" -print0 2>/dev/null)
    # 最多返回3个
    local count=0
    for r in "${results[@]}"; do
        if (( count >= 3 )); then break; fi
        echo "    - $r"
        (( count++ )) || true
    done
}

# 从内容提取关键词用于搜索相关笔记
extract_search_terms() {
    local content="$1"
    local terms=()
    # 提取中文关键词（从标题行 # 开头）
    while IFS= read -r line; do
        local cleaned
        cleaned="$(echo "$line" | sed 's/^#\+[[:space:]]*//')"
        if [[ -n "$cleaned" ]]; then
            terms+=("$cleaned")
        fi
    done <<< "$(echo "$content" | grep -E '^#{1,3} ' | head -3)"
    echo "${terms[@]}"
}

# ── 分类逻辑 ──────────────────────────────────────────────

classify_file() {
    local content="$1"
    local target=""
    local reason=""
    local tags=()

    # 会议关键词
    if echo "$content" | grep -qE '会议|讨论|参会'; then
        target="1-项目/"
        reason="包含会议相关内容"
        tags+=("#会议")
    fi

    # 任务模式
    if echo "$content" | grep -qE '\- \[ \]|任务|计划|目标|截止'; then
        target="1-项目/"
        reason="包含任务清单"
        tags+=("#项目" "#任务")
    fi

    # 领域关键词 → 细分子文件夹
    if echo "$content" | grep -qE '健康|锻炼'; then
        target="2-领域/健康/"
        reason="包含健康/锻炼相关内容"
        tags+=("#健康")
    elif echo "$content" | grep -qE '财务|理财|投资|收入|支出'; then
        target="2-领域/财务/"
        reason="包含财务相关内容"
        tags+=("#财务")
    elif echo "$content" | grep -qE '职业|工作|晋升|简历'; then
        target="2-领域/职业/"
        reason="包含职业发展相关内容"
        tags+=("#职业")
    elif echo "$content" | grep -qE '人际|社交|朋友|关系'; then
        target="2-领域/人际关系/"
        reason="包含人际关系相关内容"
        tags+=("#人际")
    elif echo "$content" | grep -qE '成长|学习|自我提升'; then
        target="2-领域/个人成长/"
        reason="包含个人成长相关内容"
        tags+=("#成长")
    elif echo "$content" | grep -qE '家庭|家人|孩子'; then
        target="2-领域/家庭/"
        reason="包含家庭相关内容"
        tags+=("#家庭")
    elif echo "$content" | grep -qE '习惯'; then
        target="2-领域/个人成长/"
        reason="包含习惯养成相关内容"
        tags+=("#习惯")
    fi

    # 资源指标
    if [[ -z "$target" ]] && echo "$content" | grep -qE 'http|书|作者|文章|课程|读|视频'; then
        target="3-资源/"
        reason="包含资源/参考材料"
        tags+=("#资源")
    fi

    # 默认
    if [[ -z "$target" ]]; then
        target=""
        reason="无法自动分类，建议手动归类"
        tags+=("#待分类")
    fi

    # 输出结果（用特殊分隔符）
    local tags_str
    tags_str="$(IFS=' '; echo "${tags[*]}")"
    echo "${target}|||${reason}|||${tags_str}"
}

# ── 主流程 ────────────────────────────────────────────────

SCAN_TIME="$(date '+%Y-%m-%d %H:%M')"
EXCLUDE_FILES=("README.md" "收集箱清理清单.md")

# 收集待处理文件
files=()
while IFS= read -r -d '' f; do
    fname="$(basename "$f")"
    skip=false
    for ex in "${EXCLUDE_FILES[@]}"; do
        if [[ "$fname" == "$ex" ]]; then
            skip=true
            break
        fi
    done
    if [[ "$skip" == false ]]; then
        files+=("$f")
    fi
done < <(find "$INBOX" -maxdepth 1 -name '*.md' -print0 2>/dev/null)

FILE_COUNT="${#files[@]}"

# ── 输出报告 ──────────────────────────────────────────────

echo "# 收集箱处理报告"
echo "扫描时间：${SCAN_TIME}"
echo "模式：$(if [[ "$MODE" == "move" ]]; then echo '移动模式'; else echo '仅报告（dry-run）'; fi)"
echo "待处理：${FILE_COUNT} 篇"
echo ""

if (( FILE_COUNT == 0 )); then
    echo "收集箱为空，无需处理。"
    exit 0
fi

echo "## 分类建议"
echo ""

MOVED=0
SKIPPED=0

for filepath in "${files[@]}"; do
    fname="$(basename "$filepath")"
    fname_no_ext="$(basename "$filepath" .md)"
    content="$(cat "$filepath")"
    age="$(file_age_days "$filepath")"

    # 分类
    result="$(classify_file "$content")"
    IFS='|||' read -r target _ reason _ tags_str <<< "$result"

    echo "### ${fname}（${age} 天前）"

    if [[ -n "$target" ]]; then
        echo "- 建议目标：${target}"
    else
        echo "- 建议目标：需手动分类"
    fi

    echo "- 建议标签：${tags_str}"
    echo "- 分类依据：${reason}"

    # 滞留警告
    if (( age > 14 )); then
        echo "- ⚠️ 滞留超过14天，需审查"
    fi

    # 搜索相关笔记
    search_terms="$(extract_search_terms "$content")"
    if [[ -n "$search_terms" ]]; then
        related=""
        for term in $search_terms; do
            found="$(find_related_notes "$term")"
            if [[ -n "$found" ]]; then
                related+="$found"$'\n'
            fi
        done
        if [[ -n "$related" ]]; then
            echo "- 可能相关笔记："
            echo "$related" | head -6
        fi
    fi

    # 移动模式
    if [[ "$MODE" == "move" && -n "$target" ]]; then
        target_dir="$VAULT_DIR/$target"
        if [[ -d "$target_dir" ]]; then
            mv "$filepath" "$target_dir"
            echo "- ✅ 已移动至 ${target}"
            (( MOVED++ )) || true
        else
            echo "- ❌ 目标目录不存在：${target_dir}，跳过"
            (( SKIPPED++ )) || true
        fi
    fi

    echo ""
done

# ── 汇总 ──────────────────────────────────────────────────

echo "---"
echo "## 汇总"
echo "- 扫描文件：${FILE_COUNT} 篇"
if [[ "$MODE" == "move" ]]; then
    echo "- 已移动：${MOVED} 篇"
    echo "- 已跳过：${SKIPPED} 篇"
else
    echo "- 提示：使用 --move 参数实际执行移动操作"
fi

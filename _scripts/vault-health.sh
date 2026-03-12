#!/usr/bin/env bash
set -euo pipefail

VAULT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
NOW="$(date '+%Y-%m-%d %H:%M')"

# Temp files
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

ALL_MD="$TMP_DIR/all_md.txt"
OUTLINKS="$TMP_DIR/outlinks.txt"
INLINKS="$TMP_DIR/inlinks.txt"
REPORT="$TMP_DIR/report.md"

# ── Helper: should this file be excluded from a check? ──
# Usage: excluded "$filepath" "README,_模板,_scripts,.obsidian"
excluded() {
  local f="$1"; shift
  for pat in $(echo "$@" | tr ',' ' '); do
    case "$f" in
      */"$pat"/*|*/"$pat"|"$pat"/*|"$pat") return 0 ;;
      */README.md) [[ "$pat" == "README" ]] && return 0 ;;
    esac
  done
  return 1
}

is_readme() { [[ "$(basename "$1")" == "README.md" ]]; }

# ── Collect all .md files (relative paths) ──
cd "$VAULT_DIR"
find . -name '*.md' -not -path './.obsidian/*' | sed 's|^\./||' | sort > "$ALL_MD"

# ── Build link index ──
# outlinks: file -> targets; inlinks: target -> sources
> "$OUTLINKS"
> "$INLINKS"
while IFS= read -r f; do
  # Extract [[target]] and [[target|alias]] links
  grep -oE '\[\[[^]]+\]\]' "$f" 2>/dev/null | sed 's/\[\[//;s/\]\]//;s/|.*//' | while IFS= read -r target; do
    [[ -z "$target" ]] && continue
    echo "$f	$target" >> "$OUTLINKS"
    echo "$target	$f" >> "$INLINKS"
  done
done < "$ALL_MD"

# ═══════════════════════════════════════════
# 1. 孤立笔记
# ═══════════════════════════════════════════
orphans=()
while IFS= read -r f; do
  is_readme "$f" && continue
  case "$f" in _模板/*|_scripts/*|.obsidian/*) continue ;; esac

  # Check outlinks
  has_out=false
  if grep -q "^${f}	" "$OUTLINKS" 2>/dev/null; then has_out=true; fi

  # Check inlinks: target could be basename without .md or full relative path
  has_in=false
  base="$(basename "$f" .md)"
  if grep -qiE "^${base}	" "$INLINKS" 2>/dev/null; then has_in=true; fi
  if grep -q "^${f%.md}	" "$INLINKS" 2>/dev/null; then has_in=true; fi
  if grep -q "^${f}	" "$INLINKS" 2>/dev/null; then has_in=true; fi

  if ! $has_out && ! $has_in; then
    orphans+=("$f")
  fi
done < "$ALL_MD"

# ═══════════════════════════════════════════
# 2. 断裂链接
# ═══════════════════════════════════════════
broken_links=()
while IFS=$'\t' read -r src target; do
  [[ -z "$target" ]] && continue
  # Strip heading/block references
  clean="${target%%#*}"
  clean="${clean%%^*}"
  [[ -z "$clean" ]] && continue

  # Check if target exists: exact path, with .md, or basename match
  found=false
  if [[ -f "$clean" ]] || [[ -f "${clean}.md" ]]; then
    found=true
  else
    # Search by basename
    base="$(basename "$clean")"
    if grep -qE "(^|/)${base}(\.md)?$" "$ALL_MD" 2>/dev/null; then
      found=true
    fi
  fi

  if ! $found; then
    broken_links+=("$src → [[$target]]")
  fi
done < "$OUTLINKS"

# ═══════════════════════════════════════════
# 3. 收集箱积压
# ═══════════════════════════════════════════
inbox_stale=()
INBOX_DIR="0-收集箱"
if [[ -d "$INBOX_DIR" ]]; then
  while IFS= read -r f; do
    base="$(basename "$f")"
    [[ "$base" == "README.md" || "$base" == "收集箱清理清单.md" ]] && continue
    # Age in days
    if [[ "$(uname)" == "Darwin" ]]; then
      mtime=$(stat -f '%m' "$f")
    else
      mtime=$(stat -c '%Y' "$f")
    fi
    now_ts=$(date +%s)
    age_days=$(( (now_ts - mtime) / 86400 ))
    if (( age_days > 7 )); then
      inbox_stale+=("$base（${age_days} 天）")
    fi
  done < <(find "$INBOX_DIR" -maxdepth 1 -name '*.md' -type f)
fi

# ═══════════════════════════════════════════
# 4. 空笔记
# ═══════════════════════════════════════════
empty_notes=()
while IFS= read -r f; do
  is_readme "$f" && continue
  case "$f" in _模板/*|_scripts/*) continue ;; esac

  # Strip frontmatter (between first --- and next ---) then count chars
  content=$(awk '
    BEGIN { in_fm=0; started=0 }
    /^---$/ {
      if (!started) { in_fm=1; started=1; next }
      if (in_fm) { in_fm=0; next }
    }
    !in_fm { print }
  ' "$f" 2>/dev/null)
  char_count=${#content}
  if (( char_count < 50 )); then
    empty_notes+=("$f")
  fi
done < "$ALL_MD"

# ═══════════════════════════════════════════
# 5. 缺失 frontmatter
# ═══════════════════════════════════════════
no_frontmatter=()
while IFS= read -r f; do
  is_readme "$f" && continue
  case "$f" in MOC/*|_scripts/*) continue ;; esac

  first_line=$(head -n1 "$f" 2>/dev/null)
  if [[ "$first_line" != "---" ]]; then
    no_frontmatter+=("$f")
  fi
done < "$ALL_MD"

# ═══════════════════════════════════════════
# 6. 无标签笔记
# ═══════════════════════════════════════════
no_tags=()
while IFS= read -r f; do
  is_readme "$f" && continue
  case "$f" in _模板/*|_scripts/*|.obsidian/*) continue ;; esac

  has_tag=false
  # Check frontmatter tags:
  if grep -q '^tags:' "$f" 2>/dev/null; then has_tag=true; fi
  # Check inline #tag (word boundary, not heading or code)
  if grep -qE '(^| )#[a-zA-Z\u4e00-\u9fff]' "$f" 2>/dev/null; then has_tag=true; fi

  if ! $has_tag; then
    no_tags+=("$f")
  fi
done < "$ALL_MD"

# ═══════════════════════════════════════════
# 7. 模板合规性 — 1-项目/ 缺少状态字段
# ═══════════════════════════════════════════
missing_status=()
if [[ -d "1-项目" ]]; then
  while IFS= read -r f; do
    is_readme "$f" && continue
    # Extract frontmatter and check for 状态
    has_status=$(awk '
      BEGIN { in_fm=0; found=0 }
      /^---$/ { if (!in_fm) { in_fm=1; next } else { exit } }
      in_fm && /^状态[:：]/ { found=1 }
      END { print found }
    ' "$f" 2>/dev/null)
    if [[ "$has_status" != "1" ]]; then
      missing_status+=("$f")
    fi
  done < <(grep '^1-项目/' "$ALL_MD")
fi

# ═══════════════════════════════════════════
# Generate report
# ═══════════════════════════════════════════
issues=0
passes=0

{
echo "# 知识库健康检查报告"
echo "生成时间：$NOW"
echo ""

# 1
echo "## 孤立笔记（${#orphans[@]} 篇）"
if (( ${#orphans[@]} > 0 )); then
  for f in "${orphans[@]}"; do echo "- $f"; done
  (( issues++ ))
else
  echo "- 无"
  (( passes++ ))
fi
echo ""

# 2
echo "## 断裂链接（${#broken_links[@]} 处）"
if (( ${#broken_links[@]} > 0 )); then
  for l in "${broken_links[@]}"; do echo "- $l"; done
  (( issues++ ))
else
  echo "- 无"
  (( passes++ ))
fi
echo ""

# 3
echo "## 收集箱积压（${#inbox_stale[@]} 篇）"
if (( ${#inbox_stale[@]} > 0 )); then
  for f in "${inbox_stale[@]}"; do echo "- $f"; done
  (( issues++ ))
else
  echo "- 无"
  (( passes++ ))
fi
echo ""

# 4
echo "## 空笔记（${#empty_notes[@]} 篇）"
if (( ${#empty_notes[@]} > 0 )); then
  for f in "${empty_notes[@]}"; do echo "- $f"; done
  (( issues++ ))
else
  echo "- 无"
  (( passes++ ))
fi
echo ""

# 5
echo "## 缺失 frontmatter（${#no_frontmatter[@]} 篇）"
if (( ${#no_frontmatter[@]} > 0 )); then
  for f in "${no_frontmatter[@]}"; do echo "- $f"; done
  (( issues++ ))
else
  echo "- 无"
  (( passes++ ))
fi
echo ""

# 6
echo "## 无标签笔记（${#no_tags[@]} 篇）"
if (( ${#no_tags[@]} > 0 )); then
  for f in "${no_tags[@]}"; do echo "- $f"; done
  (( issues++ ))
else
  echo "- 无"
  (( passes++ ))
fi
echo ""

# 7
echo "## 模板合规性 — 缺少「状态」字段（${#missing_status[@]} 篇）"
if (( ${#missing_status[@]} > 0 )); then
  for f in "${missing_status[@]}"; do echo "- $f"; done
  (( issues++ ))
else
  echo "- 无"
  (( passes++ ))
fi
echo ""

echo "## 总结"
echo "- 通过 $passes 项检查"
echo "- 发现 $issues 个问题"
} > "$REPORT"

cat "$REPORT"

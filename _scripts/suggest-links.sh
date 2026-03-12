#!/bin/bash
# 链接建议器 — 发现未链接的提及和孤立笔记
# 用法: ./suggest-links.sh

VAULT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
NOW=$(date "+%Y-%m-%d %H:%M")
TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

echo "# 链接建议报告"
echo "生成时间：$NOW"
echo ""

# --- Step 1: Build title index ---
TITLES="$TMPDIR/titles.txt"
TITLE_FILES="$TMPDIR/title_files.txt"

find "$VAULT_DIR" -name "*.md" \
    -not -path "*/.obsidian/*" \
    -not -path "*/_scripts/*" \
    -not -name "README.md" | while read -r filepath; do
    title=$(basename "$filepath" .md)
    # Only include titles with 2+ characters
    if [ ${#title} -ge 2 ]; then
        relpath="${filepath#$VAULT_DIR/}"
        echo "$title" >> "$TITLES"
        echo "$title	$relpath" >> "$TITLE_FILES"
    fi
done

sort -u "$TITLES" -o "$TITLES"

# --- Step 2: Find unlinked mentions ---
echo "## 未链接的提及"
echo ""

unlinked_count=0
suggestions="$TMPDIR/suggestions.txt"
touch "$suggestions"

while IFS=$'\t' read -r title relpath; do
    filepath="$VAULT_DIR/$relpath"
    [ ! -f "$filepath" ] && continue

    # Search other files for mentions of this title not inside [[ ]]
    find "$VAULT_DIR" -name "*.md" \
        -not -path "*/.obsidian/*" \
        -not -path "*/_scripts/*" \
        -not -path "*/_模板/*" \
        -not -name "README.md" \
        -not -path "$filepath" -print0 | \
    xargs -0 grep -l "$title" 2>/dev/null | while read -r source; do
        # Check if the mention is already linked
        if ! grep -q "\[\[$title\]\]\|\[\[$title|" "$source" 2>/dev/null; then
            # Verify it's a real mention (not inside existing link to something else)
            source_rel="${source#$VAULT_DIR/}"
            echo "- $(basename "$source" .md) → 建议链接 [[$title]]" >> "$suggestions"
        fi
    done
done < "$TITLE_FILES"

if [ -s "$suggestions" ]; then
    sort -u "$suggestions" | head -50
    unlinked_count=$(sort -u "$suggestions" | wc -l | tr -d ' ')
else
    echo "未发现未链接的提及。"
fi
echo ""
echo "共发现 $unlinked_count 处未链接提及（显示前50条）"
echo ""

# --- Step 3: Find orphan notes ---
echo "## 孤立笔记"
echo ""

# Build link graph
OUTLINKS="$TMPDIR/outlinks.txt"
INLINKS="$TMPDIR/inlinks.txt"
touch "$OUTLINKS" "$INLINKS"

find "$VAULT_DIR" -name "*.md" \
    -not -path "*/.obsidian/*" \
    -not -path "*/_scripts/*" \
    -not -path "*/_模板/*" \
    -not -name "README.md" -print0 | while IFS= read -r -d '' filepath; do
    relpath="${filepath#$VAULT_DIR/}"
    basename_noext=$(basename "$filepath" .md)

    # Count outlinks
    out=$(grep -coE '\[\[[^\]]+\]\]' "$filepath" 2>/dev/null)
    if [ "$out" -gt 0 ]; then
        echo "$relpath" >> "$OUTLINKS"
    fi

    # Extract link targets for inlink tracking
    grep -oE '\[\[([^\]|]+)' "$filepath" 2>/dev/null | sed 's/\[\[//' | while read -r target; do
        echo "$target" >> "$INLINKS"
    done
done

orphan_count=0
find "$VAULT_DIR" -name "*.md" \
    -not -path "*/.obsidian/*" \
    -not -path "*/_scripts/*" \
    -not -path "*/_模板/*" \
    -not -name "README.md" -print0 | while IFS= read -r -d '' filepath; do
    relpath="${filepath#$VAULT_DIR/}"
    basename_noext=$(basename "$filepath" .md)

    has_outlinks=$(grep -cE '\[\[' "$filepath" 2>/dev/null)
    has_inlinks=$(grep -c "^${basename_noext}$" "$INLINKS" 2>/dev/null)

    if [ "$has_outlinks" -eq 0 ] && [ "$has_inlinks" -eq 0 ]; then
        echo "- $relpath（无入链，无出链）"
        orphan_count=$((orphan_count + 1))
    fi
done

echo ""

# --- Summary ---
total_scanned=$(wc -l < "$TITLES" | tr -d ' ')
echo "## 统计"
echo ""
echo "- 扫描笔记数：$total_scanned"
echo "- 发现未链接提及：$unlinked_count"

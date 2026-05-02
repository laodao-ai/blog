#!/usr/bin/env bash
# check-summary.sh — 文章摘要质量守门
#
# 三条规则：
#   1. front matter 的 summary 长度 ∈ [80, 200]（按字符数计算，中文 1 字算 1 字符）
#   2. summary 字段值不含字面量 TODO
#   3. 正文第一段（front matter 后第一个非空行起的 blockquote 或正文段）不含字面量 TODO
#
# 跳过 draft: true 的文章。
#
# 退出码：
#   0 - 全部通过
#   1 - 至少一篇违例
#   2 - 脚本自身错误（参数/路径）
#
# 本地直跑：
#   bash scripts/check-summary.sh
#
# 失败输出格式（机器/人类双友好，CI 上一眼定位）：
#   [FAIL] <相对路径>
#     reason:   <违例原因>
#     expected: <期望区间或条件>
#     actual:   <实测值>

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
POSTS_DIR="$REPO_ROOT/content/posts"

if [[ ! -d "$POSTS_DIR" ]]; then
  echo "ERROR: 找不到目录 $POSTS_DIR" >&2
  exit 2
fi

SUMMARY_MIN=80
SUMMARY_MAX=200

checked=0
violation_count=0
# 累积违例输出，结构化四要素：path / reason / expected / actual
violations_out=""

record_violation() {
  # $1=path  $2=reason  $3=expected  $4=actual
  violation_count=$((violation_count + 1))
  violations_out+="[FAIL] $1"$'\n'
  violations_out+="  reason:   $2"$'\n'
  violations_out+="  expected: $3"$'\n'
  violations_out+="  actual:   $4"$'\n'
}

# 提取 front matter 中 summary 字段值（YAML 单/双引号或裸值，单行）
extract_summary() {
  local file="$1"
  awk '
    /^---[[:space:]]*$/ { fm = !fm; next }
    fm && /^summary:[[:space:]]*/ {
      sub(/^summary:[[:space:]]*/, "")
      gsub(/^["'"'"']|["'"'"']$/, "")
      print
      exit
    }
  ' "$file"
}

# 判断 front matter 是否标记 draft: true
is_draft() {
  local file="$1"
  awk '
    /^---[[:space:]]*$/ { fm = !fm; next }
    fm && /^draft:[[:space:]]*true[[:space:]]*$/ { print "yes"; exit }
  ' "$file"
}

# 提取正文第一段（front matter 块结束后第一个非空行起，连续非空行或 blockquote）
extract_first_para() {
  local file="$1"
  awk '
    BEGIN { fm = 0; fm_done = 0 }
    /^---[[:space:]]*$/ {
      if (fm == 0) { fm = 1; next }
      else if (fm == 1) { fm = 0; fm_done = 1; next }
    }
    fm == 1 { next }
    fm_done == 0 { next }
    NF == 0 { if (started) exit; else next }
    /^[[:space:]]*<!--/ { next }
    { started = 1; print }
  ' "$file"
}

# 字符数（按 utf-8 字符计；中文 1 字算 1 字符，不是 3 字节）
# 用 perl 而非 awk/wc——awk length() 按字节算，wc -m 在不同 locale 下行为不一
char_count() {
  printf '%s' "$1" | perl -CS -e 'my $s = do { local $/; <STDIN> }; print length($s)'
}

# 兼容 macOS / Linux：用 globbing 而非 find，避免空 glob
shopt -s nullglob
posts=("$POSTS_DIR"/*/index.md)
shopt -u nullglob

if [[ ${#posts[@]} -eq 0 ]]; then
  echo "INFO: 未找到任何 content/posts/*/index.md，已跳过校验"
  exit 0
fi

for f in "${posts[@]}"; do
  rel="${f#"$REPO_ROOT/"}"

  if [[ "$(is_draft "$f")" == "yes" ]]; then
    continue
  fi

  checked=$((checked + 1))

  summary="$(extract_summary "$f" || true)"
  first_para="$(extract_first_para "$f" || true)"

  # 规则 1：summary 长度
  len="$(char_count "$summary")"
  if (( len < SUMMARY_MIN || len > SUMMARY_MAX )); then
    record_violation "$rel" \
      "summary length out of range" \
      "${SUMMARY_MIN}-${SUMMARY_MAX} chars" \
      "${len} chars"
  fi

  # 规则 2：summary 不含 TODO
  if [[ "$summary" == *TODO* ]]; then
    record_violation "$rel" \
      "summary contains TODO placeholder" \
      "no literal 'TODO' in summary" \
      "summary contains 'TODO'"
  fi

  # 规则 3：正文首段不含 TODO
  if [[ "$first_para" == *TODO* ]]; then
    record_violation "$rel" \
      "first paragraph contains TODO placeholder" \
      "no literal 'TODO' in first paragraph" \
      "first paragraph contains 'TODO'"
  fi
done

if (( violation_count > 0 )); then
  echo "✗ check-summary 失败：${violation_count} 条违例"
  echo ""
  printf '%s' "$violations_out"
  echo "已检查 $checked 篇，违例 ${violation_count} 篇"
  exit 1
fi

echo "✓ check-summary 通过：已检查 $checked 篇，全部合规"
exit 0

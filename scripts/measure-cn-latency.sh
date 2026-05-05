#!/usr/bin/env bash
# 周采样 laodao-ai.cn 的国际首屏延迟。
#
# 由 GHA 在美国/欧洲 runner 上跑 → 模拟"国际读者"视角。
# 每个 URL 取 5 次 curl time_total，nearest-rank P95 = 最大值。
# 结果追加到 geo-audit/cn-intl-latency.csv，由 workflow auto-commit。
#
# 阈值规则（见 geo-audit/README.md）：
#   - 连续 4 周 P95 > 1500ms → 触发评估切换 Q6 方案 C
#   - 单周 P95 > 3000ms      → 立即评估
#
# 依赖：bash, curl, awk, sort（GHA ubuntu-latest 默认有）

set -euo pipefail

URLS=(
    "https://laodao-ai.cn/"
    "https://laodao-ai.cn/posts/"
    "https://laodao-ai.cn/about/"
)
N_SAMPLES=5
TIMEOUT=10
DATE="$(date -u +%Y-%m-%d)"
OUT="geo-audit/cn-intl-latency.csv"

mkdir -p geo-audit
[[ -f "$OUT" ]] || echo "date,page,p95_ms,samples_n,runner_region" > "$OUT"

# GHA runner region 提示（用于事后判断样本一致性；GHA 不直接暴露区域，用 IP geolocation 推断）
RUNNER_REGION="$(curl -fsS --max-time 5 https://ipinfo.io/region 2>/dev/null || echo unknown)"

for url in "${URLS[@]}"; do
    page="${url#https://laodao-ai.cn}"
    page="${page:-/}"

    times=()
    for ((i = 1; i <= N_SAMPLES; i++)); do
        t="$(curl -fsS -o /dev/null -w "%{time_total}" \
            --max-time "$TIMEOUT" "$url" 2>/dev/null || echo "0")"
        times+=("$t")
    done

    # P95 of 5 samples by nearest-rank: ceil(0.95 * 5) = 5 → max
    p95_s="$(printf '%s\n' "${times[@]}" | sort -g | tail -1)"
    p95_ms="$(awk -v s="$p95_s" 'BEGIN { printf "%d", s * 1000 }')"

    echo "$DATE,$page,$p95_ms,$N_SAMPLES,$RUNNER_REGION" >> "$OUT"
    printf '%s  %-40s  P95=%dms  (samples: %s)\n' \
        "$DATE" "$page" "$p95_ms" "${times[*]}"
done

echo ""
echo "=== Last 10 rows of $OUT ==="
tail -10 "$OUT"

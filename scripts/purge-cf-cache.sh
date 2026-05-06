#!/usr/bin/env bash
# purge-cf-cache.sh · 手动 purge Cloudflare cache（laodao-ai.com）
# ---
# 自动加载同目录 ../.env（gitignore）中的 CF_API_TOKEN + CF_ZONE_ID_COM。
# 也可通过 env var 直接覆盖（CI / 临时）。
# ---
# 用法：
#   bash scripts/purge-cf-cache.sh                 # 默认 purge everything
#   bash scripts/purge-cf-cache.sh --files URL...  # 仅 purge 指定 URL
# ---
# 示例：
#   bash scripts/purge-cf-cache.sh
#   bash scripts/purge-cf-cache.sh --files https://laodao-ai.com/posts/hello/

set -euo pipefail

# 1. 定位 .env：脚本所在目录的父目录（blog/.env）
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="$SCRIPT_DIR/../.env"

if [[ -f "$ENV_FILE" ]]; then
  # shellcheck disable=SC1090
  set -a; source "$ENV_FILE"; set +a
  echo "✓ 加载 $ENV_FILE"
else
  echo "ℹ .env 不存在，仅依赖 shell env vars"
fi

# 2. 校验必要变量
: "${CF_API_TOKEN:?未设置 CF_API_TOKEN（参考 .env.example）}"
: "${CF_ZONE_ID_COM:?未设置 CF_ZONE_ID_COM（参考 .env.example）}"

# 3. 构造 payload
PAYLOAD='{"purge_everything":true}'
if [[ "${1:-}" == "--files" ]]; then
  shift
  if [[ $# -eq 0 ]]; then
    echo "❌ --files 需要至少 1 个 URL" >&2; exit 1
  fi
  # 拼 JSON files array
  files_json=$(printf '"%s",' "$@" | sed 's/,$//')
  PAYLOAD="{\"files\":[${files_json}]}"
fi

echo "→ purge target: $PAYLOAD"

# 4. 调 API
response=$(curl -sS -X POST \
  "https://api.cloudflare.com/client/v4/zones/$CF_ZONE_ID_COM/purge_cache" \
  -H "Authorization: Bearer $CF_API_TOKEN" \
  -H "Content-Type: application/json" \
  --data "$PAYLOAD")

echo "$response" | python3 -m json.tool 2>/dev/null || echo "$response"

# 5. 校验 success
if echo "$response" | grep -q '"success":true'; then
  echo "✓ Cloudflare cache purged for laodao-ai.com"
else
  echo "❌ Cloudflare purge failed" >&2
  exit 1
fi

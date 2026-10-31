#!/usr/bin/env bash
# POST a Grok Bot task (JSON on stdin) to the Grok Bot webhook and print the HTTP status.
set -euo pipefail

URL="${GROK_BOT_WEBHOOK_URL:-https://api2.cursor.sh/automations/webhook/5cedd7c8-e448-5bae-ba90-7b4b29197e31}"

if [[ -z "${GROK_BOT_SENDER_KEY:-}" ]]; then
  echo "ERROR: GROK_BOT_SENDER_KEY is not set." >&2
  exit 2
fi

body="$(cat)"
if ! printf '%s' "$body" | jq -e '(.source|type=="string") and (.task|type=="string" and length>0) and (.context|type=="string") and (.priority|type=="string")' >/dev/null; then
  echo "ERROR: body must be JSON with string fields source, task (non-empty), context, priority." >&2
  exit 3
fi

resp="$(mktemp)"
trap 'rm -f "$resp"' EXIT
status="$(curl -sS -o "$resp" -w '%{http_code}' -X POST "$URL" \
  -H "Authorization: Bearer ${GROK_BOT_SENDER_KEY}" \
  -H 'Content-Type: application/json' \
  --data-binary "$body" || true)"

echo "HTTP_STATUS=${status:-000}"
echo "RESPONSE_BODY:"
cat "$resp"; echo
[[ "$status" =~ ^2 ]]

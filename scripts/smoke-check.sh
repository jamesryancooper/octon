#!/usr/bin/env bash
set -euo pipefail

TIMEOUT="${SMOKE_TIMEOUT:-10}"
EXPECT="${SMOKE_EXPECT:-}"

if [[ -z "${SMOKE_URLS:-}" ]]; then
  echo "SMOKE_URLS env var is required (space or newline separated)" >&2
  exit 1
fi

IFS=$'\n' read -r -d '' -a URLS < <(printf '%s\n' "$SMOKE_URLS" | tr ' ' '\n' | sed '/^$/d' && printf '\0')

FAIL=0
SUMMARY="Smoke check summary (timeout=${TIMEOUT}s)\n"

for url in "${URLS[@]}"; do
  code=$(curl -s -o /dev/null -w '%{http_code}' --max-time "$TIMEOUT" "$url" || true)
  if [[ "$code" -ge 200 && "$code" -lt 400 ]]; then
    if [[ -n "$EXPECT" ]]; then
      if curl -fsS --max-time "$TIMEOUT" "$url" | grep -qi "$EXPECT"; then
        SUMMARY+="✔ [$code] $url (content contains: $EXPECT)\n"
      else
        SUMMARY+="✖ [$code] $url (missing content: $EXPECT)\n"
        FAIL=1
      fi
    else
      SUMMARY+="✔ [$code] $url\n"
    fi
  else
    SUMMARY+="✖ [$code] $url\n"
    FAIL=1
  fi
done

echo -e "$SUMMARY" | tee smoke-summary.txt
exit $FAIL



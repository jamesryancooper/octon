#!/usr/bin/env bash
# context-budget.sh - Emit deterministic native context budget state.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Enforce deny-by-default policy at runtime for this shell service.
source "$SCRIPT_DIR/../../../_ops/scripts/enforce-deny-by-default.sh"
octon_enforce_service_policy "agent-platform" "$0" "$@"


limit=""
used=""
unit="tokens"
report=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --limit)
      limit="${2:-}"
      shift 2
      ;;
    --used)
      used="${2:-}"
      shift 2
      ;;
    --unit)
      unit="${2:-tokens}"
      shift 2
      ;;
    --report)
      report="${2:-}"
      shift 2
      ;;
    *)
      echo "Unknown argument: $1" >&2
      exit 2
      ;;
  esac
done

if [[ -z "$limit" || -z "$used" ]]; then
  echo "Usage: $0 --limit <int> --used <int> [--unit tokens|characters] [--report <path>]" >&2
  exit 2
fi

if ! [[ "$limit" =~ ^[0-9]+$ && "$used" =~ ^[0-9]+$ ]]; then
  echo "limit and used must be non-negative integers" >&2
  exit 2
fi

if (( limit == 0 )); then
  echo "limit must be > 0" >&2
  exit 2
fi

if (( used > limit )); then
  echo "used cannot exceed limit" >&2
  exit 2
fi

percent=$(( used * 100 / limit ))
state="ok"
if (( percent >= 90 )); then
  state="flush-required"
elif (( percent >= 80 )); then
  state="warning"
fi

json_output=$(cat <<JSON
{
  "interop_contract_version": "1.0.0",
  "mode": "native",
  "budget_limit": $limit,
  "budget_used": $used,
  "budget_unit": "$unit",
  "budget_used_percent": $percent,
  "warning_threshold_percent": 80,
  "flush_threshold_percent": 90,
  "threshold_state": "$state"
}
JSON
)

echo "$json_output"

if [[ -n "$report" ]]; then
  mkdir -p "$(dirname "$report")"
  cat > "$report" <<MD
# Context Budget Report

- Interop contract version: \`1.0.0\`
- Mode: \`native\`
- Budget used: \`${used}/${limit} ${unit}\`
- Budget used percent: \`${percent}%\`
- Threshold state: \`${state}\`
MD
fi

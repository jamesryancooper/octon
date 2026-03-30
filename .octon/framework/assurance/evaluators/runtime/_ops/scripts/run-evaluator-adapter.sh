#!/usr/bin/env bash
set -euo pipefail

if ! command -v yq >/dev/null 2>&1; then
  echo "yq is required" >&2
  exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "jq is required" >&2
  exit 1
fi

adapter_manifest=""
policy=""
schema=""
diff=""
output=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --adapter-manifest) adapter_manifest="$2"; shift 2 ;;
    --policy) policy="$2"; shift 2 ;;
    --schema) schema="$2"; shift 2 ;;
    --diff) diff="$2"; shift 2 ;;
    --output) output="$2"; shift 2 ;;
    *) echo "unknown argument: $1" >&2; exit 1 ;;
  esac
done

[[ -n "$adapter_manifest" && -n "$policy" && -n "$schema" && -n "$diff" && -n "$output" ]] || {
  echo "missing required arguments" >&2
  exit 1
}

script_ref="$(yq -r '.script_ref // ""' "$adapter_manifest")"
adapter_id="$(yq -r '.adapter_id // ""' "$adapter_manifest")"
provider="$(yq -r '.provider // ""' "$adapter_manifest")"
[[ -n "$script_ref" && -n "$adapter_id" && -n "$provider" ]] || {
  echo "invalid adapter manifest: $adapter_manifest" >&2
  exit 1
}

tmp_output="$(mktemp)"
bash "$script_ref" --policy "$policy" --schema "$schema" --diff "$diff" --output "$tmp_output"

jq \
  --arg adapter_id "$adapter_id" \
  --arg adapter_ref "$adapter_manifest" \
  --arg provider "$provider" \
  '.meta = ((.meta // {}) + { evaluator_adapter_id: $adapter_id, evaluator_adapter_ref: $adapter_ref, provider: $provider })' \
  "$tmp_output" > "$output"

rm -f "$tmp_output"
printf '%s\n' "$output"

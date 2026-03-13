#!/usr/bin/env bash
# memory-clues.sh - Deterministic clue extraction for pre-retrieval steering.

set -o pipefail

query=""
max_clues="3"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --query)
      query="${2:-}"
      shift 2
      ;;
    --max-clues)
      max_clues="${2:-3}"
      shift 2
      ;;
    *)
      echo "Unknown argument: $1" >&2
      exit 2
      ;;
  esac
done

if [[ -z "$query" ]]; then
  echo '{"ok":false,"error":{"code":"InputValidationError","message":"--query is required."}}'
  exit 0
fi

if ! [[ "$max_clues" =~ ^[0-9]+$ ]] || (( max_clues < 1 )); then
  max_clues="3"
fi

clues_json="$({
  printf '%s' "$query" \
    | tr '[:upper:]' '[:lower:]' \
    | tr -c '[:alnum:]' ' ' \
    | awk '{for(i=1;i<=NF;i++) if(length($i)>=4) print $i}' \
    | awk '!seen[$0]++' \
    | head -n "$max_clues"
} | jq -R . | jq -s '.')"

augmented_query="$query"
if [[ "$(jq 'length' <<<"$clues_json")" != "0" ]]; then
  clue_tail="$(jq -r 'join(" ")' <<<"$clues_json")"
  augmented_query="$query $clue_tail"
fi

jq -n \
  --argjson clues "$clues_json" \
  --arg augmented "$augmented_query" \
  '{ok:true,clues:$clues,augmented_query:$augmented}'

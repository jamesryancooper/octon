#!/usr/bin/env bash
# keyword.sh - Deterministic keyword signal scoring over chunks.jsonl.

set -o pipefail

query=""
snapshot=""
top_k="50"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --query)
      query="${2:-}"
      shift 2
      ;;
    --snapshot)
      snapshot="${2:-}"
      shift 2
      ;;
    --top-k)
      top_k="${2:-50}"
      shift 2
      ;;
    *)
      echo "Unknown argument: $1" >&2
      exit 2
      ;;
  esac
done

if [[ -z "$query" || -z "$snapshot" ]]; then
  echo '{"ok":false,"signal":"keyword","error":{"code":"InputValidationError","message":"--query and --snapshot are required."}}'
  exit 0
fi

if ! [[ "$top_k" =~ ^[0-9]+$ ]] || (( top_k < 1 )); then
  top_k="50"
fi

keyword_file="$snapshot/keyword.json"
chunks_file="$snapshot/chunks.jsonl"

if [[ ! -f "$keyword_file" ]]; then
  echo '{"ok":false,"signal":"keyword","error":{"code":"MissingSignalArtifactError","message":"keyword.json not found for snapshot."}}'
  exit 0
fi

if [[ ! -f "$chunks_file" ]]; then
  echo '{"ok":false,"signal":"keyword","error":{"code":"MissingSignalArtifactError","message":"chunks.jsonl not found for snapshot."}}'
  exit 0
fi

terms_json="$({
  printf '%s' "$query" \
    | tr '[:upper:]' '[:lower:]' \
    | tr -c '[:alnum:]' ' ' \
    | awk '{for(i=1;i<=NF;i++) if(length($i)>1) print $i}' \
    | sort -u
} | jq -R . | jq -s '.')"

if [[ "$(jq 'length' <<<"$terms_json")" == "0" ]]; then
  echo '{"ok":true,"signal":"keyword","candidates":[],"warnings":["No usable query terms after normalization."]}'
  exit 0
fi

candidates_json="$(jq -s \
  --argjson terms "$terms_json" \
  --argjson topk "$top_k" '
  map(select(type == "object"))
  | map(
      . as $row
      | (($row.text // "") | ascii_downcase) as $text
      | ([ $terms[] as $t | if ($text | contains($t)) then 1 else 0 end ] | add // 0) as $kw
      | {
          chunk_id: ($row.chunk_id // ""),
          doc_id: ($row.doc_id // $row.document_id // (($row.chunk_id // "") | split("#")[0]) // "_unknown"),
          locator: ($row.locator // $row.path // (($row.doc_id // $row.document_id // "_unknown") + "#" + ($row.chunk_id // "_unknown"))),
          score: ($kw | tonumber)
        }
    )
  | map(select((.chunk_id | length) > 0 and (.score > 0)))
  | sort_by(-.score, .chunk_id)
  | .[:$topk]
' "$chunks_file")"

jq -n \
  --arg signal "keyword" \
  --argjson candidates "$candidates_json" \
  '{ok:true,signal:$signal,candidates:$candidates}'

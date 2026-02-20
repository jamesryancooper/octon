#!/usr/bin/env bash
# semantic.sh - Agent-native semantic scoring over candidate chunks.

set -o pipefail

query=""
snapshot=""
input_candidates_json="[]"
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
    --input-candidates-json)
      input_candidates_json="${2:-[]}"
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
  echo '{"ok":false,"signal":"semantic","error":{"code":"InputValidationError","message":"--query and --snapshot are required."}}'
  exit 0
fi

if ! [[ "$top_k" =~ ^[0-9]+$ ]] || (( top_k < 1 )); then
  top_k="50"
fi

if [[ "${HARMONY_QUERY_SEMANTIC_AVAILABLE:-true}" != "true" ]]; then
  echo '{"ok":false,"signal":"semantic","error":{"code":"SemanticScoringUnavailableError","message":"Semantic scoring is unavailable in this runtime."}}'
  exit 0
fi

chunks_file="$snapshot/chunks.jsonl"
if [[ ! -f "$chunks_file" ]]; then
  echo '{"ok":false,"signal":"semantic","error":{"code":"MissingSignalArtifactError","message":"chunks.jsonl not found for semantic scoring."}}'
  exit 0
fi

if ! jq -e . >/dev/null 2>&1 <<<"$input_candidates_json"; then
  echo '{"ok":false,"signal":"semantic","error":{"code":"InputValidationError","message":"--input-candidates-json must be valid JSON."}}'
  exit 0
fi

terms_json="$({
  printf '%s' "$query" \
    | tr '[:upper:]' '[:lower:]' \
    | tr -c '[:alnum:]' ' ' \
    | awk '{for(i=1;i<=NF;i++) if(length($i)>1) print $i}' \
    | sort -u
} | jq -R . | jq -s '.')"

query_lc="$(printf '%s' "$query" | tr '[:upper:]' '[:lower:]')"

candidates_json="$(jq -n \
  --argjson seed "$input_candidates_json" \
  --argjson terms "$terms_json" \
  --arg query_lc "$query_lc" \
  --argjson topk "$top_k" \
  --slurpfile chunks "$chunks_file" '
  ($chunks | map(select(type == "object"))) as $rows
  | ($seed | map(.chunk_id // empty) | map(select(type == "string" and length > 0)) | unique) as $seed_ids
  | (if ($seed_ids | length) > 0
      then $rows | map(select((.chunk_id // "") as $id | $seed_ids | index($id)))
      else $rows
     end) as $pool
  | $pool
  | map(
      . as $row
      | (($row.text // "") | ascii_downcase) as $txt
      | ([ $terms[] as $t | if ($txt | contains($t)) then 1 else 0 end ] | add // 0) as $overlap
      | (if ($query_lc | length) > 2 and ($txt | contains($query_lc)) then 2 else 0 end) as $phrase
      | {
          chunk_id: ($row.chunk_id // ""),
          doc_id: ($row.doc_id // $row.document_id // (($row.chunk_id // "") | split("#")[0]) // "_unknown"),
          locator: ($row.locator // $row.path // (($row.doc_id // $row.document_id // "_unknown") + "#" + ($row.chunk_id // "_unknown"))),
          score: (($overlap + $phrase) | tonumber)
        }
    )
  | map(select((.chunk_id | length) > 0 and (.score > 0)))
  | sort_by(-.score, .chunk_id)
  | .[:$topk]
')"

jq -n \
  --arg signal "semantic" \
  --argjson candidates "$candidates_json" \
  '{ok:true,signal:$signal,candidates:$candidates}'

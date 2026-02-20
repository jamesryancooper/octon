#!/usr/bin/env bash
# hierarchical.sh - Hierarchical summary-tree route candidate expansion.

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
  echo '{"ok":false,"route":"hierarchical","error":{"code":"InputValidationError","message":"--query and --snapshot are required."}}'
  exit 0
fi

if ! [[ "$top_k" =~ ^[0-9]+$ ]] || (( top_k < 1 )); then
  top_k="50"
fi

summary_file=""
if [[ -f "$snapshot/hierarchical/summaries.jsonl" ]]; then
  summary_file="$snapshot/hierarchical/summaries.jsonl"
elif [[ -f "$snapshot/summaries.jsonl" ]]; then
  summary_file="$snapshot/summaries.jsonl"
fi

chunks_file="$snapshot/chunks.jsonl"

if [[ -z "$summary_file" ]]; then
  echo '{"ok":false,"route":"hierarchical","error":{"code":"MissingSignalArtifactError","message":"hierarchical summaries artifact not found."}}'
  exit 0
fi

if [[ ! -f "$chunks_file" ]]; then
  echo '{"ok":false,"route":"hierarchical","error":{"code":"MissingSignalArtifactError","message":"chunks.jsonl not found for hierarchical route."}}'
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
  echo '{"ok":true,"route":"hierarchical","candidates":[],"warnings":["No usable query terms for hierarchical route."]}'
  exit 0
fi

candidates_json="$(jq -n \
  --argjson terms "$terms_json" \
  --argjson topk "$top_k" \
  --slurpfile summaries "$summary_file" \
  --slurpfile chunks "$chunks_file" '
  ($chunks | map(select(type == "object"))) as $rows
  | ($rows | reduce .[] as $r ({}; .[$r.chunk_id] = $r)) as $index
  | ($summaries | map(select(type == "object"))) as $s
  | (
      reduce $s[] as $node ({};
        (($node.text // $node.summary // "") | ascii_downcase) as $body
        | ([ $terms[] as $t | if ($body | contains($t)) then 1 else 0 end ] | add // 0) as $overlap
        | if $overlap <= 0 then
            .
          else
            (($node.leaf_chunk_ids // $node.chunk_ids // $node.chunks // []) | map(select(type == "string" and length > 0))) as $leaves
            | reduce $leaves[] as $cid (.;
                .[$cid] = ((.[$cid] // 0) + ($overlap | tonumber))
              )
          end
      )
    ) as $score_map
  | ($score_map | to_entries
      | map(select((.key | length) > 0 and (.value > 0)))
      | map(
          ($index[.key] // {}) as $chunk
          | {
              chunk_id: .key,
              doc_id: ($chunk.doc_id // $chunk.document_id // (.key | split("#")[0]) // "_unknown"),
              locator: ($chunk.locator // $chunk.path // (($chunk.doc_id // $chunk.document_id // "_unknown") + "#" + .key)),
              score: (.value | tonumber)
            }
        )
      | sort_by(-.score, .chunk_id)
      | .[:$topk]
    )
')"

jq -n \
  --arg route "hierarchical" \
  --argjson candidates "$candidates_json" \
  '{ok:true,route:$route,candidates:$candidates}'

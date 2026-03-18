#!/usr/bin/env bash
# graph.sh - Deterministic graph expansion over links.jsonl.

set -o pipefail

snapshot=""
seed_json="[]"
top_k="50"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --snapshot)
      snapshot="${2:-}"
      shift 2
      ;;
    --seed-json)
      seed_json="${2:-[]}"
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

if [[ -z "$snapshot" ]]; then
  echo '{"ok":false,"signal":"graph","error":{"code":"InputValidationError","message":"--snapshot is required."}}'
  exit 0
fi

if ! [[ "$top_k" =~ ^[0-9]+$ ]] || (( top_k < 1 )); then
  top_k="50"
fi

links_file="$snapshot/links.jsonl"
chunks_file="$snapshot/chunks.jsonl"

if [[ ! -f "$links_file" ]]; then
  echo '{"ok":false,"signal":"graph","error":{"code":"MissingSignalArtifactError","message":"links.jsonl not found for snapshot."}}'
  exit 0
fi

if [[ ! -f "$chunks_file" ]]; then
  echo '{"ok":false,"signal":"graph","error":{"code":"MissingSignalArtifactError","message":"chunks.jsonl not found for snapshot."}}'
  exit 0
fi

if ! jq -e . >/dev/null 2>&1 <<<"$seed_json"; then
  echo '{"ok":false,"signal":"graph","error":{"code":"InputValidationError","message":"--seed-json must be valid JSON."}}'
  exit 0
fi

if [[ "$(jq 'length' <<<"$seed_json")" == "0" ]]; then
  echo '{"ok":true,"signal":"graph","candidates":[],"warnings":["No seed chunk IDs provided for graph expansion."]}'
  exit 0
fi

# Candidate extraction and graph scoring are deterministic.
candidates_json="$(jq -n \
  --argjson seeds "$seed_json" \
  --argjson topk "$top_k" \
  --slurpfile links "$links_file" \
  --slurpfile chunks "$chunks_file" '
  ($seeds | map(select(type == "string" and length > 0))) as $seed_ids
  | ($seed_ids | reduce .[] as $s ({}; .[$s] = true)) as $seed_set
  | (($links | map(select(type == "object")))
      | reduce .[] as $e ({};
          ($e.src // $e.source // "") as $src
          | ($e.dst // $e.target // "") as $dst
          | ($e.weight // 1) as $w
          | if (($src | length) > 0) and (($dst | length) > 0) and ($seed_set[$src] == true) then
              .[$dst] = ((.[$dst] // 0) + ($w | tonumber))
            else
              .
            end
        )
    ) as $score_map
  | ($chunks | map(select(type == "object"))) as $rows
  | ($rows | reduce .[] as $r ({}; .[$r.chunk_id] = $r)) as $chunk_index
  | ($score_map | to_entries
      | map(select((.key | length) > 0 and (.value > 0)))
      | map(
          ($chunk_index[.key] // {}) as $chunk
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
  --arg signal "graph" \
  --argjson candidates "$candidates_json" \
  '{ok:true,signal:$signal,candidates:$candidates}'

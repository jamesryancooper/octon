#!/usr/bin/env bash
# cite.sh - Build citations and evidence excerpts from fused candidates.

set -o pipefail

snapshot=""
candidates_json='[]'
max_excerpts="8"
max_chars="320"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --snapshot)
      snapshot="${2:-}"
      shift 2
      ;;
    --candidates-json)
      candidates_json="${2:-[]}"
      shift 2
      ;;
    --max-excerpts)
      max_excerpts="${2:-8}"
      shift 2
      ;;
    --max-chars)
      max_chars="${2:-320}"
      shift 2
      ;;
    *)
      echo "Unknown argument: $1" >&2
      exit 2
      ;;
  esac
done

if [[ -z "$snapshot" ]]; then
  echo '{"ok":false,"error":{"code":"InputValidationError","message":"--snapshot is required."}}'
  exit 0
fi

if ! [[ "$max_excerpts" =~ ^[0-9]+$ ]] || (( max_excerpts < 1 )); then
  max_excerpts="8"
fi

if ! [[ "$max_chars" =~ ^[0-9]+$ ]] || (( max_chars < 16 )); then
  max_chars="320"
fi

if ! jq -e . >/dev/null 2>&1 <<<"$candidates_json"; then
  echo '{"ok":false,"error":{"code":"InputValidationError","message":"--candidates-json must be valid JSON."}}'
  exit 0
fi

chunks_file="$snapshot/chunks.jsonl"
if [[ ! -f "$chunks_file" ]]; then
  echo '{"ok":false,"error":{"code":"MissingSignalArtifactError","message":"chunks.jsonl not found for citation assembly."}}'
  exit 0
fi

result_json="$(jq -n \
  --argjson candidates "$candidates_json" \
  --argjson maxExcerpts "$max_excerpts" \
  --argjson maxChars "$max_chars" \
  --slurpfile chunks "$chunks_file" '
  ($chunks | map(select(type == "object"))) as $rows
  | ($rows | reduce .[] as $r ({}; .[$r.chunk_id] = $r)) as $index
  | ($candidates | .[:$maxExcerpts]) as $trimmed
  | (($trimmed | map(.score) | max) // 0) as $max_score
  | {
      citations: (
        $trimmed
        | map(
            ($index[.chunk_id] // {}) as $chunk
            | {
                chunk_id: .chunk_id,
                locator: (
                  .locator
                  // $chunk.locator
                  // $chunk.path
                  // (($chunk.doc_id // .doc_id // "_unknown") + "#" + .chunk_id)
                ),
                confidence: (
                  if $max_score > 0 then
                    ((.score / $max_score) | if . < 0 then 0 elif . > 1 then 1 else . end)
                  else
                    0
                  end
                )
              }
          )
      ),
      evidence: (
        $trimmed
        | map(
            ($index[.chunk_id] // {}) as $chunk
            | (($chunk.text // "") | tostring) as $text
            | {
                chunk_id: .chunk_id,
                locator: (
                  .locator
                  // $chunk.locator
                  // $chunk.path
                  // (($chunk.doc_id // .doc_id // "_unknown") + "#" + .chunk_id)
                ),
                excerpt: (
                  if ($text | length) > $maxChars then
                    $text[0:$maxChars]
                  else
                    $text
                  end
                )
              }
          )
      )
    }
')"

jq -n --argjson result "$result_json" '{ok:true,citations:$result.citations,evidence:$result.evidence}'

#!/usr/bin/env bash
# evaluate-baseline.sh - Run baseline query evaluation and emit markdown report.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SERVICE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
DATASET="$SERVICE_DIR/fixtures/eval-baseline.jsonl"
SNAPSHOT_ROOT="/tmp/octon-query-indexes"
REPORT_PATH=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dataset)
      DATASET="${2:-}"
      shift 2
      ;;
    --snapshot-root)
      SNAPSHOT_ROOT="${2:-}"
      shift 2
      ;;
    --report)
      REPORT_PATH="${2:-}"
      shift 2
      ;;
    *)
      echo "Unknown argument: $1" >&2
      exit 2
      ;;
  esac
done

if [[ -z "$REPORT_PATH" ]]; then
  repo_root="$(git -C "$SCRIPT_DIR" rev-parse --show-toplevel 2>/dev/null || pwd)"
  REPORT_PATH="$repo_root/.octon/output/reports/analysis/$(date +%F)-query-baseline.md"
fi

if [[ ! -f "$DATASET" ]]; then
  echo "Dataset not found: $DATASET" >&2
  exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "jq is required" >&2
  exit 6
fi

bash "$SCRIPT_DIR/make-test-snapshot.sh" --output-root "$SNAPSHOT_ROOT" >/dev/null

tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT
lat_file="$tmp_dir/latencies.txt"
rows_file="$tmp_dir/rows.md"

cases=0
hits=0
mrr_sum="0"
ask_total=0
ask_backed=0
ask_phrase_hits=0
locator_total=0
locator_valid=0

while IFS= read -r line || [[ -n "$line" ]]; do
  [[ -z "${line//[[:space:]]/}" ]] && continue

  case_id="$(jq -r '.id // "unknown"' <<<"$line")"
  expected_chunk="$(jq -r '.expected_chunk_id // ""' <<<"$line")"
  expected_phrase="$(jq -r '.expected_phrase // ""' <<<"$line")"
  request_json="$(jq -c '.request' <<<"$line")"

  snapshot_hint="$(jq -r '.index.snapshot // ""' <<<"$request_json")"
  if [[ -n "$snapshot_hint" && ! -d "$snapshot_hint" ]]; then
    base="$(basename "$snapshot_hint")"
    if [[ -d "$SNAPSHOT_ROOT/$base" ]]; then
      request_json="$(jq -c --arg snap "$SNAPSHOT_ROOT/$base" '.index.snapshot = $snap' <<<"$request_json")"
    fi
  fi

  cmd="$(jq -r '.command // ""' <<<"$request_json")"
  output_file="$tmp_dir/$case_id.json"
  printf '%s' "$request_json" | bash "$SCRIPT_DIR/query.sh" >"$output_file"

  status="$(jq -r '.status // "error"' "$output_file")"
  latency="$(jq -r '.diagnostics.timings.total_ms // 0' "$output_file")"
  echo "$latency" >> "$lat_file"

  rank="$(jq -r --arg cid "$expected_chunk" '((.candidates | map(.chunk_id) | index($cid)) // -1) + 1' "$output_file")"
  if (( rank > 0 && rank <= 20 )); then
    hits=$((hits + 1))
  fi

  if (( rank > 0 )); then
    contrib="$(awk -v r="$rank" 'BEGIN{printf "%.6f", 1/r}')"
  else
    contrib="0"
  fi
  mrr_sum="$(awk -v a="$mrr_sum" -v b="$contrib" 'BEGIN{printf "%.6f", a+b}')"

  if [[ "$cmd" == "ask" ]]; then
    ask_total=$((ask_total + 1))
    answer_len="$(jq -r '(.answer // "") | length' "$output_file")"
    citation_len="$(jq -r '(.citations // []) | length' "$output_file")"
    if (( answer_len > 0 && citation_len > 0 )); then
      ask_backed=$((ask_backed + 1))
    fi

    if [[ -n "$expected_phrase" ]]; then
      if jq -er --arg phrase "$expected_phrase" '(.answer // "" | ascii_downcase) | contains($phrase | ascii_downcase)' "$output_file" >/dev/null; then
        ask_phrase_hits=$((ask_phrase_hits + 1))
      fi
    fi
  fi

  snapshot_path="$(jq -r '.index.snapshot' <<<"$request_json")"
  locator_file="$tmp_dir/$case_id.locators"
  jq -sr 'map(select(type=="object") | .locator // empty) | .[]' "$snapshot_path/chunks.jsonl" 2>/dev/null > "$locator_file" || true
  while IFS= read -r locator; do
    [[ -z "$locator" ]] && continue
    locator_total=$((locator_total + 1))
    if grep -Fxq "$locator" "$locator_file"; then
      locator_valid=$((locator_valid + 1))
    fi
  done < <(jq -r '.citations[].locator // empty' "$output_file")

  candidates_n="$(jq -r '(.candidates // []) | length' "$output_file")"
  citations_n="$(jq -r '(.citations // []) | length' "$output_file")"
  printf '| `%s` | `%s` | `%s` | `%s` | `%s` | `%s` | `%s` |\n' "$case_id" "$cmd" "$status" "$rank" "$candidates_n" "$citations_n" "$latency" >> "$rows_file"

  cases=$((cases + 1))
done < "$DATASET"

if (( cases == 0 )); then
  echo "No evaluation cases found in dataset." >&2
  exit 1
fi

recall_at_20="$(awk -v h="$hits" -v t="$cases" 'BEGIN{if(t==0)printf "0.0000"; else printf "%.4f", h/t}')"
mrr="$(awk -v s="$mrr_sum" -v t="$cases" 'BEGIN{if(t==0)printf "0.0000"; else printf "%.4f", s/t}')"

citation_completeness="$(awk -v b="$ask_backed" -v t="$ask_total" 'BEGIN{if(t==0)printf "1.0000"; else printf "%.4f", b/t}')"
answer_phrase_accuracy="$(awk -v p="$ask_phrase_hits" -v t="$ask_total" 'BEGIN{if(t==0)printf "0.0000"; else printf "%.4f", p/t}')"
locator_validity="$(awk -v v="$locator_valid" -v t="$locator_total" 'BEGIN{if(t==0)printf "1.0000"; else printf "%.4f", v/t}')"

p95="$(sort -n "$lat_file" | awk '
  { a[++n]=$1 }
  END {
    if (n==0) { print 0; exit }
    idx = int((n * 95 + 99) / 100)
    if (idx < 1) idx = 1
    if (idx > n) idx = n
    print a[idx]
  }
')"

mkdir -p "$(dirname "$REPORT_PATH")"
cat > "$REPORT_PATH" <<MD
# Query Baseline Report (Phase 3)

- Date: $(date +%F)
- Service: 'octon.service.query'
- Dataset: '$DATASET'
- Snapshot root: '$SNAPSHOT_ROOT'
- Cases: $cases

## Metrics

| Metric | Value |
|---|---:|
| Citation completeness (ask cases) | $citation_completeness |
| Citation locator validity | $locator_validity |
| Recall@20 | $recall_at_20 |
| MRR | $mrr |
| Answer phrase accuracy (ask cases) | $answer_phrase_accuracy |
| Latency p95 (ms) | $p95 |

## Case Results

| Case | Command | Status | Rank (expected chunk) | Candidates | Citations | Total ms |
|---|---|---|---:|---:|---:|---:|
$(cat "$rows_file")

## Notes

- Semantic signal latency is agent-bound and scales with candidate set size and model inference behavior.
- Deterministic stages: keyword, graph, fusion, citation.
- Run records emitted to '.octon/capabilities/runtime/services/_ops/state/runs/query/' include span evidence:
  - 'service.query.ask'
  - 'service.query.retrieve'
  - 'service.query.explain'
MD

jq -n \
  --arg report "$REPORT_PATH" \
  --arg recall_at_20 "$recall_at_20" \
  --arg mrr "$mrr" \
  --arg citation_completeness "$citation_completeness" \
  --arg locator_validity "$locator_validity" \
  --arg answer_phrase_accuracy "$answer_phrase_accuracy" \
  --arg p95_ms "$p95" \
  '{
    report_path: $report,
    metrics: {
      recall_at_20: ($recall_at_20 | tonumber),
      mrr: ($mrr | tonumber),
      citation_completeness: ($citation_completeness | tonumber),
      locator_validity: ($locator_validity | tonumber),
      answer_phrase_accuracy: ($answer_phrase_accuracy | tonumber),
      latency_p95_ms: ($p95_ms | tonumber)
    }
  }'

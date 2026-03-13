#!/usr/bin/env bash
# evaluate-routes.sh - Route-specific A/B evaluation vs flat baseline for Phase 4 gates.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SERVICE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
DATASET="$SERVICE_DIR/fixtures/eval-routes.jsonl"
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
  REPORT_PATH="$repo_root/.octon/output/reports/analysis/$(date +%F)-query-route-eval.md"
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
flat_lat_file="$tmp_dir/flat-latencies.txt"
route_lat_file="$tmp_dir/route-latencies.txt"
metrics_tsv="$tmp_dir/metrics.tsv"
rows_file="$tmp_dir/rows.md"
route_summary_rows="$tmp_dir/route-summary.md"

p95_for_file() {
  local file="$1"
  if [[ ! -s "$file" ]]; then
    echo 0
    return
  fi
  sort -n "$file" | awk '
    { a[++n]=$1 }
    END {
      if (n==0) { print 0; exit }
      idx = int((n * 95 + 99) / 100)
      if (idx < 1) idx = 1
      if (idx > n) idx = n
      print a[idx]
    }
  '
}

remap_snapshot() {
  local request_json="$1"
  local snapshot_hint
  snapshot_hint="$(jq -r '.index.snapshot // ""' <<<"$request_json")"
  if [[ -n "$snapshot_hint" && ! -d "$snapshot_hint" ]]; then
    local base
    base="$(basename "$snapshot_hint")"
    if [[ -d "$SNAPSHOT_ROOT/$base" ]]; then
      request_json="$(jq -c --arg snap "$SNAPSHOT_ROOT/$base" '.index.snapshot = $snap' <<<"$request_json")"
    fi
  fi
  printf '%s' "$request_json"
}

calc_rank() {
  local output_file="$1"
  local expected_chunk="$2"
  jq -r --arg cid "$expected_chunk" '((.candidates | map(.chunk_id) | index($cid)) // -1) + 1' "$output_file"
}

cases=0
while IFS= read -r line || [[ -n "$line" ]]; do
  [[ -z "${line//[[:space:]]/}" ]] && continue

  case_id="$(jq -r '.id // "unknown"' <<<"$line")"
  route_name="$(jq -r '.route // "unknown"' <<<"$line")"
  expected_chunk="$(jq -r '.expected_chunk_id // ""' <<<"$line")"
  flat_request="$(jq -c '.request_flat' <<<"$line")"
  route_request="$(jq -c '.request_route' <<<"$line")"

  flat_request="$(remap_snapshot "$flat_request")"
  route_request="$(remap_snapshot "$route_request")"

  flat_out="$tmp_dir/$case_id.flat.json"
  route_out="$tmp_dir/$case_id.route.json"
  printf '%s' "$flat_request" | bash "$SCRIPT_DIR/query.sh" >"$flat_out"
  printf '%s' "$route_request" | bash "$SCRIPT_DIR/query.sh" >"$route_out"

  flat_status="$(jq -r '.status // "error"' "$flat_out")"
  route_status="$(jq -r '.status // "error"' "$route_out")"
  flat_latency="$(jq -r '.diagnostics.timings.total_ms // 0' "$flat_out")"
  route_latency="$(jq -r '.diagnostics.timings.total_ms // 0' "$route_out")"
  echo "$flat_latency" >> "$flat_lat_file"
  echo "$route_latency" >> "$route_lat_file"

  flat_rank="$(calc_rank "$flat_out" "$expected_chunk")"
  route_rank="$(calc_rank "$route_out" "$expected_chunk")"
  route_applied="$(jq -r 'if .diagnostics.route_applied == true then 1 else 0 end' "$route_out")"
  route_citations="$(jq -r '(.citations // []) | length' "$route_out")"
  citation_backed=0
  if (( route_citations > 0 )); then
    citation_backed=1
  fi

  route_locator_total_case=0
  route_locator_valid_case=0
  route_snapshot="$(jq -r '.index.snapshot' <<<"$route_request")"
  locator_file="$tmp_dir/$case_id.route.locators"
  jq -sr 'map(select(type=="object") | .locator // empty) | .[]' "$route_snapshot/chunks.jsonl" 2>/dev/null > "$locator_file" || true
  while IFS= read -r locator; do
    [[ -z "$locator" ]] && continue
    route_locator_total_case=$((route_locator_total_case + 1))
    if grep -Fxq "$locator" "$locator_file"; then
      route_locator_valid_case=$((route_locator_valid_case + 1))
    fi
  done < <(jq -r '.citations[].locator // empty' "$route_out")

  printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
    "$route_name" "$flat_rank" "$route_rank" "$flat_latency" "$route_latency" "$route_applied" "$citation_backed" "$route_locator_total_case" "$route_locator_valid_case" >> "$metrics_tsv"

  printf '| `%s` | `%s` | `%s` | `%s` | `%s` | `%s` | `%s` | `%s` | `%s` |\n' \
    "$case_id" "$route_name" "$flat_rank" "$route_rank" "$flat_status" "$route_status" "$route_applied" "$flat_latency" "$route_latency" >> "$rows_file"

  cases=$((cases + 1))
done < "$DATASET"

if (( cases == 0 )); then
  echo "No route evaluation cases found in dataset." >&2
  exit 1
fi

flat_hits="$(awk -F'\t' '{if($2>0 && $2<=20) h++} END{print h+0}' "$metrics_tsv")"
route_hits="$(awk -F'\t' '{if($3>0 && $3<=20) h++} END{print h+0}' "$metrics_tsv")"
flat_mrr_sum="$(awk -F'\t' '{if($2>0) s+=(1/$2)} END{printf "%.6f", s+0}' "$metrics_tsv")"
route_mrr_sum="$(awk -F'\t' '{if($3>0) s+=(1/$3)} END{printf "%.6f", s+0}' "$metrics_tsv")"
route_used_count="$(awk -F'\t' '{s+=$6} END{print s+0}' "$metrics_tsv")"
route_citation_backed="$(awk -F'\t' '{s+=$7} END{print s+0}' "$metrics_tsv")"
route_locator_total="$(awk -F'\t' '{s+=$8} END{print s+0}' "$metrics_tsv")"
route_locator_valid="$(awk -F'\t' '{s+=$9} END{print s+0}' "$metrics_tsv")"

flat_recall_at_20="$(awk -v h="$flat_hits" -v t="$cases" 'BEGIN{if(t==0)printf "0.0000"; else printf "%.4f", h/t}')"
route_recall_at_20="$(awk -v h="$route_hits" -v t="$cases" 'BEGIN{if(t==0)printf "0.0000"; else printf "%.4f", h/t}')"
flat_mrr="$(awk -v s="$flat_mrr_sum" -v t="$cases" 'BEGIN{if(t==0)printf "0.0000"; else printf "%.4f", s/t}')"
route_mrr="$(awk -v s="$route_mrr_sum" -v t="$cases" 'BEGIN{if(t==0)printf "0.0000"; else printf "%.4f", s/t}')"
route_used_rate="$(awk -v h="$route_used_count" -v t="$cases" 'BEGIN{if(t==0)printf "0.0000"; else printf "%.4f", h/t}')"
route_citation_completeness="$(awk -v h="$route_citation_backed" -v t="$cases" 'BEGIN{if(t==0)printf "0.0000"; else printf "%.4f", h/t}')"
route_locator_validity="$(awk -v v="$route_locator_valid" -v t="$route_locator_total" 'BEGIN{if(t==0)printf "1.0000"; else printf "%.4f", v/t}')"

flat_p95="$(p95_for_file "$flat_lat_file")"
route_p95="$(p95_for_file "$route_lat_file")"

overall_gate="pass"
while IFS= read -r route_name; do
  [[ -z "$route_name" ]] && continue

  route_rows="$tmp_dir/${route_name}.metrics.tsv"
  awk -F'\t' -v route="$route_name" '$1==route' "$metrics_tsv" > "$route_rows"
  route_cases="$(awk 'END{print NR+0}' "$route_rows")"

  flat_hits_r="$(awk -F'\t' '{if($2>0 && $2<=20) h++} END{print h+0}' "$route_rows")"
  route_hits_r="$(awk -F'\t' '{if($3>0 && $3<=20) h++} END{print h+0}' "$route_rows")"
  flat_mrr_sum_r="$(awk -F'\t' '{if($2>0) s+=(1/$2)} END{printf "%.6f", s+0}' "$route_rows")"
  route_mrr_sum_r="$(awk -F'\t' '{if($3>0) s+=(1/$3)} END{printf "%.6f", s+0}' "$route_rows")"
  route_used_count_r="$(awk -F'\t' '{s+=$6} END{print s+0}' "$route_rows")"
  route_citation_backed_r="$(awk -F'\t' '{s+=$7} END{print s+0}' "$route_rows")"
  route_locator_total_r="$(awk -F'\t' '{s+=$8} END{print s+0}' "$route_rows")"
  route_locator_valid_r="$(awk -F'\t' '{s+=$9} END{print s+0}' "$route_rows")"

  flat_recall_r="$(awk -v h="$flat_hits_r" -v t="$route_cases" 'BEGIN{if(t==0)printf "0.0000"; else printf "%.4f", h/t}')"
  route_recall_r="$(awk -v h="$route_hits_r" -v t="$route_cases" 'BEGIN{if(t==0)printf "0.0000"; else printf "%.4f", h/t}')"
  flat_mrr_r="$(awk -v s="$flat_mrr_sum_r" -v t="$route_cases" 'BEGIN{if(t==0)printf "0.0000"; else printf "%.4f", s/t}')"
  route_mrr_r="$(awk -v s="$route_mrr_sum_r" -v t="$route_cases" 'BEGIN{if(t==0)printf "0.0000"; else printf "%.4f", s/t}')"
  route_used_rate_r="$(awk -v h="$route_used_count_r" -v t="$route_cases" 'BEGIN{if(t==0)printf "0.0000"; else printf "%.4f", h/t}')"
  route_citation_r="$(awk -v h="$route_citation_backed_r" -v t="$route_cases" 'BEGIN{if(t==0)printf "0.0000"; else printf "%.4f", h/t}')"
  route_locator_r="$(awk -v v="$route_locator_valid_r" -v t="$route_locator_total_r" 'BEGIN{if(t==0)printf "1.0000"; else printf "%.4f", v/t}')"

  gate_applied="fail"
  gate_citation="fail"
  gate_locator="fail"
  gate_recall="fail"
  gate_mrr="fail"
  awk -v x="$route_used_rate_r" 'BEGIN{exit !(x >= 1.0)}' && gate_applied="pass" || true
  awk -v x="$route_citation_r" 'BEGIN{exit !(x >= 1.0)}' && gate_citation="pass" || true
  awk -v x="$route_locator_r" 'BEGIN{exit !(x >= 0.99)}' && gate_locator="pass" || true
  awk -v r="$route_recall_r" -v f="$flat_recall_r" 'BEGIN{exit !(r >= f)}' && gate_recall="pass" || true
  awk -v r="$route_mrr_r" -v f="$flat_mrr_r" 'BEGIN{exit !(r >= f)}' && gate_mrr="pass" || true

  route_gate="pass"
  for g in "$gate_applied" "$gate_citation" "$gate_locator" "$gate_recall" "$gate_mrr"; do
    if [[ "$g" != "pass" ]]; then
      route_gate="fail"
      break
    fi
  done

  if [[ "$route_gate" != "pass" ]]; then
    overall_gate="fail"
  fi

  printf '| `%s` | `%s` | `%s` | `%s` | `%s` | `%s` | `%s` | `%s` | `%s` | `%s` |\n' \
    "$route_name" "$route_cases" "$flat_recall_r" "$route_recall_r" "$flat_mrr_r" "$route_mrr_r" "$route_used_rate_r" "$route_citation_r" "$route_locator_r" "$route_gate" >> "$route_summary_rows"
done < <(awk -F'\t' '{print $1}' "$metrics_tsv" | sort -u)

mkdir -p "$(dirname "$REPORT_PATH")"
cat > "$REPORT_PATH" <<MD
# Query Route Evaluation Report (Phase 4)

- Date: $(date +%F)
- Service: 'octon.service.query'
- Dataset: '$DATASET'
- Snapshot root: '$SNAPSHOT_ROOT'
- Cases: $cases

## Aggregate A/B Metrics

| Metric | Flat | Route |
|---|---:|---:|
| Recall@20 | $flat_recall_at_20 | $route_recall_at_20 |
| MRR | $flat_mrr | $route_mrr |
| Latency p95 (ms) | $flat_p95 | $route_p95 |

## Aggregate Route Correctness Metrics

| Metric | Value |
|---|---:|
| Route applied rate | $route_used_rate |
| Citation completeness | $route_citation_completeness |
| Citation locator validity | $route_locator_validity |

## Route-Specific Gates

| Route | Cases | Flat Recall@20 | Route Recall@20 | Flat MRR | Route MRR | Applied Rate | Citation Completeness | Locator Validity | Gate |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---|
$(cat "$route_summary_rows")

## Overall Gate

- Overall result: **$overall_gate**
- Route-level pass criteria:
  - Route applied rate = 1.0000
  - Citation completeness = 1.0000
  - Citation locator validity >= 0.9900
  - Recall non-regression vs flat
  - MRR non-regression vs flat

## Case Results

| Case | Route | Flat rank | Route rank | Flat status | Route status | Route applied | Flat ms | Route ms |
|---|---|---:|---:|---|---|---:|---:|---:|
$(cat "$rows_file")
MD

jq -n \
  --arg report "$REPORT_PATH" \
  --arg overall_gate "$overall_gate" \
  --arg flat_recall "$flat_recall_at_20" \
  --arg route_recall "$route_recall_at_20" \
  --arg flat_mrr "$flat_mrr" \
  --arg route_mrr "$route_mrr" \
  --arg route_used "$route_used_rate" \
  --arg citation "$route_citation_completeness" \
  --arg locator "$route_locator_validity" \
  --arg flat_p95 "$flat_p95" \
  --arg route_p95 "$route_p95" \
  '{
    report_path: $report,
    overall_gate: $overall_gate,
    metrics: {
      flat_recall_at_20: ($flat_recall | tonumber),
      route_recall_at_20: ($route_recall | tonumber),
      flat_mrr: ($flat_mrr | tonumber),
      route_mrr: ($route_mrr | tonumber),
      route_applied_rate: ($route_used | tonumber),
      route_citation_completeness: ($citation | tonumber),
      route_locator_validity: ($locator | tonumber),
      flat_latency_p95_ms: ($flat_p95 | tonumber),
      route_latency_p95_ms: ($route_p95 | tonumber)
    }
  }'

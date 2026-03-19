#!/usr/bin/env bash
# test-filesystem-interfaces-slo.sh - latency/error SLO gate across filesystem-interfaces ops.

set -o pipefail

OCTON_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../../../" && pwd)"
RUNTIME_RUN="$OCTON_DIR/engine/runtime/run"
export OCTON_RUNTIME_PREFER_SOURCE="${OCTON_RUNTIME_PREFER_SOURCE:-1}"
FIXTURE_BUILDER="$OCTON_DIR/capabilities/runtime/services/_ops/scripts/build-filesystem-interfaces-benchmark-fixture.sh"
SLO_BUDGETS="$OCTON_DIR/capabilities/runtime/services/interfaces/filesystem-snapshot/contracts/slo-budgets.tsv"

profile="ci"
state_dir=".octon/generated/effective/capabilities/filesystem-snapshots"
samples_override=""
fixture_root=""
report_path=""
raw_out_path=""
summary_out_path=""
emit_report="1"
HAS_RG=false

if command -v rg >/dev/null 2>&1; then
  HAS_RG=true
fi

payload_has_regex() {
  local payload="$1"
  local pattern="$2"

  if [[ "$HAS_RG" == "true" ]]; then
    rg -q "$pattern" <<<"$payload"
    return $?
  fi

  printf '%s\n' "$payload" | grep -Eq -- "$pattern"
}

usage() {
  cat <<USAGE
Usage: $0 [--profile ci|standard] [--samples <n>] [--state-dir <relative-path>] [--fixture-root <relative-path>] [--report <path>] [--raw-out <path>] [--summary-out <path>] [--no-report]
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --profile)
      profile="${2:-}"
      shift 2
      ;;
    --samples)
      samples_override="${2:-}"
      shift 2
      ;;
    --state-dir)
      state_dir="${2:-}"
      shift 2
      ;;
    --fixture-root)
      fixture_root="${2:-}"
      shift 2
      ;;
    --report)
      report_path="${2:-}"
      shift 2
      ;;
    --raw-out)
      raw_out_path="${2:-}"
      shift 2
      ;;
    --summary-out)
      summary_out_path="${2:-}"
      shift 2
      ;;
    --no-report)
      emit_report="0"
      shift 1
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      echo "ERROR: unknown argument: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

if [[ ! -x "$RUNTIME_RUN" ]]; then
  echo "ERROR: runtime launcher not found: $RUNTIME_RUN"
  exit 1
fi

if [[ ! -x "$FIXTURE_BUILDER" ]]; then
  echo "ERROR: fixture builder script missing or not executable: $FIXTURE_BUILDER"
  exit 1
fi

if [[ ! -f "$SLO_BUDGETS" ]]; then
  echo "ERROR: SLO budgets file missing: $SLO_BUDGETS"
  exit 1
fi

if ! command -v perl >/dev/null 2>&1; then
  echo "ERROR: perl is required for high-resolution timing"
  exit 1
fi

if [[ "$state_dir" = /* || "$state_dir" == *".."* ]]; then
  echo "ERROR: --state-dir must be a safe repo-relative path"
  exit 1
fi

read_kv() {
  local key="$1"
  local text="$2"
  printf '%s\n' "$text" | awk -F= -v k="$key" '$1==k {print substr($0, index($0, "=")+1); exit}'
}

extract_json_string_field() {
  local json="$1"
  local field="$2"
  printf '%s' "$json" | tr -d '\n' | sed -nE "s/.*\"$field\"[[:space:]]*:[[:space:]]*\"([^\"]+)\".*/\\1/p"
}

now_ms() {
  perl -MTime::HiRes=time -e 'printf("%.0f\n", time()*1000)'
}

timestamp="$(date +%Y%m%dT%H%M%S)"
tmp_dir="$OCTON_DIR//.octon/state/evidence/validation/analysis/.tmp"
mkdir -p "$tmp_dir"
raw_tsv="$tmp_dir/filesystem-interfaces-slo-${timestamp}.raw.tsv"
summary_tsv="$tmp_dir/filesystem-interfaces-slo-${timestamp}.summary.tsv"

if [[ -n "$raw_out_path" ]]; then
  raw_tsv="$raw_out_path"
fi

if [[ -n "$summary_out_path" ]]; then
  summary_tsv="$summary_out_path"
fi

mkdir -p "$(dirname "$raw_tsv")"
mkdir -p "$(dirname "$summary_tsv")"

if [[ -z "$report_path" && "$emit_report" == "1" ]]; then
  report_path="$OCTON_DIR//.octon/state/evidence/validation/analysis/$(date +%F)-filesystem-interfaces-slo-report.md"
fi

if [[ -z "$fixture_root" ]]; then
  fixture_info="$(bash "$FIXTURE_BUILDER" --profile "$profile")" || {
    echo "ERROR: failed to build benchmark fixture"
    exit 1
  }
  fixture_root="$(read_kv "fixture_root" "$fixture_info")"
else
  fixture_info="fixture_root=$fixture_root"
fi

if [[ -z "$fixture_root" ]]; then
  echo "ERROR: fixture root could not be resolved"
  exit 1
fi

target_file="$fixture_root/module-00/docs/doc-000.md"
target_file_node="file:$target_file"
target_dir_node="dir:$fixture_root/module-00/docs"
target_module_node="dir:$fixture_root/module-00"

bootstrap_payload="$(printf '{"root":"%s","state_dir":"%s","set_current":true}' "$fixture_root" "$state_dir")"
bootstrap_out="$("$RUNTIME_RUN" tool interfaces/filesystem-snapshot snapshot.build --json "$bootstrap_payload" 2>&1)"
if ! payload_has_regex "$bootstrap_out" '"ok"[[:space:]]*:[[:space:]]*true'; then
  echo "ERROR: bootstrap snapshot.build failed"
  echo "$bootstrap_out"
  exit 1
fi

snapshot_id="$(extract_json_string_field "$bootstrap_out" "snapshot_id")"
if [[ -z "$snapshot_id" ]]; then
  echo "ERROR: failed to read snapshot_id from bootstrap output"
  echo "$bootstrap_out"
  exit 1
fi

payload_for_op() {
  local op="$1"
  case "$op" in
    fs.list)
      printf '{"path":"%s","limit":200}' "$fixture_root"
      ;;
    fs.read)
      printf '{"path":"%s","max_bytes":2048}' "$target_file"
      ;;
    fs.stat)
      printf '{"path":"%s"}' "$target_file"
      ;;
    fs.search)
      printf '{"pattern":"bench-keyword","path":"%s","limit":50}' "$fixture_root"
      ;;
    snapshot.build)
      printf '{"root":"%s","state_dir":"%s","set_current":false}' "$fixture_root" "$state_dir"
      ;;
    snapshot.diff)
      printf '{"base":"%s","head":"%s","state_dir":"%s"}' "$snapshot_id" "$snapshot_id" "$state_dir"
      ;;
    snapshot.get-current)
      printf '{"state_dir":"%s"}' "$state_dir"
      ;;
    kg.get-node)
      printf '{"snapshot_id":"%s","node_id":"%s","state_dir":"%s"}' "$snapshot_id" "$target_file_node" "$state_dir"
      ;;
    kg.neighbors)
      printf '{"snapshot_id":"%s","node_id":"%s","direction":"out","limit":150,"state_dir":"%s"}' "$snapshot_id" "$target_dir_node" "$state_dir"
      ;;
    kg.traverse)
      printf '{"snapshot_id":"%s","start_node_id":"%s","depth":3,"state_dir":"%s"}' "$snapshot_id" "$target_module_node" "$state_dir"
      ;;
    kg.resolve-to-file)
      printf '{"snapshot_id":"%s","node_id":"%s","state_dir":"%s"}' "$snapshot_id" "$target_file_node" "$state_dir"
      ;;
    discover.start)
      printf '{"snapshot_id":"%s","query":"bench-keyword","limit":30,"content_scan_limit":500,"state_dir":"%s"}' "$snapshot_id" "$state_dir"
      ;;
    discover.expand)
      printf '{"snapshot_id":"%s","node_ids":["%s"],"limit":120,"state_dir":"%s"}' "$snapshot_id" "$target_dir_node" "$state_dir"
      ;;
    discover.explain)
      printf '{"snapshot_id":"%s","query":"bench-keyword","candidate_node_ids":["%s"],"state_dir":"%s"}' "$snapshot_id" "$target_file_node" "$state_dir"
      ;;
    discover.resolve)
      printf '{"snapshot_id":"%s","node_id":"%s","state_dir":"%s"}' "$snapshot_id" "$target_file_node" "$state_dir"
      ;;
    *)
      echo "ERROR: unsupported op in SLO script: $op" >&2
      return 1
      ;;
  esac
}

service_for_op() {
  local op="$1"
  case "$op" in
    fs.*|snapshot.*)
      echo "interfaces/filesystem-snapshot"
      ;;
    kg.*|discover.*)
      echo "interfaces/filesystem-discovery"
      ;;
    *)
      return 1
      ;;
  esac
}

printf "op\tattempt\tlatency_ms\tstatus\terror_code\n" > "$raw_tsv"
printf "op\tsamples\tp95_ms\tbudget_p95_ms\terror_rate\tmax_error_rate\tstatus\n" > "$summary_tsv"

violations=0
ops_checked=0

while IFS=$'\t' read -r op budget_samples budget_p95_ms max_error_rate; do
  [[ -z "$op" ]] && continue
  [[ "$op" =~ ^# ]] && continue

  run_samples="$budget_samples"
  if [[ -n "$samples_override" ]]; then
    run_samples="$samples_override"
  fi

  if ! [[ "$run_samples" =~ ^[0-9]+$ ]] || [[ "$run_samples" -lt 1 ]]; then
    echo "ERROR: invalid sample count for $op: $run_samples"
    exit 1
  fi

  for attempt in $(seq 1 "$run_samples"); do
    payload="$(payload_for_op "$op")" || exit 1
    service="$(service_for_op "$op")" || {
      echo "ERROR: unsupported op in SLO script: $op"
      exit 1
    }

    start_ms="$(now_ms)"
    if raw_out="$("$RUNTIME_RUN" tool "$service" "$op" --json "$payload" 2>&1)"; then
      if payload_has_regex "$raw_out" '"ok"[[:space:]]*:[[:space:]]*false'; then
        status="error"
        error_code="$(extract_json_string_field "$raw_out" "code")"
        [[ -z "$error_code" ]] && error_code="ERR_UNKNOWN"
      else
        status="ok"
        error_code=""
      fi
    else
      raw_out=""
      status="error"
      error_code="ERR_RUNTIME_EXEC_FAILED"
    fi
    end_ms="$(now_ms)"
    latency_ms=$((end_ms - start_ms))

    printf "%s\t%s\t%s\t%s\t%s\n" "$op" "$attempt" "$latency_ms" "$status" "$error_code" >> "$raw_tsv"
  done

  sample_count="$(awk -F'\t' -v target="$op" 'NR>1 && $1==target {c++} END {print c+0}' "$raw_tsv")"
  failures="$(awk -F'\t' -v target="$op" 'NR>1 && $1==target && $4 != "ok" {c++} END {print c+0}' "$raw_tsv")"

  if [[ "$sample_count" -eq 0 ]]; then
    echo "ERROR: no samples executed for op $op"
    exit 1
  fi

  p95_index=$(( (95 * sample_count + 99) / 100 ))
  p95_ms="$(awk -F'\t' -v target="$op" 'NR>1 && $1==target {print $3}' "$raw_tsv" | sort -n | sed -n "${p95_index}p")"
  [[ -z "$p95_ms" ]] && p95_ms=0

  error_rate="$(awk -v f="$failures" -v n="$sample_count" 'BEGIN { if (n == 0) { print "1.000000" } else { printf "%.6f", f / n } }')"

  status="ok"
  if [[ "$p95_ms" -gt "$budget_p95_ms" ]]; then
    status="violation"
  fi

  error_violation="$(awk -v rate="$error_rate" -v max="$max_error_rate" 'BEGIN { if (rate > max) print 1; else print 0 }')"
  if [[ "$error_violation" == "1" ]]; then
    status="violation"
  fi

  if [[ "$status" == "violation" ]]; then
    violations=$((violations + 1))
  fi
  ops_checked=$((ops_checked + 1))

  printf "%s\t%s\t%s\t%s\t%s\t%s\t%s\n" \
    "$op" "$sample_count" "$p95_ms" "$budget_p95_ms" "$error_rate" "$max_error_rate" "$status" >> "$summary_tsv"
done < "$SLO_BUDGETS"

if [[ "$emit_report" == "1" ]]; then
  mkdir -p "$(dirname "$report_path")"
  {
    echo "# Filesystem-Graph SLO Report"
    echo
    echo "- profile: \`$profile\`"
    echo "- fixture_root: \`$fixture_root\`"
    echo "- snapshot_id: \`$snapshot_id\`"
    echo "- raw_metrics: \`$raw_tsv\`"
    echo "- summary_metrics: \`$summary_tsv\`"
    echo
    echo "| op | samples | p95 (ms) | p95 budget (ms) | error rate | max error rate | status |"
    echo "| --- | --- | --- | --- | --- | --- | --- |"
    awk -F'\t' 'NR>1 {printf "| `%s` | %s | %s | %s | %s | %s | %s |\n", $1, $2, $3, $4, $5, $6, $7}' "$summary_tsv"
  } > "$report_path"
fi

if [[ "$violations" -gt 0 ]]; then
  echo "filesystem-interfaces SLO failed: $violations violating op(s) out of $ops_checked"
  if [[ "$emit_report" == "1" ]]; then
    echo "report: $report_path"
  fi
  echo "raw_metrics: $raw_tsv"
  echo "summary_metrics: $summary_tsv"
  exit 1
fi

echo "filesystem-interfaces SLO passed: $ops_checked op(s)"
if [[ "$emit_report" == "1" ]]; then
  echo "report: $report_path"
fi
echo "raw_metrics: $raw_tsv"
echo "summary_metrics: $summary_tsv"

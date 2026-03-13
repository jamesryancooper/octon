#!/usr/bin/env bash
# test-filesystem-interfaces-perf-regression.sh - cold/warm perf regression gate for filesystem-interfaces.

set -o pipefail

OCTON_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../../../" && pwd)"
RUNTIME_RUN="$OCTON_DIR/engine/runtime/run"
RUNTIME_BIN_CANDIDATE="$OCTON_DIR/engine/_ops/state/build/runtime-crates-target/debug/octon"
export OCTON_RUNTIME_PREFER_SOURCE="${OCTON_RUNTIME_PREFER_SOURCE:-1}"
FIXTURE_BUILDER="$OCTON_DIR/capabilities/runtime/services/_ops/scripts/build-filesystem-interfaces-benchmark-fixture.sh"
DEFAULT_BASELINE_FILE="$OCTON_DIR/capabilities/runtime/services/interfaces/filesystem-snapshot/contracts/perf-regression-baseline.tsv"

profile="ci"
baseline_file="$DEFAULT_BASELINE_FILE"
fixture_root=""
state_root=".octon/engine/_ops/state/snapshots-perf"
raw_out_path=""
summary_out_path=""
report_path=""
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
Usage: $0 [--profile ci|standard] [--baseline-file <path>] [--fixture-root <path>] [--state-root <path>] [--raw-out <path>] [--summary-out <path>] [--report <path>] [--no-report]
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --profile)
      profile="${2:-}"
      shift 2
      ;;
    --baseline-file)
      baseline_file="${2:-}"
      shift 2
      ;;
    --fixture-root)
      fixture_root="${2:-}"
      shift 2
      ;;
    --state-root)
      state_root="${2:-}"
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
    --report)
      report_path="${2:-}"
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

# In clean CI workspaces, the compiled runtime binary is not present on first run.
# Prime the build once before timing so sample latencies do not include repeated cargo invocation overhead.
if [[ ! -x "$RUNTIME_BIN_CANDIDATE" ]]; then
  "$RUNTIME_RUN" --help >/dev/null 2>&1 || true
fi

# Prefer a prebuilt runtime binary to avoid cargo invocation overhead during perf sampling.
# Falls back to the launcher when the binary is unavailable.
if [[ -x "$RUNTIME_BIN_CANDIDATE" ]]; then
  RUNTIME_RUN="$RUNTIME_BIN_CANDIDATE"
fi

if [[ ! -x "$FIXTURE_BUILDER" ]]; then
  echo "ERROR: fixture builder script missing or not executable: $FIXTURE_BUILDER"
  exit 1
fi

if [[ ! -f "$baseline_file" ]]; then
  echo "ERROR: baseline file missing: $baseline_file"
  exit 1
fi

if ! command -v perl >/dev/null 2>&1; then
  echo "ERROR: perl is required for high-resolution timing"
  exit 1
fi

if [[ "$state_root" = /* || "$state_root" == *".."* ]]; then
  echo "ERROR: --state-root must be a safe repo-relative path"
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

invoke_op() {
  local op="$1"
  local payload="$2"
  local service
  case "$op" in
    fs.*|snapshot.*)
      service="interfaces/filesystem-snapshot"
      ;;
    kg.*|discover.*)
      service="interfaces/filesystem-discovery"
      ;;
    *)
      echo "ERROR: unsupported op in perf regression script: $op" >&2
      return 1
      ;;
  esac
  "$RUNTIME_RUN" tool "$service" "$op" --json "$payload"
}

build_snapshot() {
  local fixture="$1"
  local state_dir="$2"
  local payload out snap_id

  payload="$(printf '{"root":"%s","state_dir":"%s","set_current":false}' "$fixture" "$state_dir")"
  out="$(invoke_op snapshot.build "$payload" 2>&1)" || {
    echo "ERROR: snapshot.build failed while preparing perf fixture state"
    echo "$out"
    return 1
  }

  if ! payload_has_regex "$out" '"ok"[[:space:]]*:[[:space:]]*true'; then
    echo "ERROR: snapshot.build returned failure payload while preparing perf fixture state"
    echo "$out"
    return 1
  fi

  snap_id="$(extract_json_string_field "$out" "snapshot_id")"
  if [[ -z "$snap_id" ]]; then
    echo "ERROR: missing snapshot_id from snapshot.build output"
    echo "$out"
    return 1
  fi

  printf '%s\n' "$snap_id"
}

run_timed_sample() {
  local op="$1"
  local payload="$2"
  local phase="$3"
  local attempt="$4"
  local start_ms end_ms latency_ms status error_code raw_out

  start_ms="$(now_ms)"
  if raw_out="$(invoke_op "$op" "$payload" 2>&1)"; then
    if payload_has_regex "$raw_out" '"ok"[[:space:]]*:[[:space:]]*false'; then
      status="error"
      error_code="$(extract_json_string_field "$raw_out" "code")"
      [[ -z "$error_code" ]] && error_code="ERR_UNKNOWN"
    else
      status="ok"
      error_code=""
    fi
  else
    status="error"
    error_code="ERR_RUNTIME_EXEC_FAILED"
  fi
  end_ms="$(now_ms)"
  latency_ms=$((end_ms - start_ms))

  printf '%s\t%s\t%s\t%s\t%s\t%s\n' "$op" "$phase" "$attempt" "$latency_ms" "$status" "$error_code" >> "$raw_tsv"
}

payload_for_snapshot_build() {
  local fixture="$1"
  local state_dir="$2"
  printf '{"root":"%s","state_dir":"%s","set_current":false}' "$fixture" "$state_dir"
}

payload_for_op() {
  local op="$1"
  local snapshot_id="$2"
  local target_file="$3"
  local target_module_node="$4"
  local state_dir="$5"

  case "$op" in
    discover.start)
      printf '{"snapshot_id":"%s","query":"bench-keyword","limit":30,"content_scan_limit":500,"state_dir":"%s"}' "$snapshot_id" "$state_dir"
      ;;
    kg.traverse)
      printf '{"snapshot_id":"%s","start_node_id":"%s","depth":3,"state_dir":"%s"}' "$snapshot_id" "$target_module_node" "$state_dir"
      ;;
    fs.read)
      printf '{"path":"%s","max_bytes":2048}' "$target_file"
      ;;
    *)
      echo "ERROR: unsupported op in perf baseline: $op" >&2
      return 1
      ;;
  esac
}

calc_phase_stats() {
  local op="$1"
  local phase="$2"
  local baseline_ms="$3"
  local max_regression_pct="$4"

  local sample_count failures p95_index p95_ms allowed_ms phase_status

  sample_count="$(awk -F'\t' -v op="$op" -v phase="$phase" 'NR>1 && $1==op && $2==phase {c++} END {print c+0}' "$raw_tsv")"
  failures="$(awk -F'\t' -v op="$op" -v phase="$phase" 'NR>1 && $1==op && $2==phase && $5 != "ok" {c++} END {print c+0}' "$raw_tsv")"

  if [[ "$sample_count" -eq 0 ]]; then
    p95_ms=0
  else
    p95_index=$(( (95 * sample_count + 99) / 100 ))
    p95_ms="$(awk -F'\t' -v op="$op" -v phase="$phase" 'NR>1 && $1==op && $2==phase {print $4}' "$raw_tsv" | sort -n | sed -n "${p95_index}p")"
    [[ -z "$p95_ms" ]] && p95_ms=0
  fi

  allowed_ms="$(awk -v base="$baseline_ms" -v pct="$max_regression_pct" 'BEGIN { printf "%.0f", base * (1 + (pct / 100.0)) }')"

  phase_status="ok"
  if [[ "$failures" -gt 0 ]]; then
    phase_status="violation"
  fi
  if [[ "$p95_ms" -gt "$allowed_ms" ]]; then
    phase_status="violation"
  fi

  printf '%s\t%s\t%s\t%s\n' "$sample_count" "$p95_ms" "$allowed_ms" "$phase_status"
}

timestamp="$(date +%Y%m%dT%H%M%S)"
tmp_dir="$OCTON_DIR/output/reports/.tmp"
mkdir -p "$tmp_dir"
raw_tsv="$tmp_dir/filesystem-interfaces-perf-${timestamp}.raw.tsv"
summary_tsv="$tmp_dir/filesystem-interfaces-perf-${timestamp}.summary.tsv"

if [[ -n "$raw_out_path" ]]; then
  raw_tsv="$raw_out_path"
fi
if [[ -n "$summary_out_path" ]]; then
  summary_tsv="$summary_out_path"
fi

mkdir -p "$(dirname "$raw_tsv")"
mkdir -p "$(dirname "$summary_tsv")"

if [[ -z "$report_path" && "$emit_report" == "1" ]]; then
  report_path="$OCTON_DIR/output/reports/analysis/$(date +%F)-filesystem-interfaces-perf-regression-report.md"
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
target_module_node="dir:$fixture_root/module-00"

printf "op\tphase\tattempt\tlatency_ms\tstatus\terror_code\n" > "$raw_tsv"
printf "op\tcold_samples\tcold_p95_ms\tcold_baseline_ms\tcold_allowed_ms\twarm_samples\twarm_p95_ms\twarm_baseline_ms\twarm_allowed_ms\tmax_regression_pct\tstatus\n" > "$summary_tsv"

violations=0
ops_checked=0

while IFS=$'\t' read -r op cold_samples warm_samples cold_baseline_ms warm_baseline_ms max_regression_pct; do
  [[ -z "$op" ]] && continue
  [[ "$op" =~ ^# ]] && continue

  for attempt in $(seq 1 "$cold_samples"); do
    cold_state_dir="${state_root}/${timestamp}/${op//./-}/cold-${attempt}"

    if [[ "$op" == "snapshot.build" ]]; then
      payload="$(payload_for_snapshot_build "$fixture_root" "$cold_state_dir")"
    else
      cold_snapshot_id="$(build_snapshot "$fixture_root" "$cold_state_dir")" || exit 1
      payload="$(payload_for_op "$op" "$cold_snapshot_id" "$target_file" "$target_module_node" "$cold_state_dir")" || exit 1
    fi

    run_timed_sample "$op" "$payload" "cold" "$attempt"
  done

  warm_state_dir="${state_root}/${timestamp}/${op//./-}/warm"
  if [[ "$op" == "snapshot.build" ]]; then
    # Warm cache/state once before warm measurements.
    warmup_payload="$(payload_for_snapshot_build "$fixture_root" "$warm_state_dir")"
    invoke_op snapshot.build "$warmup_payload" >/dev/null 2>&1 || true

    for attempt in $(seq 1 "$warm_samples"); do
      payload="$(payload_for_snapshot_build "$fixture_root" "$warm_state_dir")"
      run_timed_sample "$op" "$payload" "warm" "$attempt"
    done
  else
    warm_snapshot_id="$(build_snapshot "$fixture_root" "$warm_state_dir")" || exit 1

    for attempt in $(seq 1 "$warm_samples"); do
      payload="$(payload_for_op "$op" "$warm_snapshot_id" "$target_file" "$target_module_node" "$warm_state_dir")" || exit 1
      run_timed_sample "$op" "$payload" "warm" "$attempt"
    done
  fi

  cold_stats="$(calc_phase_stats "$op" "cold" "$cold_baseline_ms" "$max_regression_pct")"
  warm_stats="$(calc_phase_stats "$op" "warm" "$warm_baseline_ms" "$max_regression_pct")"

  cold_count="$(printf '%s' "$cold_stats" | cut -f1)"
  cold_p95="$(printf '%s' "$cold_stats" | cut -f2)"
  cold_allowed="$(printf '%s' "$cold_stats" | cut -f3)"
  cold_status="$(printf '%s' "$cold_stats" | cut -f4)"

  warm_count="$(printf '%s' "$warm_stats" | cut -f1)"
  warm_p95="$(printf '%s' "$warm_stats" | cut -f2)"
  warm_allowed="$(printf '%s' "$warm_stats" | cut -f3)"
  warm_status="$(printf '%s' "$warm_stats" | cut -f4)"

  status="ok"
  if [[ "$cold_status" != "ok" || "$warm_status" != "ok" ]]; then
    status="violation"
    violations=$((violations + 1))
  fi
  ops_checked=$((ops_checked + 1))

  printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
    "$op" "$cold_count" "$cold_p95" "$cold_baseline_ms" "$cold_allowed" "$warm_count" "$warm_p95" "$warm_baseline_ms" "$warm_allowed" "$max_regression_pct" "$status" >> "$summary_tsv"
done < "$baseline_file"

if [[ "$emit_report" == "1" ]]; then
  mkdir -p "$(dirname "$report_path")"
  {
    echo "# Filesystem-Graph Perf Regression Report"
    echo
    echo "- profile: \`$profile\`"
    echo "- fixture_root: \`$fixture_root\`"
    echo "- baseline_file: \`$baseline_file\`"
    echo "- raw_metrics: \`$raw_tsv\`"
    echo "- summary_metrics: \`$summary_tsv\`"
    echo
    echo "| op | cold samples | cold p95 (ms) | cold baseline (ms) | cold allowed (ms) | warm samples | warm p95 (ms) | warm baseline (ms) | warm allowed (ms) | max regression % | status |"
    echo "| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |"
    awk -F'\t' 'NR>1 {printf "| `%s` | %s | %s | %s | %s | %s | %s | %s | %s | %s | %s |\n", $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11}' "$summary_tsv"
  } > "$report_path"
fi

if [[ "$violations" -gt 0 ]]; then
  echo "filesystem-interfaces perf regression failed: $violations violating op(s) out of $ops_checked"
  if [[ "$emit_report" == "1" ]]; then
    echo "report: $report_path"
  fi
  echo "raw_metrics: $raw_tsv"
  echo "summary_metrics: $summary_tsv"
  exit 1
fi

echo "filesystem-interfaces perf regression passed: $ops_checked op(s)"
if [[ "$emit_report" == "1" ]]; then
  echo "report: $report_path"
fi
echo "raw_metrics: $raw_tsv"
echo "summary_metrics: $summary_tsv"

#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<USAGE
Usage: $0 <before_dir> <after_dir> [--out <file>]

Compares two baseline directories produced by collect-actions-baseline.sh.
USAGE
}

if [[ $# -lt 2 ]]; then
  usage >&2
  exit 1
fi

before_dir="$1"
after_dir="$2"
shift 2

out_file=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --out)
      out_file="${2:-}"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

before_runs="$before_dir/runs.ndjson"
after_runs="$after_dir/runs.ndjson"

if [[ ! -f "$before_runs" || ! -f "$after_runs" ]]; then
  echo "Both directories must contain runs.ndjson files." >&2
  exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "jq is required." >&2
  exit 1
fi

if ! command -v join >/dev/null 2>&1; then
  echo "join is required." >&2
  exit 1
fi

before_runs_total="$(jq -s 'length' "$before_runs")"
after_runs_total="$(jq -s 'length' "$after_runs")"

before_minutes="$(jq -s 'map(.billed_minutes_proxy) | add // 0' "$before_runs")"
after_minutes="$(jq -s 'map(.billed_minutes_proxy) | add // 0' "$after_runs")"

before_fail_rate="$(jq -s 'if length==0 then 0 else ((map(select(.conclusion=="failure"))|length) / length) end' "$before_runs")"
after_fail_rate="$(jq -s 'if length==0 then 0 else ((map(select(.conclusion=="failure"))|length) / length) end' "$after_runs")"

before_cancel_rate="$(jq -s 'if length==0 then 0 else ((map(select(.conclusion=="cancelled"))|length) / length) end' "$before_runs")"
after_cancel_rate="$(jq -s 'if length==0 then 0 else ((map(select(.conclusion=="cancelled"))|length) / length) end' "$after_runs")"

reduction_pct="$(jq -n --argjson b "$before_minutes" --argjson a "$after_minutes" 'if $b == 0 then 0 else ((($b - $a) / $b) * 100) end')"

before_tmp="$(mktemp)"
after_tmp="$(mktemp)"
join_tmp="$(mktemp)"

jq -r -s '
  sort_by(.workflow)
  | group_by(.workflow)
  | map([.[0].workflow, (map(.billed_minutes_proxy) | add // 0)] | @tsv)
  | .[]
' "$before_runs" > "$before_tmp"

jq -r -s '
  sort_by(.workflow)
  | group_by(.workflow)
  | map([.[0].workflow, (map(.billed_minutes_proxy) | add // 0)] | @tsv)
  | .[]
' "$after_runs" > "$after_tmp"

join -t $'\t' -a 1 -a 2 -e 0 -o '0,1.2,2.2' "$before_tmp" "$after_tmp" > "$join_tmp"

per_workflow_md="$(awk -F'\t' '
  BEGIN {
    print "| workflow | before_minutes_proxy | after_minutes_proxy | delta |";
    print "| --- | ---: | ---: | ---: |";
  }
  {
    b=$2+0;
    a=$3+0;
    d=a-b;
    printf "| %s | %d | %d | %+d |\n", $1, b, a, d;
  }
' "$join_tmp")"

report="$(cat <<REPORT
# Actions Baseline Comparison

- before_dir: $before_dir
- after_dir: $after_dir
- before_runs_total: $before_runs_total
- after_runs_total: $after_runs_total
- before_billed_minutes_proxy: $before_minutes
- after_billed_minutes_proxy: $after_minutes
- billed_minutes_proxy_reduction_pct: $reduction_pct
- before_failure_rate: $before_fail_rate
- after_failure_rate: $after_fail_rate
- before_cancelled_rate: $before_cancel_rate
- after_cancelled_rate: $after_cancel_rate

## Per-workflow billed-minutes proxy delta

$per_workflow_md
REPORT
)"

if [[ -n "$out_file" ]]; then
  printf '%s\n' "$report" > "$out_file"
  echo "Comparison report written to: $out_file"
else
  printf '%s\n' "$report"
fi

rm -f "$before_tmp" "$after_tmp" "$join_tmp"

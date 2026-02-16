#!/usr/bin/env bash
# tune-filesystem-interfaces-slo-budgets.sh - tighten filesystem-interfaces SLO budgets from history window.

set -o pipefail

HARMONY_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
budgets_file="$HARMONY_DIR/capabilities/services/interfaces/filesystem-snapshot/contracts/slo-budgets.tsv"
history_dir=""
min_runs="6"
headroom_percent="25"
max_tighten_percent="70"
output_file=""

usage() {
  cat <<USAGE
Usage: $0 --history-dir <path> [--budgets-file <path>] [--min-runs <n>] [--headroom-percent <n>] [--max-tighten-percent <n>] [--output <path>]

Rules:
  - candidate budget = ceil(window_p95 * (1 + headroom))
  - never increase budgets
  - cap per-pass tightening to max-tighten-percent
  - enforce per-op minimum floors
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --history-dir)
      history_dir="${2:-}"
      shift 2
      ;;
    --budgets-file)
      budgets_file="${2:-}"
      shift 2
      ;;
    --min-runs)
      min_runs="${2:-}"
      shift 2
      ;;
    --headroom-percent)
      headroom_percent="${2:-}"
      shift 2
      ;;
    --max-tighten-percent)
      max_tighten_percent="${2:-}"
      shift 2
      ;;
    --output)
      output_file="${2:-}"
      shift 2
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

if [[ -z "$history_dir" ]]; then
  echo "ERROR: --history-dir is required"
  exit 1
fi

if [[ ! -d "$history_dir" ]]; then
  echo "ERROR: history directory not found: $history_dir"
  exit 1
fi

if [[ ! -f "$budgets_file" ]]; then
  echo "ERROR: budgets file not found: $budgets_file"
  exit 1
fi

if ! [[ "$min_runs" =~ ^[0-9]+$ ]] || [[ "$min_runs" -lt 1 ]]; then
  echo "ERROR: --min-runs must be a positive integer"
  exit 1
fi

if ! [[ "$headroom_percent" =~ ^[0-9]+$ ]] || [[ "$headroom_percent" -gt 200 ]]; then
  echo "ERROR: --headroom-percent must be an integer in [0,200]"
  exit 1
fi

if ! [[ "$max_tighten_percent" =~ ^[0-9]+$ ]] || [[ "$max_tighten_percent" -lt 1 || "$max_tighten_percent" -gt 95 ]]; then
  echo "ERROR: --max-tighten-percent must be an integer in [1,95]"
  exit 1
fi

mapfile -t history_files < <(find "$history_dir" -type f -name '*.summary.tsv' | sort)
if [[ "${#history_files[@]}" -eq 0 ]]; then
  echo "ERROR: no .summary.tsv files found under history dir: $history_dir"
  exit 1
fi

op_floor_ms() {
  local op="$1"
  case "$op" in
    snapshot.build) echo 1200 ;;
    snapshot.diff) echo 400 ;;
    discover.start) echo 500 ;;
    fs.search) echo 500 ;;
    kg.traverse) echo 300 ;;
    discover.expand|discover.explain) echo 250 ;;
    fs.list|fs.read) echo 120 ;;
    fs.stat) echo 80 ;;
    snapshot.get-current|kg.get-node|kg.resolve-to-file|discover.resolve) echo 120 ;;
    kg.neighbors) echo 200 ;;
    *) echo 100 ;;
  esac
}

quantile_index() {
  local n="$1"
  local q="$2"
  echo $(( (q * n + 99) / 100 ))
}

calc_candidate() {
  local observed_p95="$1"
  local current_budget="$2"
  local floor_budget="$3"
  local headroom="$4"
  local max_tighten="$5"

  local candidate
  candidate="$(awk -v p95="$observed_p95" -v h="$headroom" 'BEGIN { printf "%d", int((p95 * (100 + h) + 99) / 100) }')"

  local tighten_floor
  tighten_floor="$(awk -v cur="$current_budget" -v t="$max_tighten" 'BEGIN { printf "%d", int((cur * (100 - t) + 99) / 100) }')"

  if [[ "$candidate" -lt "$tighten_floor" ]]; then
    candidate="$tighten_floor"
  fi

  if [[ "$candidate" -lt "$floor_budget" ]]; then
    candidate="$floor_budget"
  fi

  echo "$candidate"
}

tmp_out="$(mktemp)"
trap 'rm -f "$tmp_out"' EXIT

tightened=0
unchanged=0
insufficient=0

while IFS= read -r line || [[ -n "$line" ]]; do
  if [[ -z "$line" || "$line" =~ ^# ]]; then
    printf "%s\n" "$line" >> "$tmp_out"
    continue
  fi

  IFS=$'\t' read -r op samples current_budget max_error_rate <<< "$line"
  if [[ -z "$op" || -z "$samples" || -z "$current_budget" || -z "$max_error_rate" ]]; then
    printf "%s\n" "$line" >> "$tmp_out"
    continue
  fi

  mapfile -t values < <(awk -F'\t' -v target="$op" 'FNR>1 && $1==target && $3 ~ /^[0-9]+$/ {print $3}' "${history_files[@]}" | sort -n)
  runs="${#values[@]}"
  if [[ "$runs" -lt "$min_runs" ]]; then
    printf "%s\t%s\t%s\t%s\n" "$op" "$samples" "$current_budget" "$max_error_rate" >> "$tmp_out"
    insufficient=$((insufficient + 1))
    continue
  fi

  idx95="$(quantile_index "$runs" 95)"
  observed_p95="${values[$((idx95 - 1))]}"
  floor_budget="$(op_floor_ms "$op")"
  candidate="$(calc_candidate "$observed_p95" "$current_budget" "$floor_budget" "$headroom_percent" "$max_tighten_percent")"

  new_budget="$current_budget"
  if [[ "$candidate" -lt "$current_budget" ]]; then
    new_budget="$candidate"
    tightened=$((tightened + 1))
  else
    unchanged=$((unchanged + 1))
  fi

  printf "%s\t%s\t%s\t%s\n" "$op" "$samples" "$new_budget" "$max_error_rate" >> "$tmp_out"
done < "$budgets_file"

target_file="$budgets_file"
if [[ -n "$output_file" ]]; then
  target_file="$output_file"
fi

mkdir -p "$(dirname "$target_file")"
cp "$tmp_out" "$target_file"

echo "history_files=${#history_files[@]}"
echo "tightened_ops=$tightened"
echo "unchanged_ops=$unchanged"
echo "insufficient_history_ops=$insufficient"
echo "output=$target_file"

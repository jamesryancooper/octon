#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<USAGE
Usage: $0 [--repo <owner/repo>] [--days <n>] [--out-dir <dir>]

Collects GitHub Actions workflow-run metrics and emits baseline artifacts.
USAGE
}

repo=""
days=30
out_dir=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --repo)
      repo="${2:-}"
      shift 2
      ;;
    --days)
      days="${2:-}"
      shift 2
      ;;
    --out-dir)
      out_dir="${2:-}"
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

if ! command -v gh >/dev/null 2>&1; then
  echo "gh CLI is required." >&2
  exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "jq is required." >&2
  exit 1
fi

if [[ -z "$repo" ]]; then
  repo="$(gh repo view --json nameWithOwner -q .nameWithOwner)"
fi

if [[ -z "$repo" ]]; then
  echo "Unable to determine repository. Pass --repo <owner/repo>." >&2
  exit 1
fi

if [[ -z "$days" || ! "$days" =~ ^[0-9]+$ ]]; then
  echo "--days must be a positive integer." >&2
  exit 1
fi

iso_now="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
if since_iso="$(date -u -v-"${days}"d +%Y-%m-%dT%H:%M:%SZ 2>/dev/null)"; then
  :
else
  since_iso="$(date -u -d "${days} days ago" +%Y-%m-%dT%H:%M:%SZ 2>/dev/null)"
fi

if [[ -z "$since_iso" ]]; then
  echo "Could not compute start timestamp for --days=${days}." >&2
  exit 1
fi

stamp="$(date -u +%Y%m%dT%H%M%SZ)"
if [[ -z "$out_dir" ]]; then
  out_dir=".proposals/ci-optimizations/baseline/${stamp}"
fi

mkdir -p "$out_dir"

runs_json="$out_dir/runs.json"
runs_ndjson="$out_dir/runs.ndjson"
workflow_csv="$out_dir/workflow-summary.csv"
event_csv="$out_dir/event-summary.csv"
summary_md="$out_dir/summary.md"

# Fetch all workflow runs created during the target window.
gh api --paginate \
  "repos/${repo}/actions/runs" \
  -f per_page=100 \
  -f created=">=${since_iso}" > "$out_dir/pages.ndjson"

jq -s '{workflow_runs: (map(.workflow_runs // []) | add)}' "$out_dir/pages.ndjson" > "$runs_json"

jq -c '
  .workflow_runs[]
  | {
      id: .id,
      workflow: (.name // "(unnamed)"),
      event: (.event // "unknown"),
      conclusion: (.conclusion // "unknown"),
      status: (.status // "unknown"),
      created_at: .created_at,
      run_started_at: .run_started_at,
      updated_at: .updated_at,
      duration_minutes: (
        if (.run_started_at != null and .updated_at != null)
        then (((.updated_at | fromdateiso8601) - (.run_started_at | fromdateiso8601)) / 60)
        else 0
        end
      ),
      billed_minutes_proxy: (
        if (.run_started_at != null and .updated_at != null)
        then ((((.updated_at | fromdateiso8601) - (.run_started_at | fromdateiso8601)) / 60) | ceil)
        else 0
        end
      )
    }
' "$runs_json" > "$runs_ndjson"

jq -r '
  def median:
    if length == 0 then 0
    else (sort) as $s
      | (length) as $n
      | if ($n % 2) == 1
        then $s[($n / 2 | floor)]
        else (($s[($n / 2 - 1 | floor)] + $s[($n / 2 | floor)]) / 2)
        end
    end;

  ["workflow","run_count","median_duration_minutes","failure_rate","cancelled_rate","billed_minutes_proxy"] | @csv,
  (group_by(.workflow)
   | map({
       workflow: .[0].workflow,
       run_count: length,
       median_duration_minutes: (map(.duration_minutes) | median),
       failure_rate: ((map(select(.conclusion == "failure")) | length) / length),
       cancelled_rate: ((map(select(.conclusion == "cancelled")) | length) / length),
       billed_minutes_proxy: (map(.billed_minutes_proxy) | add)
     })
   | sort_by(-.billed_minutes_proxy)
   | .[]
   | [
       .workflow,
       .run_count,
       (.median_duration_minutes | tostring),
       (.failure_rate | tostring),
       (.cancelled_rate | tostring),
       .billed_minutes_proxy
     ]
   | @csv)
' <(jq -s 'sort_by(.workflow)' "$runs_ndjson") > "$workflow_csv"

jq -r '
  ["event","run_count","total_billed_minutes_proxy"] | @csv,
  (group_by(.event)
   | map({
       event: .[0].event,
       run_count: length,
       total_billed_minutes_proxy: (map(.billed_minutes_proxy) | add)
     })
   | sort_by(-.total_billed_minutes_proxy)
   | .[]
   | [.event, .run_count, .total_billed_minutes_proxy]
   | @csv)
' <(jq -s 'sort_by(.event)' "$runs_ndjson") > "$event_csv"

run_count_total="$(jq -s 'length' "$runs_ndjson")"
billed_total="$(jq -s 'map(.billed_minutes_proxy) | add // 0' "$runs_ndjson")"

cat > "$summary_md" <<SUMMARY
# GitHub Actions Baseline

- repository: ${repo}
- window_start_utc: ${since_iso}
- window_end_utc: ${iso_now}
- window_days: ${days}
- runs_total: ${run_count_total}
- billed_minutes_proxy_total: ${billed_total}

Top workflows by billed-minutes proxy are in:
- ${workflow_csv}

Event breakdown is in:
- ${event_csv}
SUMMARY

rm -f "$out_dir/pages.ndjson"

echo "Baseline written to: $out_dir"

echo "- $workflow_csv"
echo "- $event_csv"
echo "- $summary_md"

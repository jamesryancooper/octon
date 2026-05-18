#!/usr/bin/env bash
# download-filesystem-interfaces-slo-history.sh - fetch recent SLO summary artifacts from CI runs.

set -o pipefail

workflow="filesystem-interfaces-runtime.yml"
artifact_name="filesystem-interfaces-slo-summary"
limit="20"
out_dir=""
repo=""
allow_empty="0"

usage() {
  cat <<USAGE
Usage: $0 [--repo <owner/repo>] [--workflow <workflow-file>] [--artifact-name <name>] [--limit <n>] --out-dir <path> [--allow-empty]
USAGE
}

gh_with_retries() {
  local label="$1"
  shift

  local attempts="${GITHUB_API_RETRY_ATTEMPTS:-5}"
  local delay="${GITHUB_API_RETRY_DELAY_SECONDS:-2}"

  if ! [[ "$attempts" =~ ^[0-9]+$ ]] || [[ "$attempts" -lt 1 ]]; then
    attempts="5"
  fi
  if ! [[ "$delay" =~ ^[0-9]+$ ]] || [[ "$delay" -lt 1 ]]; then
    delay="2"
  fi

  local attempt output status
  for ((attempt = 1; attempt <= attempts; attempt += 1)); do
    if output="$("$@" 2>&1)"; then
      if [[ -n "$output" ]]; then
        printf "%s\n" "$output"
      fi
      return 0
    fi

    status="$?"
    if [[ "$attempt" -lt "$attempts" ]]; then
      echo "WARN: $label failed on attempt $attempt/$attempts; retrying in ${delay}s" >&2
      if [[ -n "$output" ]]; then
        echo "$output" >&2
      fi
      sleep "$delay"
      delay=$((delay * 2))
      continue
    fi

    echo "ERROR: $label failed after $attempts attempts" >&2
    if [[ -n "$output" ]]; then
      echo "$output" >&2
    fi
    return "$status"
  done
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --repo)
      repo="${2:-}"
      shift 2
      ;;
    --workflow)
      workflow="${2:-}"
      shift 2
      ;;
    --artifact-name)
      artifact_name="${2:-}"
      shift 2
      ;;
    --limit)
      limit="${2:-}"
      shift 2
      ;;
    --out-dir)
      out_dir="${2:-}"
      shift 2
      ;;
    --allow-empty)
      allow_empty="1"
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

if ! command -v gh >/dev/null 2>&1; then
  echo "ERROR: gh CLI is required"
  exit 1
fi

if [[ -z "$out_dir" ]]; then
  echo "ERROR: --out-dir is required"
  exit 1
fi

if [[ -z "$repo" ]]; then
  repo="$(git remote get-url origin 2>/dev/null | sed -nE 's#.*github.com[:/](.+)\.git#\1#p')"
fi

if [[ -z "$repo" ]]; then
  echo "ERROR: repository could not be inferred; pass --repo <owner/repo>"
  exit 1
fi

if ! [[ "$limit" =~ ^[0-9]+$ ]] || [[ "$limit" -lt 1 ]]; then
  echo "ERROR: --limit must be a positive integer"
  exit 1
fi

mkdir -p "$out_dir"

run_list_output="$(
  gh_with_retries "list successful runs for workflow '$workflow'" \
    gh run list \
      --repo "$repo" \
      --workflow "$workflow" \
      --limit "$limit" \
      --json databaseId,conclusion \
      --jq '.[] | select(.conclusion=="success") | .databaseId'
)" || exit "$?"

run_ids=()
if [[ -n "$run_list_output" ]]; then
  mapfile -t run_ids <<< "$run_list_output"
fi

if [[ "${#run_ids[@]}" -eq 0 ]]; then
  if [[ "$allow_empty" == "1" ]]; then
    echo "downloaded_runs=0"
    echo "summary_files=0"
    echo "history_dir=$out_dir"
    exit 0
  fi
  echo "ERROR: no successful runs found for workflow '$workflow'"
  exit 1
fi

downloaded_runs=0
for run_id in "${run_ids[@]}"; do
  run_dir="$out_dir/run-$run_id"
  mkdir -p "$run_dir"
  if gh_with_retries "download artifact '$artifact_name' from run $run_id" \
    gh run download "$run_id" --repo "$repo" --name "$artifact_name" --dir "$run_dir" >/dev/null; then
    downloaded_runs=$((downloaded_runs + 1))
  else
    rm -rf "$run_dir"
  fi
done

summary_files="$(find "$out_dir" -type f -name '*.summary.tsv' | wc -l | tr -d ' ')"

if [[ "$summary_files" -eq 0 && "$allow_empty" != "1" ]]; then
  echo "ERROR: no summary artifacts downloaded from workflow history"
  exit 1
fi

echo "downloaded_runs=$downloaded_runs"
echo "summary_files=$summary_files"
echo "history_dir=$out_dir"

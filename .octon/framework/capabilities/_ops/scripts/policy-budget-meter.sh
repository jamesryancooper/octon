#!/usr/bin/env bash
# policy-budget-meter.sh - Maintain lightweight ACP budget counters per run.

set -euo pipefail

usage() {
  cat <<'USAGE'
Usage:
  policy-budget-meter.sh init --file <path>
  policy-budget-meter.sh add --file <path> --metric <name> --value <number>
  policy-budget-meter.sh record-git-diff --file <path> [--base <rev>]
  policy-budget-meter.sh emit --file <path>
USAGE
}

require_jq() {
  if ! command -v jq >/dev/null 2>&1; then
    echo "jq is required for policy-budget-meter.sh" >&2
    exit 1
  fi
}

ensure_file() {
  local file="$1"
  if [[ ! -f "$file" ]]; then
    mkdir -p "$(dirname "$file")"
    jq -n '{ }' > "$file"
  fi
}

cmd_init() {
  local file="$1"
  mkdir -p "$(dirname "$file")"
  jq -n '{
    "repo.max_files_touched": 0,
    "repo.max_loc_delta": 0,
    "repo.max_commits": 0,
    "commands.count": 0,
    "net.calls": 0,
    "time.max_seconds": 0
  }' > "$file"
  jq -c . "$file"
}

cmd_add() {
  local file="$1"
  local metric="$2"
  local value="$3"
  ensure_file "$file"
  jq --arg metric "$metric" --argjson value "$value" \
    '.[$metric] = ((.[$metric] // 0) + $value)' "$file" > "$file.tmp"
  mv "$file.tmp" "$file"
  jq -c . "$file"
}

cmd_record_git_diff() {
  local file="$1"
  local base_ref="${2:-}"
  ensure_file "$file"

  local numstat
  if [[ -n "$base_ref" ]]; then
    numstat="$(git diff --numstat "$base_ref"...HEAD)"
  else
    numstat="$(git diff --numstat)"
  fi

  local files=0
  local loc=0
  while IFS=$'\t' read -r added deleted _rest; do
    [[ -z "${added:-}" || -z "${deleted:-}" ]] && continue
    if [[ "$added" == "-" || "$deleted" == "-" ]]; then
      continue
    fi
    files=$((files + 1))
    loc=$((loc + added + deleted))
  done <<< "$numstat"

  jq \
    --argjson files "$files" \
    --argjson loc "$loc" \
    '.["repo.max_files_touched"] = $files
      | .["repo.max_loc_delta"] = $loc' "$file" > "$file.tmp"
  mv "$file.tmp" "$file"
  jq -c . "$file"
}

main() {
  require_jq
  local cmd="${1:-}"
  shift || true

  local file="" metric="" value="" base_ref=""

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --file) file="$2"; shift 2 ;;
      --metric) metric="$2"; shift 2 ;;
      --value) value="$2"; shift 2 ;;
      --base) base_ref="$2"; shift 2 ;;
      -h|--help|help) usage; exit 0 ;;
      *) echo "Unknown option: $1" >&2; usage >&2; exit 1 ;;
    esac
  done

  [[ -n "$cmd" ]] || { usage >&2; exit 1; }
  [[ -n "$file" ]] || { echo "--file is required" >&2; exit 1; }

  case "$cmd" in
    init)
      cmd_init "$file"
      ;;
    add)
      [[ -n "$metric" ]] || { echo "--metric is required for add" >&2; exit 1; }
      [[ -n "$value" ]] || { echo "--value is required for add" >&2; exit 1; }
      cmd_add "$file" "$metric" "$value"
      ;;
    record-git-diff)
      cmd_record_git_diff "$file" "$base_ref"
      ;;
    emit)
      ensure_file "$file"
      jq -c . "$file"
      ;;
    *)
      echo "Unknown command: $cmd" >&2
      usage >&2
      exit 1
      ;;
  esac
}

main "$@"

#!/usr/bin/env bash
# snapshot-diff.sh - runtime wrapper for snapshot.diff.

set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HARMONY_DIR="$(cd "$SCRIPT_DIR/../../../../.." && pwd)"
REPO_ROOT="$(cd "$HARMONY_DIR/.." && pwd)"
RUNTIME_RUN="$HARMONY_DIR/runtime/run"

if ! command -v jq >/dev/null 2>&1; then
  echo '{"ok":false,"error":{"code":"ERR_FILESYSTEM_GRAPH_INPUT_INVALID","message":"jq is required."}}'
  exit 5
fi

if [[ ! -x "$RUNTIME_RUN" ]]; then
  jq -cn --arg code "ERR_FILESYSTEM_GRAPH_INTERNAL" --arg message "Runtime launcher not found: $RUNTIME_RUN" '{ok:false,error:{code:$code,message:$message}}'
  exit 4
fi

base=""
head=""
state_dir=".harmony/runtime/_ops/state/snapshots"

to_repo_relative() {
  local value="$1"
  if [[ -z "$value" || "$value" != /* ]]; then
    echo "$value"
    return 0
  fi

  local abs="$value"
  if [[ -d "$value" ]]; then
    abs="$(cd "$value" && pwd)"
  fi

  if [[ "$abs" == "$REPO_ROOT" ]]; then
    echo "."
    return 0
  fi

  case "$abs" in
    "$REPO_ROOT"/*)
      echo "${abs#"$REPO_ROOT/"}"
      return 0
      ;;
  esac

  return 1
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --base)
      base="${2:-}"
      shift 2
      ;;
    --head)
      head="${2:-}"
      shift 2
      ;;
    --state-dir)
      state_dir="${2:-.harmony/runtime/_ops/state/snapshots}"
      shift 2
      ;;
    *)
      jq -cn --arg code "ERR_FILESYSTEM_GRAPH_INPUT_INVALID" --arg message "Unknown argument: $1" '{ok:false,error:{code:$code,message:$message}}'
      exit 5
      ;;
  esac
done

if [[ -z "$base" || -z "$head" ]]; then
  jq -cn --arg code "ERR_FILESYSTEM_GRAPH_INPUT_INVALID" --arg message "Both --base and --head are required." '{ok:false,error:{code:$code,message:$message}}'
  exit 5
fi

if ! state_dir="$(to_repo_relative "$state_dir")"; then
  jq -cn --arg code "ERR_FILESYSTEM_GRAPH_PATH_INVALID" --arg message "--state-dir must be inside repository root." '{ok:false,error:{code:$code,message:$message}}'
  exit 4
fi

if ! base="$(to_repo_relative "$base")"; then
  jq -cn --arg code "ERR_FILESYSTEM_GRAPH_PATH_INVALID" --arg message "--base absolute paths must be inside repository root." '{ok:false,error:{code:$code,message:$message}}'
  exit 4
fi

if ! head="$(to_repo_relative "$head")"; then
  jq -cn --arg code "ERR_FILESYSTEM_GRAPH_PATH_INVALID" --arg message "--head absolute paths must be inside repository root." '{ok:false,error:{code:$code,message:$message}}'
  exit 4
fi

input_json="$(jq -cn --arg base "$base" --arg head "$head" --arg state_dir "$state_dir" '{base:$base,head:$head,state_dir:$state_dir}')"

if ! raw_out="$($RUNTIME_RUN tool interfaces/filesystem-graph snapshot.diff --json "$input_json" 2>&1)"; then
  msg="$(echo "$raw_out" | tr '\n' ' ' | sed 's/[[:space:]]\+/ /g')"
  jq -cn --arg code "ERR_FILESYSTEM_GRAPH_OPERATION_FAILED" --arg message "$msg" '{ok:false,error:{code:$code,message:$message}}'
  exit 4
fi

if ! jq -e . >/dev/null 2>&1 <<<"$raw_out"; then
  jq -cn --arg code "ERR_FILESYSTEM_GRAPH_INTERNAL" --arg message "Runtime returned non-JSON output." '{ok:false,error:{code:$code,message:$message}}'
  exit 4
fi

jq -c . <<<"$raw_out"

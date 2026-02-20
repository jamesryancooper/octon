#!/usr/bin/env bash
# playbook.sh - Native planning playbook expansion service.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Enforce deny-by-default policy at runtime for this shell service.
source "$SCRIPT_DIR/../../../_ops/scripts/enforce-deny-by-default.sh"
harmony_enforce_service_policy "playbook" "$0" "$@"


emit_output() {
  local status="$1"
  local playbook_json="$2"
  local warnings_json="${3:-[]}"
  jq -n --arg status "$status" --argjson playbook "$playbook_json" --argjson warnings "$warnings_json" \
    '{status:$status,playbook:$playbook,warnings:$warnings}'
}

fail_input() {
  local message="$1"
  emit_output "error" "{}" "$(jq -cn --arg m "$message" '[ $m ]')"
  exit 5
}

if ! command -v jq >/dev/null 2>&1; then
  printf '%s\n' '{"status":"error","playbook":{},"warnings":["jq is required"]}'
  exit 6
fi

payload="$(cat)"
if [[ -z "$(printf '%s' "$payload" | tr -d '[:space:]')" ]]; then
  fail_input "Expected JSON payload"
fi

if ! printf '%s' "$payload" | jq -e . >/dev/null 2>&1; then
  fail_input "Payload is not valid JSON"
fi

playbook_path="$(printf '%s' "$payload" | jq -r '.playbookPath // empty')"
dry_run="$(printf '%s' "$payload" | jq -r '.dryRun // false')"
params_json="$(printf '%s' "$payload" | jq -c '.params // {}')"

if [[ -z "$playbook_path" ]]; then
  fail_input "Missing playbookPath"
fi

if ! jq -e 'type == "object"' <<<"$params_json" >/dev/null 2>&1; then
  fail_input "params must be an object"
fi

playbook_id="$(basename "$playbook_path")"
playbook_id="${playbook_id%%.*}"
if [[ -z "$playbook_id" ]]; then
  playbook_id="playbook"
fi

warnings_json='[]'
if [[ ! -f "$playbook_path" ]]; then
  warnings_json="$(jq -cn --arg path "$playbook_path" '["Playbook file not found; using logical expansion only",("missing: " + $path)]')"
fi

steps_json="$(jq -cn --arg id "$playbook_id" --arg path "$playbook_path" --argjson params "$params_json" '
[
  {id:("prepare-" + $id), action:"load-playbook", playbookPath:$path},
  {id:("execute-" + $id), action:"apply-params", params:$params}
]')"

playbook_json="$(jq -cn \
  --arg path "$playbook_path" \
  --arg id "$playbook_id" \
  --argjson dryRun "$dry_run" \
  --argjson params "$params_json" \
  --argjson steps "$steps_json" \
  '{path:$path,id:$id,dryRun:$dryRun,params:$params,steps:$steps}')"

emit_output "success" "$playbook_json" "$warnings_json"

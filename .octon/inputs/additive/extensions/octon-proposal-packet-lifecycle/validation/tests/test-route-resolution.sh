#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "$SCRIPT_DIR/../../../../../../.." && pwd)"

pass_count=0
fail_count=0

pass() { printf 'PASS: %s\n' "$1"; pass_count=$((pass_count + 1)); }
fail() { printf 'FAIL: %s\n' "$1" >&2; fail_count=$((fail_count + 1)); }

publish_extensions() {
  bash "$REPO_ROOT/.octon/framework/orchestration/runtime/_ops/scripts/publish-extension-state.sh" >/dev/null
}

resolve_route_success() {
  local inputs_json="$1"
  bash "$REPO_ROOT/.octon/framework/orchestration/runtime/_ops/scripts/resolve-extension-route.sh" \
    --pack-id octon-proposal-packet-lifecycle \
    --dispatcher-id octon-proposal-packet-lifecycle \
    --inputs-json "$inputs_json"
}

resolve_route_failure() {
  local inputs_json="$1"
  local output status
  set +e
  output="$(
    bash "$REPO_ROOT/.octon/framework/orchestration/runtime/_ops/scripts/resolve-extension-route.sh" \
      --pack-id octon-proposal-packet-lifecycle \
      --dispatcher-id octon-proposal-packet-lifecycle \
      --inputs-json "$inputs_json"
  )"
  status=$?
  set -e
  [[ "$status" -ne 0 ]] || return 1
  printf '%s\n' "$output"
}

assert_json() {
  local label="$1" json="$2" query="$3"
  if jq -e "$query" >/dev/null <<<"$json"; then
    pass "$label"
  else
    fail "$label"
  fi
}

main() {
  local json
  publish_extensions

  json="$(resolve_route_success '{"lifecycle_action":"create-proposal-packet","source_kind":"audit"}')"
  assert_json "create action resolves" "$json" '.status == "resolved" and .selected_route_id == "create-proposal-packet"'

  json="$(resolve_route_success '{"lifecycle_action":"generate-correction-prompt","packet_path":".octon/inputs/exploratory/proposals/architecture/example","verification_finding_id":"FINDING-001"}')"
  assert_json "correction action resolves" "$json" '.status == "resolved" and .selected_execution_binding.command_capability_id == "octon-proposal-packet-generate-correction-prompt" and .selected_execution_binding.skill_capability_id == "octon-proposal-packet-lifecycle-generate-correction-prompt" and .selected_execution_binding.prompt_set_id == "octon-proposal-packet-lifecycle-generate-correction-prompt"'

  json="$(resolve_route_success '{"lifecycle_action":"create-proposal-program","child_packet_paths":[".octon/inputs/exploratory/proposals/architecture/child-a"]}')"
  assert_json "program action resolves" "$json" '.status == "resolved" and .selected_route_id == "create-proposal-program"'

  json="$(resolve_route_failure '{"bundle":"not-a-route"}')"
  assert_json "unsupported bundle denies" "$json" '.status == "deny" and .selected_route_id == "unsupported-route-id"'

  json="$(resolve_route_failure '{}')"
  assert_json "missing inputs escalate" "$json" '.status == "escalate" and .selected_route_id == "missing-routeable-inputs"'

  json="$(
    bash "$REPO_ROOT/.octon/framework/orchestration/runtime/_ops/scripts/resolve-extension-prompt-bundle.sh" \
      --pack-id octon-proposal-packet-lifecycle \
      --prompt-set-id octon-proposal-packet-lifecycle-create-proposal-packet
  )"
  assert_json "prompt bundle resolves fresh" "$json" '.status == "fresh" and .safe_to_run == true'

  printf '\nPassed: %s\nFailed: %s\n' "$pass_count" "$fail_count"
  [[ "$fail_count" -eq 0 ]]
}

main "$@"

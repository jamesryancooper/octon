#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../../../../../.." && pwd)"

pass_count=0
fail_count=0

pass() { echo "PASS: $1"; pass_count=$((pass_count + 1)); }
fail() { echo "FAIL: $1" >&2; fail_count=$((fail_count + 1)); }

assert_success() {
  local name="$1"
  shift
  if "$@"; then
    pass "$name"
  else
    fail "$name"
  fi
}

publish_extensions() {
  bash "$REPO_ROOT/.octon/framework/orchestration/runtime/_ops/scripts/publish-extension-state.sh" >/dev/null
}

resolve_route_success() {
  local inputs_json="$1"
  bash "$REPO_ROOT/.octon/framework/orchestration/runtime/_ops/scripts/resolve-extension-route.sh" \
    --pack-id octon-impact-map-and-validation-selector \
    --dispatcher-id octon-impact-map-and-validation-selector \
    --inputs-json "$inputs_json"
}

resolve_route_failure() {
  local inputs_json="$1"
  local output
  set +e
  output="$(
    bash "$REPO_ROOT/.octon/framework/orchestration/runtime/_ops/scripts/resolve-extension-route.sh" \
      --pack-id octon-impact-map-and-validation-selector \
      --dispatcher-id octon-impact-map-and-validation-selector \
      --inputs-json "$inputs_json"
  )"
  local status=$?
  set -e
  [[ "$status" -ne 0 ]] || return 1
  printf '%s\n' "$output"
}

resolve_prompt_bundle() {
  local prompt_set_id="$1"
  bash "$REPO_ROOT/.octon/framework/orchestration/runtime/_ops/scripts/resolve-extension-prompt-bundle.sh" \
    --pack-id octon-impact-map-and-validation-selector \
    --prompt-set-id "$prompt_set_id"
}

case_touched_paths_route_resolves() {
  local json
  json="$(resolve_route_success '{"touched_paths":[".octon/instance/ingress/AGENTS.md"]}')"
  jq -e '
    .status == "resolved"
    and .selected_route_id == "touched-paths"
    and .selected_execution_binding.command_capability_id == "octon-impact-map-and-validation-selector-touched-paths"
    and (.reason_codes | index("touched-paths")) != null
  ' >/dev/null <<<"$json"
}

case_proposal_packet_route_resolves() {
  local json
  json="$(resolve_route_success '{"proposal_packet":".octon/inputs/exploratory/proposals/architecture/octon-instruction-layer-execution-envelope-hardening"}')"
  jq -e '
    .status == "resolved"
    and .selected_route_id == "proposal-packet"
    and .selected_execution_binding.prompt_set_id == "octon-impact-map-and-validation-selector-proposal-packet-impact-map"
    and (.reason_codes | index("proposal-packet")) != null
  ' >/dev/null <<<"$json"
}

case_refactor_target_route_resolves() {
  local json
  json="$(resolve_route_success '{"refactor_target":{"type":"rename","old":"old-name","new":"new-name"}}')"
  jq -e '
    .status == "resolved"
    and .selected_route_id == "refactor-target"
    and .selected_execution_binding.skill_capability_id == "octon-impact-map-and-validation-selector-refactor-target"
    and (.reason_codes | index("refactor-target")) != null
  ' >/dev/null <<<"$json"
}

case_mixed_inputs_route_resolves() {
  local json
  json="$(resolve_route_success "{\"touched_paths\":[\"README.md\"],\"proposal_packet\":\".octon/inputs/exploratory/proposals/architecture/octon-instruction-layer-execution-envelope-hardening\"}")"
  jq -e '
    .status == "resolved"
    and .selected_route_id == "mixed-inputs"
    and .selected_execution_binding.prompt_set_id == "octon-impact-map-and-validation-selector-mixed-input-reconciliation"
    and (.reason_codes | index("mixed-inputs")) != null
  ' >/dev/null <<<"$json"
}

case_explicit_bundle_override_wins() {
  local json
  json="$(resolve_route_success "{\"bundle\":\"proposal-packet\",\"touched_paths\":[\"README.md\"],\"proposal_packet\":\".octon/inputs/exploratory/proposals/architecture/octon-instruction-layer-execution-envelope-hardening\"}")"
  jq -e '
    .status == "resolved"
    and .selected_route_id == "proposal-packet"
    and (.reason_codes | index("explicit-bundle")) != null
  ' >/dev/null <<<"$json"
}

case_unsupported_bundle_denies() {
  local json
  json="$(resolve_route_failure '{"bundle":"not-a-real-route"}')"
  jq -e '
    .status == "deny"
    and .selected_route_id == "unsupported-route-id"
    and (.reason_codes | index("unsupported-route-id")) != null
  ' >/dev/null <<<"$json"
}

case_missing_inputs_escalate() {
  local json
  json="$(resolve_route_failure '{}')"
  jq -e '
    .status == "escalate"
    and .selected_route_id == "missing-routeable-inputs"
    and (.reason_codes | index("missing-routeable-inputs")) != null
  ' >/dev/null <<<"$json"
}

case_prompt_bundles_publish_with_safe_alignment_receipts() {
  local json
  json="$(resolve_prompt_bundle "octon-impact-map-and-validation-selector-touched-paths-impact-map")"
  jq -e '
    .status == "fresh"
    and .safe_to_run == true
    and .prompt_set_id == "octon-impact-map-and-validation-selector-touched-paths-impact-map"
  ' >/dev/null <<<"$json"
}

main() {
  publish_extensions

  assert_success "touched_paths resolves to the touched-paths route" case_touched_paths_route_resolves
  assert_success "proposal_packet resolves to the proposal-packet route" case_proposal_packet_route_resolves
  assert_success "refactor_target resolves to the refactor-target route" case_refactor_target_route_resolves
  assert_success "mixed primary inputs resolve to mixed-inputs" case_mixed_inputs_route_resolves
  assert_success "explicit bundle override wins over mixed inputs" case_explicit_bundle_override_wins
  assert_success "unsupported bundle values deny cleanly" case_unsupported_bundle_denies
  assert_success "missing primary inputs escalate cleanly" case_missing_inputs_escalate
  assert_success "prompt bundles publish with safe alignment receipts" case_prompt_bundles_publish_with_safe_alignment_receipts

  echo
  echo "Passed: $pass_count"
  echo "Failed: $fail_count"
  [[ "$fail_count" -eq 0 ]]
}

main "$@"

#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../../../../../.." && pwd)"
PACK_ROOT="$REPO_ROOT/.octon/inputs/additive/extensions/octon-impact-map-and-validation-selector"

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

case_mixed_input_route_is_selected_without_bundle_override() {
  local json
  json="$(resolve_route_success "{\"touched_paths\":[\"README.md\"],\"proposal_packet\":\".octon/inputs/exploratory/proposals/architecture/octon-instruction-layer-execution-envelope-hardening\"}")"
  jq -e '
    .status == "resolved"
    and .selected_route_id == "mixed-inputs"
  ' >/dev/null <<<"$json"
}

case_mixed_input_prompt_makes_touched_paths_precedence_explicit() {
  local prompt="$PACK_ROOT/prompts/mixed-input-reconciliation/stages/01-analyze.md"
  grep -Fq 'Treat touched paths as the stronger factual source' "$prompt"
  grep -Fq 'packet refresh or supersession' "$prompt"
  grep -Fq 'clarification' "$prompt"
}

case_mixed_input_scenario_records_packet_drift_expectations() {
  local scenario="$PACK_ROOT/validation/scenarios/mixed-input-packet-drift.md"
  grep -Fq 'touched paths are the stronger factual source' "$scenario"
  grep -Fq '/octon-concept-integration-packet-refresh-and-supersession' "$scenario"
  grep -Fq 'clarification' "$scenario"
}

main() {
  publish_extensions

  assert_success "mixed-inputs route is selected when touched paths and packet input coexist" case_mixed_input_route_is_selected_without_bundle_override
  assert_success "mixed-input prompt states touched-path precedence and corrective routing" case_mixed_input_prompt_makes_touched_paths_precedence_explicit
  assert_success "mixed-input scenario records packet drift expectations" case_mixed_input_scenario_records_packet_drift_expectations

  echo
  echo "Passed: $pass_count"
  echo "Failed: $fail_count"
  [[ "$fail_count" -eq 0 ]]
}

main "$@"

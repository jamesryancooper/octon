#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PACK_ROOT="$(cd -- "$SCRIPT_DIR/../.." && pwd)"
CONTRACT="$PACK_ROOT/context/lifecycles/proposal-program.contract.yml"
SKILL="$PACK_ROOT/skills/octon-proposal-lifecycle-run-program-lifecycle/SKILL.md"
COMMAND_MANIFEST="$PACK_ROOT/commands/manifest.fragment.yml"
ALIAS_COMMAND="$PACK_ROOT/commands/octon-proposal-run-program-delivery.md"
BUNDLE_MATRIX="$PACK_ROOT/context/bundle-matrix.md"
PROGRAM_PATTERN="$PACK_ROOT/context/patterns/proposal-program.md"
REVIEW_COMMAND="$PACK_ROOT/commands/octon-proposal-review-program.md"
REVISE_COMMAND="$PACK_ROOT/commands/octon-proposal-revise-program.md"
REVIEW_SKILL="$PACK_ROOT/skills/octon-proposal-lifecycle-review-program/SKILL.md"
REVISE_SKILL="$PACK_ROOT/skills/octon-proposal-lifecycle-revise-program/SKILL.md"

pass_count=0
fail_count=0

pass() {
  echo "PASS: $1"
  pass_count=$((pass_count + 1))
}

fail() {
  echo "FAIL: $1" >&2
  fail_count=$((fail_count + 1))
}

assert_yq() {
  local label="$1" expression="$2"
  if yq -e "$expression" "$CONTRACT" >/dev/null 2>&1; then
    pass "$label"
  else
    fail "$label"
  fi
}

assert_text() {
  local label="$1" token="$2" path="$3"
  if grep -Fq "$token" "$path"; then
    pass "$label"
  else
    fail "$label"
  fi
}

assert_yq "delivery mode declares order override receipt schema" '.delivery_modes[]? | select(.mode_id == "proposal-program-delivery") | .order_override_receipt_schema_ref == ".octon/framework/product/contracts/proposal-program-delivery-order-override-receipt-v1.schema.json"'
assert_yq "delivery mode keeps canonical child-before-parent order" '.delivery_modes[]? | select(.mode_id == "proposal-program-delivery") | .execution_order_policy.canonical_order_ref == "child-before-parent-delivery"'
assert_yq "delivery readiness preflight retained receipt required" '.delivery_modes[]? | select(.mode_id == "proposal-program-delivery") | .readiness_preflight.retained_receipt_required == true'
assert_yq "delivery mode requires profile_path before admission" '.delivery_modes[]? | select(.mode_id == "proposal-program-delivery") | .input_contract.required_before_admission[] == "profile_path"'
assert_yq "delivery mode requires delivery_run_id before admission" '.delivery_modes[]? | select(.mode_id == "proposal-program-delivery") | .input_contract.required_before_admission[] == "delivery_run_id"'
assert_yq "delivery mode fails closed on missing admission input" '.delivery_modes[]? | select(.mode_id == "proposal-program-delivery") | .input_contract.missing_required_input_behavior == "fail-closed-before-mutation"'
assert_yq "delivery mode forbids generated output resume authority" '.delivery_modes[]? | select(.mode_id == "proposal-program-delivery") | .input_contract.resume_evidence.forbidden[] == "generated outputs"'
if yq -e '.delivery_modes[]? | select(.mode_id == "octon-proposal-run-program-delivery")' "$CONTRACT" >/dev/null 2>&1; then
  fail "operator alias does not create a lifecycle delivery mode"
else
  pass "operator alias does not create a lifecycle delivery mode"
fi
assert_yq "program review/revision loop is parent-local route pair" '.loops[]? | select(.loop_id == "program-review-revision" and .repeat_route_id == "revise-program" and (.terminal_values[]? == "accepted") and (.terminal_values[]? == "rejected"))'
assert_yq "program review route binds canonical command and skill" '.routes[]? | select(.route_id == "review-program" and .command_id == "octon-proposal-review-program" and .skill_id == "octon-proposal-lifecycle-review-program")'
assert_yq "program revise route binds canonical command and skill" '.routes[]? | select(.route_id == "revise-program" and .command_id == "octon-proposal-revise-program" and .skill_id == "octon-proposal-lifecycle-revise-program")'
if yq -e '.routes[]? | select(.route_id == "review-and-revise-program" or .route_id == "program-review-and-revise")' "$CONTRACT" >/dev/null 2>&1; then
  fail "standalone program review-and-revise route is absent"
else
  pass "standalone program review-and-revise route is absent"
fi
assert_yq "dirty or stale source defaults to route-owned clean worktree" '.delivery_modes[]? | select(.mode_id == "proposal-program-delivery") | .clean_worktree_route.dirty_or_stale_source_defaults_to_route_owned_clean_worktree == true'
assert_yq "include-path classification required before reconstruction and commit" '.delivery_modes[]? | select(.mode_id == "proposal-program-delivery") | .clean_worktree_route.include_path_classification_required_before_reconstruction_stage_commit == true'
assert_text "program lifecycle skill names order override receipt" "proposal-program-delivery-order-override-receipt-v1" "$SKILL"
assert_text "program lifecycle skill names delivery-readiness preflight" "delivery-readiness preflight" "$SKILL"
assert_text "program lifecycle skill names include-path classification" "include-path classification" "$SKILL"
assert_text "alias command document exists with label" "Run Program to Clean Delivery" "$ALIAS_COMMAND"
assert_text "alias command uses required inputs" "/octon-proposal-run-program-delivery target=<proposal-program-path> outcome=cleaned profile=<profile-path> run-id=<id>" "$ALIAS_COMMAND"
assert_text "alias command delegates to canonical wrapper" 'delegates to `proposal-program-delivery`' "$ALIAS_COMMAND"
assert_text "alias command denies independent lifecycle authority" "does not create an independent lifecycle contract" "$ALIAS_COMMAND"
assert_text "command manifest registers operator alias" "octon-proposal-run-program-delivery" "$COMMAND_MANIFEST"
if yq -e '.commands[]? | select(.id == "octon-proposal-run-program-delivery" and .display_name == "Run Program to Clean Delivery" and .argument_hint == "target=<proposal-program-path> outcome=cleaned profile=<profile-path> run-id=<id>")' "$COMMAND_MANIFEST" >/dev/null 2>&1; then
  pass "command manifest registers alias with required admission inputs"
else
  fail "command manifest registers alias with required admission inputs"
fi
if yq -e '.commands[]? | select(.id == "octon-proposal-review-and-revise-program" or .id == "octon-proposal-program-review-and-revise")' "$COMMAND_MANIFEST" >/dev/null 2>&1; then
  fail "command manifest has no standalone review-and-revise wrapper"
else
  pass "command manifest has no standalone review-and-revise wrapper"
fi
assert_text "bundle matrix exposes operator alias" "octon-proposal-run-program-delivery" "$BUNDLE_MATRIX"
assert_text "bundle matrix preserves canonical delivery skill" '| `proposal-program-delivery` | `proposal-program-delivery` |' "$BUNDLE_MATRIX"
assert_text "bundle matrix denies alias authority widening" "does not create an independent workflow, lifecycle mode" "$BUNDLE_MATRIX"
assert_text "program pattern documents review/revision loop" "program-review-revision" "$PROGRAM_PATTERN"
assert_text "program pattern denies review-and-revise wrapper" "standalone program review-and-revise wrapper" "$PROGRAM_PATTERN"
assert_text "review command documents review/revision loop" "program-review-revision" "$REVIEW_COMMAND"
assert_text "revise command documents review/revision loop" "program-review-revision" "$REVISE_COMMAND"
assert_text "review skill denies review-and-revise wrapper" "standalone program review-and-revise wrapper" "$REVIEW_SKILL"
assert_text "revise skill denies review-and-revise wrapper" "standalone program review-and-revise wrapper" "$REVISE_SKILL"
assert_text "program pattern keeps child manifests out of parent revision" "child manifests" "$PROGRAM_PATTERN"
assert_text "program pattern keeps child receipts target-owned" "child receipts" "$PROGRAM_PATTERN"
assert_text "program pattern keeps child validation verdicts target-owned" "child validation verdicts" "$PROGRAM_PATTERN"
assert_text "program pattern keeps child archive metadata target-owned" "child archive metadata" "$PROGRAM_PATTERN"
assert_text "program pattern keeps child terminal outcomes target-owned" "child terminal outcomes" "$PROGRAM_PATTERN"

printf '\nPassed: %s\nFailed: %s\n' "$pass_count" "$fail_count"
[[ "$fail_count" -eq 0 ]]

#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PACK_ROOT="$(cd -- "$SCRIPT_DIR/../.." && pwd)"
CONTRACT="$PACK_ROOT/context/lifecycles/proposal-program.contract.yml"
SKILL="$PACK_ROOT/skills/octon-proposal-lifecycle-run-program-lifecycle/SKILL.md"

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
assert_yq "dirty or stale source defaults to route-owned clean worktree" '.delivery_modes[]? | select(.mode_id == "proposal-program-delivery") | .clean_worktree_route.dirty_or_stale_source_defaults_to_route_owned_clean_worktree == true'
assert_yq "include-path classification required before reconstruction and commit" '.delivery_modes[]? | select(.mode_id == "proposal-program-delivery") | .clean_worktree_route.include_path_classification_required_before_reconstruction_stage_commit == true'
assert_text "program lifecycle skill names order override receipt" "proposal-program-delivery-order-override-receipt-v1" "$SKILL"
assert_text "program lifecycle skill names delivery-readiness preflight" "delivery-readiness preflight" "$SKILL"
assert_text "program lifecycle skill names include-path classification" "include-path classification" "$SKILL"

printf '\nPassed: %s\nFailed: %s\n' "$pass_count" "$fail_count"
[[ "$fail_count" -eq 0 ]]

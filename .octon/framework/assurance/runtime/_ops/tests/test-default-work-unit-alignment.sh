#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../../../../../.." && pwd)"
VALIDATOR="$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-default-work-unit-alignment.sh"

pass_count=0
fail_count=0

pass() { echo "PASS: $1"; pass_count=$((pass_count + 1)); }
fail() { echo "FAIL: $1" >&2; fail_count=$((fail_count + 1)); }

assert_success() {
  local label="$1"
  shift
  if "$@"; then pass "$label"; else fail "$label"; fi
}

case_live_repo_passes() {
  bash "$VALIDATOR" >/dev/null
}

case_receipt_schema_has_routes() {
  local schema="$ROOT_DIR/.octon/framework/product/contracts/change-receipt-v1.schema.json"
  jq -e '.properties.selected_route.enum | index("direct-main") and index("branch-no-pr") and index("branch-pr") and index("stage-only-escalate")' "$schema" >/dev/null
}

case_receipt_schema_requires_lifecycle_fields() {
  local schema="$ROOT_DIR/.octon/framework/product/contracts/change-receipt-v1.schema.json"
  jq -e '
    (.required | index("lifecycle_outcome")) and
    (.required | index("integration_status")) and
    (.required | index("publication_status")) and
    (.required | index("cleanup_status"))
  ' "$schema" >/dev/null
}

case_receipt_schema_has_lifecycle_outcomes() {
  local schema="$ROOT_DIR/.octon/framework/product/contracts/change-receipt-v1.schema.json"
  jq -e '
    (.properties.lifecycle_outcome.enum | index("preserved")) and
    (.properties.lifecycle_outcome.enum | index("branch-local-complete")) and
    (.properties.lifecycle_outcome.enum | index("published-branch")) and
    (.properties.lifecycle_outcome.enum | index("published")) and
    (.properties.lifecycle_outcome.enum | index("ready")) and
    (.properties.lifecycle_outcome.enum | index("landed")) and
    (.properties.lifecycle_outcome.enum | index("cleaned"))
  ' "$schema" >/dev/null
}

case_receipt_schema_has_hosted_landing_evidence() {
  local schema="$ROOT_DIR/.octon/framework/product/contracts/change-receipt-v1.schema.json"
  jq -e '
    (.properties.publication_status.enum | index("hosted-main-updated")) and
    (.properties.hosted_landing.required | index("provider_ruleset_ref")) and
    (.properties.hosted_landing.required | index("required_check_refs")) and
    (.properties.hosted_landing.required | index("target_post_ref"))
  ' "$schema" >/dev/null
}

case_policy_has_fail_closed_conditions() {
  local policy="$ROOT_DIR/.octon/framework/product/contracts/default-work-unit.yml"
  yq -e '.fail_closed_conditions[] | select(. == "missing_change_receipt")' "$policy" >/dev/null &&
    yq -e '.fail_closed_conditions[] | select(. == "provider_ruleset_blocks_requested_hosted_no_pr_landing")' "$policy" >/dev/null
}

case_policy_keeps_no_pr_landing_as_outcome() {
  local policy="$ROOT_DIR/.octon/framework/product/contracts/default-work-unit.yml"
  yq -e '.route_lifecycle_outcomes."branch-no-pr".allowed_outcomes[] | select(. == "landed")' "$policy" >/dev/null &&
    yq -e '.route_lifecycle_outcomes."branch-no-pr".landed_requires[] | select(. == "origin_main_equals_landed_ref_after_push")' "$policy" >/dev/null &&
    ! yq -e '.routes[]? | select(.route_id == "branch-land-no-pr")' "$policy" >/dev/null 2>&1
}

case_policy_defines_route_neutral_ruleset_target() {
  local policy="$ROOT_DIR/.octon/framework/product/contracts/default-work-unit.yml"
  yq -e '.hosted_provider_ruleset.target_model == "route-neutral protected main"' "$policy" >/dev/null &&
    yq -e '.hosted_provider_ruleset.universal_required_checks[] | select(. == "route_neutral_closeout_validation")' "$policy" >/dev/null &&
    yq -e '.hosted_provider_ruleset.pr_specific_checks[] | select(. == "AI Review Gate / decision")' "$policy" >/dev/null
}

main() {
  assert_success "default work unit validator passes live repo" case_live_repo_passes
  assert_success "receipt schema includes all route ids" case_receipt_schema_has_routes
  assert_success "receipt schema requires lifecycle status fields" case_receipt_schema_requires_lifecycle_fields
  assert_success "receipt schema includes lifecycle outcomes" case_receipt_schema_has_lifecycle_outcomes
  assert_success "receipt schema includes hosted no-PR landing evidence" case_receipt_schema_has_hosted_landing_evidence
  assert_success "machine policy includes fail-closed receipt condition" case_policy_has_fail_closed_conditions
  assert_success "machine policy keeps no-PR landing as branch-no-pr outcome" case_policy_keeps_no_pr_landing_as_outcome
  assert_success "machine policy defines route-neutral ruleset target" case_policy_defines_route_neutral_ruleset_target
  echo
  echo "Passed: $pass_count"
  echo "Failed: $fail_count"
  [[ "$fail_count" -eq 0 ]]
}

main "$@"

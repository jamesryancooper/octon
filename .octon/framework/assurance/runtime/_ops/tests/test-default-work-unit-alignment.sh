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

case_quickstart_has_route_matrix() {
  local quickstart="$ROOT_DIR/.octon/framework/execution-roles/practices/change-lifecycle-routing-quickstart.md"
  grep -Fq '## Route Matrix' "$quickstart" &&
    grep -Fq '| route | select when | allowed outcomes | required evidence | forbidden claims | handoff or escalation point |' "$quickstart" &&
    grep -Fq '`direct-main`' "$quickstart" &&
    grep -Fq '`branch-no-pr`' "$quickstart" &&
    grep -Fq '`branch-pr`' "$quickstart" &&
    grep -Fq '`stage-only-escalate`' "$quickstart"
}

case_quickstart_has_ruleset_table() {
  local quickstart="$ROOT_DIR/.octon/framework/execution-roles/practices/change-lifecycle-routing-quickstart.md"
  grep -Fq '## Ruleset State' "$quickstart" &&
    grep -Fq 'current live state' "$quickstart" &&
    grep -Fq 'repo-local target' "$quickstart" &&
    grep -Fq 'Do not claim live route-neutral migration from repo-local projection alone.' "$quickstart"
}

case_quickstart_has_fastest_safe_solo_route() {
  local quickstart="$ROOT_DIR/.octon/framework/execution-roles/practices/change-lifecycle-routing-quickstart.md"
  grep -Fq '## Fastest Safe Solo Route' "$quickstart" &&
    grep -Fq 'select `direct-main` when `main`' "$quickstart" &&
    grep -Fq 'Provider route-neutral capability is a hosted `branch-no-pr` landing' "$quickstart"
}

case_quickstart_has_post_landing_cleanup_sync() {
  local quickstart="$ROOT_DIR/.octon/framework/execution-roles/practices/change-lifecycle-routing-quickstart.md"
  grep -Fq 'full closeout while branch cleanup is pending' "$quickstart" &&
    grep -Fq 'local `main`, `origin/main`, and the recorded `landed_ref` are aligned' "$quickstart"
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

case_receipt_schema_blocks_cleaned_pending_cleanup() {
  local schema="$ROOT_DIR/.octon/framework/product/contracts/change-receipt-v1.schema.json"
  jq -e '
    [
      .allOf[]?
      | select(.if.properties.lifecycle_outcome.const == "cleaned")
      | select((.then.properties.cleanup_status.enum | index("completed")) != null)
      | select((.then.properties.cleanup_status.enum | index("deferred")) != null)
      | select((.then.properties.cleanup_status.enum | index("pending")) == null)
    ]
    | length == 1
  ' "$schema" >/dev/null
}

case_receipt_schema_blocks_completed_landed_branch_pending_cleanup() {
  local schema="$ROOT_DIR/.octon/framework/product/contracts/change-receipt-v1.schema.json"
  jq -e '
    [
      .allOf[]?
      | select(.if.properties.closeout_outcome.const == "completed")
      | select(.if.properties.integration_status.const == "landed")
      | select((.if.properties.selected_route.enum | index("branch-no-pr")) != null)
      | select((.if.properties.selected_route.enum | index("branch-pr")) != null)
      | select((.then.properties.cleanup_status.enum | index("completed")) != null)
      | select((.then.properties.cleanup_status.enum | index("deferred")) != null)
      | select((.then.properties.cleanup_status.enum | index("pending")) == null)
    ]
    | length == 1
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
    yq -e '.route_lifecycle_outcomes."branch-no-pr".landed_requires[] | select(. == "safe_branch_cleanup_completed_or_deferred_after_origin_main_contains_landed_ref")' "$policy" >/dev/null &&
    yq -e '.route_lifecycle_outcomes."branch-pr".landed_requires[] | select(. == "safe_branch_cleanup_completed_or_deferred_after_origin_main_contains_merged_result")' "$policy" >/dev/null &&
    yq -e '.route_lifecycle_outcomes."direct-main".full_closeout_requires[] | select(. == "local_main_equals_origin_main_after_fetch")' "$policy" >/dev/null &&
    yq -e '.route_lifecycle_outcomes."direct-main".full_closeout_requires[] | select(. == "local_main_contains_landed_ref_after_fetch")' "$policy" >/dev/null &&
    ! yq -e '.routes[]? | select(.route_id == "branch-land-no-pr")' "$policy" >/dev/null 2>&1
}

case_policy_defines_route_neutral_ruleset_target() {
  local policy="$ROOT_DIR/.octon/framework/product/contracts/default-work-unit.yml"
  yq -e '.hosted_provider_ruleset.target_model == "route-neutral protected main"' "$policy" >/dev/null &&
    yq -e '.hosted_provider_ruleset.universal_required_checks[] | select(. == "route_neutral_closeout_validation")' "$policy" >/dev/null &&
    yq -e '.hosted_provider_ruleset.universal_required_checks[] | select(. == "exact_source_sha_validation")' "$policy" >/dev/null &&
    yq -e '.hosted_provider_ruleset.pr_specific_checks[] | select(. == "AI Review Gate / decision")' "$policy" >/dev/null
}

case_policy_defines_solo_route_selection() {
  local policy="$ROOT_DIR/.octon/framework/product/contracts/default-work-unit.yml"
  yq -e '.solo_route_selection.rule == "Choose the fastest safe route that satisfies evidence, validation, rollback, cleanup, and protected-main controls."' "$policy" >/dev/null &&
    yq -e '.solo_route_selection.provider_route_neutral_capability == "hosted branch-no-pr landing precondition, not an independent reason to choose branch-no-pr"' "$policy" >/dev/null &&
    yq -e '.solo_route_selection.high_impact_rule == "high-impact increases caution and evidence requirements but does not by itself force branch-pr"' "$policy" >/dev/null
}

case_receipt_examples_cover_solo_routes() {
  local examples="$ROOT_DIR/.octon/framework/product/contracts/examples/change-receipts"
  jq -e '.selected_route == "direct-main" and .lifecycle_outcome == "landed" and .integration_method == "direct-commit"' "$examples/valid-direct-main-landed.json" >/dev/null &&
    jq -e '.selected_route == "branch-no-pr" and .lifecycle_outcome == "branch-local-complete" and .integration_status == "not_landed"' "$examples/valid-branch-no-pr-branch-local-complete.json" >/dev/null
}

case_closeout_skills_project_to_codex() {
  local registry="$ROOT_DIR/.octon/framework/capabilities/runtime/skills/registry.yml"
  local routing="$ROOT_DIR/.octon/generated/effective/capabilities/routing.effective.yml"
  yq -e '.skills."closeout-change".host_adapters[] | select(. == "codex")' "$registry" >/dev/null &&
    yq -e '.skills."closeout-pr".host_adapters[] | select(. == "codex")' "$registry" >/dev/null &&
    yq -e '.routing_candidates[] | select(.effective_id == "framework.skill.closeout-change") | .host_adapters[] | select(. == "codex")' "$routing" >/dev/null &&
    yq -e '.routing_candidates[] | select(.effective_id == "framework.skill.closeout-pr") | .host_adapters[] | select(. == "codex")' "$routing" >/dev/null &&
    [[ -f "$ROOT_DIR/.codex/skills/closeout-change/SKILL.md" ]] &&
    [[ -f "$ROOT_DIR/.codex/skills/closeout-pr/SKILL.md" ]]
}

case_closeout_tool_surface_supports_route_actions() {
  local closeout_change="$ROOT_DIR/.octon/framework/capabilities/runtime/skills/remediation/closeout-change/SKILL.md"
  grep -Fq 'Bash(git push *)' "$closeout_change" &&
    grep -Fq 'git-branch-push.sh' "$closeout_change" &&
    grep -Fq 'git-required-checks-at-ref.sh' "$closeout_change" &&
    grep -Fq 'git-branch-hosted-preflight.sh' "$closeout_change" &&
    grep -Fq 'git-branch-land-hosted-no-pr.sh' "$closeout_change"
}

main() {
  assert_success "default work unit validator passes live repo" case_live_repo_passes
  assert_success "quickstart has route matrix for all routes" case_quickstart_has_route_matrix
  assert_success "quickstart has live-vs-target ruleset table" case_quickstart_has_ruleset_table
  assert_success "quickstart has fastest safe solo route rule" case_quickstart_has_fastest_safe_solo_route
  assert_success "quickstart has post-landing cleanup and sync rules" case_quickstart_has_post_landing_cleanup_sync
  assert_success "receipt schema includes all route ids" case_receipt_schema_has_routes
  assert_success "receipt schema requires lifecycle status fields" case_receipt_schema_requires_lifecycle_fields
  assert_success "receipt schema includes lifecycle outcomes" case_receipt_schema_has_lifecycle_outcomes
  assert_success "receipt schema includes hosted no-PR landing evidence" case_receipt_schema_has_hosted_landing_evidence
  assert_success "receipt schema blocks cleaned with pending cleanup" case_receipt_schema_blocks_cleaned_pending_cleanup
  assert_success "receipt schema blocks completed landed branch closeout with pending cleanup" case_receipt_schema_blocks_completed_landed_branch_pending_cleanup
  assert_success "machine policy includes fail-closed receipt condition" case_policy_has_fail_closed_conditions
  assert_success "machine policy keeps no-PR landing as branch-no-pr outcome" case_policy_keeps_no_pr_landing_as_outcome
  assert_success "machine policy defines route-neutral ruleset target" case_policy_defines_route_neutral_ruleset_target
  assert_success "machine policy defines solo route selection semantics" case_policy_defines_solo_route_selection
  assert_success "receipt examples cover solo direct-main and branch-local routes" case_receipt_examples_cover_solo_routes
  assert_success "closeout skills project to Codex" case_closeout_skills_project_to_codex
  assert_success "closeout-change tool surface supports route actions" case_closeout_tool_surface_supports_route_actions
  echo
  echo "Passed: $pass_count"
  echo "Failed: $fail_count"
  [[ "$fail_count" -eq 0 ]]
}

main "$@"

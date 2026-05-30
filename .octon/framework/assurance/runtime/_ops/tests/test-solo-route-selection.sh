#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../../../../../.." && pwd)"
POLICY="$ROOT_DIR/.octon/framework/product/contracts/default-work-unit.yml"
QUICKSTART="$ROOT_DIR/.octon/framework/execution-roles/practices/change-lifecycle-routing-quickstart.md"
PLAYBOOK="$ROOT_DIR/.octon/framework/execution-roles/practices/git-autonomy-playbook.md"
FIXTURES="$ROOT_DIR/.octon/framework/assurance/runtime/_ops/fixtures/change-route-selection/solo-route-selection.yml"

pass_count=0
fail_count=0

pass() { echo "PASS: $1"; pass_count=$((pass_count + 1)); }
fail() { echo "FAIL: $1" >&2; fail_count=$((fail_count + 1)); }

assert_success() {
  local label="$1"
  shift
  if "$@"; then pass "$label"; else fail "$label"; fi
}

fact() {
  local idx="$1"
  local key="$2"
  yq -r ".cases[$idx].facts.$key // false" "$FIXTURES"
}

selected_route_for_case() {
  local idx="$1"

  if [[ "$(fact "$idx" change_identity_resolved)" != "true" ]]; then
    printf 'stage-only-escalate\n'
    return
  fi

  if [[ "$(fact "$idx" requested_hosted_no_pr_landing)" == "true" && "$(fact "$idx" provider_ruleset_requires_pr)" == "true" && "$(fact "$idx" explicit_operator_pr_request)" != "true" ]]; then
    printf 'stage-only-escalate\n'
    return
  fi

  if [[ "$(fact "$idx" explicit_operator_pr_request)" == "true" || "$(fact "$idx" hosted_review_required)" == "true" || "$(fact "$idx" preview_publication_required)" == "true" || "$(fact "$idx" external_signoff_required)" == "true" || "$(fact "$idx" provider_ruleset_requires_pr)" == "true" || "$(fact "$idx" release_automation_requires_pr)" == "true" || "$(fact "$idx" existing_pr_context)" == "true" ]]; then
    printf 'branch-pr\n'
    return
  fi

  if [[ "$(fact "$idx" current_branch_main)" == "true" && "$(fact "$idx" main_clean_current)" == "true" && "$(fact "$idx" no_unrelated_changes)" == "true" && "$(fact "$idx" solo_low_risk)" == "true" && "$(fact "$idx" local_validation_sufficient)" == "true" && "$(fact "$idx" straightforward_rollback)" == "true" && "$(fact "$idx" change_receipt_available)" == "true" && "$(fact "$idx" branch_isolation_needed)" != "true" ]]; then
    printf 'direct-main\n'
    return
  fi

  if [[ "$(fact "$idx" branch_isolation_needed)" == "true" && "$(fact "$idx" local_validation_sufficient)" == "true" && "$(fact "$idx" change_receipt_available)" == "true" ]]; then
    printf 'branch-no-pr\n'
    return
  fi

  printf 'stage-only-escalate\n'
}

case_static_contracts_match_solo_rule() {
  yq -e '.solo_route_selection.rule == "Choose the fastest safe route that satisfies evidence, validation, rollback, cleanup, and protected-main controls."' "$POLICY" >/dev/null &&
    yq -e '.solo_route_selection.direct_main_first_when_all[] | select(. == "clean_current_main")' "$POLICY" >/dev/null &&
    yq -e '.solo_route_selection.provider_route_neutral_capability == "hosted branch-no-pr landing precondition, not an independent reason to choose branch-no-pr"' "$POLICY" >/dev/null &&
    yq -e '.solo_route_selection.high_impact_rule == "high-impact increases caution and evidence requirements but does not by itself force branch-pr"' "$POLICY" >/dev/null &&
    yq -e '.solo_route_selection.branch_no_pr_preference_rule == "when direct-main is ineligible and no concrete PR predicate is proven with evidence, prefer branch-no-pr for branch-isolated work"' "$POLICY" >/dev/null &&
    grep -Fq "## Fastest Safe Solo Route" "$QUICKSTART" &&
    grep -Fq "Provider route-neutral capability is a hosted \`branch-no-pr\` landing" "$QUICKSTART"
}

case_route_order_prefers_direct_main_before_branch_no_pr() {
  local order
  order="$(yq -r '.route_selection_order[]' "$POLICY")"
  grep -Fq "direct-main" <<<"$order" &&
    [[ "$(grep -n '^direct-main$' <<<"$order" | cut -d: -f1)" -lt "$(grep -n '^branch-no-pr$' <<<"$order" | cut -d: -f1)" ]]
}

case_playbook_avoids_universal_branch_start() {
  ! grep -Fq "New work starts in a branch worktree, not on \`main\`." "$PLAYBOOK" &&
    ! grep -Fq "all new work" "$PLAYBOOK" &&
    grep -Fq "New work starts with Change route selection." "$PLAYBOOK"
}

case_route_fixtures_match_expected_routes() {
  local count idx expected actual
  count="$(yq -r '.cases | length' "$FIXTURES")"
  idx=0
  while [[ "$idx" -lt "$count" ]]; do
    expected="$(yq -r ".cases[$idx].expected_route" "$FIXTURES")"
    actual="$(selected_route_for_case "$idx")"
    if [[ "$actual" != "$expected" ]]; then
      echo "case $(yq -r ".cases[$idx].id" "$FIXTURES"): expected $expected, got $actual" >&2
      return 1
    fi
    idx=$((idx + 1))
  done
}

main() {
  command -v yq >/dev/null 2>&1 || { echo "yq is required" >&2; exit 1; }

  assert_success "static contracts describe fastest safe solo route" case_static_contracts_match_solo_rule
  assert_success "route order considers direct-main before branch-no-pr" case_route_order_prefers_direct_main_before_branch_no_pr
  assert_success "playbook avoids universal branch-worktree start" case_playbook_avoids_universal_branch_start
  assert_success "solo route-selection fixtures match expected routes" case_route_fixtures_match_expected_routes

  echo
  echo "Passed: $pass_count"
  echo "Failed: $fail_count"
  [[ "$fail_count" -eq 0 ]]
}

main "$@"

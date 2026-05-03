#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
DEFAULT_ROOT_DIR="$(cd -- "$DEFAULT_OCTON_DIR/.." && pwd)"
ROOT_DIR="$DEFAULT_ROOT_DIR"

usage() {
  cat <<'USAGE'
usage:
  validate-github-projection-alignment.sh [--root <repo-root>]

Validates repo-local GitHub projection alignment for the Change Lifecycle
Routing Model. This is static validation only and does not mutate live GitHub
settings.
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --root)
      shift
      [[ $# -gt 0 ]] || { usage >&2; exit 2; }
      ROOT_DIR="$1"
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      usage >&2
      exit 2
      ;;
  esac
  shift
done

ROOT_DIR="$(cd -- "$ROOT_DIR" && pwd)"
OCTON_DIR="$ROOT_DIR/.octon"
GITHUB_DIR="$ROOT_DIR/.github"

MAIN_GUARD="$GITHUB_DIR/workflows/main-change-route-guard.yml"
OLD_MAIN_GUARD="$GITHUB_DIR/workflows/main-pr-first-guard.yml"
CHANGE_ROUTE_WORKFLOW="$GITHUB_DIR/workflows/change-route-projection.yml"
COMMIT_BRANCH_WORKFLOW="$GITHUB_DIR/workflows/commit-and-branch-standards.yml"
PR_AUTONOMY_WORKFLOW="$GITHUB_DIR/workflows/pr-autonomy-policy.yml"
AI_REVIEW_WORKFLOW="$GITHUB_DIR/workflows/ai-review-gate.yml"
PR_QUALITY_WORKFLOW="$GITHUB_DIR/workflows/pr-quality.yml"
PR_AUTO_MERGE_WORKFLOW="$GITHUB_DIR/workflows/pr-auto-merge.yml"
PR_CLEAN_STATE_WORKFLOW="$GITHUB_DIR/workflows/pr-clean-state-enforcer.yml"
CODEX_PR_REVIEW_WORKFLOW="$GITHUB_DIR/workflows/codex-pr-review.yml"
CONTROL_CONTRACT="$OCTON_DIR/framework/execution-roles/practices/standards/github-control-plane-contract.json"
AI_GATE_POLICY="$OCTON_DIR/framework/execution-roles/practices/standards/ai-gate-policy.json"
HOSTED_NO_PR_VALIDATOR="$OCTON_DIR/framework/assurance/runtime/_ops/scripts/validate-hosted-no-pr-landing.sh"
RULESET_VALIDATOR="$OCTON_DIR/framework/assurance/runtime/_ops/scripts/validate-github-main-ruleset-alignment.sh"

errors=0

pass() { echo "[OK] $1"; }
fail() { echo "[ERROR] $1"; errors=$((errors + 1)); }

require_file() {
  local file="$1"
  [[ -f "$file" ]] && pass "found ${file#$ROOT_DIR/}" || fail "missing ${file#$ROOT_DIR/}"
}

forbid_file() {
  local file="$1"
  [[ ! -e "$file" ]] && pass "absent ${file#$ROOT_DIR/}" || fail "removed file still exists: ${file#$ROOT_DIR/}"
}

require_literal() {
  local file="$1"
  local needle="$2"
  local ok_msg="$3"
  local fail_msg="$4"
  grep -Fq -- "$needle" "$file" && pass "$ok_msg" || fail "$fail_msg"
}

forbid_literal() {
  local file="$1"
  local needle="$2"
  local ok_msg="$3"
  local fail_msg="$4"
  if grep -Fq -- "$needle" "$file"; then
    fail "$fail_msg"
  else
    pass "$ok_msg"
  fi
}

require_jq() {
  local file="$1"
  local expr="$2"
  local ok_msg="$3"
  local fail_msg="$4"
  jq -e "$expr" "$file" >/dev/null 2>&1 && pass "$ok_msg" || fail "$fail_msg"
}

search_regex() {
  local pattern="$1"
  shift
  if command -v rg >/dev/null 2>&1; then
    rg -n -- "$pattern" "$@" 2>/dev/null || true
  else
    grep -REn -- "$pattern" "$@" 2>/dev/null || true
  fi
}

existing_search_roots() {
  local root
  for root in "$GITHUB_DIR" "$OCTON_DIR/framework" "$OCTON_DIR/instance"; do
    [[ -e "$root" ]] && printf '%s\n' "$root"
  done
}

check_guard_projection() {
  require_file "$MAIN_GUARD"
  forbid_file "$OLD_MAIN_GUARD"
  require_literal "$MAIN_GUARD" "name: Main Change Route Guard" "main guard has route-aware workflow name" "main guard must use route-aware workflow name"
  require_literal "$MAIN_GUARD" "classify-main-change-route" "main guard uses route-aware job id" "main guard must use route-aware job id"
  require_literal "$MAIN_GUARD" "branch-pr" "main guard accepts branch-pr mode" "main guard must classify branch-pr mode"
  require_literal "$MAIN_GUARD" "direct-main" "main guard accepts direct-main mode" "main guard must classify direct-main mode"
  require_literal "$MAIN_GUARD" "branch-no-pr" "main guard accepts branch-no-pr mode" "main guard must classify branch-no-pr mode"
  require_literal "$MAIN_GUARD" "break-glass" "main guard preserves break-glass mode" "main guard must preserve break-glass mode"
  require_literal "$MAIN_GUARD" "hosted_landing.provider_ruleset_ref" "main guard requires provider ruleset evidence for hosted no-PR" "main guard must require provider ruleset evidence"
  require_literal "$MAIN_GUARD" "hosted_landing.source_ref is not an exact commit SHA" "main guard validates exact source SHA" "main guard must validate exact source SHA"
  require_literal "$MAIN_GUARD" "target_post_ref does not equal landed_ref" "main guard requires target post-ref equals landed ref" "main guard must require target post-ref equals landed ref"
  require_literal "$MAIN_GUARD" "Accepted modes are branch-pr merged PR, direct-main Change receipt, hosted branch-no-pr Change receipt, or authorized break-glass." "main guard fails closed with route-aware message" "main guard must fail closed with route-aware message"
  forbid_literal "$MAIN_GUARD" "Enforce PR-first" "main guard does not use PR-first job copy" "main guard must not use PR-first job copy"
}

check_route_neutral_projection_workflow() {
  require_file "$CHANGE_ROUTE_WORKFLOW"
  require_literal "$CHANGE_ROUTE_WORKFLOW" "route_neutral_closeout_validation" "route-neutral closeout check is projected" "route-neutral closeout check must be projected"
  require_literal "$CHANGE_ROUTE_WORKFLOW" "branch_naming_validation" "branch naming check is projected" "branch naming check must be projected"
  require_literal "$CHANGE_ROUTE_WORKFLOW" "route_aware_autonomy_validation" "route-aware autonomy check is projected" "route-aware autonomy check must be projected"
  require_literal "$CHANGE_ROUTE_WORKFLOW" "exact_source_sha_validation" "exact source SHA check is projected" "exact source SHA check must be projected"
  require_literal "$CHANGE_ROUTE_WORKFLOW" "hosted_landing.source_ref == \$sha" "hosted no-PR receipt is tied to exact source SHA" "hosted no-PR receipt must be tied to exact source SHA"
  require_literal "$CHANGE_ROUTE_WORKFLOW" "validate-hosted-no-pr-landing.sh" "hosted no-PR validator runs in projection workflow" "hosted no-PR validator must run in projection workflow"
  require_literal "$COMMIT_BRANCH_WORKFLOW" "group: change-route-" "branch/commit standards use route-neutral concurrency" "branch/commit standards must not use required-pr concurrency"
}

check_pr_specific_scope() {
  require_file "$AI_REVIEW_WORKFLOW"
  require_file "$PR_QUALITY_WORKFLOW"
  require_file "$PR_AUTO_MERGE_WORKFLOW"
  require_file "$PR_AUTONOMY_WORKFLOW"
  require_file "$PR_CLEAN_STATE_WORKFLOW"
  require_file "$CODEX_PR_REVIEW_WORKFLOW"

  require_literal "$AI_REVIEW_WORKFLOW" "pull_request:" "AI review gate is PR-triggered" "AI review gate must be PR-triggered"
  forbid_literal "$AI_REVIEW_WORKFLOW" "  push:" "AI review gate has no push trigger" "AI review gate must not run as a universal push gate"
  require_literal "$PR_QUALITY_WORKFLOW" "pull_request:" "PR quality is PR-triggered" "PR quality must be PR-triggered"
  forbid_literal "$PR_QUALITY_WORKFLOW" "  push:" "PR quality has no push trigger" "PR quality must not run as a universal push gate"
  require_literal "$PR_AUTO_MERGE_WORKFLOW" "pull_request_target:" "PR auto-merge is PR-target triggered" "PR auto-merge must be PR-target triggered"
  forbid_literal "$PR_AUTO_MERGE_WORKFLOW" "  push:" "PR auto-merge has no push trigger" "PR auto-merge must not run as a universal push gate"
  require_literal "$PR_CLEAN_STATE_WORKFLOW" "pull_request_target:" "PR clean-state is PR-target triggered" "PR clean-state must be PR-target triggered"
  require_literal "$CODEX_PR_REVIEW_WORKFLOW" "pull_request:" "Codex PR review is PR-triggered" "Codex PR review must be PR-triggered"
  require_literal "$PR_AUTONOMY_WORKFLOW" "branches-ignore:" "PR autonomy excludes main pushes" "PR autonomy must exclude main pushes"
  require_literal "$PR_AUTONOMY_WORKFLOW" "- main" "PR autonomy excludes main branch" "PR autonomy must exclude main branch"
}

check_control_contracts() {
  require_file "$CONTROL_CONTRACT"
  require_file "$AI_GATE_POLICY"
  require_jq "$CONTROL_CONTRACT" '.scope.projection_host_for == "route-aware Change lifecycle GitHub projection"' "control contract is route-aware projection" "control contract must be route-aware projection"
  require_jq "$CONTROL_CONTRACT" '.rulesets.current_live_main.expectation == "current-pr-required"' "control contract distinguishes current live ruleset" "control contract must distinguish current live ruleset"
  require_jq "$CONTROL_CONTRACT" '.rulesets.target_route_neutral_main.expectation == "target-route-neutral"' "control contract defines target route-neutral ruleset" "control contract must define target route-neutral ruleset"
  require_jq "$CONTROL_CONTRACT" '.rulesets.target_route_neutral_main.universal_required_checks[]? | select(. == "route_neutral_closeout_validation")' "target includes route-neutral closeout check" "target must include route-neutral closeout check"
  require_jq "$CONTROL_CONTRACT" '.rulesets.target_route_neutral_main.universal_required_checks[]? | select(. == "branch_naming_validation")' "target includes branch naming check" "target must include branch naming check"
  require_jq "$CONTROL_CONTRACT" '.rulesets.target_route_neutral_main.universal_required_checks[]? | select(. == "route_aware_autonomy_validation")' "target includes route-aware autonomy check" "target must include route-aware autonomy check"
  require_jq "$CONTROL_CONTRACT" '.rulesets.target_route_neutral_main.universal_required_checks[]? | select(. == "exact_source_sha_validation")' "target includes exact source SHA check" "target must include exact source SHA check"
  require_jq "$CONTROL_CONTRACT" '(.rulesets.target_route_neutral_main.universal_required_checks | index("AI Review Gate / decision") | not) and (.rulesets.target_route_neutral_main.universal_required_checks | index("PR Quality Standards") | not)' "PR checks are not universal target main checks" "PR checks must not be universal target main checks"
  require_jq "$CONTROL_CONTRACT" '.rulesets.target_route_neutral_main.pr_specific_checks[]? | select(. == "AI Review Gate / decision")' "AI review gate remains PR-specific" "AI review gate must remain PR-specific"
  require_jq "$CONTROL_CONTRACT" '.rulesets.target_route_neutral_main.pr_specific_checks[]? | select(. == "PR Quality Standards")' "PR quality remains PR-specific" "PR quality must remain PR-specific"
  require_jq "$CONTROL_CONTRACT" '.rulesets.target_route_neutral_main.live_mutation_performed_by_this_projection == false' "control contract says live mutation not performed" "control contract must not claim live mutation"
  require_jq "$AI_GATE_POLICY" '.route_scope.hosted_gate_route == "branch-pr" and .route_scope.no_pr_change_gate_required == false' "AI gate policy remains branch-pr scoped" "AI gate policy must remain branch-pr scoped"
}

check_validators() {
  require_file "$HOSTED_NO_PR_VALIDATOR"
  require_file "$RULESET_VALIDATOR"
  require_literal "$HOSTED_NO_PR_VALIDATOR" "pushed-only branches" "hosted no-PR validator rejects pushed-only landing claims" "hosted no-PR validator must reject pushed-only landing claims"
  require_literal "$HOSTED_NO_PR_VALIDATOR" "validated_ref must equal source_ref" "hosted no-PR validator requires exact source validation" "hosted no-PR validator must require exact source validation"
  require_literal "$RULESET_VALIDATOR" "current-pr-required|target-route-neutral" "ruleset validator supports current and target expectations" "ruleset validator must support current and target expectations"
  require_literal "$RULESET_VALIDATOR" "PR-required ruleset blocks hosted branch-no-pr landing" "ruleset validator detects current PR-required blocker" "ruleset validator must detect current PR-required blocker"

  local mutation
  mutation="$(search_regex '--method[[:space:]]+(PATCH|POST|PUT|DELETE)|-X[[:space:]]+(PATCH|POST|PUT|DELETE)' "$RULESET_VALIDATOR")"
  if [[ -n "$mutation" ]]; then
    printf '%s\n' "$mutation"
    fail "ruleset validator must not mutate live GitHub settings"
  else
    pass "ruleset validator is read-only"
  fi
}

check_stale_projection_drift() {
  local stale_github
  stale_github="$(search_regex 'PR-first|pr-first|main-pr-first|required-pr-|Main PR-First|Enforce PR-first|Direct pushes to main are blocked|\[main-pr-first\]' "$GITHUB_DIR")"
  if [[ -n "$stale_github" ]]; then
    printf '%s\n' "$stale_github"
    fail ".github projection must not retain universal PR-first language"
  else
    pass ".github projection avoids universal PR-first language"
  fi

  local old_ref_roots=()
  while IFS= read -r root; do
    old_ref_roots+=("$root")
  done < <(existing_search_roots)

  local old_refs
  old_refs="$(
    search_regex 'main-pr-first-guard\.yml|main-pr-first' "${old_ref_roots[@]}" \
      | grep -v 'validate-github-projection-alignment.sh' \
      | grep -v 'test-github-projection-alignment.sh' \
      || true
  )"
  if [[ -n "$old_refs" ]]; then
    printf '%s\n' "$old_refs"
    fail "old main PR-first guard references must be removed"
  else
    pass "old main PR-first guard references are removed"
  fi
}

main() {
  echo "== GitHub Projection Alignment Validation =="
  command -v jq >/dev/null 2>&1 || { echo "[ERROR] jq is required" >&2; exit 1; }

  check_guard_projection
  check_route_neutral_projection_workflow
  check_pr_specific_scope
  check_control_contracts
  check_validators
  check_stale_projection_drift

  echo
  echo "Validation summary: errors=$errors"
  [[ "$errors" -eq 0 ]]
}

main "$@"

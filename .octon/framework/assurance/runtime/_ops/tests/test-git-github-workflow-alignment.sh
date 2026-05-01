#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../../../../../.." && pwd)"
VALIDATOR="$REPO_ROOT/.octon/framework/assurance/runtime/_ops/scripts/validate-git-github-workflow-alignment.sh"

pass_count=0
fail_count=0
declare -a CLEANUP_DIRS=()

cleanup() {
  local dir
  for dir in "${CLEANUP_DIRS[@]}"; do
    [[ -n "$dir" ]] && rm -r -f -- "$dir"
  done
}
trap cleanup EXIT

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

create_fixture() {
  local fixture_root
  fixture_root="$(mktemp -d)"
  CLEANUP_DIRS+=("$fixture_root")

  mkdir -p \
    "$fixture_root/.octon/framework/product/contracts" \
    "$fixture_root/.octon/framework/execution-roles/practices/standards" \
    "$fixture_root/.octon/framework/execution-roles/practices" \
    "$fixture_root/.octon/framework/execution-roles/_ops/scripts/git" \
    "$fixture_root/.octon/framework/assurance/governance/_ops/scripts" \
    "$fixture_root/.octon/framework/orchestration/runtime/workflows/meta/closeout" \
    "$fixture_root/.octon/framework/capabilities/runtime/skills/remediation/closeout-change" \
    "$fixture_root/.octon/framework/capabilities/runtime/skills/remediation/closeout-pr" \
    "$fixture_root/.octon/framework/capabilities/runtime/skills/remediation/resolve-pr-comments/references" \
    "$fixture_root/.octon/framework/engine/runtime/adapters/host" \
    "$fixture_root/.octon/framework/assurance/runtime/_ops/scripts" \
    "$fixture_root/.octon/instance/ingress" \
    "$fixture_root/.github/workflows"

  cp "$REPO_ROOT/.octon/framework/product/contracts/default-work-unit.yml" \
    "$fixture_root/.octon/framework/product/contracts/default-work-unit.yml"
  cp "$REPO_ROOT/.octon/framework/execution-roles/practices/standards/git-worktree-autonomy-contract.yml" \
    "$fixture_root/.octon/framework/execution-roles/practices/standards/git-worktree-autonomy-contract.yml"
  cp "$REPO_ROOT/.octon/framework/orchestration/runtime/workflows/meta/closeout/workflow.yml" \
    "$fixture_root/.octon/framework/orchestration/runtime/workflows/meta/closeout/workflow.yml"
  cp "$REPO_ROOT/.octon/instance/ingress/manifest.yml" \
    "$fixture_root/.octon/instance/ingress/manifest.yml"
  cp "$REPO_ROOT/.octon/instance/ingress/AGENTS.md" \
    "$fixture_root/.octon/instance/ingress/AGENTS.md"
  cp "$REPO_ROOT/.octon/framework/execution-roles/practices/git-autonomy-playbook.md" \
    "$fixture_root/.octon/framework/execution-roles/practices/git-autonomy-playbook.md"
  cp "$REPO_ROOT/.octon/framework/execution-roles/practices/git-github-autonomy-workflow-v1.md" \
    "$fixture_root/.octon/framework/execution-roles/practices/git-github-autonomy-workflow-v1.md"
  cp "$REPO_ROOT/.octon/framework/execution-roles/practices/pull-request-standards.md" \
    "$fixture_root/.octon/framework/execution-roles/practices/pull-request-standards.md"
  cp "$REPO_ROOT/.octon/framework/execution-roles/_ops/scripts/git/git-pr-open.sh" \
    "$fixture_root/.octon/framework/execution-roles/_ops/scripts/git/git-pr-open.sh"
  cp "$REPO_ROOT/.octon/framework/execution-roles/_ops/scripts/git/git-pr-ship.sh" \
    "$fixture_root/.octon/framework/execution-roles/_ops/scripts/git/git-pr-ship.sh"
  cp "$REPO_ROOT/.octon/framework/execution-roles/_ops/scripts/git/git-wt-new.sh" \
    "$fixture_root/.octon/framework/execution-roles/_ops/scripts/git/git-wt-new.sh"
  cp "$REPO_ROOT/.octon/framework/execution-roles/_ops/scripts/git/git-branch-commit.sh" \
    "$fixture_root/.octon/framework/execution-roles/_ops/scripts/git/git-branch-commit.sh"
  cp "$REPO_ROOT/.octon/framework/execution-roles/_ops/scripts/git/git-branch-push.sh" \
    "$fixture_root/.octon/framework/execution-roles/_ops/scripts/git/git-branch-push.sh"
  cp "$REPO_ROOT/.octon/framework/execution-roles/_ops/scripts/git/git-branch-land.sh" \
    "$fixture_root/.octon/framework/execution-roles/_ops/scripts/git/git-branch-land.sh"
  cp "$REPO_ROOT/.octon/framework/execution-roles/_ops/scripts/git/git-required-checks-at-ref.sh" \
    "$fixture_root/.octon/framework/execution-roles/_ops/scripts/git/git-required-checks-at-ref.sh"
  cp "$REPO_ROOT/.octon/framework/execution-roles/_ops/scripts/git/git-branch-hosted-preflight.sh" \
    "$fixture_root/.octon/framework/execution-roles/_ops/scripts/git/git-branch-hosted-preflight.sh"
  cp "$REPO_ROOT/.octon/framework/execution-roles/_ops/scripts/git/git-branch-land-hosted-no-pr.sh" \
    "$fixture_root/.octon/framework/execution-roles/_ops/scripts/git/git-branch-land-hosted-no-pr.sh"
  cp "$REPO_ROOT/.octon/framework/execution-roles/_ops/scripts/git/git-branch-cleanup.sh" \
    "$fixture_root/.octon/framework/execution-roles/_ops/scripts/git/git-branch-cleanup.sh"
  cp "$REPO_ROOT/.octon/framework/assurance/governance/_ops/scripts/evaluate-pr-autonomy-policy.sh" \
    "$fixture_root/.octon/framework/assurance/governance/_ops/scripts/evaluate-pr-autonomy-policy.sh"
  cp "$REPO_ROOT/.octon/framework/capabilities/runtime/skills/remediation/closeout-change/SKILL.md" \
    "$fixture_root/.octon/framework/capabilities/runtime/skills/remediation/closeout-change/SKILL.md"
  cp "$REPO_ROOT/.octon/framework/capabilities/runtime/skills/remediation/closeout-pr/SKILL.md" \
    "$fixture_root/.octon/framework/capabilities/runtime/skills/remediation/closeout-pr/SKILL.md"
  cp "$REPO_ROOT/.octon/framework/capabilities/runtime/skills/remediation/resolve-pr-comments/SKILL.md" \
    "$fixture_root/.octon/framework/capabilities/runtime/skills/remediation/resolve-pr-comments/SKILL.md"
  cp "$REPO_ROOT/.octon/framework/capabilities/runtime/skills/remediation/resolve-pr-comments/references/safety.md" \
    "$fixture_root/.octon/framework/capabilities/runtime/skills/remediation/resolve-pr-comments/references/safety.md"
  cp "$REPO_ROOT/.github/PULL_REQUEST_TEMPLATE.md" \
    "$fixture_root/.github/PULL_REQUEST_TEMPLATE.md"
  cp "$REPO_ROOT/.github/workflows/pr-quality.yml" \
    "$fixture_root/.github/workflows/pr-quality.yml"
  cp "$REPO_ROOT/.github/workflows/pr-autonomy-policy.yml" \
    "$fixture_root/.github/workflows/pr-autonomy-policy.yml"
  cp "$REPO_ROOT/.github/workflows/commit-and-branch-standards.yml" \
    "$fixture_root/.github/workflows/commit-and-branch-standards.yml"
  cp "$REPO_ROOT/.github/workflows/pr-auto-merge.yml" \
    "$fixture_root/.github/workflows/pr-auto-merge.yml"
  cp "$REPO_ROOT/.github/workflows/main-pr-first-guard.yml" \
    "$fixture_root/.github/workflows/main-pr-first-guard.yml"
  cp "$REPO_ROOT/.github/workflows/ci-efficiency-guard.yml" \
    "$fixture_root/.github/workflows/ci-efficiency-guard.yml"
  cp "$REPO_ROOT/.octon/framework/engine/runtime/adapters/host/github-control-plane.yml" \
    "$fixture_root/.octon/framework/engine/runtime/adapters/host/github-control-plane.yml"
  cp "$REPO_ROOT/.octon/framework/engine/runtime/adapters/host/repo-shell.yml" \
    "$fixture_root/.octon/framework/engine/runtime/adapters/host/repo-shell.yml"
  cp "$VALIDATOR" \
    "$fixture_root/.octon/framework/assurance/runtime/_ops/scripts/validate-git-github-workflow-alignment.sh"
  cp "$REPO_ROOT/.octon/framework/assurance/runtime/_ops/scripts/validate-hosted-no-pr-landing.sh" \
    "$fixture_root/.octon/framework/assurance/runtime/_ops/scripts/validate-hosted-no-pr-landing.sh"
  cp "$REPO_ROOT/.octon/framework/assurance/runtime/_ops/scripts/validate-github-main-ruleset-alignment.sh" \
    "$fixture_root/.octon/framework/assurance/runtime/_ops/scripts/validate-github-main-ruleset-alignment.sh"

  printf '%s\n' "$fixture_root"
}

run_validator() {
  local fixture_root="$1"
  (
    cd "$fixture_root"
    bash ".octon/framework/assurance/runtime/_ops/scripts/validate-git-github-workflow-alignment.sh" >/dev/null
  )
}

case_live_repo_passes() {
  bash "$VALIDATOR" >/dev/null
}

case_policy_missing_direct_main_route_fails() {
  local fixture_root
  fixture_root="$(create_fixture)"
  perl -0pi -e 's/route_id: "direct-main"/route_id: "direct-main-disabled"/' \
    "$fixture_root/.octon/framework/product/contracts/default-work-unit.yml"
  ! run_validator "$fixture_root"
}

case_worktree_guard_missing_branch_routes_fails() {
  local fixture_root
  fixture_root="$(create_fixture)"
  perl -0pi -e 's/branch-no-pr or branch-pr only/direct-main allowed/g' \
    "$fixture_root/.octon/framework/execution-roles/practices/standards/git-worktree-autonomy-contract.yml"
  ! run_validator "$fixture_root"
}

case_no_pr_landing_route_proliferation_fails() {
  local fixture_root
  fixture_root="$(create_fixture)"
  perl -0pi -e 's/route_id: "stage-only-escalate"/route_id: "branch-land-no-pr"/' \
    "$fixture_root/.octon/framework/product/contracts/default-work-unit.yml"
  ! run_validator "$fixture_root"
}

case_pr_open_missing_branch_pr_guard_fails() {
  local fixture_root
  fixture_root="$(create_fixture)"
  perl -0pi -e 's/branch-pr/branch-no-pr/g' \
    "$fixture_root/.octon/framework/execution-roles/_ops/scripts/git/git-pr-open.sh"
  ! run_validator "$fixture_root"
}

case_branch_land_tip_only_cherry_pick_fails() {
  local fixture_root
  fixture_root="$(create_fixture)"
  perl -0pi -e 's/CHERRY_PICK_COMMITS="\$\(git -C "\$REPO_ROOT" rev-list --reverse "\$TARGET_PRE_REF\.\.\$SOURCE_REF"\)"\n    \[\[ -n "\$CHERRY_PICK_COMMITS" \]\] \|\| error "No source commits to cherry-pick from \$SOURCE_BRANCH onto \$TARGET_BRANCH\."\n    while IFS= read -r commit; do\n      \[\[ -n "\$commit" \]\] \|\| continue\n      run_cmd git -C "\$REPO_ROOT" cherry-pick "\$commit"\n    done <<<"\$CHERRY_PICK_COMMITS"/run_cmd git -C "\$REPO_ROOT" cherry-pick "\$SOURCE_BRANCH"/' \
    "$fixture_root/.octon/framework/execution-roles/_ops/scripts/git/git-branch-land.sh"
  ! run_validator "$fixture_root"
}

case_closeout_change_allows_pr_without_route_fails() {
  local fixture_root
  fixture_root="$(create_fixture)"
  perl -0pi -e 's/Do not open a PR unless route selection returns `branch-pr`\./Open a PR when publication is convenient./' \
    "$fixture_root/.octon/framework/capabilities/runtime/skills/remediation/closeout-change/SKILL.md"
  ! run_validator "$fixture_root"
}

case_hosted_no_pr_helper_allows_pr_mutation_fails() {
  local fixture_root
  fixture_root="$(create_fixture)"
  printf '\n# gh pr create\n' >>"$fixture_root/.octon/framework/execution-roles/_ops/scripts/git/git-branch-land-hosted-no-pr.sh"
  ! run_validator "$fixture_root"
}

case_hosted_preflight_loses_pr_required_blocker_fails() {
  local fixture_root
  fixture_root="$(create_fixture)"
  perl -0pi -e 's/Provider ruleset requires PR; hosted branch-no-pr landing unavailable\./Provider ruleset warning only./g' \
    "$fixture_root/.octon/framework/execution-roles/_ops/scripts/git/git-branch-hosted-preflight.sh"
  ! run_validator "$fixture_root"
}

main() {
  assert_success "workflow alignment validator passes on live repo" case_live_repo_passes
  assert_success "workflow alignment validator fails when policy loses direct-main route" case_policy_missing_direct_main_route_fails
  assert_success "workflow alignment validator fails when worktree guard loses branch-route scope" case_worktree_guard_missing_branch_routes_fails
  assert_success "workflow alignment validator fails on branch-land-no-pr route proliferation" case_no_pr_landing_route_proliferation_fails
  assert_success "workflow alignment validator fails when PR helper loses branch-pr guard" case_pr_open_missing_branch_pr_guard_fails
  assert_success "workflow alignment validator fails when branch landing cherry-picks only branch tip" case_branch_land_tip_only_cherry_pick_fails
  assert_success "workflow alignment validator fails when closeout-change allows PR before routing" case_closeout_change_allows_pr_without_route_fails
  assert_success "workflow alignment validator fails when hosted no-PR helper mutates PRs" case_hosted_no_pr_helper_allows_pr_mutation_fails
  assert_success "workflow alignment validator fails when hosted preflight loses PR-required blocker" case_hosted_preflight_loses_pr_required_blocker_fails

  echo
  echo "Passed: $pass_count"
  echo "Failed: $fail_count"
  [[ "$fail_count" -eq 0 ]]
}

main "$@"

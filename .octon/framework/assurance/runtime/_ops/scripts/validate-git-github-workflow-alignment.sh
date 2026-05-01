#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
ROOT_DIR="$(cd -- "$OCTON_DIR/.." && pwd)"

POLICY="$OCTON_DIR/framework/product/contracts/default-work-unit.yml"
CONTRACT="$OCTON_DIR/framework/execution-roles/practices/standards/git-worktree-autonomy-contract.yml"
WORKFLOW="$OCTON_DIR/framework/orchestration/runtime/workflows/meta/closeout/workflow.yml"
INGRESS="$OCTON_DIR/instance/ingress/AGENTS.md"
MANIFEST="$OCTON_DIR/instance/ingress/manifest.yml"
CLOSEOUT_CHANGE="$OCTON_DIR/framework/capabilities/runtime/skills/remediation/closeout-change/SKILL.md"
CLOSEOUT_PR="$OCTON_DIR/framework/capabilities/runtime/skills/remediation/closeout-pr/SKILL.md"
OPEN_SCRIPT="$OCTON_DIR/framework/execution-roles/_ops/scripts/git/git-pr-open.sh"
SHIP_SCRIPT="$OCTON_DIR/framework/execution-roles/_ops/scripts/git/git-pr-ship.sh"
WT_SCRIPT="$OCTON_DIR/framework/execution-roles/_ops/scripts/git/git-wt-new.sh"
BRANCH_COMMIT_SCRIPT="$OCTON_DIR/framework/execution-roles/_ops/scripts/git/git-branch-commit.sh"
BRANCH_PUSH_SCRIPT="$OCTON_DIR/framework/execution-roles/_ops/scripts/git/git-branch-push.sh"
BRANCH_LAND_SCRIPT="$OCTON_DIR/framework/execution-roles/_ops/scripts/git/git-branch-land.sh"
BRANCH_CLEANUP_SCRIPT="$OCTON_DIR/framework/execution-roles/_ops/scripts/git/git-branch-cleanup.sh"
REQUIRED_CHECKS_SCRIPT="$OCTON_DIR/framework/execution-roles/_ops/scripts/git/git-required-checks-at-ref.sh"
HOSTED_PREFLIGHT_SCRIPT="$OCTON_DIR/framework/execution-roles/_ops/scripts/git/git-branch-hosted-preflight.sh"
HOSTED_LAND_SCRIPT="$OCTON_DIR/framework/execution-roles/_ops/scripts/git/git-branch-land-hosted-no-pr.sh"
HOSTED_NO_PR_VALIDATOR="$OCTON_DIR/framework/assurance/runtime/_ops/scripts/validate-hosted-no-pr-landing.sh"
GITHUB_RULESET_VALIDATOR="$OCTON_DIR/framework/assurance/runtime/_ops/scripts/validate-github-main-ruleset-alignment.sh"
GITHUB_ADAPTER="$OCTON_DIR/framework/engine/runtime/adapters/host/github-control-plane.yml"
REPO_ADAPTER="$OCTON_DIR/framework/engine/runtime/adapters/host/repo-shell.yml"

errors=0

pass() { echo "[OK] $1"; }
fail() { echo "[ERROR] $1"; errors=$((errors + 1)); }

require_file() {
  local file="$1"
  [[ -f "$file" ]] && pass "found ${file#$ROOT_DIR/}" || fail "missing ${file#$ROOT_DIR/}"
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

require_yq() {
  local file="$1"
  local expr="$2"
  local ok_msg="$3"
  local fail_msg="$4"
  yq -e "$expr" "$file" >/dev/null 2>&1 && pass "$ok_msg" || fail "$fail_msg"
}

main() {
  echo "== Git/GitHub Workflow Alignment Validation =="
  command -v yq >/dev/null 2>&1 || { echo "[ERROR] yq is required" >&2; exit 1; }

  for file in "$POLICY" "$CONTRACT" "$WORKFLOW" "$INGRESS" "$MANIFEST" "$CLOSEOUT_CHANGE" "$CLOSEOUT_PR" "$OPEN_SCRIPT" "$SHIP_SCRIPT" "$WT_SCRIPT" "$BRANCH_COMMIT_SCRIPT" "$BRANCH_PUSH_SCRIPT" "$BRANCH_LAND_SCRIPT" "$BRANCH_CLEANUP_SCRIPT" "$REQUIRED_CHECKS_SCRIPT" "$HOSTED_PREFLIGHT_SCRIPT" "$HOSTED_LAND_SCRIPT" "$HOSTED_NO_PR_VALIDATOR" "$GITHUB_RULESET_VALIDATOR" "$GITHUB_ADAPTER" "$REPO_ADAPTER"; do
    require_file "$file"
  done

  require_yq "$POLICY" '.routes[]? | select(.route_id == "direct-main")' "policy exposes direct-main route" "policy missing direct-main route"
  require_yq "$POLICY" '.routes[]? | select(.route_id == "branch-no-pr")' "policy exposes branch-no-pr route" "policy missing branch-no-pr route"
  require_yq "$POLICY" '.routes[]? | select(.route_id == "branch-pr")' "policy exposes branch-pr route" "policy missing branch-pr route"
  if yq -e '.routes[]? | select(.route_id == "branch-land-no-pr")' "$POLICY" >/dev/null 2>&1; then
    fail "policy must not add branch-land-no-pr top-level route"
  else
    pass "policy keeps no-PR branch landing as branch-no-pr lifecycle outcome"
  fi
  require_yq "$CONTRACT" '.helpers.git_wt_new.route_guard == "branch-no-pr or branch-pr only"' "worktree helper is route-gated to branch routes" "worktree helper must be branch-route gated"
  require_yq "$CONTRACT" '.helpers.git_pr_open.route_guard == "branch-pr only"' "PR open helper is branch-pr gated" "PR open helper must be branch-pr gated"
  require_yq "$CONTRACT" '.helpers.git_branch_land.route_guard == "branch-no-pr only"' "no-PR branch landing helper is branch-no-pr gated" "branch landing helper must be branch-no-pr gated"
  require_yq "$CONTRACT" '.helpers.git_branch_land_hosted_no_pr.route_guard == "branch-no-pr only"' "hosted no-PR branch landing helper is branch-no-pr gated" "hosted branch landing helper must be branch-no-pr gated"
  require_yq "$CONTRACT" '.helpers.git_required_checks_at_ref.posture == "exact-SHA hosted check evidence helper"' "exact-SHA check helper is registered" "exact-SHA check helper must be registered"
  require_yq "$CONTRACT" '.helpers.git_branch_cleanup.route_guard == "branch-no-pr or branch-pr only"' "branch cleanup helper is branch-route gated" "branch cleanup helper must be branch-route gated"
  require_yq "$POLICY" '.hosted_provider_ruleset.target_model == "route-neutral protected main"' "policy defines route-neutral protected main target" "policy must define route-neutral protected main target"
  require_yq "$POLICY" '.hosted_provider_ruleset.forbidden_universal_rules[]? | select(. == "pull_request_required_for_all_main_updates")' "policy forbids universal PR rule in target ruleset" "policy must forbid universal PR rule in target ruleset"
  require_yq "$POLICY" '.hosted_provider_ruleset.pr_specific_checks[]? | select(. == "PR Quality Standards")' "policy keeps PR quality behind PR route" "policy must keep PR quality behind PR route"
  require_yq "$CONTRACT" '.closeout.owner_surface == "/closeout-change"' "closeout owner is closeout-change" "closeout owner must be closeout-change"
  require_yq "$CONTRACT" '.closeout.pr_backed_subflow == "/closeout-pr"' "closeout-pr is PR-backed subflow" "closeout-pr must be PR-backed subflow"
  require_yq "$WORKFLOW" '.policy_refs.default_work_unit_policy_ref == ".octon/framework/product/contracts/default-work-unit.yml"' "workflow references default work unit policy" "workflow missing default work unit policy"
  require_yq "$MANIFEST" '.default_work_unit_policy_ref == ".octon/framework/product/contracts/default-work-unit.yml"' "ingress manifest references default work unit policy" "ingress manifest missing default work unit policy"
  require_literal "$INGRESS" "Ingress does not own Change closeout policy." "ingress delegates Change closeout policy" "ingress must delegate Change closeout policy"
  require_literal "$CLOSEOUT_CHANGE" 'Do not open a PR unless route selection returns `branch-pr`.' "closeout-change route-gates PR creation" "closeout-change must route-gate PR creation"
  require_literal "$CLOSEOUT_PR" 'selected route `branch-pr`' "closeout-pr requires branch-pr route" "closeout-pr must require branch-pr route"
  require_literal "$OPEN_SCRIPT" "branch-pr" "git-pr-open documents branch-pr route guard" "git-pr-open must document branch-pr route guard"
  require_literal "$WT_SCRIPT" "branch-no-pr or branch-pr" "git-wt-new documents branch route guard" "git-wt-new must document branch route guard"
  require_literal "$SHIP_SCRIPT" "branch-pr" "git-pr-ship documents branch-pr route guard" "git-pr-ship must document branch-pr route guard"
  require_literal "$BRANCH_COMMIT_SCRIPT" "branch-no-pr or branch-pr" "git-branch-commit documents branch route guard" "git-branch-commit must document branch route guard"
  require_literal "$BRANCH_PUSH_SCRIPT" "without opening a PR" "git-branch-push avoids PR mutation" "git-branch-push must avoid PR mutation"
  require_literal "$BRANCH_LAND_SCRIPT" "branch-no-pr" "git-branch-land documents branch-no-pr route guard" "git-branch-land must document branch-no-pr route guard"
  require_literal "$BRANCH_LAND_SCRIPT" 'rev-list --reverse "$TARGET_PRE_REF..$SOURCE_REF"' "git-branch-land cherry-picks full branch range" "git-branch-land must cherry-pick the full target-to-source range"
  forbid_literal "$BRANCH_LAND_SCRIPT" 'cherry-pick "$SOURCE_BRANCH"' "git-branch-land avoids tip-only cherry-pick" "git-branch-land must not cherry-pick only the branch tip"
  require_literal "$BRANCH_CLEANUP_SCRIPT" "without requiring PR metadata" "git-branch-cleanup avoids PR metadata dependency" "git-branch-cleanup must avoid PR metadata dependency"
  require_literal "$REQUIRED_CHECKS_SCRIPT" "exact commit SHA" "required checks helper validates exact SHA" "required checks helper must validate exact SHA"
  require_literal "$HOSTED_PREFLIGHT_SCRIPT" "Provider ruleset requires PR; hosted branch-no-pr landing unavailable." "hosted preflight blocks PR-required ruleset" "hosted preflight must block PR-required ruleset"
  require_literal "$HOSTED_LAND_SCRIPT" 'push "$REMOTE" "$SOURCE_REF:refs/heads/$TARGET_BRANCH"' "hosted no-PR landing uses non-force target push" "hosted no-PR landing must use non-force target push"
  forbid_literal "$HOSTED_LAND_SCRIPT" "gh pr" "hosted no-PR landing helper does not mutate PRs" "hosted no-PR landing helper must not mutate PRs"
  require_literal "$HOSTED_NO_PR_VALIDATOR" "branch-no-pr landed/cleaned requires hosted landing evidence" "hosted no-PR validator enforces hosted landing evidence" "hosted no-PR validator must enforce hosted landing evidence"
  require_literal "$GITHUB_RULESET_VALIDATOR" "PR-required ruleset blocks hosted branch-no-pr landing" "GitHub ruleset validator detects PR-required blocker" "GitHub ruleset validator must detect PR-required blocker"
  require_literal "$GITHUB_ADAPTER" "PR-backed Changes" "GitHub adapter scoped to PR-backed Changes" "GitHub adapter must scope GitHub to PR-backed Changes"
  require_literal "$REPO_ADAPTER" "direct-main" "repo shell adapter covers direct-main route" "repo shell adapter must cover direct-main route"

  echo
  echo "Validation summary: errors=$errors"
  [[ "$errors" -eq 0 ]]
}

main "$@"

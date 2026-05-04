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
PR_DOC="$OCTON_DIR/framework/execution-roles/practices/pull-request-standards.md"
WORKFLOW_DOC="$OCTON_DIR/framework/execution-roles/practices/git-github-autonomy-workflow-v1.md"
GITHUB_RUNBOOK="$OCTON_DIR/framework/execution-roles/practices/github-autonomy-runbook.md"
PR_AUTONOMY_EVALUATOR="$OCTON_DIR/framework/assurance/governance/_ops/scripts/evaluate-pr-autonomy-policy.sh"
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
GITHUB_PROJECTION_VALIDATOR="$OCTON_DIR/framework/assurance/runtime/_ops/scripts/validate-github-projection-alignment.sh"
COMMIT_PR_STANDARDS="$OCTON_DIR/framework/execution-roles/practices/standards/commit-pr-standards.json"
GITHUB_ADAPTER="$OCTON_DIR/framework/engine/runtime/adapters/host/github-control-plane.yml"
REPO_ADAPTER="$OCTON_DIR/framework/engine/runtime/adapters/host/repo-shell.yml"
GITHUB_CONTROL_CONTRACT="$OCTON_DIR/framework/execution-roles/practices/standards/github-control-plane-contract.json"
MAIN_CHANGE_ROUTE_GUARD="$ROOT_DIR/.github/workflows/main-change-route-guard.yml"
CHANGE_ROUTE_PROJECTION="$ROOT_DIR/.github/workflows/change-route-projection.yml"
PR_AUTO_MERGE_WORKFLOW="$ROOT_DIR/.github/workflows/pr-auto-merge.yml"
PR_TRIAGE_WORKFLOW="$ROOT_DIR/.github/workflows/pr-triage.yml"
PR_AUTONOMY_POLICY_TEST="$OCTON_DIR/framework/assurance/runtime/_ops/tests/test-pr-autonomy-policy.sh"

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

require_jq() {
  local file="$1"
  local expr="$2"
  local ok_msg="$3"
  local fail_msg="$4"
  jq -e "$expr" "$file" >/dev/null 2>&1 && pass "$ok_msg" || fail "$fail_msg"
}

main() {
  echo "== Git/GitHub Workflow Alignment Validation =="
  command -v jq >/dev/null 2>&1 || { echo "[ERROR] jq is required" >&2; exit 1; }
  command -v yq >/dev/null 2>&1 || { echo "[ERROR] yq is required" >&2; exit 1; }

  for file in "$POLICY" "$CONTRACT" "$WORKFLOW" "$INGRESS" "$MANIFEST" "$CLOSEOUT_CHANGE" "$CLOSEOUT_PR" "$PR_DOC" "$WORKFLOW_DOC" "$GITHUB_RUNBOOK" "$PR_AUTONOMY_EVALUATOR" "$OPEN_SCRIPT" "$SHIP_SCRIPT" "$WT_SCRIPT" "$BRANCH_COMMIT_SCRIPT" "$BRANCH_PUSH_SCRIPT" "$BRANCH_LAND_SCRIPT" "$BRANCH_CLEANUP_SCRIPT" "$REQUIRED_CHECKS_SCRIPT" "$HOSTED_PREFLIGHT_SCRIPT" "$HOSTED_LAND_SCRIPT" "$HOSTED_NO_PR_VALIDATOR" "$GITHUB_RULESET_VALIDATOR" "$GITHUB_PROJECTION_VALIDATOR" "$COMMIT_PR_STANDARDS" "$GITHUB_ADAPTER" "$REPO_ADAPTER" "$GITHUB_CONTROL_CONTRACT" "$MAIN_CHANGE_ROUTE_GUARD" "$CHANGE_ROUTE_PROJECTION" "$PR_AUTO_MERGE_WORKFLOW" "$PR_TRIAGE_WORKFLOW" "$PR_AUTONOMY_POLICY_TEST"; do
    require_file "$file"
  done
  [[ -x "$PR_AUTONOMY_POLICY_TEST" ]] && pass "PR autonomy policy test is directly executable" || fail "PR autonomy policy test must be directly executable"

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
  require_yq "$POLICY" '.route_lifecycle_outcomes."branch-pr".ready_requires[]? | select(. == "AI Review Gate / decision passing when required")' "policy includes AI gate in branch-pr ready evidence" "policy must include AI gate in branch-pr ready evidence"
  require_yq "$POLICY" '.route_lifecycle_outcomes."branch-pr".ready_requires[]? | select(. == "high_impact_diff_policy_evidence_rollback_self_review_when_applicable")' "policy includes high-impact self-review ready evidence" "policy must include high-impact self-review ready evidence"
  require_yq "$POLICY" '.route_lifecycle_outcomes."branch-pr".ready_requires[]? | select(. == "no_merge_conflicts")' "policy includes merge-conflict absence in branch-pr ready evidence" "policy must include merge-conflict absence in branch-pr ready evidence"
  require_yq "$POLICY" '.route_lifecycle_outcomes."branch-pr".ready_requires[]? | select(. == "Change receipt or PR closeout evidence")' "policy includes Change receipt or PR closeout evidence in branch-pr ready evidence" "policy must include Change receipt or PR closeout evidence in branch-pr ready evidence"
  require_yq "$POLICY" '.route_lifecycle_outcomes."branch-pr".landed_requires[]? | select(. == "origin_main_contains_merged_result")' "policy requires origin/main verification for PR landed outcome" "policy must require origin/main verification for PR landed outcome"
  require_yq "$CONTRACT" '.closeout.owner_surface == "/closeout-change"' "closeout owner is closeout-change" "closeout owner must be closeout-change"
  require_yq "$CONTRACT" '.closeout.pr_backed_subflow == "/closeout-pr"' "closeout-pr is PR-backed subflow" "closeout-pr must be PR-backed subflow"
  require_yq "$CONTRACT" '.pr_backed_review_policy.autonomous_draft_completion.status == "allowed"' "contract allows autonomous draft completion explicitly" "contract must explicitly allow autonomous draft completion"
  require_yq "$CONTRACT" '.pr_backed_review_policy.autonomous_draft_completion.route_guard == "branch-pr only"' "contract route-gates autonomous draft completion to branch-pr" "contract must route-gate autonomous draft completion to branch-pr"
  require_yq "$CONTRACT" '.pr_backed_review_policy.autonomous_draft_completion.eligibility[]? | select(. == "PR is open and draft")' "contract requires open draft PR for autonomous completion" "contract must require open draft PR for autonomous completion"
  require_yq "$CONTRACT" '.pr_backed_review_policy.autonomous_draft_completion.eligibility[]? | select(. == "AI Review Gate / decision is passing when required")' "contract requires AI gate when required" "contract must require AI gate when required"
  require_yq "$CONTRACT" '.pr_backed_review_policy.autonomous_draft_completion.eligibility[]? | select(. == "no merge conflicts remain")' "contract requires no merge conflicts for autonomous completion" "contract must require no merge conflicts"
  require_yq "$CONTRACT" '.pr_backed_review_policy.autonomous_draft_completion.eligibility[]? | select(. == "Change receipt or PR closeout evidence is present")' "contract requires Change receipt or PR closeout evidence" "contract must require Change receipt or PR closeout evidence"
  require_yq "$CONTRACT" '.pr_backed_review_policy.autonomous_draft_completion.protected_main_bypass_allowed == false' "contract forbids protected-main bypass for autonomous draft completion" "contract must forbid protected-main bypass"
  require_yq "$CONTRACT" '.pr_backed_review_policy.autonomous_draft_completion.high_impact_posture.autonomy_model == "elevated-autonomy" and .pr_backed_review_policy.autonomous_draft_completion.high_impact_posture.manual_default == false' "contract treats high-impact as elevated autonomy" "contract must treat high-impact as elevated autonomy"
  require_jq "$COMMIT_PR_STANDARDS" '.pr.autonomous_draft_completion.protected_main_bypass_allowed == false and .pr.autonomous_draft_completion.requires_open_draft == true' "commit/PR standards encode autonomous draft completion guard" "commit/PR standards must encode autonomous draft completion guard"
  require_jq "$COMMIT_PR_STANDARDS" '.pr.autonomous_draft_completion.high_impact_posture.autonomy_model == "elevated-autonomy" and .pr.autonomous_draft_completion.high_impact_posture.manual_default == false' "commit/PR standards encode high-impact elevated autonomy" "commit/PR standards must encode high-impact elevated autonomy"
  require_jq "$GITHUB_CONTROL_CONTRACT" '.branch_pr_autonomous_completion.protected_main_bypass_allowed == false and .branch_pr_autonomous_completion.live_ruleset_mutation_allowed == false' "GitHub control contract forbids bypass and live mutation for draft completion" "GitHub control contract must forbid bypass and live mutation for draft completion"
  require_jq "$GITHUB_CONTROL_CONTRACT" '.branch_pr_autonomous_completion.high_impact_posture.autonomy_model == "elevated-autonomy" and .branch_pr_autonomous_completion.high_impact_posture.manual_default == false' "GitHub control contract encodes high-impact elevated autonomy" "GitHub control contract must encode high-impact elevated autonomy"
  require_yq "$WORKFLOW" '.policy_refs.default_work_unit_policy_ref == ".octon/framework/product/contracts/default-work-unit.yml"' "workflow references default work unit policy" "workflow missing default work unit policy"
  require_yq "$MANIFEST" '.default_work_unit_policy_ref == ".octon/framework/product/contracts/default-work-unit.yml"' "ingress manifest references default work unit policy" "ingress manifest missing default work unit policy"
  require_literal "$INGRESS" "Ingress does not own Change closeout policy." "ingress delegates Change closeout policy" "ingress must delegate Change closeout policy"
  require_literal "$CLOSEOUT_CHANGE" 'Do not open a PR unless route selection returns `branch-pr`.' "closeout-change route-gates PR creation" "closeout-change must route-gate PR creation"
  require_literal "$CLOSEOUT_PR" 'selected route `branch-pr`' "closeout-pr requires branch-pr route" "closeout-pr must require branch-pr route"
  require_literal "$CLOSEOUT_PR" 'Autonomous draft completion is allowed only for' "closeout-pr carries autonomous draft completion policy" "closeout-pr must carry autonomous draft completion policy"
  require_literal "$CLOSEOUT_PR" 'high impact alone is not a' "closeout-pr rejects high-impact manual default" "closeout-pr must reject high-impact manual default"
  require_literal "$PR_DOC" "Autonomous Draft Completion Policy" "PR standards define autonomous draft completion policy" "PR standards must define autonomous draft completion policy"
  require_literal "$PR_DOC" "High-impact is a risk classification, not a manual-lane default." "PR standards define high-impact elevated autonomy" "PR standards must define high-impact elevated autonomy"
  forbid_literal "$PR_DOC" "High-impact path changes are triaged out of the autonomous merge lane" "PR standards avoid high-impact manual-only drift" "PR standards must not make high-impact manual-only"
  require_literal "$WORKFLOW_DOC" "A draft PR in the autonomous branch-pr lane may be marked ready only when" "workflow overview defines draft-to-ready eligibility" "workflow overview must define draft-to-ready eligibility"
  require_literal "$WORKFLOW_DOC" "High-impact elevated-autonomy lane" "workflow overview defines high-impact elevated lane" "workflow overview must define high-impact elevated lane"
  require_literal "$GITHUB_RUNBOOK" "Autonomous Draft Completion Preflight" "GitHub runbook documents autonomous draft preflight" "GitHub runbook must document autonomous draft preflight"
  require_literal "$GITHUB_RUNBOOK" 'High-impact `branch-pr` PRs do not default' "GitHub runbook rejects high-impact manual default" "GitHub runbook must reject high-impact manual default"
  require_literal "$PR_AUTONOMY_EVALUATOR" "PR_AUTONOMY_HIGH_IMPACT_ELEVATED" "autonomy evaluator grants high-impact elevated posture" "autonomy evaluator must grant high-impact elevated posture"
  forbid_literal "$PR_AUTONOMY_EVALUATOR" "PR_AUTONOMY_HIGH_IMPACT_REVIEW_REQUIRED" "autonomy evaluator avoids high-impact review-required reason" "autonomy evaluator must not make high-impact review-required"
  forbid_literal "$PR_AUTONOMY_EVALUATOR" "High-impact change detected. PR remains manual-lane only" "autonomy evaluator avoids high-impact manual-only notice" "autonomy evaluator must not emit high-impact manual-only notice"
  require_literal "$OPEN_SCRIPT" "branch-pr" "git-pr-open documents branch-pr route guard" "git-pr-open must document branch-pr route guard"
  require_literal "$WT_SCRIPT" "branch-no-pr or branch-pr" "git-wt-new documents branch route guard" "git-wt-new must document branch route guard"
  require_literal "$SHIP_SCRIPT" "branch-pr" "git-pr-ship documents branch-pr route guard" "git-pr-ship must document branch-pr route guard"
  require_literal "$SHIP_SCRIPT" "Autonomous draft completion eligibility must be verified before --request-ready or --request-automerge." "git-pr-ship documents request preflight" "git-pr-ship must document request preflight"
  require_literal "$SHIP_SCRIPT" "High-impact PRs remain eligible under elevated autonomy" "git-pr-ship documents high-impact elevated autonomy" "git-pr-ship must document high-impact elevated autonomy"
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
  require_literal "$GITHUB_PROJECTION_VALIDATOR" "Main Change Route Guard" "GitHub projection validator protects route-aware guard" "GitHub projection validator must protect route-aware guard"
  require_literal "$MAIN_CHANGE_ROUTE_GUARD" "Accepted modes are branch-pr merged PR, direct-main Change receipt, hosted branch-no-pr Change receipt, or authorized break-glass." "main guard fails closed by Change route" "main guard must fail closed by Change route"
  require_literal "$CHANGE_ROUTE_PROJECTION" "exact_source_sha_validation" "route projection exposes exact source SHA check" "route projection must expose exact source SHA check"
  require_literal "$PR_AUTO_MERGE_WORKFLOW" "Autonomous draft completion must mark the PR ready only after the branch-pr ready preflight passes." "PR auto-merge preserves draft readiness boundary" "PR auto-merge must preserve draft readiness boundary"
  require_literal "$PR_TRIAGE_WORKFLOW" "Elevated-autonomy path remains eligible" "PR triage treats high-impact as elevated autonomy" "PR triage must treat high-impact as elevated autonomy"
  forbid_literal "$PR_TRIAGE_WORKFLOW" "highImpactHumanRequired" "PR triage avoids high-impact human-required flag" "PR triage must not make high-impact human-required"
  require_literal "$GITHUB_ADAPTER" "PR-backed Changes" "GitHub adapter scoped to PR-backed Changes" "GitHub adapter must scope GitHub to PR-backed Changes"
  require_literal "$REPO_ADAPTER" "direct-main" "repo shell adapter covers direct-main route" "repo shell adapter must cover direct-main route"

  echo
  echo "Validation summary: errors=$errors"
  [[ "$errors" -eq 0 ]]
}

main "$@"

#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
ROOT_DIR="$(cd -- "$OCTON_DIR/.." && pwd)"

POLICY="$OCTON_DIR/framework/product/contracts/default-work-unit.yml"
POLICY_MD="$OCTON_DIR/framework/product/contracts/default-work-unit.md"
RECEIPT_SCHEMA="$OCTON_DIR/framework/product/contracts/change-receipt-v1.schema.json"
RECEIPT_EXAMPLES_DIR="$OCTON_DIR/framework/product/contracts/examples/change-receipts"
VALID_DIRECT_MAIN_LANDED="$RECEIPT_EXAMPLES_DIR/valid-direct-main-landed.json"
VALID_BRANCH_PR_READY="$RECEIPT_EXAMPLES_DIR/valid-branch-pr-ready.json"
VALID_BRANCH_NO_PR_BRANCH_LOCAL_COMPLETE="$RECEIPT_EXAMPLES_DIR/valid-branch-no-pr-branch-local-complete.json"
VALID_BRANCH_NO_PR_PUBLISHED_BRANCH="$RECEIPT_EXAMPLES_DIR/valid-branch-no-pr-published-branch.json"
VALID_HOSTED_BRANCH_NO_PR_LANDED="$RECEIPT_EXAMPLES_DIR/valid-hosted-branch-no-pr-landed.json"
INVALID_PUSHED_ONLY_BRANCH_CLAIMED_LANDED="$RECEIPT_EXAMPLES_DIR/invalid-pushed-only-branch-claimed-landed.json"
INVALID_PUBLISHED_BRANCH_COMPLETED_CLOSEOUT="$RECEIPT_EXAMPLES_DIR/invalid-published-branch-completed-closeout.json"
INVALID_STALE_REMOTE_BRANCH_REF="$RECEIPT_EXAMPLES_DIR/invalid-stale-remote-branch-ref.json"
INVALID_DRAFT_PR_CLAIMED_FULL_CLOSEOUT="$RECEIPT_EXAMPLES_DIR/invalid-draft-pr-claimed-full-closeout.json"
CLOSEOUT_CHANGE="$OCTON_DIR/framework/capabilities/runtime/skills/remediation/closeout-change/SKILL.md"
CLOSEOUT_PR="$OCTON_DIR/framework/capabilities/runtime/skills/remediation/closeout-pr/SKILL.md"
WORKFLOW_STAGE="$OCTON_DIR/framework/orchestration/runtime/workflows/meta/closeout/stages/02-request-or-report.md"
WORKTREE_CONTRACT="$OCTON_DIR/framework/execution-roles/practices/standards/git-worktree-autonomy-contract.yml"
BRANCH_COMMIT_SCRIPT="$OCTON_DIR/framework/execution-roles/_ops/scripts/git/git-branch-commit.sh"
BRANCH_PUSH_SCRIPT="$OCTON_DIR/framework/execution-roles/_ops/scripts/git/git-branch-push.sh"
BRANCH_LAND_SCRIPT="$OCTON_DIR/framework/execution-roles/_ops/scripts/git/git-branch-land.sh"
BRANCH_CLEANUP_SCRIPT="$OCTON_DIR/framework/execution-roles/_ops/scripts/git/git-branch-cleanup.sh"
REQUIRED_CHECKS_SCRIPT="$OCTON_DIR/framework/execution-roles/_ops/scripts/git/git-required-checks-at-ref.sh"
HOSTED_PREFLIGHT_SCRIPT="$OCTON_DIR/framework/execution-roles/_ops/scripts/git/git-branch-hosted-preflight.sh"
HOSTED_LAND_SCRIPT="$OCTON_DIR/framework/execution-roles/_ops/scripts/git/git-branch-land-hosted-no-pr.sh"

RECEIPT_PATH=""
VERIFY_LIVE_REFS=0
errors=0

usage() {
  cat <<'USAGE'
usage:
  validate-change-closeout-lifecycle-alignment.sh [--receipt <path>] [--verify-live-refs]

Without --receipt, validates policy/workflow/schema/helper alignment.
With --receipt, also validates route/lifecycle semantic claims in the receipt.
With --verify-live-refs, compares recorded remote branch refs with local
refs/remotes state without fetching.
USAGE
}

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

json_value() {
  local expr="$1"
  jq -r "$expr // \"\"" "$RECEIPT_PATH"
}

json_has_nonempty() {
  local expr="$1"
  jq -e "$expr | type == \"string\" and length > 0" "$RECEIPT_PATH" >/dev/null 2>&1
}

json_array_nonempty() {
  local expr="$1"
  jq -e "$expr | type == \"array\" and length > 0" "$RECEIPT_PATH" >/dev/null 2>&1
}

looks_like_sha() {
  [[ "$1" =~ ^[0-9a-fA-F]{40}$ ]]
}

remote_ref_name() {
  local value="$1"
  printf '%s\n' "${value%@*}"
}

remote_ref_sha() {
  local value="$1"
  if [[ "$value" == *@* ]]; then
    printf '%s\n' "${value##*@}"
  fi
}

validate_contracts() {
  for file in "$POLICY" "$POLICY_MD" "$RECEIPT_SCHEMA" "$VALID_DIRECT_MAIN_LANDED" "$VALID_BRANCH_NO_PR_BRANCH_LOCAL_COMPLETE" "$VALID_BRANCH_NO_PR_PUBLISHED_BRANCH" "$VALID_BRANCH_PR_READY" "$VALID_HOSTED_BRANCH_NO_PR_LANDED" "$INVALID_PUSHED_ONLY_BRANCH_CLAIMED_LANDED" "$INVALID_PUBLISHED_BRANCH_COMPLETED_CLOSEOUT" "$INVALID_STALE_REMOTE_BRANCH_REF" "$INVALID_DRAFT_PR_CLAIMED_FULL_CLOSEOUT" "$CLOSEOUT_CHANGE" "$CLOSEOUT_PR" "$WORKFLOW_STAGE" "$WORKTREE_CONTRACT" "$BRANCH_COMMIT_SCRIPT" "$BRANCH_PUSH_SCRIPT" "$BRANCH_LAND_SCRIPT" "$BRANCH_CLEANUP_SCRIPT" "$REQUIRED_CHECKS_SCRIPT" "$HOSTED_PREFLIGHT_SCRIPT" "$HOSTED_LAND_SCRIPT"; do
    require_file "$file"
  done

  for route in direct-main branch-no-pr branch-pr stage-only-escalate; do
    require_yq "$POLICY" ".routes[]? | select(.route_id == \"$route\")" "policy exposes route $route" "policy missing route $route"
  done
  if yq -e '.routes[]? | select(.route_id == "branch-land-no-pr")' "$POLICY" >/dev/null 2>&1; then
    fail "branch-land-no-pr must not be a top-level route"
  else
    pass "branch landing without PR remains a branch-no-pr lifecycle outcome"
  fi

  for outcome in preserved branch-local-complete published-branch published ready landed cleaned blocked escalated denied; do
    require_jq "$RECEIPT_SCHEMA" ".properties.lifecycle_outcome.enum[] | select(. == \"$outcome\")" "receipt schema accepts outcome $outcome" "receipt schema missing outcome $outcome"
  done
  for field in target_lifecycle_outcome lifecycle_outcome outcome_intent integration_status publication_status cleanup_status; do
    require_jq "$RECEIPT_SCHEMA" ".required[] | select(. == \"$field\")" "receipt schema requires $field" "receipt schema missing required $field"
  done
  require_jq "$RECEIPT_SCHEMA" '.properties.outcome_intent.enum[] | select(. == "handoff-only")' "receipt schema models outcome intent" "receipt schema must model outcome intent"
  require_jq "$RECEIPT_SCHEMA" '.properties.landing_evaluation.properties.status.enum[] | select(. == "blocked")' "receipt schema models landing evaluation" "receipt schema must model landing evaluation"
  require_jq "$RECEIPT_SCHEMA" '.properties.main_alignment.required[] | select(. == "origin_main_ref")' "receipt schema models final main alignment" "receipt schema must model final main alignment"
  require_jq "$RECEIPT_SCHEMA" '.properties.source_branch_cleanup.properties.status.enum[] | select(. == "deferred")' "receipt schema models source branch cleanup disposition" "receipt schema must model source branch cleanup disposition"
  require_jq "$RECEIPT_SCHEMA" '.properties.publication_status.enum[] | select(. == "hosted-main-updated")' "receipt schema models hosted main update publication status" "receipt schema missing hosted-main-updated publication status"
  require_jq "$RECEIPT_SCHEMA" '.properties.hosted_landing.required[] | select(. == "provider_ruleset_ref")' "receipt schema requires provider ruleset evidence for hosted landing" "receipt schema must require provider ruleset evidence for hosted landing"
  require_jq "$RECEIPT_SCHEMA" '.properties.hosted_landing.required[] | select(. == "required_check_refs")' "receipt schema requires exact-SHA check refs for hosted landing" "receipt schema must require exact-SHA check refs for hosted landing"
  require_jq "$RECEIPT_SCHEMA" '[.allOf[]? | select(.if.properties.closeout_outcome.const == "completed") | select(.if.properties.integration_status.const == "landed") | select((.if.properties.selected_route.enum | index("branch-no-pr")) != null) | select((.if.properties.selected_route.enum | index("branch-pr")) != null) | select((.then.properties.cleanup_status.enum | index("completed")) != null) | select((.then.properties.cleanup_status.enum | index("deferred")) != null) | select((.then.properties.cleanup_status.enum | index("pending")) == null)] | length == 1' "receipt schema blocks completed landed branch closeout with pending cleanup" "receipt schema must block completed landed branch closeout with pending cleanup"
  require_jq "$RECEIPT_SCHEMA" '[.allOf[]? | select(.if.properties.selected_route.const == "branch-no-pr") | select(.if.properties.lifecycle_outcome.const == "published-branch") | select((.then.properties.closeout_outcome.enum | index("completed")) == null)] | length == 1' "receipt schema blocks published-branch completed closeout" "receipt schema must block published-branch completed closeout"

  require_yq "$POLICY" '.route_lifecycle_outcomes."branch-no-pr".allowed_outcomes[]? | select(. == "landed")' "branch-no-pr supports landed lifecycle outcome" "branch-no-pr must support landed lifecycle outcome"
  require_yq "$POLICY" '.route_lifecycle_outcomes."branch-no-pr".landed_requires[]? | select(. == "provider_ruleset_allows_route_neutral_fast_forward_update")' "branch-no-pr landed requires route-neutral provider rules" "branch-no-pr landed must require route-neutral provider rules"
  require_yq "$POLICY" '.route_lifecycle_outcomes."branch-no-pr".landed_requires[]? | select(. == "origin_main_equals_landed_ref_after_push")' "branch-no-pr landed requires origin/main equality" "branch-no-pr landed must require origin/main equality"
  require_yq "$POLICY" '.route_lifecycle_outcomes."branch-no-pr".landed_requires[]? | select(. == "safe_branch_cleanup_completed_or_deferred_after_origin_main_contains_landed_ref")' "branch-no-pr landed requires branch cleanup or deferred cleanup record" "branch-no-pr landed must require branch cleanup or deferred cleanup record"
  require_yq "$POLICY" '.route_lifecycle_outcomes."branch-no-pr".landed_requires[]? | select(. == "local_main_origin_main_landed_ref_alignment_verified")' "branch-no-pr landed requires local/main/origin alignment proof" "branch-no-pr landed must require local/main/origin alignment proof"
  require_yq "$POLICY" '.route_lifecycle_outcomes."branch-pr".allowed_outcomes[]? | select(. == "ready")' "branch-pr supports ready lifecycle outcome" "branch-pr must support ready lifecycle outcome"
  require_yq "$POLICY" '.route_lifecycle_outcomes."branch-pr".landed_requires[]? | select(. == "safe_branch_cleanup_completed_or_deferred_after_origin_main_contains_merged_result")' "branch-pr landed requires branch cleanup or deferred cleanup record" "branch-pr landed must require branch cleanup or deferred cleanup record"
  require_yq "$POLICY" '.route_lifecycle_outcomes."branch-pr".landed_requires[]? | select(. == "local_main_origin_main_landed_ref_alignment_verified")' "branch-pr landed requires local/main/origin alignment proof" "branch-pr landed must require local/main/origin alignment proof"
  require_yq "$POLICY" '.route_lifecycle_outcomes."direct-main".full_closeout_requires[]? | select(. == "local_main_equals_origin_main_after_fetch")' "direct-main closeout requires local main sync after fetch" "direct-main closeout must require local main sync after fetch"
  require_yq "$POLICY" '.route_lifecycle_outcomes."direct-main".full_closeout_requires[]? | select(. == "local_main_contains_landed_ref_after_fetch")' "direct-main closeout requires landed ref containment after fetch" "direct-main closeout must require landed ref containment after fetch"
  require_yq "$POLICY" '.fail_closed_conditions[]? | select(. == "landed_branch_closeout_without_safe_branch_cleanup_or_deferred_cleanup_record")' "policy fails closed on landed branch closeout without cleanup disposition" "policy must fail closed on landed branch closeout without cleanup disposition"
  require_yq "$POLICY" '.fail_closed_conditions[]? | select(. == "published_branch_reported_as_completed_closeout")' "policy fails closed on pushed branch handoff reported as completed" "policy must fail closed on pushed branch handoff reported as completed"
  require_yq "$POLICY" '.fail_closed_conditions[]? | select(. == "target_landed_or_cleaned_without_landing_evaluation")' "policy fails closed on missing landing evaluation for landing targets" "policy must fail closed on missing landing evaluation for landing targets"
  require_yq "$POLICY" '.fail_closed_conditions[]? | select(. == "stale_remote_branch_ref_in_closeout_receipt")' "policy fails closed on stale recorded remote branch refs" "policy must fail closed on stale recorded remote branch refs"
  require_yq "$POLICY" '.fail_closed_conditions[]? | select(. == "post_landing_local_main_not_synced_to_origin_main")' "policy fails closed on missing post-landing local main sync" "policy must fail closed on missing post-landing local main sync"
  require_yq "$POLICY" '.fail_closed_conditions[]? | select(. == "branch_cleanup_attempts_protected_active_unmerged_open_pr_or_unretained_rollback_ref")' "policy fails closed on unsafe branch cleanup" "policy must fail closed on unsafe branch cleanup"
  require_literal "$POLICY_MD" "Routes do not by themselves prove landing, publication, or cleanup." "policy docs separate route from outcome" "policy docs must separate route from outcome"
  require_literal "$POLICY_MD" "Target lifecycle outcome records what the operator or" "policy docs separate target and actual outcome" "policy docs must separate target and actual outcome"
  require_literal "$POLICY_MD" "This is a continued handoff outcome, not completed closeout." "policy docs define published-branch as continued handoff" "policy docs must define published-branch as continued handoff"
  require_literal "$POLICY_MD" 'direct-main` closeout must push to `origin/main`' "policy docs require direct-main origin push for closeout" "policy docs must require direct-main origin push for closeout"
  require_literal "$POLICY_MD" "push the source branch to" "policy docs require branch-no-pr origin push for closeout" "policy docs must require branch-no-pr origin push for closeout"
  require_literal "$POLICY_MD" "## Post-Landing Cleanup And Sync" "policy docs define post-landing cleanup and sync" "policy docs must define post-landing cleanup and sync"
  require_literal "$POLICY_MD" "Do not delete protected branches, active work branches, unmerged branches" "policy docs protect unsafe branches from cleanup" "policy docs must protect unsafe branches from cleanup"
  require_literal "$POLICY_MD" 'local `main`, `origin/main`, and the recorded landed ref are aligned' "policy docs require final local main alignment" "policy docs must require final local main alignment"
  require_literal "$POLICY_MD" 'If a provider ruleset currently requires a pull request for `main`, hosted' "policy docs fail closed when provider requires PR" "policy docs must fail closed when provider ruleset requires PR"
  require_literal "$CLOSEOUT_CHANGE" 'Do not claim `branch-no-pr` as `landed`' "closeout-change blocks false no-PR landing claims" "closeout-change must block false no-PR landing claims"
  require_literal "$CLOSEOUT_CHANGE" "Resolve Target Outcome" "closeout-change resolves target outcome" "closeout-change must resolve target outcome"
  require_literal "$CLOSEOUT_CHANGE" "do not call it completed" "closeout-change blocks published-branch completion overclaim" "closeout-change must block published-branch completion overclaim"
  require_literal "$CLOSEOUT_CHANGE" "Bash(git push *)" "closeout-change can push direct-main and branch publication refs" "closeout-change must allow route-required git push"
  require_literal "$CLOSEOUT_CHANGE" "git-branch-push.sh" "closeout-change can invoke branch publication helper" "closeout-change must allow branch publication helper"
  require_literal "$CLOSEOUT_CHANGE" "git-required-checks-at-ref.sh" "closeout-change can invoke exact-SHA check helper" "closeout-change must allow exact-SHA check helper"
  require_literal "$CLOSEOUT_CHANGE" "git-branch-hosted-preflight.sh" "closeout-change can invoke hosted no-PR preflight helper" "closeout-change must allow hosted no-PR preflight helper"
  require_literal "$CLOSEOUT_CHANGE" "git-branch-land-hosted-no-pr.sh" "closeout-change can invoke hosted no-PR landing helper" "closeout-change must allow hosted no-PR landing helper"
  require_literal "$CLOSEOUT_CHANGE" 'push to `origin/main`' "closeout-change requires direct-main origin push" "closeout-change must require direct-main origin push"
  require_literal "$CLOSEOUT_CHANGE" "push the source branch to origin" "closeout-change requires branch-no-pr origin push" "closeout-change must require branch-no-pr origin push"
  require_literal "$CLOSEOUT_CHANGE" "hosted no-PR landing preflight" "closeout-change requires hosted no-PR preflight" "closeout-change must require hosted no-PR preflight"
  require_literal "$CLOSEOUT_CHANGE" "Post-Landing Cleanup And Sync" "closeout-change requires post-landing cleanup and sync" "closeout-change must require post-landing cleanup and sync"
  require_literal "$CLOSEOUT_CHANGE" "Never delete protected" "closeout-change forbids unsafe branch cleanup" "closeout-change must forbid unsafe branch cleanup"
  require_literal "$CLOSEOUT_PR" 'Draft/open PR state is `published`, not full closeout' "closeout-pr blocks draft/open full closeout claims" "closeout-pr must block draft/open full closeout claims"
  require_literal "$CLOSEOUT_PR" 'Full PR-backed closeout after merge requires branch cleanup' "closeout-pr requires post-merge branch cleanup" "closeout-pr must require post-merge branch cleanup"
  require_literal "$CLOSEOUT_PR" 'Required branch cleanup or post-cleanup local `main` sync cannot be proven' "closeout-pr escalates unprovable cleanup or sync" "closeout-pr must escalate unprovable cleanup or sync"
  require_literal "$WORKFLOW_STAGE" "Never report a patch, checkpoint, branch-local commit, or pushed-only branch" "workflow blocks false landed claims" "workflow must block false landed claims"
  require_literal "$WORKFLOW_STAGE" "published-branch" "workflow distinguishes pushed-branch handoff from completed closeout" "workflow must distinguish pushed-branch handoff from completed closeout"
  require_literal "$WORKFLOW_STAGE" "clean up obsolete safe local and remote source branches" "workflow requires landed branch cleanup" "workflow must require landed branch cleanup"
  require_literal "$WORKFLOW_STAGE" 'local `main`, `origin/main`, and' "workflow requires post-cleanup local main alignment" "workflow must require post-cleanup local main alignment"
  require_literal "$WORKFLOW_STAGE" "cleanup-local-run-artifacts.sh" "workflow classifies local run/control/evidence residue before cleaned closeout" "workflow must classify local residue before cleaned closeout"
  require_yq "$WORKTREE_CONTRACT" '.helpers.git_branch_land.route_guard == "branch-no-pr only"' "branch landing helper is route guarded" "branch landing helper must be route guarded"
  require_yq "$WORKTREE_CONTRACT" '.helpers.git_branch_land_hosted_no_pr.route_guard == "branch-no-pr only"' "hosted no-PR landing helper is route guarded" "hosted no-PR landing helper must be route guarded"
  require_yq "$WORKTREE_CONTRACT" '.closeout.post_landing_cleanup.applies_to_routes[]? | select(. == "branch-no-pr")' "worktree contract applies post-landing cleanup to branch-no-pr" "worktree contract must apply post-landing cleanup to branch-no-pr"
  require_yq "$WORKTREE_CONTRACT" '.closeout.post_landing_cleanup.applies_to_routes[]? | select(. == "branch-pr")' "worktree contract applies post-landing cleanup to branch-pr" "worktree contract must apply post-landing cleanup to branch-pr"
  require_yq "$WORKTREE_CONTRACT" '.helpers.git_branch_cleanup.safety[]? | select(. == "requires origin/main containment before deleting local or remote refs")' "worktree contract requires origin/main containment before cleanup" "worktree contract must require origin/main containment before cleanup"
  require_yq "$WORKTREE_CONTRACT" '.helpers.git_branch_cleanup.safety[]? | select(. == "requires retained rollback posture for mutating cleanup")' "worktree contract requires retained rollback posture before cleanup" "worktree contract must require retained rollback posture before cleanup"
  require_yq "$WORKTREE_CONTRACT" '.helpers.git_branch_cleanup.safety[]? | select(. == "blocks cleanup when no-open-PR proof cannot be completed or an open PR exists")' "worktree contract blocks open-PR or unprovable no-PR cleanup" "worktree contract must block open-PR or unprovable no-PR cleanup"
  require_literal "$BRANCH_CLEANUP_SCRIPT" "Refusing to clean up protected branch" "branch cleanup helper refuses protected branches" "branch cleanup helper must refuse protected branches"
  require_literal "$BRANCH_CLEANUP_SCRIPT" "origin/main containment" "branch cleanup helper emits origin/main containment evidence" "branch cleanup helper must emit origin/main containment evidence"
  require_literal "$BRANCH_CLEANUP_SCRIPT" "retained rollback" "branch cleanup helper requires retained rollback posture" "branch cleanup helper must require retained rollback posture"
  require_literal "$BRANCH_CLEANUP_SCRIPT" "open PR exists" "branch cleanup helper refuses open-PR branches" "branch cleanup helper must refuse open-PR branches"
  require_literal "$HOSTED_PREFLIGHT_SCRIPT" "Provider ruleset requires PR; hosted branch-no-pr landing unavailable." "hosted preflight blocks PR-required provider rules" "hosted preflight must block PR-required provider rules"
  require_literal "$HOSTED_LAND_SCRIPT" 'origin/main equals landed_ref after push' "hosted land helper emits origin/main equality evidence" "hosted land helper must emit origin/main equality evidence"
  require_jq "$VALID_DIRECT_MAIN_LANDED" '.selected_route == "direct-main" and .lifecycle_outcome == "landed" and .integration_method == "direct-commit" and .integration_status == "landed" and .publication_status == "none" and .durable_history.kind == "commit"' "receipt example covers direct-main landed closeout" "receipt example must cover direct-main landed closeout"
  require_jq "$VALID_BRANCH_NO_PR_BRANCH_LOCAL_COMPLETE" '.selected_route == "branch-no-pr" and .lifecycle_outcome == "branch-local-complete" and .integration_status == "not_landed" and .publication_status == "none" and .closeout_outcome == "continued" and .durable_history.kind == "commit"' "receipt example covers branch-no-pr branch-local completion" "receipt example must cover branch-no-pr branch-local completion"
  require_jq "$VALID_BRANCH_NO_PR_PUBLISHED_BRANCH" '.selected_route == "branch-no-pr" and .target_lifecycle_outcome == "published-branch" and .lifecycle_outcome == "published-branch" and .publication_status == "pushed-branch" and .integration_status == "not_landed" and .closeout_outcome == "continued"' "receipt example covers branch-no-pr pushed-branch handoff" "receipt example must cover branch-no-pr pushed-branch handoff"
  require_jq "$VALID_BRANCH_PR_READY" '.selected_route == "branch-pr" and .lifecycle_outcome == "ready" and .publication_status == "pr-ready" and .integration_status == "not_landed" and .closeout_outcome == "continued"' "receipt example covers branch-pr ready without landed closeout" "receipt example must cover branch-pr ready without landed closeout"
  require_jq "$VALID_HOSTED_BRANCH_NO_PR_LANDED" '.selected_route == "branch-no-pr" and .target_lifecycle_outcome == "landed" and .lifecycle_outcome == "landed" and .integration_status == "landed" and .publication_status == "hosted-main-updated" and .hosted_landing.target_post_ref == .landed_ref and .main_alignment.aligned == true' "receipt example covers hosted branch-no-pr landing" "receipt example must cover hosted branch-no-pr landing"
  require_jq "$INVALID_PUSHED_ONLY_BRANCH_CLAIMED_LANDED" '.selected_route == "branch-no-pr" and .lifecycle_outcome == "landed" and .publication_status == "pushed-branch"' "receipt example covers pushed-only landed overclaim" "receipt example must cover pushed-only landed overclaim"
  require_jq "$INVALID_PUBLISHED_BRANCH_COMPLETED_CLOSEOUT" '.selected_route == "branch-no-pr" and .lifecycle_outcome == "published-branch" and .closeout_outcome == "completed"' "receipt example covers pushed-branch completed-closeout overclaim" "receipt example must cover pushed-branch completed-closeout overclaim"
  require_jq "$INVALID_STALE_REMOTE_BRANCH_REF" '.selected_route == "branch-no-pr" and .lifecycle_outcome == "published-branch" and .remote_branch_ref != ("origin/" + .source_branch_ref + "@" + .durable_history.ref)' "receipt example covers stale remote branch ref" "receipt example must cover stale remote branch ref"
  require_jq "$INVALID_DRAFT_PR_CLAIMED_FULL_CLOSEOUT" '.selected_route == "branch-pr" and .lifecycle_outcome == "ready" and .closeout_outcome == "completed"' "receipt example covers draft/open PR full-closeout overclaim" "receipt example must cover draft/open PR full-closeout overclaim"
}

validate_receipt() {
  [[ -f "$RECEIPT_PATH" ]] || { fail "receipt exists: $RECEIPT_PATH"; return; }
  jq -e '.' "$RECEIPT_PATH" >/dev/null 2>&1 && pass "receipt parses as JSON" || { fail "receipt parses as JSON"; return; }

  local route target outcome integration publication cleanup durable_kind durable_ref closeout_outcome integration_method outcome_intent
  route="$(json_value '.selected_route')"
  target="$(json_value '.target_lifecycle_outcome')"
  outcome="$(json_value '.lifecycle_outcome')"
  integration="$(json_value '.integration_status')"
  publication="$(json_value '.publication_status')"
  cleanup="$(json_value '.cleanup_status')"
  durable_kind="$(json_value '.durable_history.kind')"
  durable_ref="$(json_value '.durable_history.ref')"
  closeout_outcome="$(json_value '.closeout_outcome')"
  integration_method="$(json_value '.integration_method')"
  outcome_intent="$(json_value '.outcome_intent')"

  [[ -n "$route" ]] && pass "receipt has selected route" || fail "receipt missing selected route"
  [[ -n "$target" ]] && pass "receipt has target lifecycle outcome" || fail "receipt missing target lifecycle outcome"
  [[ -n "$outcome" ]] && pass "receipt has lifecycle outcome" || fail "receipt missing lifecycle outcome"
  [[ -n "$outcome_intent" ]] && pass "receipt has outcome intent" || fail "receipt missing outcome intent"
  [[ -n "$integration" ]] && pass "receipt has integration status" || fail "receipt missing integration status"
  [[ -n "$publication" ]] && pass "receipt has publication status" || fail "receipt missing publication status"
  [[ -n "$cleanup" ]] && pass "receipt has cleanup status" || fail "receipt missing cleanup status"

  case "$outcome" in
    preserved|branch-local-complete|published-branch|published|ready)
      if [[ "$closeout_outcome" == "completed" ]]; then
        fail "$outcome must not be reported as completed closeout"
      else
        pass "$outcome is not reported as completed closeout"
      fi
      ;;
  esac

  case "$route" in
    direct-main)
      case "$target" in
        landed|cleaned) pass "direct-main target outcome is landing-scoped" ;;
        *) fail "direct-main target outcome must be landed or cleaned" ;;
      esac
      case "$outcome" in
        landed|cleaned) pass "direct-main outcome is landing-scoped" ;;
        *) fail "direct-main outcome must be landed or cleaned" ;;
      esac
      ;;
    branch-no-pr)
      case "$target" in
        preserved|branch-local-complete|published-branch|landed|cleaned|blocked|escalated|denied)
          pass "branch-no-pr target outcome is branch-only scoped"
          ;;
        *)
          fail "branch-no-pr target outcome must not use PR lifecycle states"
          ;;
      esac
      case "$outcome" in
        preserved|branch-local-complete|published-branch|landed|cleaned|blocked|escalated|denied)
          pass "branch-no-pr outcome is branch-only scoped"
          ;;
        *)
          fail "branch-no-pr outcome must not use PR lifecycle states"
          ;;
      esac
      ;;
    branch-pr)
      case "$target" in
        preserved|published|ready|landed|cleaned|blocked|escalated|denied)
          pass "branch-pr target outcome is PR-route scoped"
          ;;
        *)
          fail "branch-pr target outcome must not use branch-only lifecycle states"
          ;;
      esac
      case "$outcome" in
        preserved|published|ready|landed|cleaned|blocked|escalated|denied)
          pass "branch-pr outcome is PR-route scoped"
          ;;
        *)
          fail "branch-pr outcome must not use branch-only lifecycle states"
          ;;
      esac
      ;;
    stage-only-escalate)
      case "$target" in
        preserved|blocked|escalated|denied) pass "stage-only target is preservation or blocker scoped" ;;
        *) fail "stage-only-escalate target must not claim completion lifecycle states" ;;
      esac
      case "$outcome" in
        preserved|blocked|escalated|denied) pass "stage-only outcome is preservation or blocker scoped" ;;
        *) fail "stage-only-escalate outcome must not claim completion lifecycle states" ;;
      esac
      ;;
  esac

  if [[ "$route" == "branch-no-pr" ]]; then
    if jq -e '(.durable_history.kind == "pr") or (.durable_history.pr_url? // "" | length > 0) or (.pr_url? // "" | length > 0) or (.pr_number? // "" | tostring | length > 0)' "$RECEIPT_PATH" >/dev/null; then
      fail "branch-no-pr receipt must not include PR metadata"
    else
      pass "branch-no-pr receipt has no PR metadata"
    fi
    if [[ "$publication" == pr-* ]]; then
      fail "branch-no-pr receipt must not use PR publication status"
    else
      pass "branch-no-pr receipt avoids PR publication status"
    fi
    if [[ "$outcome" == "branch-local-complete" ]]; then
      [[ "$integration" != "landed" ]] && pass "branch-local-complete is not landed" || fail "branch-local-complete must not claim landed integration"
      [[ "$durable_kind" == "commit" ]] && pass "branch-local-complete has branch commit evidence" || fail "branch-local-complete requires commit durable history"
      [[ "$closeout_outcome" != "completed" ]] && pass "branch-local-complete is continued or blocked closeout" || fail "branch-local-complete must not claim completed closeout"
    fi
    if [[ "$outcome" == "published-branch" ]]; then
      [[ "$publication" == "pushed-branch" ]] && pass "published-branch has pushed branch publication status" || fail "published-branch requires pushed-branch publication status"
      json_has_nonempty '.remote_branch_ref' && pass "published-branch has remote branch ref" || fail "published-branch requires remote_branch_ref"
      [[ "$integration" != "landed" ]] && pass "published-branch is not landed" || fail "published-branch must not claim landed integration"
      [[ "$closeout_outcome" != "completed" ]] && pass "published-branch is continued or blocked closeout" || fail "published-branch must not claim completed closeout"
      local source_branch_ref remote_branch_ref remote_name recorded_sha expected_remote
      source_branch_ref="$(json_value '.source_branch_ref')"
      remote_branch_ref="$(json_value '.remote_branch_ref')"
      remote_name="$(remote_ref_name "$remote_branch_ref")"
      recorded_sha="$(remote_ref_sha "$remote_branch_ref")"
      expected_remote="origin/$source_branch_ref"
      [[ "$remote_name" == "$expected_remote" ]] && pass "published-branch remote ref names the source branch" || fail "published-branch remote_branch_ref must be origin/source_branch_ref"
      if [[ -n "$recorded_sha" && -n "$durable_ref" ]] && looks_like_sha "$recorded_sha" && looks_like_sha "$durable_ref"; then
        [[ "$recorded_sha" == "$durable_ref" ]] && pass "published-branch remote ref SHA matches durable branch head" || fail "published-branch remote ref SHA must match durable_history.ref"
      elif [[ -z "$recorded_sha" ]]; then
        fail "published-branch remote_branch_ref must include exact @sha"
      fi
      if [[ "$VERIFY_LIVE_REFS" -eq 1 ]]; then
        if git -C "$ROOT_DIR" rev-parse --verify "$remote_name^{commit}" >/dev/null 2>&1; then
          local live_remote_ref
          live_remote_ref="$(git -C "$ROOT_DIR" rev-parse "$remote_name")"
          if [[ -n "$recorded_sha" ]]; then
            [[ "$live_remote_ref" == "$recorded_sha" ]] && pass "live remote branch ref matches recorded SHA" || fail "live remote branch ref does not match recorded SHA"
          fi
        else
          fail "live remote branch ref unavailable: $remote_name"
        fi
      fi
    fi
    if [[ ( "$target" == "landed" || "$target" == "cleaned" ) && "$integration" != "landed" ]]; then
      jq -e '.landing_evaluation | type == "object"' "$RECEIPT_PATH" >/dev/null 2>&1 && pass "landing target has landing evaluation" || fail "landing target requires landing_evaluation"
      json_has_nonempty '.not_landed_reason' && pass "landing target downgrade has not_landed_reason" || fail "landing target downgrade requires not_landed_reason"
      [[ "$closeout_outcome" != "completed" ]] && pass "landing target downgrade is not completed closeout" || fail "landing target downgrade must not claim completed closeout"
    fi
    if [[ "$target" == "cleaned" && "$outcome" != "cleaned" ]]; then
      json_has_nonempty '.not_cleaned_reason' && pass "cleaned target downgrade has not_cleaned_reason" || fail "cleaned target downgrade requires not_cleaned_reason"
      [[ "$closeout_outcome" != "completed" ]] && pass "cleaned target downgrade is not completed closeout" || fail "cleaned target downgrade must not claim completed closeout"
    fi
    if [[ "$outcome" == "landed" || "$outcome" == "cleaned" ]]; then
      [[ "$publication" == "hosted-main-updated" ]] && pass "branch-no-pr landed has hosted main update status" || fail "branch-no-pr landed requires hosted-main-updated publication status"
      [[ "$integration_method" == "fast-forward" ]] && pass "branch-no-pr landed uses fast-forward integration" || fail "branch-no-pr landed requires fast-forward integration"
      jq -e '.landing_evaluation | type == "object"' "$RECEIPT_PATH" >/dev/null 2>&1 && pass "branch-no-pr landed has landing evaluation" || fail "branch-no-pr landed requires landing_evaluation"
      jq -e '.hosted_landing | type == "object"' "$RECEIPT_PATH" >/dev/null 2>&1 && pass "branch-no-pr landed has hosted landing evidence" || fail "branch-no-pr landed requires hosted_landing evidence"
      json_has_nonempty '.hosted_landing.provider_ruleset_ref' && pass "hosted landing has provider ruleset evidence" || fail "hosted landing requires provider_ruleset_ref"
      json_array_nonempty '.hosted_landing.required_check_refs' && pass "hosted landing has exact-SHA check refs" || fail "hosted landing requires required_check_refs"
      jq -e '.hosted_landing.fast_forward_only == true' "$RECEIPT_PATH" >/dev/null 2>&1 && pass "hosted landing is fast-forward only" || fail "hosted landing requires fast_forward_only true"
      if json_has_nonempty '.hosted_landing.source_ref' && json_has_nonempty '.hosted_landing.validated_ref'; then
        [[ "$(json_value '.hosted_landing.source_ref')" == "$(json_value '.hosted_landing.validated_ref')" ]] && pass "hosted landing validates exact source SHA" || fail "hosted landing validated_ref must equal source_ref"
      else
        fail "hosted landing requires source_ref and validated_ref"
      fi
      if json_has_nonempty '.hosted_landing.target_post_ref' && json_has_nonempty '.landed_ref'; then
        [[ "$(json_value '.hosted_landing.target_post_ref')" == "$(json_value '.landed_ref')" ]] && pass "origin/main target post-ref equals landed ref" || fail "hosted landing target_post_ref must equal landed_ref"
      else
        fail "hosted landing requires target_post_ref and landed_ref"
      fi
    fi
  fi

  if [[ "$route" == "direct-main" ]]; then
    [[ "$integration" == "landed" ]] && pass "direct-main integration is landed" || fail "direct-main must claim landed integration"
    [[ "$integration_method" == "direct-commit" ]] && pass "direct-main uses direct-commit integration" || fail "direct-main must use direct-commit integration"
    [[ "$durable_kind" == "commit" ]] && pass "direct-main uses commit durable history" || fail "direct-main requires commit durable history"
    if [[ "$publication" == pr-* ]]; then
      fail "direct-main must not use PR publication status"
    else
      pass "direct-main avoids PR publication status"
    fi
    if jq -e '(.durable_history.kind == "pr") or (.durable_history.pr_url? // "" | length > 0) or (.pr_url? // "" | length > 0) or (.pr_number? // "" | tostring | length > 0)' "$RECEIPT_PATH" >/dev/null; then
      fail "direct-main receipt must not include PR metadata"
    else
      pass "direct-main receipt has no PR metadata"
    fi
  fi

  if [[ "$outcome" == "preserved" && "$integration" == "landed" ]]; then
    fail "preserved outcome must not claim landed integration"
  elif [[ "$outcome" == "preserved" ]]; then
    pass "preserved outcome does not claim landed integration"
  fi

  if [[ "$integration" == "landed" || "$outcome" == "landed" || "$outcome" == "cleaned" ]]; then
    json_has_nonempty '.landed_ref' && pass "landed claim has landed ref" || fail "landed claim requires landed_ref"
    json_has_nonempty '.target_branch_ref' && pass "landed claim has target branch ref" || fail "landed claim requires target_branch_ref"
    jq -e '.main_alignment.aligned == true' "$RECEIPT_PATH" >/dev/null 2>&1 && pass "landed claim has final main alignment evidence" || fail "landed claim requires main_alignment.aligned true"
    if json_has_nonempty '.main_alignment.landed_ref' && json_has_nonempty '.landed_ref'; then
      [[ "$(json_value '.main_alignment.landed_ref')" == "$(json_value '.landed_ref')" ]] && pass "main alignment landed_ref matches receipt landed_ref" || fail "main_alignment.landed_ref must equal landed_ref"
    fi
    if json_has_nonempty '.main_alignment.local_main_ref' && json_has_nonempty '.main_alignment.origin_main_ref' && json_has_nonempty '.landed_ref'; then
      local alignment_local alignment_origin alignment_landed
      alignment_local="$(json_value '.main_alignment.local_main_ref')"
      alignment_origin="$(json_value '.main_alignment.origin_main_ref')"
      alignment_landed="$(json_value '.landed_ref')"
      [[ "$alignment_local" == "$alignment_origin" && "$alignment_origin" == "$alignment_landed" ]] && pass "local main, origin/main, and landed_ref align" || fail "main_alignment refs must all equal landed_ref"
    fi
    json_has_nonempty '.rollback_handle.ref' && pass "landed claim has rollback handle" || fail "landed claim requires rollback handle"
    json_array_nonempty '.validation_evidence_refs' && pass "landed claim has validation evidence" || fail "landed claim requires validation evidence"
    if [[ "$durable_kind" == "patch" || "$durable_kind" == "checkpoint" ]]; then
      fail "patch or checkpoint durable history cannot claim landed"
    else
      pass "landed claim uses commit, branch, or PR durable history"
    fi
  fi

  if [[ "$route" == "branch-pr" ]]; then
    if [[ "$outcome" == "preserved" ]]; then
      [[ "$publication" == "none" ]] && pass "branch-pr preserved has no PR publication" || fail "branch-pr preserved must not claim PR publication"
    fi
    if [[ "$outcome" == "published" ]]; then
      [[ "$publication" == "pr-opened" ]] && pass "branch-pr published has opened PR status" || fail "branch-pr published requires pr-opened publication status"
      [[ "$durable_kind" == "pr" ]] && pass "branch-pr published uses PR durable history" || fail "branch-pr published requires PR durable history"
      json_has_nonempty '.durable_history.pr_url' && pass "branch-pr published has PR URL" || fail "branch-pr published requires PR URL"
    fi
    if [[ "$outcome" == "ready" ]]; then
      [[ "$publication" == "pr-ready" ]] && pass "branch-pr ready has ready PR status" || fail "branch-pr ready requires pr-ready publication status"
      [[ "$durable_kind" == "pr" ]] && pass "branch-pr ready uses PR durable history" || fail "branch-pr ready requires PR durable history"
      json_has_nonempty '.durable_history.pr_url' && pass "branch-pr ready has PR URL" || fail "branch-pr ready requires PR URL"
    fi
    if [[ "$closeout_outcome" == "completed" && ( "$outcome" == "published" || "$outcome" == "ready" || "$publication" == "pr-opened" || "$publication" == "pr-ready" ) ]]; then
      fail "branch-pr cannot claim full closeout from draft/open/ready PR state"
    else
      pass "branch-pr full closeout is not based only on draft/open/ready state"
    fi
    if [[ "$outcome" == "landed" || "$outcome" == "cleaned" ]]; then
      [[ "$publication" == "pr-merged" ]] && pass "PR landed claim has merged publication status" || fail "PR landed claim requires pr-merged publication status"
      json_has_nonempty '.durable_history.pr_url' && pass "PR landed claim has PR URL" || fail "PR landed claim requires PR URL"
    fi
  fi

  if [[ "$cleanup" == "completed" ]]; then
    json_array_nonempty '.cleanup_evidence_refs' && pass "completed cleanup has evidence refs" || fail "completed cleanup requires cleanup_evidence_refs"
  elif [[ "$cleanup" == "deferred" ]]; then
    if json_array_nonempty '.cleanup_evidence_refs' || json_array_nonempty '.external_blocker_refs'; then
      pass "deferred cleanup has evidence or blocker refs"
    else
      fail "deferred cleanup requires cleanup evidence or external blocker refs"
    fi
  fi

  if [[ ( "$route" == "branch-no-pr" || "$route" == "branch-pr" ) && "$integration" == "landed" && "$closeout_outcome" == "completed" ]]; then
    case "$cleanup" in
      completed|deferred) pass "completed landed branch closeout has cleanup completed or deferred" ;;
      *) fail "completed landed branch closeout must not leave cleanup pending" ;;
    esac
    jq -e '.source_branch_cleanup | type == "object"' "$RECEIPT_PATH" >/dev/null 2>&1 && pass "completed landed branch closeout has source branch cleanup disposition" || fail "completed landed branch closeout requires source_branch_cleanup"
    if jq -e '.source_branch_cleanup | type == "object"' "$RECEIPT_PATH" >/dev/null 2>&1; then
      local cleanup_disposition
      cleanup_disposition="$(json_value '.source_branch_cleanup.status')"
      case "$cleanup_disposition" in
        completed|deferred|skipped) pass "source branch cleanup disposition is terminal or explicitly deferred" ;;
        *) fail "source_branch_cleanup.status must be completed, deferred, or skipped for completed closeout" ;;
      esac
    fi
  fi

  if [[ "$outcome" == "cleaned" ]]; then
    case "$cleanup" in
      completed|deferred) pass "cleaned outcome has terminal or explicitly deferred cleanup status" ;;
      *) fail "cleaned outcome must not have pending or not_applicable cleanup status" ;;
    esac
  fi
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --receipt)
      shift
      [[ $# -gt 0 ]] || { usage >&2; exit 2; }
      RECEIPT_PATH="$1"
      ;;
    --verify-live-refs)
      VERIFY_LIVE_REFS=1
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

if [[ -n "$RECEIPT_PATH" && "$RECEIPT_PATH" != /* ]]; then
  RECEIPT_PATH="$ROOT_DIR/$RECEIPT_PATH"
fi

command -v jq >/dev/null 2>&1 || { echo "[ERROR] jq is required" >&2; exit 1; }
command -v yq >/dev/null 2>&1 || { echo "[ERROR] yq is required" >&2; exit 1; }

echo "== Change Closeout Lifecycle Alignment Validation =="
validate_contracts
[[ -z "$RECEIPT_PATH" ]] || validate_receipt

echo
echo "Validation summary: errors=$errors"
[[ "$errors" -eq 0 ]]

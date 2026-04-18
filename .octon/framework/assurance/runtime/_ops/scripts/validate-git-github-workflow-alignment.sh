#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
ROOT_DIR="$(cd -- "$OCTON_DIR/.." && pwd)"

CONTRACT_FILE="$OCTON_DIR/framework/agency/practices/standards/git-worktree-autonomy-contract.yml"
MANIFEST_FILE="$OCTON_DIR/instance/ingress/manifest.yml"
INGRESS_FILE="$OCTON_DIR/instance/ingress/AGENTS.md"
PLAYBOOK_FILE="$OCTON_DIR/framework/agency/practices/git-autonomy-playbook.md"
OVERVIEW_FILE="$OCTON_DIR/framework/agency/practices/git-github-autonomy-workflow-v1.md"
PR_DOC_FILE="$OCTON_DIR/framework/agency/practices/pull-request-standards.md"
OPEN_SCRIPT="$OCTON_DIR/framework/agency/_ops/scripts/git/git-pr-open.sh"
SHIP_SCRIPT="$OCTON_DIR/framework/agency/_ops/scripts/git/git-pr-ship.sh"
CLOSEOUT_SKILL_FILE="$OCTON_DIR/framework/capabilities/runtime/skills/remediation/closeout-pr/SKILL.md"
SKILL_FILE="$OCTON_DIR/framework/capabilities/runtime/skills/remediation/resolve-pr-comments/SKILL.md"
SAFETY_FILE="$OCTON_DIR/framework/capabilities/runtime/skills/remediation/resolve-pr-comments/references/safety.md"
TEMPLATE_FILE="$ROOT_DIR/.github/PULL_REQUEST_TEMPLATE.md"
PR_QUALITY_FILE="$ROOT_DIR/.github/workflows/pr-quality.yml"
PR_AUTONOMY_FILE="$ROOT_DIR/.github/workflows/pr-autonomy-policy.yml"
PR_AUTO_MERGE_FILE="$ROOT_DIR/.github/workflows/pr-auto-merge.yml"

errors=0
warnings=0

fail() {
  echo "[ERROR] $1"
  errors=$((errors + 1))
}

warn() {
  echo "[WARN] $1"
  warnings=$((warnings + 1))
}

pass() {
  echo "[OK] $1"
}

require_file() {
  local file="$1"
  if [[ ! -f "$file" ]]; then
    fail "missing file: ${file#$ROOT_DIR/}"
  else
    pass "found file: ${file#$ROOT_DIR/}"
  fi
}

require_literal() {
  local file="$1"
  local needle="$2"
  local ok_msg="$3"
  local fail_msg="$4"
  if grep -Fq -- "$needle" "$file"; then
    pass "$ok_msg"
  else
    fail "$fail_msg"
  fi
}

require_absent_literal() {
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

require_yq_value() {
  local file="$1"
  local expr="$2"
  local ok_msg="$3"
  local fail_msg="$4"
  local value

  value="$(yq -r "$expr // \"\"" "$file" 2>/dev/null || true)"
  if [[ -n "$value" && "$value" != "null" ]]; then
    pass "$ok_msg"
  else
    fail "$fail_msg"
  fi
}

check_contract() {
  require_yq_value \
    "$CONTRACT_FILE" \
    '.operating_model.final_merge_authority.system' \
    "workflow contract defines final merge authority" \
    "workflow contract missing final merge authority"
  require_yq_value \
    "$CONTRACT_FILE" \
    '.closeout.ready_pr_status_contexts.branch_worktree_ready_pr_waiting_on_required_checks_or_auto_merge.message' \
    "workflow contract defines ready-pr check or auto-merge status" \
    "workflow contract missing ready-pr waiting-on-checks or auto-merge status"
  require_yq_value \
    "$CONTRACT_FILE" \
    '.remediation.allowed_git_subset[] | select(. == "git push")' \
    "workflow contract includes git push in safe remediation subset" \
    "workflow contract missing git push in safe remediation subset"
  require_yq_value \
    "$CONTRACT_FILE" \
    '.helpers.git_pr_ship.explicit_request_flags[] | select(. == "--request-ready")' \
    "workflow contract defines explicit ready request flag" \
    "workflow contract missing explicit ready request flag"
  require_yq_value \
    "$CONTRACT_FILE" \
    '.helpers.git_pr_open.draft_only | select(. == true)' \
    "workflow contract defines git-pr-open as draft-only" \
    "workflow contract missing draft-only git-pr-open semantics"
  require_yq_value \
    "$CONTRACT_FILE" \
    '.autonomous_closeout_loop.owner_surface' \
    "workflow contract defines an owner surface for the autonomous closeout loop" \
    "workflow contract missing autonomous closeout loop owner surface"
  require_yq_value \
    "$CONTRACT_FILE" \
    '.validation.drift_classes[] | select(. == "git-pr-open widening initial PR creation beyond draft-first")' \
    "workflow contract tracks git-pr-open draft-first drift" \
    "workflow contract missing git-pr-open draft-first drift coverage"
  require_yq_value \
    "$CONTRACT_FILE" \
    '.validation.drift_classes[] | select(. == "git-pr-open template population coupled to stale placeholder prose")' \
    "workflow contract tracks git-pr-open template-population drift" \
    "workflow contract missing git-pr-open template-population drift coverage"
}

check_ingress() {
  require_yq_value \
    "$MANIFEST_FILE" \
    '.workflow_contract_ref' \
    "ingress manifest points to workflow contract" \
    "ingress manifest missing workflow contract reference"
  require_yq_value \
    "$MANIFEST_FILE" \
    '.branch_closeout_gate.detect.pr_state.ready_status_contexts[0]' \
    "ingress manifest defines ready-pr status contexts" \
    "ingress manifest missing ready-pr status contexts"
  require_yq_value \
    "$MANIFEST_FILE" \
    '.branch_closeout_gate.status_by_context.branch_worktree_ready_pr_waiting_on_required_checks_or_auto_merge' \
    "ingress manifest explicitly handles ready PR waiting on checks or auto-merge" \
    "ingress manifest missing ready PR status handling for checks or auto-merge"
  require_yq_value \
    "$MANIFEST_FILE" \
    '.branch_closeout_gate.status_by_context.branch_worktree_ready_pr_waiting_on_reviewer_or_maintainer_confirmation' \
    "ingress manifest explicitly handles ready PR waiting on reviewer confirmation" \
    "ingress manifest missing ready PR status handling for reviewer confirmation"
  require_literal \
    "$INGRESS_FILE" \
    "Ready PR states report status instead of asking another closeout question" \
    "ingress AGENTS documents ready-pr status behavior" \
    "ingress AGENTS missing ready-pr status behavior"
}

check_docs() {
  require_literal \
    "$PLAYBOOK_FILE" \
    ".octon/framework/agency/practices/standards/git-worktree-autonomy-contract.yml" \
    "playbook references canonical workflow contract" \
    "playbook missing canonical workflow contract reference"
  require_literal \
    "$OVERVIEW_FILE" \
    ".octon/framework/agency/practices/standards/git-worktree-autonomy-contract.yml" \
    "workflow overview references canonical workflow contract" \
    "workflow overview missing canonical workflow contract reference"
  require_literal \
    "$PLAYBOOK_FILE" \
    "/closeout-pr" \
    "playbook documents the closeout-pr skill" \
    "playbook missing closeout-pr skill reference"
  require_literal \
    "$OVERVIEW_FILE" \
    "closeout-pr" \
    "workflow overview documents the closeout-pr skill" \
    "workflow overview missing closeout-pr skill reference"
  require_absent_literal \
    "$PLAYBOOK_FILE" \
    "Opens or updates the PR in draft-first posture." \
    "playbook no longer overstates git-pr-open behavior" \
    "playbook still claims git-pr-open opens or updates PRs"
  require_literal \
    "$PR_DOC_FILE" \
    "fix + commit + push + reply" \
    "pull-request standards use fix + commit + push + reply remediation" \
    "pull-request standards missing fix + commit + push + reply remediation"
  require_absent_literal \
    "$PR_DOC_FILE" \
    "Rebase and force-push cleanup." \
    "pull-request standards no longer teach stale rebase and force-push cleanup wording" \
    "pull-request standards still teach stale rebase and force-push cleanup wording"
}

check_helper_and_skill() {
  require_literal \
    "$OPEN_SCRIPT" \
    "git-pr-open.sh is draft-only. Use git-pr-ship.sh --request-ready once author action items are closed." \
    "git-pr-open rejects non-draft widening" \
    "git-pr-open missing draft-only rejection guidance"
  require_literal \
    "$OPEN_SCRIPT" \
    'PR_ARGS=(pr create --base "$BASE_BRANCH" --head "$CURRENT_BRANCH" --title "$TITLE" --body-file "$BODY_TMP" --draft)' \
    "git-pr-open always creates draft PRs" \
    "git-pr-open is not pinned to draft PR creation"
  require_literal \
    "$OPEN_SCRIPT" \
    'replace_markdown_section "$BODY_TMP" "## Why" "$WHY_TEXT"' \
    "git-pr-open populates the Why section from the canonical heading" \
    "git-pr-open missing canonical Why-section population"
  require_absent_literal \
    "$OPEN_SCRIPT" \
    "Open non-draft PR instead of draft." \
    "git-pr-open no longer advertises non-draft PR creation" \
    "git-pr-open still advertises non-draft PR creation"
  require_absent_literal \
    "$OPEN_SCRIPT" \
    "The problem this solves and why it matters. Include ticket/issue links." \
    "git-pr-open no longer depends on stale placeholder prose" \
    "git-pr-open still depends on stale placeholder prose"
  require_literal \
    "$SHIP_SCRIPT" \
    "--request-ready" \
    "git-pr-ship exposes explicit ready request flag" \
    "git-pr-ship missing explicit ready request flag"
  require_literal \
    "$SHIP_SCRIPT" \
    "--request-automerge" \
    "git-pr-ship exposes explicit auto-merge request flag" \
    "git-pr-ship missing explicit auto-merge request flag"
  require_literal \
    "$SHIP_SCRIPT" \
    "Report current PR status, lane hints, and blockers without mutating PR state." \
    "git-pr-ship defaults to status-only mode" \
    "git-pr-ship missing status-only default behavior"
  require_absent_literal \
    "$SHIP_SCRIPT" \
    "1) request ready-for-review if the PR is still draft," \
    "git-pr-ship no longer defaults to eager mutation" \
    "git-pr-ship still defaults to eager mutation"
  require_literal \
    "$SHIP_SCRIPT" \
    "GitHub remains the final merge gate" \
    "git-pr-ship states that GitHub is the final merge gate" \
    "git-pr-ship missing final merge gate message"
  require_literal \
    "$SKILL_FILE" \
    "Bash(git add *)" \
    "resolve-pr-comments skill allows git add" \
    "resolve-pr-comments skill missing git add from allowed-tools"
  require_literal \
    "$SKILL_FILE" \
    "Bash(git commit *)" \
    "resolve-pr-comments skill allows git commit" \
    "resolve-pr-comments skill missing git commit from allowed-tools"
  require_literal \
    "$SKILL_FILE" \
    "Bash(git push *)" \
    "resolve-pr-comments skill allows git push" \
    "resolve-pr-comments skill missing git push from allowed-tools"
  require_file \
    "$CLOSEOUT_SKILL_FILE"
  require_literal \
    "$CLOSEOUT_SKILL_FILE" \
    "same branch and same PR for the life of the task" \
    "closeout-pr skill preserves same branch and same PR lifetime" \
    "closeout-pr skill missing same branch/same PR lifetime rule"
  require_literal \
    "$CLOSEOUT_SKILL_FILE" \
    "fix + commit + push + reply" \
    "closeout-pr skill uses fix + commit + push + reply remediation" \
    "closeout-pr skill missing fix + commit + push + reply remediation rule"
  require_literal \
    "$CLOSEOUT_SKILL_FILE" \
    "Continue until merged or until a precise external blocker is reached and reported" \
    "closeout-pr skill defines the merged-or-blocker stop condition" \
    "closeout-pr skill missing merged-or-blocker stop condition"
  require_literal \
    "$SAFETY_FILE" \
    "Push the updated branch before replying that the fix landed" \
    "resolve-pr-comments safety requires push before reply" \
    "resolve-pr-comments safety missing push-before-reply rule"
  require_absent_literal \
    "$SAFETY_FILE" \
    '`git push` access (user must push manually)' \
    "resolve-pr-comments safety no longer claims git push is unavailable" \
    "resolve-pr-comments safety still claims git push is unavailable"
}

check_github_companions() {
  require_literal \
    "$TEMPLATE_FILE" \
    "fix, commit, push, reply" \
    "PR template reflects hardened remediation wording" \
    "PR template missing hardened remediation wording"
  require_literal \
    "$PR_QUALITY_FILE" \
    "const templatePath = \".github/PULL_REQUEST_TEMPLATE.md\";" \
    "pr-quality workflow validates canonical PR template path" \
    "pr-quality workflow not pinned to canonical PR template path"
  require_literal \
    "$PR_AUTONOMY_FILE" \
    "standardsText = await readTextFile" \
    "pr-autonomy-policy reads standards from canonical repo state" \
    "pr-autonomy-policy missing canonical standards read"
  require_literal \
    "$PR_AUTO_MERGE_FILE" \
    "evaluate-pr-autonomy-policy.sh" \
    "pr-auto-merge derives merge authority from canonical policy evaluator" \
    "pr-auto-merge missing canonical autonomy policy evaluator"
}

main() {
  echo "== Git/GitHub Workflow Alignment Validation =="

  command -v yq >/dev/null 2>&1 || {
    echo "[ERROR] yq is required for workflow alignment validation" >&2
    exit 1
  }

  require_file "$CONTRACT_FILE"
  require_file "$MANIFEST_FILE"
  require_file "$INGRESS_FILE"
  require_file "$PLAYBOOK_FILE"
  require_file "$OVERVIEW_FILE"
  require_file "$PR_DOC_FILE"
  require_file "$OPEN_SCRIPT"
  require_file "$SHIP_SCRIPT"
  require_file "$SKILL_FILE"
  require_file "$SAFETY_FILE"
  require_file "$TEMPLATE_FILE"
  require_file "$PR_QUALITY_FILE"
  require_file "$PR_AUTONOMY_FILE"
  require_file "$PR_AUTO_MERGE_FILE"

  check_contract
  check_ingress
  check_docs
  check_helper_and_skill
  check_github_companions

  echo
  echo "Validation summary: errors=$errors warnings=$warnings"
  if [[ $errors -gt 0 ]]; then
    exit 1
  fi
}

main "$@"

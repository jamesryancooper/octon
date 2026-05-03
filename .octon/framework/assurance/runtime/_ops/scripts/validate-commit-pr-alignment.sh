#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
ROOT_DIR="$(cd -- "$OCTON_DIR/.." && pwd)"

COMMITS_DOC="$OCTON_DIR/framework/execution-roles/practices/commits.md"
PR_DOC="$OCTON_DIR/framework/execution-roles/practices/pull-request-standards.md"
STANDARDS_JSON="$OCTON_DIR/framework/execution-roles/practices/standards/commit-pr-standards.json"
POLICY="$OCTON_DIR/framework/product/contracts/default-work-unit.yml"

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

require_jq() {
  local file="$1"
  local expr="$2"
  local ok_msg="$3"
  local fail_msg="$4"
  jq -e "$expr" "$file" >/dev/null 2>&1 && pass "$ok_msg" || fail "$fail_msg"
}

main() {
  echo "== Commit/PR Route-Aware Alignment Validation =="
  command -v jq >/dev/null 2>&1 || { echo "[ERROR] jq is required" >&2; exit 1; }

  require_file "$COMMITS_DOC"
  require_file "$PR_DOC"
  require_file "$STANDARDS_JSON"
  require_file "$POLICY"
  require_jq "$STANDARDS_JSON" '.commit.policy_doc == ".octon/framework/execution-roles/practices/commits.md" or .commit_policy_doc == ".octon/framework/execution-roles/practices/commits.md"' "standards point to commits.md" "standards must point to commits.md"
  require_jq "$STANDARDS_JSON" '.pr.policy_doc == ".octon/framework/execution-roles/practices/pull-request-standards.md" or .pr_policy_doc == ".octon/framework/execution-roles/practices/pull-request-standards.md"' "standards point to pull-request-standards.md" "standards must point to pull-request-standards.md"
  require_literal "$COMMITS_DOC" "direct-main" "commits doc covers direct-main route" "commits doc must cover direct-main route"
  require_literal "$COMMITS_DOC" "branch-no-pr" "commits doc covers branch-no-pr route" "commits doc must cover branch-no-pr route"
  require_literal "$COMMITS_DOC" "Change receipt" "commits doc requires Change receipt evidence" "commits doc must require Change receipt evidence"
  require_literal "$PR_DOC" "PR-backed Changes" "PR standards are scoped to PR-backed Changes" "PR standards must be scoped to PR-backed Changes"
  require_literal "$PR_DOC" "Change receipt" "PR standards require Change receipt fields" "PR standards must require Change receipt fields"
  require_literal "$PR_DOC" "Autonomous Draft Completion Policy" "PR standards define autonomous draft completion" "PR standards must define autonomous draft completion"
  require_jq "$STANDARDS_JSON" '.pr.autonomous_draft_completion.status == "allowed" and .pr.autonomous_draft_completion.route == "branch-pr"' "standards route autonomous draft completion to branch-pr" "standards must route autonomous draft completion to branch-pr"
  require_jq "$STANDARDS_JSON" '.pr.autonomous_draft_completion.requires_open_draft == true and .pr.autonomous_draft_completion.requires_autonomous_lane == true' "standards require open autonomous draft PR before completion" "standards must require open autonomous draft PR before completion"
  require_jq "$STANDARDS_JSON" '.pr.autonomous_draft_completion.requires_change_receipt_or_closeout_evidence == true' "standards require receipt or closeout evidence before draft completion" "standards must require receipt or closeout evidence before draft completion"
  require_jq "$STANDARDS_JSON" '.pr.autonomous_draft_completion.high_impact_posture.autonomy_model == "elevated-autonomy" and .pr.autonomous_draft_completion.high_impact_posture.manual_default == false' "standards treat high-impact as elevated autonomy" "standards must treat high-impact as elevated autonomy"
  require_jq "$STANDARDS_JSON" '.pr.autonomous_draft_completion.protected_main_bypass_allowed == false' "standards forbid protected-main bypass for draft completion" "standards must forbid protected-main bypass for draft completion"

  echo
  echo "Validation summary: errors=$errors"
  [[ "$errors" -eq 0 ]]
}

main "$@"

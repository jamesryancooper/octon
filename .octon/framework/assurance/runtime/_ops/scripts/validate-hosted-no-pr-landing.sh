#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
ROOT_DIR="$(cd -- "$OCTON_DIR/.." && pwd)"

POLICY="$OCTON_DIR/framework/product/contracts/default-work-unit.yml"
RECEIPT_SCHEMA="$OCTON_DIR/framework/product/contracts/change-receipt-v1.schema.json"
CLOSEOUT_CHANGE="$OCTON_DIR/framework/capabilities/runtime/skills/remediation/closeout-change/SKILL.md"
WORKFLOW_STAGE="$OCTON_DIR/framework/orchestration/runtime/workflows/meta/closeout/stages/02-request-or-report.md"
WORKTREE_CONTRACT="$OCTON_DIR/framework/execution-roles/practices/standards/git-worktree-autonomy-contract.yml"
REQUIRED_CHECKS_SCRIPT="$OCTON_DIR/framework/execution-roles/_ops/scripts/git/git-required-checks-at-ref.sh"
HOSTED_PREFLIGHT_SCRIPT="$OCTON_DIR/framework/execution-roles/_ops/scripts/git/git-branch-hosted-preflight.sh"
HOSTED_LAND_SCRIPT="$OCTON_DIR/framework/execution-roles/_ops/scripts/git/git-branch-land-hosted-no-pr.sh"
GITHUB_CONTROL_CONTRACT="$OCTON_DIR/framework/execution-roles/practices/standards/github-control-plane-contract.json"

RECEIPT_PATH=""
SKIP_LIVE_REMOTE=0
REQUIRE_LIVE_REMOTE=0
errors=0

usage() {
  cat <<'USAGE'
usage:
  validate-hosted-no-pr-landing.sh [--receipt <path>] [--skip-live-remote] [--require-live-remote]

Without --receipt, validates static hosted no-PR landing policy/helper alignment.
With --receipt, validates that branch-no-pr landed/cleaned claims have hosted
landing evidence and cannot be local checkpoints, branch-local commits, or
pushed-only branches.
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

validate_static() {
  for file in "$POLICY" "$RECEIPT_SCHEMA" "$CLOSEOUT_CHANGE" "$WORKFLOW_STAGE" "$WORKTREE_CONTRACT" "$REQUIRED_CHECKS_SCRIPT" "$HOSTED_PREFLIGHT_SCRIPT" "$HOSTED_LAND_SCRIPT" "$GITHUB_CONTROL_CONTRACT"; do
    require_file "$file"
  done

  require_yq "$POLICY" '.route_lifecycle_outcomes."branch-no-pr".landed_requires[]? | select(. == "provider_ruleset_allows_route_neutral_fast_forward_update")' "policy requires route-neutral provider rules for hosted no-PR landing" "policy must require route-neutral provider rules for hosted no-PR landing"
  require_yq "$POLICY" '.route_lifecycle_outcomes."branch-no-pr".landed_requires[]? | select(. == "source_branch_pushed_to_remote")' "policy requires pushed source branch for hosted no-PR landing" "policy must require pushed source branch for hosted no-PR landing"
  require_yq "$POLICY" '.route_lifecycle_outcomes."branch-no-pr".landed_requires[]? | select(. == "origin_main_equals_landed_ref_after_push")' "policy requires origin/main equality after hosted no-PR landing" "policy must require origin/main equality after hosted no-PR landing"
  require_jq "$RECEIPT_SCHEMA" '.properties.hosted_landing.required[] | select(. == "source_ref")' "receipt schema requires hosted source ref" "receipt schema must require hosted source ref"
  require_jq "$RECEIPT_SCHEMA" '.properties.hosted_landing.required[] | select(. == "target_post_ref")' "receipt schema requires hosted target post-ref" "receipt schema must require hosted target post-ref"
  require_jq "$RECEIPT_SCHEMA" '.properties.hosted_landing.required[] | select(. == "required_check_refs")' "receipt schema requires hosted required check refs" "receipt schema must require hosted required check refs"
  require_literal "$CLOSEOUT_CHANGE" "hosted no-PR landing preflight" "closeout skill requires hosted no-PR preflight" "closeout skill must require hosted no-PR preflight"
  require_literal "$WORKFLOW_STAGE" "exact source SHA required checks" "workflow requires exact source SHA required checks" "workflow must require exact source SHA required checks"
  require_yq "$WORKTREE_CONTRACT" '.helpers.git_branch_land_hosted_no_pr.posture == "fast-forward-only hosted no-PR landing helper"' "worktree contract registers hosted no-PR landing helper" "worktree contract must register hosted no-PR landing helper"
  require_literal "$REQUIRED_CHECKS_SCRIPT" "exact commit SHA" "required-check helper validates exact commit SHA" "required-check helper must validate exact commit SHA"
  require_literal "$HOSTED_PREFLIGHT_SCRIPT" "Provider ruleset requires PR; hosted branch-no-pr landing unavailable." "preflight fails closed when provider requires PR" "preflight must fail closed when provider requires PR"
  require_literal "$HOSTED_LAND_SCRIPT" 'push "$REMOTE" "$SOURCE_REF:refs/heads/$TARGET_BRANCH"' "hosted land helper uses non-force target push" "hosted land helper must use non-force target push"
  require_jq "$GITHUB_CONTROL_CONTRACT" '(.rulesets.current_live_main.required_checks // []) | index("route_neutral_closeout_validation")' "control contract exposes route-neutral required checks" "control contract must expose route-neutral required checks"
}

expected_route_neutral_checks() {
  jq -r '
    if (.rulesets.current_live_main.required_checks // [] | length) > 0 then
      .rulesets.current_live_main.required_checks[]
    else
      .rulesets.target_route_neutral_main.universal_required_checks[]?
    end
  ' "$GITHUB_CONTROL_CONTRACT"
}

validate_required_check_refs() {
  local source_ref="$1"
  local expected_check ref found
  local -a refs=()
  mapfile -t refs < <(jq -r '.hosted_landing.required_check_refs[]?' "$RECEIPT_PATH")

  while IFS= read -r expected_check; do
    [[ -n "$expected_check" ]] || continue
    found=0
    for ref in "${refs[@]}"; do
      if [[ "$ref" == *"$expected_check"* && "$ref" == *"$source_ref"* ]]; then
        found=1
        break
      fi
    done
    if [[ "$found" -eq 1 ]]; then
      pass "hosted landing has exact-SHA check ref for $expected_check"
    else
      fail "hosted landing missing exact-SHA check ref for $expected_check"
    fi
  done < <(expected_route_neutral_checks)
}

validate_receipt() {
  [[ -f "$RECEIPT_PATH" ]] || { fail "receipt exists: $RECEIPT_PATH"; return; }
  jq -e '.' "$RECEIPT_PATH" >/dev/null 2>&1 && pass "receipt parses as JSON" || { fail "receipt parses as JSON"; return; }

  local route target outcome publication integration integration_method durable_kind cleanup landed_ref target_post_ref source_ref validated_ref source_branch_ref hosted_source_branch remote_branch_ref
  route="$(json_value '.selected_route')"
  target="$(json_value '.target_lifecycle_outcome')"
  outcome="$(json_value '.lifecycle_outcome')"
  publication="$(json_value '.publication_status')"
  integration="$(json_value '.integration_status')"
  integration_method="$(json_value '.integration_method')"
  durable_kind="$(json_value '.durable_history.kind')"
  cleanup="$(json_value '.cleanup_status')"
  landed_ref="$(json_value '.landed_ref')"
  target_post_ref="$(json_value '.hosted_landing.target_post_ref')"
  source_ref="$(json_value '.hosted_landing.source_ref')"
  validated_ref="$(json_value '.hosted_landing.validated_ref')"
  source_branch_ref="$(json_value '.source_branch_ref')"
  hosted_source_branch="$(json_value '.hosted_landing.source_branch')"
  remote_branch_ref="$(json_value '.remote_branch_ref')"

  [[ "$route" == "branch-no-pr" ]] && pass "receipt route is branch-no-pr" || fail "hosted no-PR landing receipt must use branch-no-pr route"
  case "$target" in
    landed|cleaned) pass "receipt target outcome is hosted landing scoped" ;;
    *) fail "hosted no-PR landing receipt target must be landed or cleaned" ;;
  esac
  case "$outcome" in
    landed|cleaned) pass "receipt outcome is hosted landing scoped" ;;
    *) fail "branch-no-pr landed/cleaned requires hosted landing evidence; outcome was '$outcome'" ;;
  esac

  if jq -e '(.durable_history.kind == "pr") or (.durable_history.pr_url? // "" | length > 0) or (.pr_url? // "" | length > 0) or (.pr_number? // "" | tostring | length > 0)' "$RECEIPT_PATH" >/dev/null; then
    fail "branch-no-pr hosted landing must not include PR metadata"
  else
    pass "branch-no-pr hosted landing has no PR metadata"
  fi

  [[ "$publication" == "hosted-main-updated" ]] && pass "publication status records hosted main update" || fail "branch-no-pr landed/cleaned requires hosted-main-updated publication status"
  [[ "$integration" == "landed" ]] && pass "integration status is landed" || fail "branch-no-pr hosted landing requires landed integration status"
  [[ "$integration_method" == "fast-forward" ]] && pass "integration method is fast-forward" || fail "branch-no-pr hosted landing requires fast-forward integration"
  case "$durable_kind" in
    commit|branch) pass "durable history can support hosted landing" ;;
    *) fail "checkpoint, patch, or PR durable history cannot claim hosted no-PR landing" ;;
  esac

  jq -e '.hosted_landing | type == "object"' "$RECEIPT_PATH" >/dev/null 2>&1 && pass "receipt has hosted_landing evidence" || fail "branch-no-pr landed/cleaned requires hosted landing evidence"
  jq -e '.landing_evaluation | type == "object"' "$RECEIPT_PATH" >/dev/null 2>&1 && pass "receipt has landing evaluation evidence" || fail "branch-no-pr landed/cleaned requires landing_evaluation"
  jq -e '.main_alignment.aligned == true' "$RECEIPT_PATH" >/dev/null 2>&1 && pass "receipt has final main alignment evidence" || fail "branch-no-pr landed/cleaned requires main_alignment.aligned true"
  json_has_nonempty '.hosted_landing.provider_ruleset_ref' && pass "hosted landing has provider ruleset ref" || fail "hosted landing requires provider_ruleset_ref"
  json_array_nonempty '.hosted_landing.required_check_refs' && pass "hosted landing has required check refs" || fail "hosted landing requires required_check_refs"
  [[ -n "$hosted_source_branch" ]] && pass "hosted landing has source branch evidence" || fail "hosted landing requires source_branch"
  [[ -n "$remote_branch_ref" ]] && pass "hosted landing has pushed remote branch ref" || fail "hosted landing requires remote_branch_ref"
  [[ -n "$source_branch_ref" && "$source_branch_ref" == "$hosted_source_branch" ]] && pass "source branch ref matches hosted source branch" || fail "source_branch_ref must equal hosted_landing.source_branch"
  [[ -n "$remote_branch_ref" && -n "$hosted_source_branch" && "$remote_branch_ref" == *"$hosted_source_branch"* ]] && pass "remote branch ref proves pushed source branch" || fail "remote_branch_ref must identify the hosted source branch"
  jq -e '.hosted_landing.fast_forward_only == true' "$RECEIPT_PATH" >/dev/null 2>&1 && pass "hosted landing is fast-forward-only" || fail "hosted landing requires fast_forward_only true"
  [[ -n "$source_ref" && "$source_ref" == "$validated_ref" ]] && pass "validated ref equals source ref" || fail "hosted landing validated_ref must equal source_ref"
  [[ -n "$landed_ref" && "$landed_ref" == "$target_post_ref" ]] && pass "target post-ref equals landed ref" || fail "hosted landing target_post_ref must equal landed_ref"
  if json_has_nonempty '.main_alignment.local_main_ref' && json_has_nonempty '.main_alignment.origin_main_ref'; then
    [[ "$(json_value '.main_alignment.local_main_ref')" == "$landed_ref" && "$(json_value '.main_alignment.origin_main_ref')" == "$landed_ref" ]] && pass "local main, origin/main, and landed ref align" || fail "main_alignment refs must equal landed_ref"
  fi
  [[ "$cleanup" == "completed" || "$cleanup" == "deferred" || "$cleanup" == "pending" ]] && pass "cleanup status is explicit" || fail "cleanup status must be explicit"
  validate_required_check_refs "$source_ref"

  if [[ "$outcome" == "cleaned" ]]; then
    case "$cleanup" in
      completed|deferred) pass "cleaned hosted landing has terminal or explicitly deferred cleanup status" ;;
      *) fail "cleaned hosted landing must not have pending cleanup status" ;;
    esac
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

  if [[ "$cleanup" == "completed" || "$cleanup" == "deferred" ]]; then
    jq -e '.source_branch_cleanup | type == "object"' "$RECEIPT_PATH" >/dev/null 2>&1 && pass "receipt has source branch cleanup disposition" || fail "completed or deferred cleanup requires source_branch_cleanup"
  fi

  if [[ "$SKIP_LIVE_REMOTE" -eq 0 ]]; then
    if git -C "$ROOT_DIR" rev-parse --verify "origin/main^{commit}" >/dev/null 2>&1; then
      local origin_main_ref
      origin_main_ref="$(git -C "$ROOT_DIR" rev-parse origin/main)"
      [[ "$origin_main_ref" == "$landed_ref" ]] && pass "origin/main equals recorded landed ref" || fail "origin/main does not equal recorded landed ref"
    elif [[ "$REQUIRE_LIVE_REMOTE" -eq 1 ]]; then
      fail "origin/main live ref is required but unavailable"
    else
      pass "origin/main live comparison skipped because origin/main is unavailable"
    fi
  else
    pass "origin/main live comparison skipped by flag"
  fi
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --receipt)
      shift
      [[ $# -gt 0 ]] || { usage >&2; exit 2; }
      RECEIPT_PATH="$1"
      ;;
    --skip-live-remote)
      SKIP_LIVE_REMOTE=1
      ;;
    --require-live-remote)
      REQUIRE_LIVE_REMOTE=1
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

echo "== Hosted No-PR Landing Validation =="
validate_static
[[ -z "$RECEIPT_PATH" ]] || validate_receipt

echo
echo "Validation summary: errors=$errors"
[[ "$errors" -eq 0 ]]

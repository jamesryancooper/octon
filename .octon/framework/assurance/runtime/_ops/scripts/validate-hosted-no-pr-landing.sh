#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
ROOT_DIR="$(cd -- "$OCTON_DIR/.." && pwd)"

POLICY="$OCTON_DIR/framework/product/contracts/default-work-unit.yml"
RECEIPT_SCHEMA="$OCTON_DIR/framework/product/contracts/change-receipt-v1.schema.json"
AUTHORIZATION_SCHEMA="$OCTON_DIR/framework/product/contracts/branch-landing-authorization-v1.schema.json"
CLOSEOUT_CHANGE="$OCTON_DIR/framework/capabilities/runtime/skills/remediation/closeout-change/SKILL.md"
WORKFLOW_STAGE="$OCTON_DIR/framework/orchestration/runtime/workflows/meta/closeout/stages/02-request-or-report.md"
WORKTREE_CONTRACT="$OCTON_DIR/framework/execution-roles/practices/standards/git-worktree-autonomy-contract.yml"
REQUIRED_CHECKS_SCRIPT="$OCTON_DIR/framework/execution-roles/_ops/scripts/git/git-required-checks-at-ref.sh"
HOSTED_PREFLIGHT_SCRIPT="$OCTON_DIR/framework/execution-roles/_ops/scripts/git/git-branch-hosted-preflight.sh"
HOSTED_AUTH_SCRIPT="$OCTON_DIR/framework/execution-roles/_ops/scripts/git/git-branch-authorize-hosted-no-pr.sh"
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

json_bool_true() {
  local expr="$1"
  jq -e "$expr == true" "$RECEIPT_PATH" >/dev/null 2>&1
}

resolve_ref_path() {
  local ref="$1"
  case "$ref" in
    "")
      return 1
      ;;
    /*)
      printf '%s\n' "$ref"
      ;;
    evidence://*)
      printf '%s/.octon/state/evidence/%s\n' "$ROOT_DIR" "${ref#evidence://}"
      ;;
    *)
      printf '%s/%s\n' "$ROOT_DIR" "$ref"
      ;;
  esac
}

validate_static() {
  for file in "$POLICY" "$RECEIPT_SCHEMA" "$AUTHORIZATION_SCHEMA" "$CLOSEOUT_CHANGE" "$WORKFLOW_STAGE" "$WORKTREE_CONTRACT" "$REQUIRED_CHECKS_SCRIPT" "$HOSTED_PREFLIGHT_SCRIPT" "$HOSTED_AUTH_SCRIPT" "$HOSTED_LAND_SCRIPT" "$GITHUB_CONTROL_CONTRACT"; do
    require_file "$file"
  done

  require_yq "$POLICY" '.route_lifecycle_outcomes."branch-no-pr".landed_requires[]? | select(. == "provider_ruleset_allows_route_neutral_fast_forward_update")' "policy requires route-neutral provider rules for hosted no-PR landing" "policy must require route-neutral provider rules for hosted no-PR landing"
  require_yq "$POLICY" '.route_lifecycle_outcomes."branch-no-pr".landed_requires[]? | select(. == "governed_landing_authorization_receipt")' "policy requires governed landing authorization for hosted no-PR landing" "policy must require governed landing authorization for hosted no-PR landing"
  require_yq "$POLICY" '.route_lifecycle_outcomes."branch-no-pr".landed_requires[]? | select(. == "landing_authorization_matches_source_ref_and_origin_main_pre_ref")' "policy requires current authorization source/target refs" "policy must require authorization to match source and target pre-ref"
  require_yq "$POLICY" '.route_lifecycle_outcomes."branch-no-pr".landed_requires[]? | select(. == "source_branch_pushed_to_remote")' "policy requires pushed source branch for hosted no-PR landing" "policy must require pushed source branch for hosted no-PR landing"
  require_yq "$POLICY" '.route_lifecycle_outcomes."branch-no-pr".landed_requires[]? | select(. == "source_branch_changes_integrated_into_origin_main")' "policy requires source branch integration for hosted no-PR landing" "policy must require source branch integration for hosted no-PR landing"
  require_yq "$POLICY" '.route_lifecycle_outcomes."branch-no-pr".landed_requires[]? | select(. == "origin_main_equals_landed_ref_after_push")' "policy requires origin/main equality after hosted no-PR landing" "policy must require origin/main equality after hosted no-PR landing"
  require_yq "$POLICY" '.route_lifecycle_outcomes."branch-no-pr".landed_requires[]? | select(. == "post_landing_fetch_origin_completed")' "policy requires post-landing fetch for hosted no-PR landing" "policy must require post-landing fetch for hosted no-PR landing"
  require_yq "$POLICY" '.route_lifecycle_outcomes."branch-no-pr".landed_requires[]? | select(. == "local_main_contains_landed_ref_after_sync")' "policy requires synced local main containment for hosted no-PR landing" "policy must require synced local main containment for hosted no-PR landing"
  require_yq "$POLICY" '.fail_closed_conditions[]? | select(. == "hosted_no_pr_landing_without_valid_governed_authorization")' "policy fails closed without governed landing authorization" "policy must fail closed without governed landing authorization"
  require_yq "$POLICY" '.fail_closed_conditions[]? | select(. == "hosted_no_pr_landing_with_stale_or_denied_authorization")' "policy fails closed on stale or denied landing authorization" "policy must fail closed on stale or denied landing authorization"
  require_yq "$POLICY" '.hosted_provider_ruleset.branch_no_pr_hosted_landing.requires_governed_landing_authorization == true' "policy requires authorization before hosted mutation" "policy must require authorization before hosted mutation"
  require_jq "$AUTHORIZATION_SCHEMA" '.properties.schema_version.const == "branch-landing-authorization-v1"' "authorization schema version valid" "authorization schema must define branch-landing-authorization-v1"
  require_jq "$AUTHORIZATION_SCHEMA" '.properties.no_pr_required.const == true' "authorization schema requires no-PR proof" "authorization schema must require no_pr_required true"
  require_jq "$AUTHORIZATION_SCHEMA" '.properties.host_controls_not_bypassed.const == true' "authorization schema preserves host controls" "authorization schema must preserve host controls"
  require_jq "$AUTHORIZATION_SCHEMA" '.properties.allow_empty_check_set.type == "boolean"' "authorization schema models explicit empty-check-set policy" "authorization schema must model allow_empty_check_set"
  require_jq "$AUTHORIZATION_SCHEMA" '.properties.empty_check_set_rationale.type == "string"' "authorization schema models empty-check-set rationale" "authorization schema must model empty_check_set_rationale"
  require_jq "$AUTHORIZATION_SCHEMA" '.allOf[]? | select(.then.required[]? == "empty_check_set_rationale")' "authorization schema requires rationale when empty check set is allowed" "authorization schema must require empty_check_set_rationale when allow_empty_check_set is true"
  require_jq "$RECEIPT_SCHEMA" '.properties.landing_authorization_ref' "receipt schema models landing authorization ref" "receipt schema must model landing_authorization_ref"
  require_jq "$RECEIPT_SCHEMA" '.allOf[]? | select(.then.required[]? == "landing_authorization_ref")' "receipt schema requires landing authorization for branch-no-pr landing" "receipt schema must require landing_authorization_ref for branch-no-pr landing"
  require_jq "$RECEIPT_SCHEMA" '.properties.hosted_landing.required[] | select(. == "source_ref")' "receipt schema requires hosted source ref" "receipt schema must require hosted source ref"
  require_jq "$RECEIPT_SCHEMA" '.properties.hosted_landing.required[] | select(. == "target_post_ref")' "receipt schema requires hosted target post-ref" "receipt schema must require hosted target post-ref"
  require_jq "$RECEIPT_SCHEMA" '.properties.hosted_landing.required[] | select(. == "required_check_refs")' "receipt schema requires hosted required check refs" "receipt schema must require hosted required check refs"
  require_jq "$RECEIPT_SCHEMA" '.properties.hosted_landing_execution.properties.signal.const == "--execute-authorized-landing"' "receipt schema models hosted landing execution signal" "receipt schema must model --execute-authorized-landing"
  require_jq "$RECEIPT_SCHEMA" '.properties.hosted_landing_execution.properties.authorization_consumed.const == true' "receipt schema models authorization consumption" "receipt schema must model authorization consumption"
  require_jq "$RECEIPT_SCHEMA" '.properties.hosted_landing_execution.properties.execution_lane_status.enum[] | select(. == "authorized")' "receipt schema models authorized execution lane status" "receipt schema must model authorized execution lane status"
  require_jq "$RECEIPT_SCHEMA" '.properties.hosted_landing_execution.properties.execution_lane_status.enum[] | select(. == "denied")' "receipt schema models denied execution lane status" "receipt schema must model denied execution lane status"
  require_jq "$RECEIPT_SCHEMA" '.allOf[]? | select(.then.required[]? == "hosted_landing_execution")' "receipt schema requires execution signal for hosted branch-no-pr landing" "receipt schema must require hosted_landing_execution for hosted branch-no-pr landing"
  require_jq "$RECEIPT_SCHEMA" '.properties.source_branch_integration.required[] | select(. == "evidence_refs")' "receipt schema requires source branch integration evidence refs" "receipt schema must require source branch integration evidence refs"
  require_jq "$RECEIPT_SCHEMA" '.properties.main_alignment.properties.origin_fetch_evidence_ref' "receipt schema models post-landing fetch evidence" "receipt schema must model post-landing fetch evidence"
  require_jq "$RECEIPT_SCHEMA" '.properties.main_alignment.properties.local_main_sync_evidence_ref' "receipt schema models local main sync evidence" "receipt schema must model local main sync evidence"
  require_literal "$CLOSEOUT_CHANGE" "hosted no-PR landing preflight" "closeout skill requires hosted no-PR preflight" "closeout skill must require hosted no-PR preflight"
  require_literal "$CLOSEOUT_CHANGE" "branch-landing-authorization-v1" "closeout skill requires governed landing authorization" "closeout skill must require governed landing authorization"
  require_literal "$CLOSEOUT_CHANGE" "--execute-authorized-landing" "closeout skill documents authorization-consuming landing signal" "closeout skill must document --execute-authorized-landing"
  require_literal "$CLOSEOUT_CHANGE" "receipt-consumption signal" "closeout skill classifies execution signal as receipt consumption" "closeout skill must classify execution signal as receipt consumption"
  require_literal "$CLOSEOUT_CHANGE" "execution-lane evidence" "closeout skill requires execution-lane evidence" "closeout skill must require execution-lane evidence"
  require_literal "$WORKFLOW_STAGE" "exact source SHA required checks" "workflow requires exact source SHA required checks" "workflow must require exact source SHA required checks"
  require_yq "$WORKTREE_CONTRACT" '.helpers.git_branch_authorize_hosted_no_pr.posture == "governed hosted no-PR landing authorization helper"' "worktree contract registers hosted no-PR authorization helper" "worktree contract must register hosted no-PR authorization helper"
  require_yq "$WORKTREE_CONTRACT" '.helpers.git_branch_land_hosted_no_pr.posture == "fast-forward-only hosted no-PR landing helper requiring governed authorization"' "worktree contract registers hosted no-PR landing helper" "worktree contract must register hosted no-PR landing helper"
  require_literal "$REQUIRED_CHECKS_SCRIPT" "exact commit SHA" "required-check helper validates exact commit SHA" "required-check helper must validate exact commit SHA"
  require_literal "$HOSTED_PREFLIGHT_SCRIPT" "Provider ruleset requires PR; hosted branch-no-pr landing unavailable." "preflight fails closed when provider requires PR" "preflight must fail closed when provider requires PR"
  require_literal "$HOSTED_AUTH_SCRIPT" "branch-landing-authorization-v1" "authorization helper emits governed receipt" "authorization helper must emit governed receipt"
  require_literal "$HOSTED_AUTH_SCRIPT" "git-branch-hosted-preflight.sh" "authorization helper runs hosted preflight" "authorization helper must run hosted preflight"
  require_literal "$HOSTED_AUTH_SCRIPT" "does not bypass platform, sandbox, or host safety controls" "authorization helper records host safety boundary" "authorization helper must record host safety boundary"
  require_literal "$HOSTED_AUTH_SCRIPT" "empty-check-set-explicitly-allowed@" "authorization helper records explicit empty-check-set sentinel" "authorization helper must record explicit empty-check-set sentinel"
  require_literal "$HOSTED_AUTH_SCRIPT" "--empty-check-set-rationale" "authorization helper requires retained empty-check-set rationale" "authorization helper must require retained empty-check-set rationale"
  require_literal "$HOSTED_AUTH_SCRIPT" "Governed rerun path" "authorization helper emits governed rerun guidance" "authorization helper must emit governed rerun guidance for sandbox/provider boundaries"
  require_literal "$HOSTED_LAND_SCRIPT" "requires --authorization" "hosted land helper requires authorization before mutation" "hosted land helper must require authorization before mutation"
  require_literal "$HOSTED_LAND_SCRIPT" "Landing authorization target pre-ref is stale" "hosted land helper blocks stale authorization" "hosted land helper must block stale authorization"
  require_literal "$HOSTED_LAND_SCRIPT" "empty check set requires retained rationale" "hosted land helper validates empty-check-set rationale" "hosted land helper must validate empty-check-set rationale"
  require_literal "$HOSTED_LAND_SCRIPT" "Governed rerun path" "hosted land helper emits governed rerun guidance" "hosted land helper must emit governed rerun guidance for sandbox/provider boundaries"
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

empty_check_set_authorized() {
  local source_ref="$1"
  local auth_ref auth_path expected_ref

  auth_ref="$(json_value '.landing_authorization_ref')"
  [[ -n "$auth_ref" ]] || return 1
  auth_path="$(resolve_ref_path "$auth_ref")" || return 1
  [[ -f "$auth_path" ]] || return 1
  expected_ref="empty-check-set-explicitly-allowed@${source_ref}"

  jq -e --arg expected "$expected_ref" --slurpfile receipt "$RECEIPT_PATH" '
    .allow_empty_check_set == true
    and (.required_check_refs | type == "array" and length == 1 and .[0] == $expected)
    and (.empty_check_set_rationale | type == "string" and length > 0)
    and ($receipt[0].hosted_landing.required_check_refs | type == "array" and length == 1 and .[0] == $expected)
    and ((.required_check_refs | sort) == ($receipt[0].hosted_landing.required_check_refs | sort))
  ' "$auth_path" >/dev/null 2>&1
}

validate_required_check_refs() {
  local source_ref="$1"
  local expected_check ref found
  local -a refs=()
  mapfile -t refs < <(jq -r '.hosted_landing.required_check_refs[]?' "$RECEIPT_PATH")

  if empty_check_set_authorized "$source_ref"; then
    pass "hosted landing uses explicitly authorized empty check set bound to source SHA"
    return
  fi

  for ref in "${refs[@]}"; do
    if [[ "$ref" == empty-check-set-explicitly-allowed@* ]]; then
      fail "empty check set requires matching landing authorization allow_empty_check_set"
      return
    fi
  done

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

validate_landing_authorization_ref() {
  local auth_ref auth_path source_ref target_pre_ref source_branch target_branch remote provider_ruleset_ref
  auth_ref="$(json_value '.landing_authorization_ref')"
  json_has_nonempty '.landing_authorization_ref' && pass "receipt has landing authorization ref" || { fail "hosted landing requires landing_authorization_ref"; return; }
  auth_path="$(resolve_ref_path "$auth_ref")" || { fail "landing_authorization_ref cannot be resolved"; return; }
  [[ -f "$auth_path" ]] || { fail "landing authorization receipt resolves to an existing file"; return; }
  jq -e '.' "$auth_path" >/dev/null 2>&1 && pass "landing authorization parses as JSON" || { fail "landing authorization parses as JSON"; return; }

  source_ref="$(json_value '.hosted_landing.source_ref')"
  target_pre_ref="$(json_value '.hosted_landing.target_pre_ref')"
  source_branch="$(json_value '.source_branch_ref')"
  target_branch="$(json_value '.hosted_landing.target_branch')"
  remote="$(json_value '.hosted_landing.remote')"
  provider_ruleset_ref="$(json_value '.hosted_landing.provider_ruleset_ref')"

  jq -e '.schema_version == "branch-landing-authorization-v1"' "$auth_path" >/dev/null 2>&1 && pass "landing authorization schema version valid" || fail "landing authorization schema_version must be branch-landing-authorization-v1"
  jq -e '.authorization_result == "approved"' "$auth_path" >/dev/null 2>&1 && pass "landing authorization is approved" || fail "landing authorization must be approved"
  jq -e '.selected_route == "branch-no-pr"' "$auth_path" >/dev/null 2>&1 && pass "landing authorization route is branch-no-pr" || fail "landing authorization route must be branch-no-pr"
  jq -e '.target_lifecycle_outcome == "landed" or .target_lifecycle_outcome == "cleaned"' "$auth_path" >/dev/null 2>&1 && pass "landing authorization target is landing scoped" || fail "landing authorization target must be landed or cleaned"
  [[ "$(jq -r '.remote // ""' "$auth_path")" == "$remote" ]] && pass "landing authorization remote matches hosted landing" || fail "landing authorization remote must match hosted landing"
  [[ "$(jq -r '.target_branch // ""' "$auth_path")" == "$target_branch" ]] && pass "landing authorization target branch matches hosted landing" || fail "landing authorization target branch must match hosted landing"
  [[ "$(jq -r '.source_branch // ""' "$auth_path")" == "$source_branch" ]] && pass "landing authorization source branch matches receipt" || fail "landing authorization source branch must match receipt"
  [[ "$(jq -r '.source_ref // ""' "$auth_path")" == "$source_ref" ]] && pass "landing authorization source ref matches hosted landing" || fail "landing authorization source ref must match hosted landing"
  [[ "$(jq -r '.remote_source_ref // ""' "$auth_path")" == "$source_ref" ]] && pass "landing authorization remote source ref matches source" || fail "landing authorization remote source ref must match source"
  [[ "$(jq -r '.target_pre_ref // ""' "$auth_path")" == "$target_pre_ref" ]] && pass "landing authorization target pre-ref matches hosted landing" || fail "landing authorization target pre-ref must match hosted landing"
  [[ "$(jq -r '.provider_ruleset_ref // ""' "$auth_path")" == "$provider_ruleset_ref" ]] && pass "landing authorization provider ruleset matches hosted landing" || fail "landing authorization provider ruleset must match hosted landing"
  jq -e --slurpfile receipt "$RECEIPT_PATH" '(.required_check_refs | sort) == ($receipt[0].hosted_landing.required_check_refs | sort)' "$auth_path" >/dev/null 2>&1 && pass "landing authorization check refs match hosted landing" || fail "landing authorization check refs must match hosted landing required_check_refs"
  jq -e '.no_pr_required == true' "$auth_path" >/dev/null 2>&1 && pass "landing authorization proves no PR required" || fail "landing authorization must prove no PR required"
  jq -e '.preflight_status == "passed"' "$auth_path" >/dev/null 2>&1 && pass "landing authorization records passed preflight" || fail "landing authorization must record passed preflight"
  jq -e '.required_check_refs | type == "array" and length > 0' "$auth_path" >/dev/null 2>&1 && pass "landing authorization records check evidence" || fail "landing authorization requires check evidence"
  if jq -e '.allow_empty_check_set == true' "$auth_path" >/dev/null 2>&1; then
    jq -e '.empty_check_set_rationale | type == "string" and length > 0' "$auth_path" >/dev/null 2>&1 && pass "landing authorization records empty-check-set rationale" || fail "landing authorization empty check set requires retained rationale"
  fi
  jq -e '.rollback_handle | type == "string" and length > 0' "$auth_path" >/dev/null 2>&1 && pass "landing authorization records rollback handle" || fail "landing authorization requires rollback handle"
  jq -e '.host_controls_not_bypassed == true' "$auth_path" >/dev/null 2>&1 && pass "landing authorization preserves host controls" || fail "landing authorization must preserve host controls"
}

execution_ref_is_forbidden_authority() {
  local value="$1"
  grep -Eiq '(^|[^a-z])(chat|host UI|host state|dashboard|generated projection|generated output|parent summary|proposal file|proposal-local|tool availability|model memory|--confirm)([^a-z]|$)' <<<"$value"
}

validate_hosted_landing_execution() {
  local expected_status="$1"
  local auth_ref execution_auth_ref source_ref target_pre_ref target_post_ref signal lane_status lane_ref lane_kind rollback_ref final_sync_ref push_refspec

  if jq -e '.hosted_landing_execution | type == "object"' "$RECEIPT_PATH" >/dev/null 2>&1; then
    pass "hosted landing execution signal is recorded"
  else
    fail "hosted branch-no-pr landing requires hosted_landing_execution"
    return
  fi

  signal="$(json_value '.hosted_landing_execution.signal')"
  [[ "$signal" == "--execute-authorized-landing" ]] && pass "hosted landing execution signal consumes authorization" || fail "hosted_landing_execution.signal must be --execute-authorized-landing"
  jq -e '.hosted_landing_execution.authorization_consumed == true' "$RECEIPT_PATH" >/dev/null 2>&1 && pass "hosted landing execution consumes authorization receipt" || fail "hosted_landing_execution.authorization_consumed must be true"

  auth_ref="$(json_value '.landing_authorization_ref')"
  execution_auth_ref="$(json_value '.hosted_landing_execution.landing_authorization_ref')"
  [[ -n "$execution_auth_ref" && "$execution_auth_ref" == "$auth_ref" ]] && pass "hosted landing execution names consumed authorization" || fail "hosted_landing_execution.landing_authorization_ref must match landing_authorization_ref"

  lane_kind="$(json_value '.hosted_landing_execution.execution_lane_kind')"
  case "$lane_kind" in
    pre-approved-command-prefix|sandbox-tool-authority-receipt|runtime-denial-receipt)
      pass "hosted landing execution lane kind is supported"
      ;;
    *)
      fail "hosted_landing_execution.execution_lane_kind is unsupported"
      ;;
  esac

  lane_status="$(json_value '.hosted_landing_execution.execution_lane_status')"
  [[ "$lane_status" == "$expected_status" ]] && pass "hosted landing execution lane status is $expected_status" || fail "hosted_landing_execution.execution_lane_status must be $expected_status"
  lane_ref="$(json_value '.hosted_landing_execution.execution_lane_evidence_ref')"
  if [[ -n "$lane_ref" ]]; then
    if execution_ref_is_forbidden_authority "$lane_ref"; then
      fail "hosted landing execution lane evidence must not rely on --confirm, chat, host UI, generated, proposal, parent summary, model, or tool state"
    else
      pass "hosted landing execution lane evidence preserves authority boundaries"
    fi
  else
    fail "hosted_landing_execution.execution_lane_evidence_ref is required"
  fi

  source_ref="$(json_value '.hosted_landing.source_ref')"
  target_pre_ref="$(json_value '.hosted_landing.target_pre_ref')"
  target_post_ref="$(json_value '.hosted_landing.target_post_ref')"
  [[ "$(json_value '.hosted_landing_execution.source_ref')" == "$source_ref" ]] && pass "hosted landing execution source ref matches hosted landing" || fail "hosted_landing_execution.source_ref must match hosted_landing.source_ref"
  [[ "$(json_value '.hosted_landing_execution.target_pre_ref')" == "$target_pre_ref" ]] && pass "hosted landing execution target pre-ref matches hosted landing" || fail "hosted_landing_execution.target_pre_ref must match hosted_landing.target_pre_ref"

  rollback_ref="$(json_value '.hosted_landing_execution.rollback_handle_ref')"
  [[ -n "$rollback_ref" ]] && pass "hosted landing execution records rollback handle" || fail "hosted_landing_execution.rollback_handle_ref is required"
  jq -e '.hosted_landing_execution.host_controls_not_bypassed == true' "$RECEIPT_PATH" >/dev/null 2>&1 && pass "hosted landing execution preserves host controls" || fail "hosted_landing_execution.host_controls_not_bypassed must be true"

  if [[ "$expected_status" == "authorized" ]]; then
    [[ "$(json_value '.hosted_landing_execution.target_post_ref')" == "$target_post_ref" ]] && pass "hosted landing execution target post-ref matches hosted landing" || fail "hosted_landing_execution.target_post_ref must match hosted_landing.target_post_ref"
    final_sync_ref="$(json_value '.hosted_landing_execution.final_sync_evidence_ref')"
    [[ -n "$final_sync_ref" ]] && pass "hosted landing execution records final sync evidence" || fail "hosted_landing_execution.final_sync_evidence_ref is required for successful hosted landing"
  fi

  push_refspec="$(json_value '.hosted_landing.push_refspec')"
  if [[ "$push_refspec" == +* || "$push_refspec" == *"--force"* || "$push_refspec" == *"force-push"* ]]; then
    fail "hosted landing push refspec must not require force-push"
  else
    pass "hosted landing push refspec is non-force"
  fi
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
  validate_landing_authorization_ref
  validate_hosted_landing_execution "authorized"
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
  [[ -n "$source_ref" && "$source_ref" == "$landed_ref" ]] && pass "hosted no-PR source ref is the landed ref" || fail "hosted no-PR source_ref must equal landed_ref"
  if json_has_nonempty '.main_alignment.local_main_ref' && json_has_nonempty '.main_alignment.origin_main_ref'; then
    [[ "$(json_value '.main_alignment.local_main_ref')" == "$landed_ref" && "$(json_value '.main_alignment.origin_main_ref')" == "$landed_ref" ]] && pass "local main, origin/main, and landed ref align" || fail "main_alignment refs must equal landed_ref"
  else
    fail "main_alignment requires local_main_ref and origin_main_ref"
  fi
  json_has_nonempty '.main_alignment.origin_fetch_evidence_ref' && pass "hosted landing records post-landing origin fetch evidence" || fail "hosted landing requires main_alignment.origin_fetch_evidence_ref"
  json_has_nonempty '.main_alignment.local_main_sync_evidence_ref' && pass "hosted landing records local main sync evidence" || fail "hosted landing requires main_alignment.local_main_sync_evidence_ref"
  json_bool_true '.main_alignment.origin_main_contains_landed_ref' && pass "origin/main containment of landed_ref is proven" || fail "hosted landing requires origin_main_contains_landed_ref true"
  json_bool_true '.main_alignment.local_main_contains_landed_ref' && pass "local main containment of landed_ref is proven" || fail "hosted landing requires local_main_contains_landed_ref true"
  jq -e '.source_branch_integration | type == "object"' "$RECEIPT_PATH" >/dev/null 2>&1 && pass "hosted landing records source branch integration evidence" || fail "hosted landing requires source_branch_integration"
  if jq -e '.source_branch_integration | type == "object"' "$RECEIPT_PATH" >/dev/null 2>&1; then
    json_bool_true '.source_branch_integration.integrated' && pass "source branch integration is affirmed" || fail "source_branch_integration.integrated must be true"
    json_array_nonempty '.source_branch_integration.evidence_refs' && pass "source branch integration has evidence refs" || fail "source_branch_integration requires evidence_refs"
    [[ "$(json_value '.source_branch_integration.source_branch_ref')" == "$source_branch_ref" ]] && pass "source branch integration names source branch" || fail "source_branch_integration.source_branch_ref must equal source_branch_ref"
    [[ "$(json_value '.source_branch_integration.source_ref')" == "$source_ref" ]] && pass "source branch integration names exact source ref" || fail "source_branch_integration.source_ref must equal hosted_landing.source_ref"
    [[ "$(json_value '.source_branch_integration.landed_ref')" == "$landed_ref" ]] && pass "source branch integration landed ref matches receipt" || fail "source_branch_integration.landed_ref must equal landed_ref"
    [[ "$(json_value '.source_branch_integration.origin_main_ref')" == "$(json_value '.main_alignment.origin_main_ref')" ]] && pass "source branch integration origin/main ref matches final alignment" || fail "source_branch_integration.origin_main_ref must equal main_alignment.origin_main_ref"
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

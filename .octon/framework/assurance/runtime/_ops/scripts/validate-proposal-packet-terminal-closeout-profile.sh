#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
FRAMEWORK_DIR="$(cd -- "$SCRIPT_DIR/../../../../" && pwd)"
SCHEMA_PATH="$FRAMEWORK_DIR/product/contracts/proposal-packet-terminal-closeout-profile-v1.schema.json"
PROFILE_PATH=""
errors=0

usage() {
  cat <<'USAGE'
usage:
  validate-proposal-packet-terminal-closeout-profile.sh [--profile <path>]
USAGE
}

pass() { echo "[OK] $1"; }
fail() {
  echo "[ERROR] $1"
  errors=$((errors + 1))
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --profile)
      shift
      [[ $# -gt 0 ]] || { usage >&2; exit 2; }
      PROFILE_PATH="$1"
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

need_tool() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "[ERROR] $1 is required" >&2
    exit 1
  fi
}

scalar() {
  yq -r "$1" "$2" 2>/dev/null || true
}

require_scalar() {
  local path="$1" label="$2" value
  value="$(scalar "$path" "$PROFILE_PATH")"
  if [[ -n "$value" && "$value" != "null" ]]; then
    pass "$label declared"
  else
    fail "$label missing"
  fi
}

require_bool_true() {
  local path="$1" label="$2" value
  value="$(scalar "$path" "$PROFILE_PATH")"
  [[ "$value" == "true" ]] && pass "$label true" || fail "$label must be true"
}

require_bool_false() {
  local path="$1" label="$2" value
  value="$(scalar "$path" "$PROFILE_PATH")"
  [[ "$value" == "false" ]] && pass "$label false" || fail "$label must be false"
}

require_array_nonempty() {
  local path="$1" label="$2" count
  count="$(yq -r "($path // []) | length" "$PROFILE_PATH" 2>/dev/null || echo 0)"
  [[ "$count" -gt 0 ]] && pass "$label non-empty" || fail "$label must be non-empty"
}

need_tool jq
need_tool yq

echo "== Proposal Packet Terminal Closeout Profile Validation =="

if [[ -f "$SCHEMA_PATH" ]]; then
  pass "profile schema exists"
else
  fail "profile schema missing: $SCHEMA_PATH"
fi

if jq -e '.' "$SCHEMA_PATH" >/dev/null 2>&1; then
  pass "profile schema JSON parses"
else
  fail "profile schema JSON does not parse"
fi

for token in \
  '"proposal-packet-terminal-closeout-profile-v1"' \
  '"target_outcome"' \
  '"archive-ready"' \
  '"blocked"' \
  '"RP00_CONTAINMENT_PUBLICATION_DISABLED"' \
  '"forbidden_authority_requests"' \
  '"validator_family_map"'; do
  grep -Fq "$token" "$SCHEMA_PATH" && pass "schema token present: $token" || fail "schema token missing: $token"
done

if [[ -n "$PROFILE_PATH" ]]; then
  if [[ -f "$PROFILE_PATH" ]]; then
    pass "profile file exists: $PROFILE_PATH"
  else
    fail "profile file missing: $PROFILE_PATH"
    echo "Validation summary: errors=$errors"
    exit 1
  fi

  if yq -e '.' "$PROFILE_PATH" >/dev/null 2>&1; then
    pass "profile YAML parses"
  else
    fail "profile YAML does not parse"
  fi

  [[ "$(scalar '.schema_version' "$PROFILE_PATH")" == "proposal-packet-terminal-closeout-profile-v1" ]] \
    && pass "profile schema_version correct" \
    || fail "profile schema_version must be proposal-packet-terminal-closeout-profile-v1"

  require_scalar '.profile_id' "profile_id"
  require_scalar '.created_at' "created_at"
  require_scalar '.packet.proposal_id' "packet.proposal_id"
  require_scalar '.packet.path' "packet.path"
  [[ "$(scalar '.packet.expected_status' "$PROFILE_PATH")" == "implemented" ]] \
    && pass "packet expected_status implemented" \
    || fail "packet expected_status must be implemented"

  case "$(scalar '.target_outcome' "$PROFILE_PATH")" in
    archive-ready|blocked)
      pass "target_outcome allowed"
      ;;
    *)
      fail "target_outcome must be archive-ready or blocked"
      ;;
  esac

  [[ "$(scalar '.containment_policy.reason_code' "$PROFILE_PATH")" == "RP00_CONTAINMENT_PUBLICATION_DISABLED" ]] \
    && pass "containment reason code correct" \
    || fail "containment reason code must be RP00_CONTAINMENT_PUBLICATION_DISABLED"
  require_bool_false '.containment_policy.publication_effects_enabled' "publication effects enabled"
  require_bool_true '.containment_policy.exact_work_preserved' "exact work preserved"

  case "$(scalar '.route_preference' "$PROFILE_PATH")" in
    stage-only-escalate|none-closeout-only)
      pass "route preference is contained"
      ;;
    *)
      fail "RP00_CONTAINMENT_PUBLICATION_DISABLED: hosted and direct publication routes are disabled"
      ;;
  esac

  require_bool_false '.pr_policy.allow_pr_creation' "PR creation allowed"
  require_bool_false '.pr_policy.allow_branch_no_pr' "branch-no-PR allowed"

  require_array_nonempty '.expected_retained_evidence' "expected_retained_evidence"
  require_array_nonempty '.required_validators_by_target_family' "required_validators_by_target_family"
  require_array_nonempty '.publication_freshness_policy.validator_family_map' "publication_freshness_policy.validator_family_map"

  require_bool_true '.publication_freshness_policy.canonical_publisher_only' "canonical publisher only"
  require_bool_true '.publication_freshness_policy.direct_generated_edits_forbidden' "direct generated edits forbidden"
  require_bool_true '.hygiene_policy.repo_hygiene_delegation_only' "repo hygiene delegation only"
  require_bool_true '.hygiene_policy.worktree_foreign_residue_blocks_archive_ready' "foreign worktree residue blocks archive-ready"
  require_bool_false '.hygiene_policy.cleanup_authorization_required' "cleanup authorization required"
  require_bool_false '.git_github_hosted_check_policy.delegate_to_closeout_routes' "Git/GitHub delegation"
  require_bool_true '.git_github_hosted_check_policy.exact_sha_required_when_hosted' "exact SHA required when hosted"
  require_bool_false '.git_github_hosted_check_policy.landing_authorization_required' "landing authorization required"
  require_bool_false '.git_github_hosted_check_policy.branch_cleanup_authorization_required' "branch cleanup authorization required"
  require_bool_true '.blocker_reporting.required' "blocker reporting required"
  require_array_nonempty '.blocker_reporting.allowed_blocker_classes' "allowed blocker classes"
  require_array_nonempty '.blocker_reporting.allowed_next_routes' "allowed next routes"

  for key in \
    archive_relocation \
    proposal_status_mutation \
    git_mutation \
    residue_deletion \
    generated_direct_publication \
    host_state_authority \
    chat_or_model_memory_authority \
    tool_authority; do
    require_bool_false ".forbidden_authority_requests.$key" "forbidden_authority_requests.$key"
  done
fi

echo "Validation summary: errors=$errors"
[[ "$errors" -eq 0 ]]

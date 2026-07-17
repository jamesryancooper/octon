#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
FRAMEWORK_DIR="$(cd -- "$SCRIPT_DIR/../../../../" && pwd)"
SCHEMA_PATH="$FRAMEWORK_DIR/product/contracts/proposal-packet-delivery-profile-v1.schema.json"
PROFILE_PATH=""
errors=0

usage() {
  cat <<'USAGE'
usage:
  validate-proposal-packet-delivery-profile.sh [--profile <path>]
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
  yq -r "$1" "$PROFILE_PATH" 2>/dev/null || true
}

require_scalar() {
  local path="$1" label="$2" value
  value="$(scalar "$path")"
  if [[ -n "$value" && "$value" != "null" ]]; then
    pass "$label declared"
  else
    fail "$label missing"
  fi
}

require_bool_true() {
  local path="$1" label="$2" value
  value="$(scalar "$path")"
  [[ "$value" == "true" ]] && pass "$label true" || fail "$label must be true"
}

require_bool_false() {
  local path="$1" label="$2" value
  value="$(scalar "$path")"
  [[ "$value" == "false" ]] && pass "$label false" || fail "$label must be false"
}

require_array_nonempty() {
  local path="$1" label="$2" count
  count="$(yq -r "($path // []) | length" "$PROFILE_PATH" 2>/dev/null || echo 0)"
  [[ "$count" -gt 0 ]] && pass "$label non-empty" || fail "$label must be non-empty"
}

require_value() {
  local path="$1" expected="$2" label="$3" value
  value="$(scalar "$path")"
  [[ "$value" == "$expected" ]] && pass "$label is $expected" || fail "$label must be $expected"
}

need_tool jq
need_tool yq

echo "== Proposal Packet Delivery Profile Validation =="

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
  '"proposal-packet-delivery-profile-v1"' \
  '"target_outcome"' \
  '"RP00_CONTAINMENT_PUBLICATION_DISABLED"' \
  '"pr_policy"' \
  '"stash_policy"' \
  '"packet_execution"' \
  '"promotion_requirements"' \
  '"closeout_requirements"' \
  '"non_authority_boundaries"' \
  '"final_sync_requirements"'; do
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

  [[ "$(scalar '.schema_version')" == "proposal-packet-delivery-profile-v1" ]] \
    && pass "profile schema_version correct" \
    || fail "profile schema_version must be proposal-packet-delivery-profile-v1"

  require_scalar '.profile_id' "profile_id"
  require_scalar '.created_at' "created_at"
  require_scalar '.target_packet_path' "target_packet_path"
  require_scalar '.target_outcome' "target_outcome"
  case "$(scalar '.target_outcome')" in
    implemented|archive-ready)
      pass "target_outcome allowed"
      ;;
    *)
      fail "RP00_CONTAINMENT_PUBLICATION_DISABLED: target_outcome must be implemented or archive-ready"
      ;;
  esac

  require_value '.containment_policy.reason_code' 'RP00_CONTAINMENT_PUBLICATION_DISABLED' "containment reason code"
  require_bool_false '.containment_policy.publication_effects_enabled' "publication effects enabled"
  require_bool_true '.containment_policy.exact_work_preserved' "exact work preserved"

  [[ "$(scalar '.target_packet_path')" == .octon/inputs/exploratory/proposals/* ]] \
    && pass "target_packet_path under proposal inputs" \
    || fail "target_packet_path must be under .octon/inputs/exploratory/proposals/"

  require_value '.route_preference.work_unit_route' 'stage-only' "work unit route"
  require_value '.route_preference.landing_route' 'not-applicable' "landing route"
  require_bool_false '.route_preference.pr_creation_allowed' "route PR creation allowed"

  require_value '.pr_policy.mode' 'forbid-pr' "PR policy mode"
  require_bool_false '.pr_policy.allow_pr_creation' "PR creation"
  require_bool_false '.pr_policy.fallback_to_pr' "PR fallback"

  require_value '.stash_policy.mode' 'forbidden' "stash policy mode"
  require_bool_true '.stash_policy.preserve_unrelated_work' "preserve unrelated work"

  require_bool_true '.packet_execution.replan_after_material_changes' "replan after material changes"
  require_bool_true '.packet_execution.target_owned_receipts_required' "target-owned receipts required"
  require_bool_false '.packet_execution.aggregate_receipt_replaces_target_receipts' "aggregate receipt replaces target receipts"
  require_bool_false '.packet_execution.self_authorization_allowed' "self authorization allowed"

  require_array_nonempty '.required_proposal_validators' "required_proposal_validators"
  require_array_nonempty '.required_implementation_validators' "required_implementation_validators"

  require_bool_true '.publication_checks.owning_publishers_only' "owning publishers only"
  require_bool_true '.publication_checks.generated_outputs_are_non_authority' "generated outputs non-authority"
  require_scalar '.publication_checks.freshness_validator' "publication freshness validator"
  require_bool_false '.publication_checks.direct_generated_output_edits_allowed' "direct generated output edits allowed"

  require_bool_true '.mechanism_integration_checks.required_when_applicable' "mechanism integration required when applicable"
  require_bool_true '.mechanism_integration_checks.receipt_required_when_required' "mechanism integration receipt required"

  require_bool_true '.promotion_requirements.promote_proposal_required' "promote-proposal required"
  require_bool_true '.promotion_requirements.implemented_status_required' "implemented status required"
  require_bool_true '.promotion_requirements.promotion_receipt_required' "promotion receipt required"

  require_bool_true '.closeout_requirements.packet_closeout_required' "packet closeout required"
  require_bool_true '.closeout_requirements.terminal_closeout_required' "terminal closeout required"
  require_bool_true '.closeout_requirements.archive_lifecycle_required' "archive lifecycle required"
  require_bool_false '.closeout_requirements.change_closeout_required' "Change closeout required"
  require_bool_false '.closeout_requirements.delegate_git_mutation_to_change_closeout' "delegate Git mutation to Change closeout"

  require_bool_false '.hygiene_requirements.cleanup_authorization_required' "cleanup authorization required"
  require_bool_false '.hygiene_requirements.classification_alone_authorizes_deletion' "classification alone authorizes deletion"

  require_bool_false '.terminal_proof_requirements.terminal_current_state_proof_required' "terminal current-state proof required"
  require_bool_false '.terminal_proof_requirements.worktree_hygiene_required' "worktree hygiene required"
  require_bool_false '.final_sync_requirements.main_origin_landed_ref_equality_required' "main/origin/landed ref equality required"

  require_value '.non_authority_boundaries.proposal_local_files' 'non-authority' "proposal-local files authority"
  require_value '.non_authority_boundaries.generated_prompts' 'non-authority' "generated prompts authority"
  require_value '.non_authority_boundaries.generated_outputs' 'derived-only-non-authority' "generated outputs authority"
  require_value '.non_authority_boundaries.dashboards' 'non-authority' "dashboards authority"
  require_value '.non_authority_boundaries.chat_or_model_memory' 'non-authority' "chat/model memory authority"
fi

echo "Validation summary: errors=$errors"
[[ "$errors" -eq 0 ]]

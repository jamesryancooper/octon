#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
FRAMEWORK_DIR="$(cd -- "$SCRIPT_DIR/../../../../" && pwd)"
ROOT_DIR="$(cd -- "$FRAMEWORK_DIR/../.." && pwd)"
SCHEMA_PATH="$FRAMEWORK_DIR/product/contracts/proposal-program-delivery-profile-v1.schema.json"
OVERRIDE_SCHEMA_PATH="$FRAMEWORK_DIR/product/contracts/proposal-program-delivery-order-override-receipt-v1.schema.json"
PROFILE_PATH=""
errors=0

usage() {
  cat <<'USAGE'
usage:
  validate-proposal-program-delivery-profile.sh [--profile <path>]
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

scalar_file() {
  local file="$1" path="$2"
  yq -r "$path" "$file" 2>/dev/null || true
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

resolve_profile_ref() {
  local ref="$1" profile_dir
  profile_dir="$(cd -- "$(dirname -- "$PROFILE_PATH")" && pwd)"
  case "$ref" in
    /*)
      printf '%s\n' "$ref"
      ;;
    *)
      if [[ -f "$ROOT_DIR/$ref" ]]; then
        printf '%s\n' "$ROOT_DIR/$ref"
      else
        printf '%s\n' "$profile_dir/$ref"
      fi
      ;;
  esac
}

validate_override_receipt() {
  local ref="$1" path target_path profile_id requested_order revoked
  path="$(resolve_profile_ref "$ref")"
  if [[ -f "$path" ]]; then
    pass "order override receipt exists"
  else
    fail "order override receipt missing: $ref"
    return
  fi
  if yq -e '.' "$path" >/dev/null 2>&1; then
    pass "order override receipt YAML parses"
  else
    fail "order override receipt YAML does not parse"
    return
  fi

  [[ "$(scalar_file "$path" '.schema_version')" == "proposal-program-delivery-order-override-receipt-v1" ]] \
    && pass "order override schema_version correct" \
    || fail "order override schema_version must be proposal-program-delivery-order-override-receipt-v1"
  target_path="$(scalar_file "$path" '.target_program.path')"
  profile_id="$(scalar_file "$path" '.run_binding.profile_id')"
  requested_order="$(scalar_file "$path" '.requested_order.requested_order_ref')"
  revoked="$(scalar_file "$path" '.revocation.revoked')"

  [[ "$target_path" == "$(scalar '.target_program_path')" ]] \
    && pass "order override target program matches profile" \
    || fail "order override target program must match profile target_program_path"
  [[ "$profile_id" == "$(scalar '.profile_id')" ]] \
    && pass "order override profile binding matches" \
    || fail "order override run binding profile_id must match profile_id"
  [[ "$requested_order" == "$(scalar '.execution_order_policy.requested_order_ref')" ]] \
    && pass "order override requested order matches profile" \
    || fail "order override requested_order_ref must match profile requested_order_ref"
  [[ "$(scalar_file "$path" '.requested_order.canonical_order_ref')" == "child-before-parent-delivery" ]] \
    && pass "order override canonical order binding correct" \
    || fail "order override canonical_order_ref must be child-before-parent-delivery"
  [[ "$(scalar_file "$path" '.requested_order.operator_requested_alternative_order')" == "true" ]] \
    && pass "order override records alternative order" \
    || fail "order override must record operator_requested_alternative_order=true"
  [[ "$(scalar_file "$path" '.efficiency_risk_acknowledgement.acknowledged')" == "true" ]] \
    && pass "order override risk acknowledged" \
    || fail "order override must acknowledge efficiency risk"
  [[ "$revoked" == "false" ]] \
    && pass "order override not revoked" \
    || fail "order override must not be revoked"
  [[ "$(scalar_file "$path" '.authority_boundary.retained_evidence_only')" == "true" ]] \
    && pass "order override is retained evidence only" \
    || fail "order override must be retained evidence only"
  [[ "$(scalar_file "$path" '.authority_boundary.authorizes_delivery')" == "false" ]] \
    && pass "order override does not authorize delivery" \
    || fail "order override must not authorize delivery"
  [[ "$(scalar_file "$path" '.authority_boundary.authorizes_git_mutation')" == "false" ]] \
    && pass "order override does not authorize git mutation" \
    || fail "order override must not authorize git mutation"
  [[ "$(scalar_file "$path" '.non_authority_classification.generated_outputs')" == "derived-only-non-authority" ]] \
    && pass "order override classifies generated outputs as non-authority" \
    || fail "order override must classify generated outputs as derived-only-non-authority"
}

need_tool jq
need_tool yq

echo "== Proposal Program Delivery Profile Validation =="

if [[ -f "$SCHEMA_PATH" ]]; then
  pass "profile schema exists"
else
  fail "profile schema missing: $SCHEMA_PATH"
fi

if [[ -f "$OVERRIDE_SCHEMA_PATH" ]]; then
  pass "order override receipt schema exists"
else
  fail "order override receipt schema missing: $OVERRIDE_SCHEMA_PATH"
fi

if jq -e '.' "$SCHEMA_PATH" >/dev/null 2>&1; then
  pass "profile schema JSON parses"
else
  fail "profile schema JSON does not parse"
fi

if jq -e '.' "$OVERRIDE_SCHEMA_PATH" >/dev/null 2>&1; then
  pass "order override receipt schema JSON parses"
else
  fail "order override receipt schema JSON does not parse"
fi

for token in \
  '"proposal-program-delivery-profile-v1"' \
  '"execution_order_policy"' \
  '"target_outcome"' \
  '"RP00_CONTAINMENT_PUBLICATION_DISABLED"' \
  '"pr_policy"' \
  '"stash_policy"' \
  '"non_authority_boundaries"' \
  '"final_sync_requirements"'; do
  grep -Fq "$token" "$SCHEMA_PATH" && pass "schema token present: $token" || fail "schema token missing: $token"
done

for token in \
  '"proposal-program-delivery-order-override-receipt-v1"' \
  '"run_binding"' \
  '"requested_order"' \
  '"efficiency_risk_acknowledgement"' \
  '"revocation"' \
  '"retained_evidence_only"'; do
  grep -Fq "$token" "$OVERRIDE_SCHEMA_PATH" && pass "override schema token present: $token" || fail "override schema token missing: $token"
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

  [[ "$(scalar '.schema_version')" == "proposal-program-delivery-profile-v1" ]] \
    && pass "profile schema_version correct" \
    || fail "profile schema_version must be proposal-program-delivery-profile-v1"

  require_scalar '.profile_id' "profile_id"
  require_scalar '.created_at' "created_at"
  require_scalar '.target_program_path' "target_program_path"
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

  [[ "$(scalar '.target_program_path')" == .octon/inputs/exploratory/proposals/* ]] \
    && pass "target_program_path under proposal inputs" \
    || fail "target_program_path must be under .octon/inputs/exploratory/proposals/"

  require_bool_true '.execution_order_policy.canonical_order_required' "canonical order required"
  require_value '.execution_order_policy.canonical_order_ref' 'child-before-parent-delivery' "canonical order ref"
  require_bool_true '.execution_order_policy.override_required_when_order_differs' "override required when order differs"
  require_scalar '.execution_order_policy.requested_order_ref' "requested order ref"
  requested_order="$(scalar '.execution_order_policy.requested_order_ref')"
  alternative_order="$(scalar '.execution_order_policy.operator_requested_alternative_order')"
  override_ref="$(scalar '.execution_order_policy.override_receipt_ref')"
  if [[ "$requested_order" == "child-before-parent-delivery" && "$alternative_order" == "false" ]]; then
    pass "requested delivery order is canonical"
    [[ "$override_ref" == "not-applicable" || -z "$override_ref" || "$override_ref" == "null" ]] \
      && pass "canonical delivery order does not bind override receipt" \
      || fail "canonical delivery order must not bind an override receipt"
  else
    [[ "$alternative_order" == "true" ]] \
      && pass "non-canonical delivery order is operator-requested" \
      || fail "non-canonical delivery order must set operator_requested_alternative_order=true"
    [[ -n "$override_ref" && "$override_ref" != "null" && "$override_ref" != "not-applicable" ]] \
      && pass "non-canonical delivery order binds override receipt" \
      || fail "non-canonical delivery order requires override_receipt_ref"
    if [[ -n "$override_ref" && "$override_ref" != "null" && "$override_ref" != "not-applicable" ]]; then
      validate_override_receipt "$override_ref"
    fi
  fi

  require_value '.route_preference.work_unit_route' 'stage-only' "work unit route"
  require_value '.route_preference.landing_route' 'not-applicable' "landing route"
  require_bool_false '.route_preference.pr_creation_allowed' "route PR creation allowed"

  require_value '.pr_policy.mode' 'forbid-pr' "PR policy mode"
  require_bool_false '.pr_policy.allow_pr_creation' "PR creation"
  require_bool_false '.pr_policy.fallback_to_pr' "PR fallback"

  require_value '.stash_policy.mode' 'forbidden' "stash policy mode"
  require_bool_true '.stash_policy.preserve_unrelated_work' "preserve unrelated work"

  require_bool_true '.child_execution.replan_after_material_changes' "replan after material changes"
  require_bool_true '.child_execution.target_owned_receipts_required' "target-owned receipts required"
  require_bool_false '.child_execution.parent_summary_satisfies_child_receipts' "parent summary satisfies child receipts"

  require_array_nonempty '.required_proposal_validators' "required_proposal_validators"
  require_array_nonempty '.required_implementation_validators' "required_implementation_validators"

  require_bool_true '.publication_checks.owning_publishers_only' "owning publishers only"
  require_bool_true '.publication_checks.generated_outputs_are_non_authority' "generated outputs non-authority"
  require_scalar '.publication_checks.freshness_validator' "publication freshness validator"
  require_bool_false '.publication_checks.direct_generated_output_edits_allowed' "direct generated output edits allowed"

  require_bool_true '.mechanism_integration_checks.required_when_applicable' "mechanism integration required when applicable"
  require_bool_true '.mechanism_integration_checks.receipt_required_when_required' "mechanism integration receipt required"

  require_bool_true '.closeout_requirements.packet_closeout_required' "packet closeout required"
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

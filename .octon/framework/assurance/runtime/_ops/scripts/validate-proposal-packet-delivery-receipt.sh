#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
FRAMEWORK_DIR="$(cd -- "$SCRIPT_DIR/../../../../" && pwd)"
SCHEMA_PATH="$FRAMEWORK_DIR/product/contracts/proposal-packet-delivery-receipt-v1.schema.json"
RECEIPT_PATH=""
errors=0

usage() {
  cat <<'USAGE'
usage:
  validate-proposal-packet-delivery-receipt.sh [--receipt <path>]
USAGE
}

pass() { echo "[OK] $1"; }
fail() {
  echo "[ERROR] $1"
  errors=$((errors + 1))
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --receipt)
      shift
      [[ $# -gt 0 ]] || { usage >&2; exit 2; }
      RECEIPT_PATH="$1"
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
  yq -r "$1" "$RECEIPT_PATH" 2>/dev/null || true
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

require_bool() {
  local path="$1" expected="$2" label="$3" value
  value="$(scalar "$path")"
  [[ "$value" == "$expected" ]] && pass "$label is $expected" || fail "$label must be $expected"
}

require_bool_declared() {
  local path="$1" label="$2" value
  value="$(scalar "$path")"
  case "$value" in
    true|false)
      pass "$label declared as boolean"
      ;;
    *)
      fail "$label must be boolean"
      ;;
  esac
}

require_value() {
  local path="$1" expected="$2" label="$3" value
  value="$(scalar "$path")"
  [[ "$value" == "$expected" ]] && pass "$label is $expected" || fail "$label must be $expected"
}

require_array_declared() {
  local path="$1" label="$2"
  if yq -e "$path | tag == \"!!seq\"" "$RECEIPT_PATH" >/dev/null 2>&1; then
    pass "$label declared as array"
  else
    fail "$label must be an array"
  fi
}

require_array_nonempty() {
  local path="$1" label="$2" count
  count="$(yq -r "($path // []) | length" "$RECEIPT_PATH" 2>/dev/null || echo 0)"
  [[ "$count" -gt 0 ]] && pass "$label non-empty" || fail "$label must be non-empty"
}

require_fresh_pass_receipt() {
  local base="$1" label="$2"
  require_scalar "$base.receipt_ref" "$label receipt_ref"
  require_bool "$base.fresh" "true" "$label fresh"
  require_value "$base.verdict" "pass" "$label verdict"
}

require_receipt_verdict_shape() {
  local base="$1" label="$2" verdict
  require_scalar "$base.receipt_ref" "$label receipt_ref"
  require_bool_declared "$base.fresh" "$label fresh"
  verdict="$(scalar "$base.verdict")"
  case "$verdict" in
    pass|fail|blocked|not-run)
      pass "$label verdict declared"
      ;;
    *)
      fail "$label verdict must be pass, fail, blocked, or not-run"
      ;;
  esac
}

need_tool jq
need_tool yq

echo "== Proposal Packet Delivery Receipt Validation =="

if [[ -f "$SCHEMA_PATH" ]]; then
  pass "receipt schema exists"
else
  fail "receipt schema missing: $SCHEMA_PATH"
fi

if jq -e '.' "$SCHEMA_PATH" >/dev/null 2>&1; then
  pass "receipt schema JSON parses"
else
  fail "receipt schema JSON does not parse"
fi

for token in \
  '"proposal-packet-delivery-receipt-v1"' \
  '"actual_outcome"' \
  '"cleaned"' \
  '"target_receipts"' \
  '"promotion"' \
  '"terminal_closeout"' \
  '"terminal_current_state_proof"' \
  '"target_owned_evidence_policy"'; do
  grep -Fq "$token" "$SCHEMA_PATH" && pass "schema token present: $token" || fail "schema token missing: $token"
done

if [[ -n "$RECEIPT_PATH" ]]; then
  if [[ -f "$RECEIPT_PATH" ]]; then
    pass "receipt file exists: $RECEIPT_PATH"
  else
    fail "receipt file missing: $RECEIPT_PATH"
    echo "Validation summary: errors=$errors"
    exit 1
  fi

  if yq -e '.' "$RECEIPT_PATH" >/dev/null 2>&1; then
    pass "receipt YAML parses"
  else
    fail "receipt YAML does not parse"
  fi

  [[ "$(scalar '.schema_version')" == "proposal-packet-delivery-receipt-v1" ]] \
    && pass "receipt schema_version correct" \
    || fail "receipt schema_version must be proposal-packet-delivery-receipt-v1"

  require_scalar '.receipt_id' "receipt_id"
  require_scalar '.emitted_at' "emitted_at"
  require_scalar '.profile.profile_id' "profile.profile_id"
  require_scalar '.profile.profile_ref' "profile.profile_ref"
  require_scalar '.profile.validated_at' "profile.validated_at"
  require_value '.profile.verdict' 'pass' "profile verdict"
  require_scalar '.target_packet.path' "target_packet.path"
  require_scalar '.target_packet.status' "target_packet.status"
  require_scalar '.target_packet.accepted_review_digest' "target_packet.accepted_review_digest"
  if [[ "$(scalar '.target_packet.accepted_review_digest')" =~ ^sha256:[0-9a-f]{64}$ ]]; then
    pass "target_packet.accepted_review_digest is sha256"
  else
    fail "target_packet.accepted_review_digest must be sha256:<64 hex>"
  fi
  require_bool '.target_packet.accepted_review_fresh' 'true' "accepted review freshness"
  require_bool '.target_packet.implementation_authorized' 'true' "implementation authorization"
  require_scalar '.target_packet.implementation_authorization_ref' "target_packet.implementation_authorization_ref"
  require_scalar '.target_outcome' "target_outcome"
  require_scalar '.actual_outcome' "actual_outcome"
  actual_outcome="$(scalar '.actual_outcome')"

  case "$actual_outcome" in
    blocked|implemented|archive-ready|landed|synced|cleaned)
      pass "actual_outcome allowed"
      ;;
    *)
      fail "actual_outcome must be blocked, implemented, archive-ready, landed, synced, or cleaned"
      ;;
  esac

  require_scalar '.packet_lifecycle.workflow_ref' "packet lifecycle workflow_ref"
  require_scalar '.packet_lifecycle.receipt_ref' "packet lifecycle receipt_ref"
  if [[ "$actual_outcome" == "blocked" ]]; then
    require_value '.packet_lifecycle.verdict' 'blocked' "packet lifecycle verdict"
  else
    require_value '.packet_lifecycle.verdict' 'pass' "packet lifecycle verdict"
  fi
  require_bool '.packet_lifecycle.replanned_after_material_changes' 'true' "packet lifecycle replanned after material changes"

  for receipt_family in \
    implementation_run \
    implementation_conformance \
    post_implementation_drift_churn \
    promotion \
    packet_closeout \
    terminal_closeout \
    archive \
    change_closeout; do
    if [[ "$actual_outcome" == "blocked" ]]; then
      require_array_declared ".target_receipts.$receipt_family" "target_receipts.$receipt_family"
    else
      require_array_nonempty ".target_receipts.$receipt_family" "target_receipts.$receipt_family"
    fi
  done

  if [[ "$actual_outcome" == "blocked" ]]; then
    require_receipt_verdict_shape '.implementation_conformance' "implementation conformance"
    require_receipt_verdict_shape '.post_implementation_drift_churn' "post-implementation drift/churn"
    require_receipt_verdict_shape '.promotion' "promotion"
    require_receipt_verdict_shape '.packet_closeout' "packet closeout"
    require_receipt_verdict_shape '.terminal_closeout' "terminal closeout"
    require_receipt_verdict_shape '.archive' "archive"
  else
    require_fresh_pass_receipt '.implementation_conformance' "implementation conformance"
    require_fresh_pass_receipt '.post_implementation_drift_churn' "post-implementation drift/churn"
    require_fresh_pass_receipt '.promotion' "promotion"
    require_fresh_pass_receipt '.packet_closeout' "packet closeout"
    require_fresh_pass_receipt '.terminal_closeout' "terminal closeout"
    require_fresh_pass_receipt '.archive' "archive"
  fi

  require_scalar '.generated_publication.validator' "generated publication validator"
  if [[ "$actual_outcome" == "blocked" ]]; then
    require_array_declared '.generated_publication.publisher_refs' "generated publication publisher refs"
    require_bool_declared '.generated_publication.fresh' "generated publication fresh"
  else
    require_array_nonempty '.generated_publication.publisher_refs' "generated publication publisher refs"
    require_bool '.generated_publication.fresh' 'true' "generated publication fresh"
  fi
  require_bool '.generated_publication.direct_generated_output_edit_used' 'false' "direct generated output edit used"

  require_scalar '.governed_mechanism_integration.required' "governed mechanism integration required flag"
  if [[ "$(scalar '.governed_mechanism_integration.required')" == "true" ]]; then
    if [[ "$actual_outcome" == "blocked" ]]; then
      require_scalar '.governed_mechanism_integration.verdict' "governed mechanism integration verdict"
    else
      require_value '.governed_mechanism_integration.verdict' 'pass' "governed mechanism integration verdict"
    fi
    require_array_nonempty '.governed_mechanism_integration.receipt_refs' "governed mechanism integration receipt refs"
  else
    require_value '.governed_mechanism_integration.verdict' 'not-applicable' "governed mechanism integration verdict"
    require_scalar '.governed_mechanism_integration.not_applicable_rationale' "governed mechanism integration not-applicable rationale"
  fi

  require_bool '.lifecycle_residue_cleanup.unauthorized_deletion_performed' 'false' "unauthorized lifecycle residue deletion"
  if [[ "$(scalar '.lifecycle_residue_cleanup.cleanup_performed')" == "true" ]]; then
    require_array_nonempty '.lifecycle_residue_cleanup.cleanup_authorization_refs' "lifecycle residue cleanup authorization refs"
  fi

  require_scalar '.change_closeout.route' "Change closeout route"
  require_scalar '.change_closeout.receipt_ref' "Change closeout receipt ref"
  require_scalar '.change_closeout.verdict' "Change closeout verdict"

  if [[ "$(scalar '.branch_authorization.landing_performed')" == "true" ]]; then
    [[ "$(scalar '.branch_authorization.landing_authorization_ref')" != "not-applicable" ]] \
      && require_scalar '.branch_authorization.landing_authorization_ref' "branch landing authorization ref" \
      || fail "branch landing requires landing authorization ref"
  fi
  if [[ "$(scalar '.branch_authorization.branch_cleanup_performed')" == "true" || "$(scalar '.branch_authorization.branch_deleted')" == "true" ]]; then
    [[ "$(scalar '.branch_authorization.cleanup_authorization_ref')" != "not-applicable" ]] \
      && require_scalar '.branch_authorization.cleanup_authorization_ref' "branch cleanup authorization ref" \
      || fail "branch cleanup requires cleanup authorization ref"
  fi

  if [[ "$actual_outcome" == "synced" || "$actual_outcome" == "cleaned" ]]; then
    require_scalar '.final_sync.landed_ref' "final sync landed_ref"
    require_scalar '.final_sync.local_main_ref' "final sync local_main_ref"
    require_scalar '.final_sync.origin_main_ref' "final sync origin_main_ref"
    require_bool '.final_sync.main_origin_landed_ref_equal' 'true' "main/origin/landed ref equality"
  fi

  if [[ "$actual_outcome" == "cleaned" ]]; then
    require_scalar '.terminal_current_state_proof.evidence_ref' "terminal current-state proof evidence_ref"
    require_bool '.terminal_current_state_proof.fresh_after_last_mutation' 'true' "terminal proof fresh after last mutation"
    require_value '.terminal_current_state_proof.verdict' 'pass' "terminal current-state proof verdict"
    require_scalar '.worktree_hygiene.evidence_ref' "worktree hygiene evidence_ref"
    require_bool '.worktree_hygiene.dirty_worktree' 'false' "worktree dirty flag"
    require_value '.worktree_hygiene.verdict' 'pass' "worktree hygiene verdict"
  fi

  open_blocker_count="$(yq -r '[.blockers[]? | select(.status == "open")] | length' "$RECEIPT_PATH" 2>/dev/null || echo 0)"
  if [[ "$actual_outcome" == "blocked" && "$open_blocker_count" -eq 0 ]]; then
    fail "blocked outcomes require explicit open blocker evidence"
  elif [[ "$actual_outcome" != "blocked" && "$open_blocker_count" -gt 0 ]]; then
    fail "non-blocked outcomes must not retain open blockers"
  else
    pass "blocker state compatible with actual outcome"
  fi

  require_value '.non_authority_classification.proposal_local_files' 'non-authority' "proposal-local files authority"
  require_value '.non_authority_classification.generated_prompts' 'non-authority' "generated prompts authority"
  require_value '.non_authority_classification.generated_outputs' 'derived-only-non-authority' "generated outputs authority"
  require_value '.non_authority_classification.dashboards' 'non-authority' "dashboards authority"
  require_value '.non_authority_classification.chat_or_model_memory' 'non-authority' "chat/model memory authority"

  require_bool '.target_owned_evidence_policy.target_owned_receipts_required' 'true' "target-owned receipts required"
  require_bool '.target_owned_evidence_policy.aggregate_receipt_replaces_target_owned_receipts' 'false' "aggregate receipt replaces target-owned receipts"
fi

echo "Validation summary: errors=$errors"
[[ "$errors" -eq 0 ]]

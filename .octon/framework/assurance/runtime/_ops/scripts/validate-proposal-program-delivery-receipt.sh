#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
FRAMEWORK_DIR="$(cd -- "$SCRIPT_DIR/../../../../" && pwd)"
SCHEMA_PATH="$FRAMEWORK_DIR/product/contracts/proposal-program-delivery-receipt-v1.schema.json"
RECEIPT_PATH=""
errors=0

usage() {
  cat <<'USAGE'
usage:
  validate-proposal-program-delivery-receipt.sh [--receipt <path>]
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

validate_feature_catalog_drift_gate() {
  local actual_outcome="$1" verdict outcome unresolved_count open_blocker_count
  require_scalar '.feature_catalog_drift.receipt_ref' "feature catalog drift receipt_ref"
  require_value '.feature_catalog_drift.validator_ref' '.octon/framework/assurance/runtime/_ops/scripts/validate-feature-catalog-drift-closeout.sh' "feature catalog drift validator_ref"
  verdict="$(scalar '.feature_catalog_drift.verdict')"
  outcome="$(scalar '.feature_catalog_drift.outcome')"
  unresolved_count="$(scalar '.feature_catalog_drift.unresolved_count')"
  case "$verdict" in
    pass|fail|blocked|not-run)
      pass "feature catalog drift verdict allowed"
      ;;
    *)
      fail "feature catalog drift verdict must be pass, fail, blocked, or not-run"
      ;;
  esac
  case "$outcome" in
    no-change|documented-change|documented-retirement|blocked-unresolved-drift)
      pass "feature catalog drift outcome allowed"
      ;;
    *)
      fail "feature catalog drift outcome invalid"
      ;;
  esac
  [[ "$unresolved_count" =~ ^[0-9]+$ ]] && pass "feature catalog drift unresolved_count numeric" || fail "feature catalog drift unresolved_count must be numeric"
  require_array_nonempty '.feature_catalog_drift.authority_notes' "feature catalog drift authority notes"
  if yq -e '.feature_catalog_drift.affected_feature_ids | tag == "!!seq"' "$RECEIPT_PATH" >/dev/null 2>&1; then
    pass "feature catalog drift affected feature ids declared"
  else
    fail "feature catalog drift affected feature ids must be an array"
  fi
  if yq -e '.feature_catalog_drift.required_documentation_actions | tag == "!!seq"' "$RECEIPT_PATH" >/dev/null 2>&1; then
    pass "feature catalog drift documentation actions declared"
  else
    fail "feature catalog drift documentation actions must be an array"
  fi
  if yq -e '.feature_catalog_drift.child_receipt_refs | tag == "!!seq"' "$RECEIPT_PATH" >/dev/null 2>&1; then
    pass "feature catalog drift child receipt refs declared"
  else
    fail "feature catalog drift child receipt refs must be an array"
  fi
  if [[ "$actual_outcome" == "blocked" ]]; then
    require_bool_declared '.feature_catalog_drift.fresh' "feature catalog drift fresh"
    if [[ "$outcome" == "blocked-unresolved-drift" ]]; then
      [[ "$unresolved_count" -gt 0 ]] && pass "blocked feature catalog drift unresolved count" || fail "blocked feature catalog drift requires unresolved_count > 0"
      open_blocker_count="$(yq -r '[.blockers[]? | select(.status == "open" and .class == "feature-catalog-drift")] | length' "$RECEIPT_PATH" 2>/dev/null || echo 0)"
      [[ "$open_blocker_count" -gt 0 ]] && pass "blocked feature catalog drift has open blocker" || fail "blocked feature catalog drift requires open feature-catalog-drift blocker"
    fi
  else
    require_bool '.feature_catalog_drift.fresh' 'true' "feature catalog drift fresh"
    require_value '.feature_catalog_drift.verdict' 'pass' "feature catalog drift verdict"
    [[ "$outcome" != "blocked-unresolved-drift" ]] && pass "feature catalog drift non-blocking outcome" || fail "non-blocked delivery cannot carry blocked-unresolved-drift"
    [[ "$unresolved_count" == "0" ]] && pass "feature catalog drift unresolved_count zero" || fail "non-blocked delivery requires feature catalog drift unresolved_count 0"
  fi
}

retained_state_rows=(
  delivered_branch
  route_owned_delivery_branch
  source_dirty_anchor_branches
  retained_local_branches
  retained_worktrees
  retained_required_evidence
  local_private_evidence
  generated_diagnostics
  deleted_residue
  excluded_residue
  manual_review_residue
  remote_mutation_status
  archive_authorization
  final_current_state_proof
)

retained_state_subjects_are_none() {
  local row="$1"
  yq -e "(.retained_state_report.$row.subjects // []) | length == 1 and .[0] == \"none\"" "$RECEIPT_PATH" >/dev/null 2>&1
}

retained_state_evidence_is_none() {
  local row="$1"
  yq -e "(.retained_state_report.$row.evidence_refs // []) | length == 1 and .[0] == \"none\"" "$RECEIPT_PATH" >/dev/null 2>&1
}

retained_state_deleted_residue_is_concrete() {
  local disposition
  disposition="$(scalar '.retained_state_report.deleted_residue.disposition')"
  [[ "$disposition" == "deleted" ]] &&
    ! retained_state_subjects_are_none deleted_residue &&
    ! retained_state_evidence_is_none deleted_residue
}

validate_retained_state_report() {
  local terminal_claim="$1"
  local row row_kind disposition evidence_count subject_count reason forbidden_refs branch_cleanup_performed branch_deleted

  if yq -e '.retained_state_report | tag == "!!map"' "$RECEIPT_PATH" >/dev/null 2>&1; then
    pass "retained_state_report declared"
  else
    fail "retained_state_report missing"
    return
  fi

  for row in "${retained_state_rows[@]}"; do
    if yq -e ".retained_state_report.$row | tag == \"!!map\"" "$RECEIPT_PATH" >/dev/null 2>&1; then
      pass "retained_state_report.$row declared"
    else
      fail "retained_state_report.$row missing"
      continue
    fi

    row_kind="$(scalar ".retained_state_report.$row.row_kind")"
    [[ "$row_kind" == "$row" ]] && pass "retained_state_report.$row row_kind matches" || fail "retained_state_report.$row row_kind must be $row"

    subject_count="$(yq -r "(.retained_state_report.$row.subjects // []) | length" "$RECEIPT_PATH" 2>/dev/null || echo 0)"
    [[ "$subject_count" -gt 0 ]] && pass "retained_state_report.$row subjects declared" || fail "retained_state_report.$row subjects must be non-empty"

    evidence_count="$(yq -r "(.retained_state_report.$row.evidence_refs // []) | length" "$RECEIPT_PATH" 2>/dev/null || echo 0)"
    [[ "$evidence_count" -gt 0 ]] && pass "retained_state_report.$row evidence_refs declared" || fail "retained_state_report.$row evidence_refs must be non-empty"

    disposition="$(scalar ".retained_state_report.$row.disposition")"
    case "$disposition" in
      delivered|retained|deleted|excluded|manual-review|not-authorized|not-applicable|blocked|verified|authorized)
        pass "retained_state_report.$row disposition allowed"
        ;;
      *)
        fail "retained_state_report.$row disposition invalid"
        ;;
    esac

    reason="$(scalar ".retained_state_report.$row.retention_or_blocker_reason")"
    [[ -n "$reason" && "$reason" != "null" ]] && pass "retained_state_report.$row reason declared" || fail "retained_state_report.$row retention_or_blocker_reason missing"

    case "$disposition" in
      delivered|deleted|verified|authorized)
        if retained_state_evidence_is_none "$row"; then
          fail "retained_state_report.$row $disposition disposition requires concrete evidence refs"
        else
          pass "retained_state_report.$row $disposition disposition has concrete evidence refs"
        fi
        ;;
    esac

    forbidden_refs="$(yq -r "(.retained_state_report.$row.evidence_refs // [])[]" "$RECEIPT_PATH" 2>/dev/null | grep -E '(\.octon/inputs/exploratory/proposals/|\.octon/generated/|chat|model memory|dashboard|host state|tool availability)' || true)"
    if [[ -n "$forbidden_refs" ]]; then
      fail "retained_state_report.$row evidence_refs must not use proposal-local, generated, chat, dashboard, host, model, or tool state as authority"
    else
      pass "retained_state_report.$row evidence refs preserve authority boundaries"
    fi
  done

  if [[ "$terminal_claim" == "true" ]]; then
    require_value '.retained_state_report.final_current_state_proof.disposition' 'verified' "retained state final current-state proof disposition"
    if retained_state_evidence_is_none final_current_state_proof; then
      fail "cleaned retained_state_report final_current_state_proof requires concrete evidence"
    else
      pass "cleaned retained_state_report final current-state proof has evidence"
    fi
    for row in source_dirty_anchor_branches retained_local_branches retained_worktrees local_private_evidence generated_diagnostics excluded_residue manual_review_residue; do
      disposition="$(scalar ".retained_state_report.$row.disposition")"
      if [[ "$disposition" != "not-applicable" ]] && ! retained_state_subjects_are_none "$row"; then
        fail "cleaned delivery cannot hide retained $row under terminal claim"
      else
        pass "cleaned delivery has no undispositioned $row"
      fi
    done
  fi

  branch_cleanup_performed="$(scalar '.branch_authorization.branch_cleanup_performed')"
  branch_deleted="$(scalar '.branch_authorization.branch_deleted')"
  if [[ "$branch_cleanup_performed" == "true" || "$branch_deleted" == "true" ]]; then
    if ! retained_state_deleted_residue_is_concrete; then
      fail "branch cleanup/deletion requires concrete deleted_residue retained-state rows"
    else
      pass "branch cleanup/deletion has concrete deleted_residue retained-state rows"
    fi
  fi

  if grep -Eiq 'source branches? deleted|source-branches-deleted' "$RECEIPT_PATH"; then
    if ! retained_state_deleted_residue_is_concrete; then
      fail "broad source-branch deletion language requires exact deleted_residue rows"
    else
      pass "broad source-branch deletion language is backed by deleted_residue rows"
    fi
  fi
}

need_tool jq
need_tool yq

echo "== Proposal Program Delivery Receipt Validation =="

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
  '"proposal-program-delivery-receipt-v1"' \
  '"actual_outcome"' \
  '"cleaned"' \
  '"order_policy"' \
  '"delivery_readiness_preflight"' \
  '"feature_catalog_drift"' \
  '"clean_worktree_route"' \
  '"delivery_evidence_index"' \
  '"lifecycle_postmortem"' \
  '"child_packet_coverage"' \
  '"terminal_current_state_proof"' \
  '"retained_state_report"' \
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

  [[ "$(scalar '.schema_version')" == "proposal-program-delivery-receipt-v1" ]] \
    && pass "receipt schema_version correct" \
    || fail "receipt schema_version must be proposal-program-delivery-receipt-v1"

  require_scalar '.receipt_id' "receipt_id"
  require_scalar '.emitted_at' "emitted_at"
  require_scalar '.profile.profile_id' "profile.profile_id"
  require_scalar '.profile.profile_ref' "profile.profile_ref"
  require_scalar '.profile.validated_at' "profile.validated_at"
  require_value '.profile.verdict' 'pass' "profile verdict"
  require_scalar '.target_program.path' "target_program.path"
  require_scalar '.target_program.status' "target_program.status"
  require_scalar '.target_program.accepted_review_digest' "target_program.accepted_review_digest"
  require_scalar '.target_outcome' "target_outcome"
  require_scalar '.actual_outcome' "actual_outcome"

  case "$(scalar '.actual_outcome')" in
    blocked|implemented|archive-ready|landed|synced|cleaned)
      pass "actual_outcome allowed"
      ;;
    *)
      fail "actual_outcome must be blocked, implemented, archive-ready, landed, synced, or cleaned"
      ;;
  esac

  require_value '.order_policy.canonical_order_ref' 'child-before-parent-delivery' "order policy canonical ref"
  require_scalar '.order_policy.requested_order_ref' "order policy requested order ref"
  requested_order="$(scalar '.order_policy.requested_order_ref')"
  alternative_order="$(scalar '.order_policy.operator_requested_alternative_order')"
  override_required="$(scalar '.order_policy.override_receipt_required')"
  override_status="$(scalar '.order_policy.override_receipt_status')"
  if [[ "$requested_order" == "child-before-parent-delivery" && "$alternative_order" == "false" ]]; then
    [[ "$override_required" == "false" ]] \
      && pass "canonical order does not require override receipt" \
      || fail "canonical order must set override_receipt_required=false"
    require_value '.order_policy.override_receipt_status' 'not-required' "canonical order override status"
  else
    [[ "$alternative_order" == "true" ]] \
      && pass "non-canonical order is operator-requested" \
      || fail "non-canonical order must set operator_requested_alternative_order=true"
    [[ "$override_required" == "true" ]] \
      && pass "non-canonical order requires override receipt" \
      || fail "non-canonical order must set override_receipt_required=true"
    require_scalar '.order_policy.override_receipt_ref' "non-canonical order override receipt ref"
    [[ "$override_status" == "valid" ]] \
      && pass "non-canonical order override receipt valid" \
      || fail "non-canonical order override_receipt_status must be valid"
  fi

  require_scalar '.delivery_readiness_preflight.receipt_ref' "delivery readiness preflight receipt_ref"
  require_bool '.delivery_readiness_preflight.fresh' 'true' "delivery readiness preflight fresh"
  if [[ "$(scalar '.actual_outcome')" == "blocked" ]]; then
    case "$(scalar '.delivery_readiness_preflight.verdict')" in
      pass|blocked|fail)
        pass "blocked delivery readiness preflight verdict recorded"
        ;;
      *)
        fail "blocked delivery readiness preflight verdict must be pass, blocked, or fail"
        ;;
    esac
  else
    require_value '.delivery_readiness_preflight.verdict' 'pass' "delivery readiness preflight verdict"
  fi
  for readiness_check in \
    checked_git_write \
    checked_worktree_cleanliness \
    checked_review_freshness \
    checked_child_receipt_compatibility \
    checked_tooling \
    checked_route_legality \
    checked_generated_freshness; do
    require_bool ".delivery_readiness_preflight.$readiness_check" 'true' "delivery readiness preflight $readiness_check"
  done
  if [[ "$(scalar '.actual_outcome')" != "blocked" ]]; then
    readiness_blocker_count="$(yq -r '(.delivery_readiness_preflight.blockers // []) | length' "$RECEIPT_PATH" 2>/dev/null || echo 0)"
    [[ "$readiness_blocker_count" -eq 0 ]] \
      && pass "non-blocked delivery readiness preflight has no blockers" \
      || fail "non-blocked delivery readiness preflight blockers must be empty"
  fi

  require_scalar '.parent_program_lifecycle.workflow_ref' "parent lifecycle workflow_ref"
  require_scalar '.parent_program_lifecycle.receipt_ref' "parent lifecycle receipt_ref"
  require_value '.parent_program_lifecycle.verdict' 'pass' "parent lifecycle verdict"
  require_bool '.parent_program_lifecycle.replanned_after_material_changes' 'true' "parent lifecycle replanned after material changes"

  require_bool '.child_packet_coverage.parent_summary_satisfies_child_receipts' 'false' "parent summary satisfies child receipts"
  child_count="$(yq -r '(.child_packet_coverage.children // []) | length' "$RECEIPT_PATH" 2>/dev/null || echo 0)"
  if [[ "$child_count" -gt 0 ]]; then
    pass "child packet coverage non-empty"
    for ((index=0; index<child_count; index++)); do
      require_scalar ".child_packet_coverage.children[$index].path" "child[$index] path"
      require_scalar ".child_packet_coverage.children[$index].status" "child[$index] status"
      require_array_nonempty ".child_packet_coverage.children[$index].required_receipts" "child[$index] required receipts"
      require_bool ".child_packet_coverage.children[$index].fresh" "true" "child[$index] fresh"
    done
  else
    fail "child packet coverage must be non-empty"
  fi

  for receipt_family in \
    implementation_run \
    implementation_conformance \
    post_implementation_drift_churn \
    packet_closeout \
    archive \
    change_closeout; do
    require_array_nonempty ".child_receipts.$receipt_family" "child_receipts.$receipt_family"
  done

  require_fresh_pass_receipt '.implementation_conformance' "implementation conformance"
  require_fresh_pass_receipt '.post_implementation_drift_churn' "post-implementation drift/churn"
  validate_feature_catalog_drift_gate "$(scalar '.actual_outcome')"

  require_scalar '.generated_publication.validator' "generated publication validator"
  require_array_nonempty '.generated_publication.publisher_refs' "generated publication publisher refs"
  require_bool '.generated_publication.fresh' 'true' "generated publication fresh"
  require_bool '.generated_publication.direct_generated_output_edit_used' 'false' "direct generated output edit used"

  require_scalar '.governed_mechanism_integration.required' "governed mechanism integration required flag"
  if [[ "$(scalar '.governed_mechanism_integration.required')" == "true" ]]; then
    require_value '.governed_mechanism_integration.verdict' 'pass' "governed mechanism integration verdict"
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

  open_blocker_count="$(yq -r '[.blockers[]? | select(.status == "open")] | length' "$RECEIPT_PATH" 2>/dev/null || echo 0)"
  if [[ "$(scalar '.actual_outcome')" == "blocked" ]]; then
    if [[ "$open_blocker_count" -gt 0 ]]; then
      pass "blocked outcome has open blocker evidence"
    else
      fail "blocked outcome requires at least one open blocker"
    fi
    require_value '.change_closeout.verdict' 'blocked' "blocked delivery Change closeout verdict"
    require_bool '.branch_authorization.landing_performed' 'false' "blocked delivery landing performed"
    require_bool '.branch_authorization.branch_cleanup_performed' 'false' "blocked delivery branch cleanup performed"
    require_bool '.branch_authorization.branch_deleted' 'false' "blocked delivery branch deleted"
    if yq -e '.blockers[]? | select(.status == "open") | select(.class == "git-index-write-denied" or .class == "git-ref-write-denied")' "$RECEIPT_PATH" >/dev/null 2>&1; then
      pass "blocked delivery records typed git mutation blocker"
      require_bool '.final_sync.main_origin_landed_ref_equal' 'false' "blocked delivery final sync equality"
      require_value '.terminal_current_state_proof.verdict' 'not-run' "blocked delivery terminal proof verdict"
    fi
  fi

  if [[ "$(scalar '.actual_outcome')" == "synced" || "$(scalar '.actual_outcome')" == "cleaned" ]]; then
    require_scalar '.final_sync.landed_ref' "final sync landed_ref"
    require_scalar '.final_sync.local_main_ref' "final sync local_main_ref"
    require_scalar '.final_sync.origin_main_ref' "final sync origin_main_ref"
    require_bool '.final_sync.main_origin_landed_ref_equal' 'true' "main/origin/landed ref equality"
  fi

  if [[ "$(scalar '.actual_outcome')" == "cleaned" ]]; then
    require_scalar '.terminal_current_state_proof.evidence_ref' "terminal current-state proof evidence_ref"
    require_bool '.terminal_current_state_proof.fresh_after_last_mutation' 'true' "terminal proof fresh after last mutation"
    require_value '.terminal_current_state_proof.verdict' 'pass' "terminal current-state proof verdict"
    require_scalar '.worktree_hygiene.evidence_ref' "worktree hygiene evidence_ref"
    require_bool '.worktree_hygiene.dirty_worktree' 'false' "worktree dirty flag"
    require_value '.worktree_hygiene.verdict' 'pass' "worktree hygiene verdict"
  fi
  validate_retained_state_report "$([[ "$(scalar '.actual_outcome')" == "cleaned" ]] && printf true || printf false)"

  require_scalar '.delivery_evidence_index.ref' "delivery evidence index ref"
  require_value '.delivery_evidence_index.schema_version' 'proposal-program-delivery-evidence-index-v1' "delivery evidence index schema_version"
  require_value '.delivery_evidence_index.validator_ref' '.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-delivery-evidence-index.sh' "delivery evidence index validator_ref"
  case "$(scalar '.delivery_evidence_index.validator_verdict')" in
    pass|fail|not-run)
      pass "delivery evidence index validator_verdict allowed"
      ;;
    *)
      fail "delivery evidence index validator_verdict must be pass, fail, or not-run"
      ;;
  esac
  require_bool '.delivery_evidence_index.evidence_only' 'true' "delivery evidence index evidence-only"
  require_bool '.delivery_evidence_index.source_receipt_digest_bound' 'true' "delivery evidence index source receipt digest bound"
  require_bool '.delivery_evidence_index.circular_digest_required' 'false' "delivery evidence index circular digest required"
  if [[ "$(scalar '.actual_outcome')" != "blocked" ]]; then
    require_value '.delivery_evidence_index.validator_verdict' 'pass' "non-blocked delivery evidence index validator verdict"
  fi

  require_scalar '.clean_worktree_route.selected_route' "clean worktree selected route"
  case "$(scalar '.clean_worktree_route.selected_route')" in
    current-clean-worktree|route-owned-clean-worktree|blocked)
      pass "clean worktree route allowed"
      ;;
    *)
      fail "clean worktree selected_route must be current-clean-worktree, route-owned-clean-worktree, or blocked"
      ;;
  esac
  source_dirty="$(scalar '.clean_worktree_route.source_dirty')"
  source_stale="$(scalar '.clean_worktree_route.source_stale')"
  broad_stage_all="$(scalar '.clean_worktree_route.broad_stage_all_requested')"
  include_classification_valid="$(scalar '.clean_worktree_route.include_path_classification_valid')"
  if [[ "$source_dirty" == "true" || "$source_stale" == "true" ]]; then
    require_value '.clean_worktree_route.selected_route' 'route-owned-clean-worktree' "dirty/stale source clean worktree route"
    require_scalar '.clean_worktree_route.route_owned_worktree_ref' "route-owned clean worktree ref"
    require_scalar '.clean_worktree_route.include_path_classification_ref' "include-path classification ref"
    require_bool '.clean_worktree_route.include_path_classification_valid' 'true' "include-path classification valid"
  fi
  if [[ "$broad_stage_all" == "true" ]]; then
    require_scalar '.clean_worktree_route.include_path_classification_ref' "broad stage-all include-path classification ref"
    [[ "$include_classification_valid" == "true" ]] \
      && pass "broad stage-all include-path classification valid" \
      || fail "broad stage-all requires valid include-path classification"
  fi

  require_scalar '.lifecycle_postmortem.status' "lifecycle postmortem status"
  postmortem_required="$(scalar '.lifecycle_postmortem.required')"
  if [[ "$postmortem_required" == "true" ]]; then
    require_value '.lifecycle_postmortem.status' 'required-present' "required lifecycle postmortem status"
    require_value '.lifecycle_postmortem.verdict' 'pass' "required lifecycle postmortem verdict"
    require_scalar '.lifecycle_postmortem.evaluation_ref' "lifecycle postmortem evaluation ref"
    require_scalar '.lifecycle_postmortem.report_ref' "lifecycle postmortem report ref"
    require_scalar '.lifecycle_postmortem.readiness_summary_ref' "lifecycle postmortem readiness summary ref"
    require_scalar '.lifecycle_postmortem.evidence_map_ref' "lifecycle postmortem evidence map ref"
    require_array_nonempty '.lifecycle_postmortem.digest_bound_evidence_refs' "lifecycle postmortem digest-bound evidence refs"
  else
    require_value '.lifecycle_postmortem.status' 'not-required' "not-required lifecycle postmortem status"
    require_value '.lifecycle_postmortem.verdict' 'not-required' "not-required lifecycle postmortem verdict"
  fi

  if [[ "$(scalar '.actual_outcome')" != "blocked" && "$open_blocker_count" -gt 0 ]]; then
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

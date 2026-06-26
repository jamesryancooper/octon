#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
FRAMEWORK_DIR="$(cd -- "$SCRIPT_DIR/../../../../" && pwd)"
ROOT_DIR="$(cd -- "$FRAMEWORK_DIR/../.." && pwd)"
SCHEMA_PATH="$FRAMEWORK_DIR/product/contracts/proposal-packet-delivery-order-override-receipt-v1.schema.json"
WORKTREE_VALIDATOR="$SCRIPT_DIR/validate-closeout-worktree-wrapper.sh"
INTERACTION_VALIDATOR="$SCRIPT_DIR/validate-lifecycle-interaction-receipts.sh"
RECEIPT_PATH=""
errors=0

usage() {
  cat <<'USAGE'
usage:
  validate-proposal-packet-delivery-order-override-receipt.sh [--receipt <path>]
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

scalar_file() {
  local file="$1" expr="$2"
  yq -r "$expr" "$file" 2>/dev/null || true
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

require_value() {
  local path="$1" expected="$2" label="$3" value
  value="$(scalar "$path")"
  [[ "$value" == "$expected" ]] && pass "$label is $expected" || fail "$label must be $expected"
}

require_bool() {
  local path="$1" expected="$2" label="$3" value
  value="$(scalar "$path")"
  [[ "$value" == "$expected" ]] && pass "$label is $expected" || fail "$label must be $expected"
}

resolve_ref() {
  local ref="$1" label="$2"
  if [[ -z "$ref" || "$ref" == "null" ]]; then
    fail "$label missing"
    return 1
  fi
  case "$ref" in
    /*|*"/../"*|../*|./*|*"//"*)
      fail "$label must be repo-relative without traversal: $ref"
      return 1
      ;;
  esac
  local resolved="$ROOT_DIR/$ref"
  if [[ ! -f "$resolved" ]]; then
    fail "$label does not resolve to a file: $ref"
    return 1
  fi
  printf '%s\n' "$resolved"
}

check_digest() {
  local ref="$1" expected="$2" label="$3" path actual
  path="$(resolve_ref "$ref" "$label ref")" || return 1
  actual="sha256:$(shasum -a 256 "$path" | awk '{print $1}')"
  if [[ "$expected" =~ ^sha256:[0-9a-f]{64}$ && "$actual" == "$expected" ]]; then
    pass "$label digest matches"
  else
    fail "$label digest mismatch: expected $expected current $actual"
  fi
}

require_candidate_id_exists() {
  local report="$1" candidate_id="$2" label="$3"
  yq -e ".candidates[]? | select(.candidate_id == \"$candidate_id\")" "$report" >/dev/null 2>&1 \
    && pass "$label candidate exists" \
    || fail "$label candidate missing from closeout-worktree report: $candidate_id"
}

jq_receipt_report() {
  local report="$1" filter="$2"
  jq -r --slurpfile report <(yq -o=json '.' "$report") "$filter" <(yq -o=json '.' "$RECEIPT_PATH") 2>/dev/null || true
}

need_tool jq
need_tool yq

echo "== Proposal Packet Delivery Order Override Receipt Validation =="

if [[ -f "$SCHEMA_PATH" ]]; then
  pass "order override schema exists"
else
  fail "order override schema missing: $SCHEMA_PATH"
fi

if jq -e '.' "$SCHEMA_PATH" >/dev/null 2>&1; then
  pass "order override schema JSON parses"
else
  fail "order override schema JSON does not parse"
fi

for token in \
  '"proposal-packet-delivery-order-override-receipt-v1"' \
  '"partition-clean-for-archive-readiness"' \
  '"closeout_worktree_report_ref"' \
  '"lifecycle_interaction_return_ref"' \
  '"remaining_dirty_paths_exactly_partitioned"' \
  '"branch_no_pr_change_closeout_remains_owner"'; do
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

  require_value '.schema_version' 'proposal-packet-delivery-order-override-receipt-v1' "receipt schema_version"
  require_scalar '.receipt_id' "receipt_id"
  require_scalar '.emitted_at' "emitted_at"
  require_scalar '.target_packet.path' "target packet path"
  require_scalar '.target_packet.accepted_review_digest' "target packet accepted review digest"
  require_scalar '.run_binding.delivery_run_id' "delivery run id"
  require_scalar '.run_binding.profile_id' "profile id"
  require_value '.requested_order.canonical_order_ref' 'archive-before-branch-no-pr-change-closeout' "canonical order ref"
  require_value '.requested_order.requested_order_ref' 'partition-clean-archive-readiness-before-branch-no-pr-change-closeout' "requested order ref"
  require_bool '.requested_order.operator_requested_alternative_order' 'true' "operator requested alternative order"
  require_scalar '.requested_order.rationale' "requested order rationale"
  require_bool '.efficiency_risk_acknowledgement.acknowledged' 'true' "efficiency risk acknowledged"
  require_bool '.revocation.revoked' 'false' "revocation state"
  require_value '.partition_clean_archive_readiness.mode' 'partition-clean-for-archive-readiness' "partition clean mode"

  for key in \
    remaining_dirty_paths_exactly_partitioned \
    no_arbitrary_foreign_user_owned_or_unsafe_residue_masked \
    child_packet_closeout_authority_preserved \
    closeout_worktree_report_validated \
    lifecycle_interaction_return_validated \
    closeout_worktree_non_mutating \
    branch_no_pr_change_closeout_remains_owner; do
    require_bool ".partition_clean_archive_readiness.$key" 'true' "partition_clean_archive_readiness.$key"
  done

  for key in \
    closeout_worktree_cleaned_claim \
    git_clean_claim \
    archive_authorization_claim \
    hosted_landing_claim \
    branch_cleanup_claim \
    repo_hygiene_cleanup_claim \
    cleaned_outcome_claim; do
    require_bool ".partition_clean_archive_readiness.$key" 'false' "partition_clean_archive_readiness.$key"
  done

  for key in \
    retained_evidence_only; do
    require_bool ".authority_boundary.$key" 'true' "authority_boundary.$key"
  done
  for key in \
    authorizes_delivery \
    authorizes_child_receipt_replacement \
    authorizes_archive \
    authorizes_git_mutation \
    authorizes_hosted_landing \
    authorizes_branch_cleanup \
    authorizes_repo_hygiene_cleanup \
    authorizes_cleaned_claim \
    authorizes_cleanup; do
    require_bool ".authority_boundary.$key" 'false' "authority_boundary.$key"
  done

  require_value '.non_authority_classification.proposal_local_files' 'non-authority' "proposal local files non-authority"
  require_value '.non_authority_classification.generated_prompts' 'non-authority' "generated prompts non-authority"
  require_value '.non_authority_classification.generated_outputs' 'derived-only-non-authority' "generated outputs non-authority"
  require_value '.non_authority_classification.dashboards' 'non-authority' "dashboards non-authority"
  require_value '.non_authority_classification.chat_or_model_memory' 'non-authority' "chat/model memory non-authority"

  report_ref="$(scalar '.partition_clean_archive_readiness.closeout_worktree_report_ref')"
  report_digest="$(scalar '.partition_clean_archive_readiness.closeout_worktree_report_digest')"
  return_ref="$(scalar '.partition_clean_archive_readiness.lifecycle_interaction_return_ref')"
  return_digest="$(scalar '.partition_clean_archive_readiness.lifecycle_interaction_return_digest')"
  classifier_ref="$(scalar '.partition_clean_archive_readiness.source_worktree_hygiene_classifier_ref')"
  classifier_digest="$(scalar '.partition_clean_archive_readiness.source_worktree_hygiene_classifier_digest')"
  check_digest "$report_ref" "$report_digest" "closeout-worktree report"
  check_digest "$return_ref" "$return_digest" "lifecycle interaction return"
  check_digest "$classifier_ref" "$classifier_digest" "source worktree hygiene classifier"

  report_path="$(resolve_ref "$report_ref" "closeout-worktree report")" || report_path=""
  return_path="$(resolve_ref "$return_ref" "lifecycle interaction return")" || return_path=""
  if [[ -n "$report_path" ]]; then
    if bash "$WORKTREE_VALIDATOR" --report "$report_path" >/dev/null; then
      pass "closeout-worktree report validates"
    else
      fail "closeout-worktree report must validate"
    fi
  fi
  if [[ -n "$return_path" ]]; then
    if bash "$INTERACTION_VALIDATOR" --return "$return_path" >/dev/null; then
      pass "lifecycle interaction return validates"
    else
      fail "lifecycle interaction return must validate"
    fi
  fi

  if [[ -n "$return_path" ]]; then
    ref_in_return="$(scalar_file "$return_path" '.return_evidence_refs[]? | select(.schema_version == "closeout-worktree-report-v1") | .ref' | head -n 1)"
    digest_in_return="$(scalar_file "$return_path" '.return_evidence_refs[]? | select(.schema_version == "closeout-worktree-report-v1") | .digest' | head -n 1)"
    [[ "$ref_in_return" == "$report_ref" ]] && pass "return cites closeout-worktree report ref" || fail "return must cite closeout-worktree report ref"
    [[ "$digest_in_return" == "$report_digest" ]] && pass "return cites closeout-worktree report digest" || fail "return must cite closeout-worktree report digest"
    [[ "$(scalar_file "$return_path" '.outcome.non_mutating')" == "true" ]] && pass "return outcome non-mutating" || fail "return outcome must be non-mutating"
    [[ "$(scalar_file "$return_path" '.outcome.cleaned_claim')" == "false" ]] && pass "return does not claim cleaned" || fail "return must not claim cleaned"
  fi

  if [[ -n "$report_path" ]]; then
    [[ "$(scalar_file "$report_path" '.read_only_classification')" == "true" ]] && pass "wrapper read-only classification" || fail "wrapper report must be read-only classification"
    [[ "$(scalar_file "$report_path" '.detection_is_deletion_authority')" == "false" ]] && pass "wrapper detection is not deletion authority" || fail "wrapper detection must not be deletion authority"
    [[ "$(scalar_file "$report_path" '.direct_material_actions_performed')" == "false" ]] && pass "wrapper performed no material actions" || fail "wrapper must not perform material actions"
    [[ "$(scalar_file "$report_path" '.repo_hygiene_cleanup_actions_performed')" != "true" ]] && pass "wrapper performed no repo hygiene cleanup" || fail "wrapper must not perform repo hygiene cleanup"

    delivery_candidate="$(scalar '.partition_clean_archive_readiness.delivery_change_candidate_id')"
    packet_candidate="$(scalar '.partition_clean_archive_readiness.packet_archive_candidate_id')"
    retained_candidate="$(scalar '.partition_clean_archive_readiness.retained_local_evidence_candidate_id')"
    require_candidate_id_exists "$report_path" "$delivery_candidate" "delivery change"
    require_candidate_id_exists "$report_path" "$packet_candidate" "packet archive"
    require_candidate_id_exists "$report_path" "$retained_candidate" "retained local evidence"

    unknown_candidates="$(jq_receipt_report "$report_path" '
      (.partition_clean_archive_readiness.authorized_candidate_ids // []) as $authorized
      | ($report[0].candidates // [])[]?.candidate_id
      | . as $id
      | select(($authorized | index($id) | not))
    ')"
    if [[ -z "$unknown_candidates" ]]; then
      pass "all wrapper candidates are authorized by override"
    else
      fail "wrapper contains candidates not authorized by override: $unknown_candidates"
    fi

    extra_authorized_candidates="$(jq_receipt_report "$report_path" '
      ($report[0].candidates // [] | map(.candidate_id)) as $candidate_ids
      | (.partition_clean_archive_readiness.authorized_candidate_ids // [])[]
      | . as $id
      | select(($candidate_ids | index($id) | not))
    ')"
    if [[ -z "$extra_authorized_candidates" ]]; then
      pass "override authorized candidate list exactly matches wrapper candidates"
    else
      fail "override authorizes candidates not present in wrapper report: $extra_authorized_candidates"
    fi

    disallowed_classes="$(jq_receipt_report "$report_path" '
      (.partition_clean_archive_readiness.allowed_residue_routing_classes // []) as $allowed
      | ($report[0].candidates // [])[]?
      | select(.residue_routing_class as $class | ($allowed | index($class) | not))
      | .candidate_id + ":" + .residue_routing_class
    ')"
    if [[ -z "$disallowed_classes" ]]; then
      pass "wrapper routing classes are allowed"
    else
      fail "wrapper has disallowed routing classes: $disallowed_classes"
    fi

    disallowed_states="$(jq_receipt_report "$report_path" '
      (.partition_clean_archive_readiness.allowed_final_states // []) as $allowed
      | $report[0].final_candidate_dispositions
      | to_entries[]
      | select(.value.state as $state | ($allowed | index($state) | not))
      | .key + ":" + .value.state
    ')"
    if [[ -z "$disallowed_states" ]]; then
      pass "wrapper final candidate states are allowed"
    else
      fail "wrapper has disallowed final states: $disallowed_states"
    fi

    terminal_state="$(scalar_file "$report_path" '.worktree_terminal_state')"
    [[ "$terminal_state" == "nonterminal" ]] && pass "wrapper terminal state is nonterminal" || fail "wrapper terminal state must remain nonterminal for partition-clean archive readiness"

    unsafe_count="$(yq -r '[.candidates[]? | select(.residue_routing_class == "unsafe" or .residue_routing_class == "ambiguous")] | length' "$report_path" 2>/dev/null || echo 1)"
    [[ "$unsafe_count" == "0" ]] && pass "wrapper masks no unsafe or ambiguous residue" || fail "wrapper must not retain unsafe or ambiguous residue"

    foreign_without_child_auth="$(yq -r '
      [.candidates[]?
        | select(.residue_routing_class == "foreign_manual_review")
        | select((.proposal_program_handoff_authorization.child_closeout_authority_preserved // false) != true)
      ] | length
    ' "$report_path" 2>/dev/null || echo 1)"
    [[ "$foreign_without_child_auth" == "0" ]] && pass "foreign residue preserves child closeout authority" || fail "foreign/manual residue must preserve child closeout authority"

    bad_blocker_count="$(DELIVERY_CANDIDATE="$delivery_candidate" yq -r '[.blockers[]? | select(.candidate_id != strenv(DELIVERY_CANDIDATE))] | length' "$report_path" 2>/dev/null || echo 1)"
    [[ "$bad_blocker_count" == "0" ]] && pass "only delivery change candidate may remain deferred or blocked" || fail "only the delivery change candidate may carry partition-clean blocker evidence"
  fi
fi

echo "Validation summary: errors=$errors"
[[ "$errors" -eq 0 ]]

#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
FRAMEWORK_DIR="$(cd -- "$SCRIPT_DIR/../../../../" && pwd)"
ROOT_DIR="$(cd -- "$FRAMEWORK_DIR/../.." && pwd)"
SCHEMA_PATH="$FRAMEWORK_DIR/product/contracts/proposal-packet-terminal-closeout-receipt-v1.schema.json"
ORDER_OVERRIDE_VALIDATOR="$SCRIPT_DIR/validate-proposal-packet-delivery-order-override-receipt.sh"
RECEIPT_PATH=""
errors=0

usage() {
  cat <<'USAGE'
usage:
  validate-proposal-packet-terminal-closeout-receipt.sh [--receipt <path>]
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

require_pass_validation() {
  local base="$1" label="$2"
  require_scalar "$base.validation_ref" "$label validation_ref"
  [[ "$(scalar "$base.verdict")" == "pass" ]] && pass "$label verdict pass" || fail "$label verdict must be pass"
}

require_state() {
  local state_id="$1"
  yq -e ".state_ledger[]? | select(.state_id == \"$state_id\")" "$RECEIPT_PATH" >/dev/null 2>&1 \
    && pass "state ledger includes $state_id" \
    || fail "state ledger missing $state_id"
}

require_state_materialization() {
  local state_id="$1" outputs verdict
  outputs="$(yq -r ".state_ledger[]? | select(.state_id == \"$state_id\") | .output_evidence_refs[]?" "$RECEIPT_PATH" 2>/dev/null || true)"
  verdict="$(yq -r ".state_ledger[]? | select(.state_id == \"$state_id\") | .state_verdict // \"\"" "$RECEIPT_PATH" 2>/dev/null || true)"
  grep -Fq "reports/$state_id-report.md" <<<"$outputs" \
    && pass "state $state_id report materialized" \
    || fail "state $state_id must reference reports/$state_id-report.md"
  grep -Fq "stages/$state_id/outcome.json" <<<"$outputs" \
    && pass "state $state_id outcome materialized" \
    || fail "state $state_id must reference stages/$state_id/outcome.json"
  if [[ "$verdict" == "pass" ]] && grep -Eiq 'timeout|timed-out|executor-timeout' <<<"$outputs"; then
    fail "state $state_id cannot report timeout evidence as pass"
  fi
}

require_suffix() {
  local path_expr="$1" suffix="$2" label="$3" value
  value="$(scalar "$path_expr")"
  [[ "$value" == *"$suffix" ]] && pass "$label has expected receipt suffix" || fail "$label must end with $suffix"
}

resolve_repo_ref() {
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

check_repo_ref_digest() {
  local ref="$1" expected="$2" label="$3" path actual
  path="$(resolve_repo_ref "$ref" "$label")" || return 1
  actual="sha256:$(shasum -a 256 "$path" | awk '{print $1}')"
  if [[ "$expected" =~ ^sha256:[0-9a-f]{64}$ && "$actual" == "$expected" ]]; then
    pass "$label digest matches"
  else
    fail "$label digest mismatch: expected $expected current $actual"
    return 1
  fi
}

validate_partition_clean_archive_readiness() {
  if [[ "$(scalar '.partition_clean_archive_readiness.enabled')" != "true" ]]; then
    return 1
  fi
  [[ "$(scalar '.partition_clean_archive_readiness.mode')" == "partition-clean-for-archive-readiness" ]] \
    && pass "partition-clean archive readiness mode" \
    || { fail "partition_clean_archive_readiness.mode must be partition-clean-for-archive-readiness"; return 1; }
  for key in does_not_authorize_archive does_not_authorize_git_mutation does_not_authorize_cleaned_claim; do
    [[ "$(scalar ".partition_clean_archive_readiness.$key")" == "true" ]] \
      && pass "partition_clean_archive_readiness.$key" \
      || { fail "partition_clean_archive_readiness.$key must be true"; return 1; }
  done

  local override_ref override_digest override_path report_ref return_ref
  override_ref="$(scalar '.partition_clean_archive_readiness.order_override_receipt_ref')"
  override_digest="$(scalar '.partition_clean_archive_readiness.order_override_receipt_digest')"
  report_ref="$(scalar '.partition_clean_archive_readiness.closeout_worktree_report_ref')"
  return_ref="$(scalar '.partition_clean_archive_readiness.lifecycle_interaction_return_ref')"
  check_repo_ref_digest "$override_ref" "$override_digest" "partition-clean order override receipt" || return 1
  override_path="$(resolve_repo_ref "$override_ref" "partition-clean order override receipt")" || return 1
  if bash "$ORDER_OVERRIDE_VALIDATOR" --receipt "$override_path" >/dev/null; then
    pass "partition-clean order override receipt validates"
  else
    fail "partition-clean order override receipt must validate"
    return 1
  fi
  [[ "$(yq -r '.partition_clean_archive_readiness.closeout_worktree_report_ref' "$override_path" 2>/dev/null || true)" == "$report_ref" ]] \
    && pass "partition-clean report ref matches override" \
    || { fail "partition-clean report ref must match override"; return 1; }
  [[ "$(yq -r '.partition_clean_archive_readiness.lifecycle_interaction_return_ref' "$override_path" 2>/dev/null || true)" == "$return_ref" ]] \
    && pass "partition-clean return ref matches override" \
    || { fail "partition-clean return ref must match override"; return 1; }
}

reject_authority_substitution() {
  local path_expr="$1" label="$2" value
  value="$(scalar "$path_expr")"
  if [[ "$value" == .octon/generated/* || "$value" == *"/generated/"* ]]; then
    fail "$label must not use generated output as authority"
  fi
  if [[ "$value" == *"/support/proposal-closeout.md" || "$value" == *"/support/executable-implementation-prompt.md" ]]; then
    fail "$label must not use proposal-local prose summary or generated prompt as child receipt authority"
  fi
}

require_publication_validators_pass() {
  local count index verdict fresh
  count="$(yq -r '(.publication_freshness.validators // []) | length' "$RECEIPT_PATH" 2>/dev/null || echo 0)"
  if [[ "$count" -lt 1 ]]; then
    fail "publication_freshness.validators must be non-empty"
    return
  fi
  pass "publication_freshness.validators non-empty"
  for ((index=0; index<count; index++)); do
    require_scalar ".publication_freshness.validators[$index].validator_ref" "publication validator[$index] validator_ref"
    require_scalar ".publication_freshness.validators[$index].evidence_ref" "publication validator[$index] evidence_ref"
    verdict="$(scalar ".publication_freshness.validators[$index].verdict")"
    fresh="$(scalar ".publication_freshness.validators[$index].fresh")"
    [[ "$verdict" == "pass" ]] && pass "publication validator[$index] verdict pass" || fail "publication validator[$index] verdict must be pass"
    [[ "$fresh" == "true" ]] && pass "publication validator[$index] fresh" || fail "publication validator[$index] must be fresh"
  done
}

need_tool jq
need_tool yq

echo "== Proposal Packet Terminal Closeout Receipt Validation =="

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
  '"proposal-packet-terminal-closeout-receipt-v1"' \
  '"terminal_verdict"' \
  '"archive_ready"' \
  '"archive-ready"' \
  '"blocked"' \
  '"state_ledger"' \
  '"target_owned_evidence_policy"' \
  '"partition_clean_archive_readiness"'; do
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

  [[ "$(scalar '.schema_version')" == "proposal-packet-terminal-closeout-receipt-v1" ]] \
    && pass "receipt schema_version correct" \
    || fail "receipt schema_version must be proposal-packet-terminal-closeout-receipt-v1"

  require_scalar '.terminal_run_id' "terminal_run_id"
  require_scalar '.terminalized_at' "terminalized_at"
  require_scalar '.packet.proposal_id' "packet.proposal_id"
  require_scalar '.packet.path' "packet.path"
  require_scalar '.packet.proposal_kind' "packet.proposal_kind"
  require_scalar '.packet.status' "packet.status"
  require_scalar '.target_outcome' "target_outcome"
  require_scalar '.archive_ready' "archive_ready"
  require_scalar '.profile.profile_ref' "profile.profile_ref"
  require_scalar '.profile.profile_digest' "profile.profile_digest"
  require_scalar '.profile.profile_validation_evidence_ref' "profile.profile_validation_evidence_ref"
  [[ "$(scalar '.profile.profile_ref')" == .octon/state/evidence/runs/workflows/*/profile.yml ]] \
    && pass "profile ref is workflow-owned" \
    || fail "profile.profile_ref must point to workflow-owned terminal closeout profile evidence"

  terminal_verdict="$(scalar '.terminal_verdict')"
  case "$terminal_verdict" in
    archive-ready|blocked)
      pass "terminal_verdict allowed"
      ;;
    *)
      fail "terminal_verdict must be archive-ready or blocked"
      ;;
  esac

  state_count="$(yq -r '(.state_ledger // []) | length' "$RECEIPT_PATH" 2>/dev/null || echo 0)"
  [[ "$state_count" -ge 10 ]] && pass "state ledger has at least ten entries" || fail "state ledger must have at least ten entries"
  for state_id in \
    bind-profile \
    verify-durable-implementation-state \
    verify-implementation-conformance \
    verify-post-implementation-drift \
    validate-publication-freshness \
    classify-repo-hygiene \
    classify-worktree-hygiene \
    run-evidence-only-reviews \
    resolve-git-github-route \
    emit-terminal-receipt; do
    require_state "$state_id"
    require_state_materialization "$state_id"
  done

  durable_count="$(yq -r '(.durable_implementation_state_evidence_refs // []) | length' "$RECEIPT_PATH" 2>/dev/null || echo 0)"
  [[ "$durable_count" -gt 0 ]] && pass "durable implementation state evidence refs non-empty" || fail "durable implementation state evidence refs required"

  require_scalar '.implementation.conformance_receipt_ref' "implementation conformance receipt ref"
  require_scalar '.implementation.conformance_validator_ref' "implementation conformance validator ref"
  require_scalar '.implementation.post_implementation_drift_receipt_ref' "post-implementation drift receipt ref"
  require_scalar '.implementation.post_implementation_drift_validator_ref' "post-implementation drift validator ref"
  require_suffix '.implementation.conformance_receipt_ref' '/support/implementation-conformance-review.md' "implementation conformance receipt ref"
  require_suffix '.implementation.post_implementation_drift_receipt_ref' '/support/post-implementation-drift-churn-review.md' "post-implementation drift receipt ref"
  reject_authority_substitution '.implementation.conformance_receipt_ref' "implementation conformance receipt ref"
  reject_authority_substitution '.implementation.post_implementation_drift_receipt_ref' "post-implementation drift receipt ref"

  require_bool '.publication_freshness.direct_generated_output_edit_used' "false" "direct generated output edit used"
  require_scalar '.generated_input_non_authority.validation_ref' "generated input non-authority validation ref"
  reject_authority_substitution '.generated_input_non_authority.validation_ref' "generated input non-authority validation ref"
  for key in \
    proposal_inputs_non_authority \
    generated_outputs_non_authority \
    generated_prompts_non_authority \
    host_state_non_authority \
    chat_state_non_authority \
    tool_state_non_authority \
    model_memory_non_authority; do
    require_bool ".generated_input_non_authority.$key" "true" "generated_input_non_authority.$key"
  done

  require_scalar '.repo_hygiene.classification_ref' "repo hygiene classification ref"
  require_bool '.repo_hygiene.unauthorized_deletion_performed' "false" "repo hygiene unauthorized deletion"
  if [[ "$(scalar '.repo_hygiene.cleanup_performed')" == "true" ]]; then
    auth_count="$(yq -r '(.repo_hygiene.cleanup_authorization_refs // []) | length' "$RECEIPT_PATH" 2>/dev/null || echo 0)"
    [[ "$auth_count" -gt 0 ]] && pass "cleanup authorization refs present" || fail "cleanup performed requires cleanup authorization refs"
  fi

  require_scalar '.worktree_hygiene.classification_ref' "worktree hygiene classification ref"
  require_scalar '.worktree_hygiene.verdict' "worktree hygiene verdict"
  require_scalar '.worktree_hygiene.foreign_or_ambiguous_count' "worktree foreign or ambiguous count"
  require_scalar '.worktree_hygiene.dirty_worktree' "worktree dirty flag"
  retained_fixture_path_count="$(scalar '.worktree_hygiene.retained_fixture_path_count // 0')"
  if [[ "$retained_fixture_path_count" =~ ^[0-9]+$ ]]; then
    pass "worktree retained fixture path count is numeric"
  else
    fail "worktree_hygiene.retained_fixture_path_count must be numeric when present"
  fi
  fixture_ref_count="$(yq -r '(.worktree_hygiene.fixture_retention_refs // []) | length' "$RECEIPT_PATH" 2>/dev/null || echo 0)"
  for ((index=0; index<fixture_ref_count; index++)); do
    fixture_ref="$(scalar ".worktree_hygiene.fixture_retention_refs[$index]")"
    [[ "$fixture_ref" == .octon/state/evidence/runs/workflows/*/retention-receipt.yml ]] \
      && pass "fixture retention ref[$index] is workflow-owned" \
      || fail "fixture_retention_refs[$index] must point to workflow-owned retention-receipt.yml"
    reject_authority_substitution ".worktree_hygiene.fixture_retention_refs[$index]" "fixture retention ref[$index]"
  done

  for key in \
    post_integration_architecture_review \
    packet_terminal_evaluator \
    lifecycle_postmortem; do
    require_scalar ".evidence_only_reviews.${key}_ref" "evidence-only $key ref"
    [[ "$(scalar ".evidence_only_reviews.${key}_authority")" == "evidence-only" ]] \
      && pass "evidence-only $key authority" \
      || fail "$key authority must be evidence-only"
  done

  require_bool '.git_github_route.mutation_delegated' "true" "Git/GitHub mutation delegated"
  if [[ "$(scalar '.git_github_route.branch_no_pr')" == "true" ]]; then
    [[ "$(scalar '.git_github_route.exact_sha_checks_ref')" != "not-applicable" ]] \
      && require_scalar '.git_github_route.exact_sha_checks_ref' "exact SHA checks ref" \
      || fail "branch-no-pr route requires exact SHA checks ref"
    [[ "$(scalar '.git_github_route.landing_authorization_ref')" != "not-applicable" ]] \
      && require_scalar '.git_github_route.landing_authorization_ref' "landing authorization ref" \
      || fail "branch-no-pr route requires landing authorization ref"
  fi
  if [[ "$(scalar '.git_github_route.branch_cleanup_required')" == "true" ]]; then
    [[ "$(scalar '.git_github_route.branch_cleanup_authorization_ref')" != "not-applicable" ]] \
      && require_scalar '.git_github_route.branch_cleanup_authorization_ref' "branch cleanup authorization ref" \
      || fail "branch cleanup requires branch cleanup authorization ref"
  fi

  [[ "$(scalar '.archive_boundary.archive_owner_ref')" == ".octon/framework/orchestration/runtime/workflows/meta/archive-proposal/workflow.yml" ]] \
    && pass "archive owner ref correct" \
    || fail "archive owner ref must point to archive-proposal workflow"
  require_bool '.archive_boundary.relocation_performed' "false" "archive relocation performed"
  require_bool '.target_owned_evidence_policy.cites_target_owned_evidence' "true" "target-owned evidence cited"
  require_bool '.target_owned_evidence_policy.aggregate_receipt_replaces_target_owned_receipts' "false" "aggregate receipt replaces target-owned receipts"
  require_bool '.expected_no_new_evidence_loop' "true" "expected no new evidence loop"

  [[ "$(scalar '.non_authority_declarations.proposal_inputs')" == "non-authority" ]] \
    && pass "proposal inputs non-authority declaration" \
    || fail "proposal inputs must be non-authority"
  [[ "$(scalar '.non_authority_declarations.generated_outputs')" == "derived-only-non-authority" ]] \
    && pass "generated outputs non-authority declaration" \
    || fail "generated outputs must be derived-only-non-authority"
  for key in generated_prompts host_state dashboards chat tool_state model_memory; do
    [[ "$(scalar ".non_authority_declarations.$key")" == "non-authority" ]] \
      && pass "$key non-authority declaration" \
      || fail "$key must be non-authority"
  done

  if [[ "$terminal_verdict" == "archive-ready" ]]; then
    [[ "$(scalar '.archive_ready')" == "yes" ]] && pass "archive_ready yes" || fail "archive-ready verdict requires archive_ready yes"
    require_bool '.implementation.conformance_fresh' "true" "implementation conformance freshness"
    require_bool '.implementation.post_implementation_drift_fresh' "true" "post-implementation drift freshness"
    require_publication_validators_pass
    require_pass_validation '.run_health' "run health"
    require_pass_validation '.capability_publication' "capability publication"
    require_pass_validation '.extension_publication' "extension publication"
    if [[ "$(scalar '.worktree_hygiene.verdict')" == "pass" \
      && "$(scalar '.worktree_hygiene.foreign_or_ambiguous_count')" == "0" \
      && "$(scalar '.worktree_hygiene.dirty_worktree')" == "false" ]]; then
      pass "worktree hygiene strict archive-ready pass"
    elif validate_partition_clean_archive_readiness; then
      pass "partition-clean archive readiness accepted"
    else
      fail "archive-ready requires strict worktree hygiene pass or validating partition-clean archive readiness"
    fi
    [[ "$(scalar '.blocker.class')" == "none" ]] && pass "archive-ready blocker class none" || fail "archive-ready requires blocker.class none"
    if yq -r '.retained_evidence_inventory[]?' "$RECEIPT_PATH" 2>/dev/null | grep -Eiq '(^|/)cleaned($|[-./])'; then
      fail "archive-ready terminal receipt must not claim cleaned before downstream closeout proof"
    fi
  elif [[ "$terminal_verdict" == "blocked" ]]; then
    [[ "$(scalar '.archive_ready')" == "no" ]] && pass "archive_ready no" || fail "blocked verdict requires archive_ready no"
    [[ "$(scalar '.blocker.class')" != "none" ]] && require_scalar '.blocker.class' "blocked blocker class" || fail "blocked receipt requires blocker.class other than none"
    require_scalar '.blocker.detail' "blocked blocker detail"
    require_scalar '.blocker.failing_evidence_ref' "blocked failing evidence ref"
    require_scalar '.blocker.next_canonical_route' "blocked next canonical route"
  fi
fi

echo "Validation summary: errors=$errors"
[[ "$errors" -eq 0 ]]

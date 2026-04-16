#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../../../../../.." && pwd)"
PACK_ROOT="$REPO_ROOT/.octon/inputs/additive/extensions/octon-decision-drafter"

pass_count=0
fail_count=0

pass() { echo "PASS: $1"; pass_count=$((pass_count + 1)); }
fail() { echo "FAIL: $1" >&2; fail_count=$((fail_count + 1)); }

assert_success() {
  local name="$1"
  shift
  if "$@"; then
    pass "$name"
  else
    fail "$name"
  fi
}

case_shared_contract_labels_every_output_non_authoritative() {
  grep -Fq 'Draft / Non-Authoritative' "$PACK_ROOT/prompts/shared/non-authoritative-draft-contract.md"
  grep -Fq 'must never create or update canonical control or evidence files automatically' \
    "$PACK_ROOT/prompts/shared/non-authoritative-draft-contract.md"
}

case_diff_contract_requires_exactly_one_diff_source() {
  grep -Fq 'Exactly one of:' "$PACK_ROOT/prompts/shared/diff-evidence-input-contract.md"
  grep -Fq 'If both diff inputs are present, fail closed.' "$PACK_ROOT/prompts/shared/diff-evidence-input-contract.md"
  grep -Fq 'If neither diff input is present, fail closed.' "$PACK_ROOT/prompts/shared/diff-evidence-input-contract.md"
}

case_output_contract_blocks_forbidden_patch_targets() {
  grep -Fq 'patch-suggestion' "$PACK_ROOT/prompts/shared/draft-output-contract.md"
  grep -Fq 'Allowed only when `draft_target_path` is explicit.' \
    "$PACK_ROOT/prompts/shared/draft-output-contract.md"
  grep -Fq 'Never target discovery indexes, retained receipts, rollback-control files, or generated outputs.' \
    "$PACK_ROOT/prompts/shared/draft-output-contract.md"
}

case_artifact_contract_uses_generic_skill_roots_only() {
  grep -Fq '/.octon/state/control/skills/checkpoints/octon-decision-drafter/<run-id>/' \
    "$PACK_ROOT/prompts/shared/draft-artifact-contract.md"
  grep -Fq '/.octon/state/evidence/runs/skills/octon-decision-drafter/<run-id>.md' \
    "$PACK_ROOT/skills/octon-decision-drafter/references/io-contract.md"
}

case_change_receipt_contract_reuses_retained_receipts() {
  grep -Fq 'cites existing retained receipts and evidence' \
    "$PACK_ROOT/prompts/change-receipt/README.md"
  grep -Fq 'never create a new canonical receipt surface' \
    "$PACK_ROOT/prompts/change-receipt/references/bundle-contract.md"
  grep -Fq 'Never materialize this draft under retained receipt roots' \
    "$PACK_ROOT/prompts/change-receipt/stages/03-draft-change-receipt.md"
}

case_compatibility_profile_omits_proposal_validators() {
  ! grep -Fq 'validate-architecture-proposal.sh' "$PACK_ROOT/validation/compatibility.yml"
  ! grep -Fq 'validate-policy-proposal.sh' "$PACK_ROOT/validation/compatibility.yml"
  ! grep -Fq 'validate-migration-proposal.sh' "$PACK_ROOT/validation/compatibility.yml"
}

main() {
  assert_success "shared contract marks outputs as Draft / Non-Authoritative" case_shared_contract_labels_every_output_non_authoritative
  assert_success "diff contract requires exactly one diff source" case_diff_contract_requires_exactly_one_diff_source
  assert_success "output contract blocks forbidden patch targets" case_output_contract_blocks_forbidden_patch_targets
  assert_success "artifact contract uses generic skill roots only" case_artifact_contract_uses_generic_skill_roots_only
  assert_success "change-receipt bundle reuses retained receipts instead of minting new ones" case_change_receipt_contract_reuses_retained_receipts
  assert_success "compatibility profile omits proposal validators" case_compatibility_profile_omits_proposal_validators

  echo
  echo "Passed: $pass_count"
  echo "Failed: $fail_count"
  [[ "$fail_count" -eq 0 ]]
}

main "$@"

#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
ROOT_DIR="${OCTON_ROOT_DIR:-$(cd -- "$OCTON_DIR/.." && pwd)}"
SUPPORT_TARGETS="$OCTON_DIR/instance/governance/support-targets.yml"
source "$SCRIPT_DIR/validator-result-common.sh"
PROOF_EXECUTION_CONTRACT="$(pick_existing_file "$OCTON_DIR/framework/engine/runtime/spec/proof-bundle-execution-v1.md" || true)"

errors=0
fail() { echo "[ERROR] $1"; errors=$((errors + 1)); }
pass() { echo "[OK] $1"; }

has_execution_or_replay_evidence() {
  local file="$1"
  local execution_mode evaluator_version

  execution_mode="$(yq -r '.execution.mode // ""' "$file" 2>/dev/null || true)"
  evaluator_version="$(yq -r '.evaluator_version // ""' "$file" 2>/dev/null || true)"

  if [[ -n "$execution_mode" && "$execution_mode" != "null" ]]; then
    case "$execution_mode" in
      command|command_only|hybrid)
        yq -e '.execution.command_ref // .command_or_evaluator' "$file" >/dev/null 2>&1 \
          && pass "execution command declared for $file" \
          || fail "execution command missing for $file"
        ;;
    esac

    case "$execution_mode" in
      replay|replay_only|hybrid)
        yq -e '.execution.replay_ref // .scenario_evidence.replay_refs[0] // .scenario_evidence.lab_refs[0]' "$file" >/dev/null 2>&1 \
          && pass "replay evidence declared for $file" \
          || fail "replay evidence missing for $file"
        ;;
    esac

    return 0
  fi

  if [[ "$evaluator_version" == *"executable"* || "$evaluator_version" == *"replay"* ]]; then
    if yq -e '.scenario_evidence.replay_refs[0] // .scenario_evidence.lab_refs[0]' "$file" >/dev/null 2>&1; then
      validator_result_add_limitation "$file relies on evaluator_version plus scenario replay/lab refs without an explicit execution block"
      return 0
    fi
  fi

  return 1
}

reset_validator_result_metadata
validator_result_add_evidence \
  ".octon/instance/governance/support-targets.yml"
validator_result_add_runtime_test \
  ".octon/framework/assurance/runtime/_ops/tests/test-proof-bundle-execution.sh"
validator_result_add_negative_control \
  "missing-proof-execution-or-replay-evidence-denies"
validator_result_add_schema_version \
  "support-target-proof-bundle-v1" \
  "support-target-proof-bundle-v2"
[[ -n "${PROOF_EXECUTION_CONTRACT:-}" ]] && validator_result_add_contract "${PROOF_EXECUTION_CONTRACT#$ROOT_DIR/}"

echo "== Proof Bundle Executability Validation =="

while IFS= read -r ref; do
  [[ -n "$ref" ]] || continue
  file="$ROOT_DIR/$ref"
  if [[ ! -f "$file" ]]; then
    fail "missing proof bundle: $ref"
    continue
  fi
  yq -e '.proof_planes | length > 0' "$file" >/dev/null 2>&1 \
    && pass "proof planes present for $ref" \
    || fail "proof planes missing for $ref"
  yq -e '.scenario_evidence.representative_run_refs | length > 0' "$file" >/dev/null 2>&1 \
    && pass "representative run refs present for $ref" \
    || fail "representative run refs missing for $ref"
  yq -e '.scenario_evidence.negative_control_refs | length > 0' "$file" >/dev/null 2>&1 \
    && pass "negative control refs present for $ref" \
    || fail "negative control refs missing for $ref"
  yq -e '.disclosure_evidence.run_card_refs | length > 0' "$file" >/dev/null 2>&1 \
    && pass "run card refs present for $ref" \
    || fail "run card refs missing for $ref"
  yq -e '.freshness.reviewed_at and .freshness.review_due_at and .sufficiency.status' "$file" >/dev/null 2>&1 \
    && pass "freshness and sufficiency present for $ref" \
    || fail "freshness or sufficiency missing for $ref"
  yq -e '.command_or_evaluator and .evaluator_version and .result' "$file" >/dev/null 2>&1 \
    && pass "evaluator identity and result present for $ref" \
    || fail "evaluator identity or result missing for $ref"
  yq -e '.input_digests | length > 0' "$file" >/dev/null 2>&1 \
    && pass "input digests present for $ref" \
    || fail "input digests missing for $ref"
  yq -e '.output_digests | length > 0' "$file" >/dev/null 2>&1 \
    && pass "output digests present for $ref" \
    || fail "output digests missing for $ref"
  yq -e '.pass_fail_criteria | length > 0' "$file" >/dev/null 2>&1 \
    && pass "pass/fail criteria present for $ref" \
    || fail "pass/fail criteria missing for $ref"
  yq -e '.receipt_refs | length > 0' "$file" >/dev/null 2>&1 \
    && pass "receipt refs present for $ref" \
    || fail "receipt refs missing for $ref"

  case "$(yq -r '.schema_version // ""' "$file")" in
    support-target-proof-bundle-v1|support-target-proof-bundle-v2)
      pass "proof bundle schema version supported for $ref"
      ;;
    *)
      fail "proof bundle schema version unsupported for $ref"
      ;;
  esac

  if has_execution_or_replay_evidence "$file"; then
    pass "proof execution or replay evidence present for $ref"
  else
    fail "proof bundle must declare executable or replayable evidence for $ref"
  fi

  validator_result_add_evidence "$ref"
done < <(yq -r '.tuple_admissions[]?.proof_bundle_ref // ""' "$SUPPORT_TARGETS")

echo "Validation summary: errors=$errors"
if [[ $errors -eq 0 ]]; then
  emit_validator_result "validate-proof-bundle-executability.sh" "support_proof" "proof" "proof" "pass"
else
  emit_validator_result "validate-proof-bundle-executability.sh" "support_proof" "proof" "existence" "fail"
fi
[[ $errors -eq 0 ]]

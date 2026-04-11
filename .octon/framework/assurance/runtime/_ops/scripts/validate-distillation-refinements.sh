#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
ROOT_DIR="${OCTON_ROOT_DIR:-$(cd -- "$OCTON_DIR/.." && pwd)}"

FAILURE_BUNDLE_DIR="$OCTON_DIR/state/evidence/validation/failure-distillation/2026-04-11-selected-harness-concepts-integration"
DISTILLATION_BUNDLE_DIR="$OCTON_DIR/state/evidence/validation/distillation/2026-04-11-selected-harness-concepts-integration"
SUMMARY_FILE="$OCTON_DIR/generated/cognition/distillation/2026-04-11-selected-harness-concepts-integration/summary.md"
FAILURE_WORKFLOW="$OCTON_DIR/instance/governance/contracts/failure-distillation-workflow.yml"
DISTILLATION_WORKFLOW="$OCTON_DIR/instance/governance/contracts/evidence-distillation-workflow.yml"

errors=0
fail() { echo "[ERROR] $1"; errors=$((errors + 1)); }
pass() { echo "[OK] $1"; }

main() {
  echo "== Distillation Refinements Validation =="

  for path in \
    "$OCTON_DIR/framework/constitution/contracts/assurance/failure-classification-v1.schema.json" \
    "$OCTON_DIR/framework/constitution/contracts/assurance/hardening-recommendation-v1.schema.json" \
    "$OCTON_DIR/framework/constitution/contracts/assurance/distillation-bundle-v1.schema.json" \
    "$FAILURE_WORKFLOW" \
    "$DISTILLATION_WORKFLOW" \
    "$FAILURE_BUNDLE_DIR/bundle.yml" \
    "$DISTILLATION_BUNDLE_DIR/bundle.yml" \
    "$SUMMARY_FILE"
  do
    [[ -f "$path" ]] && pass "found ${path#$ROOT_DIR/}" || fail "missing ${path#$ROOT_DIR/}"
  done

  yq -e '.promotion_mode == "proposal_gated" and .auto_promote == false' "$FAILURE_WORKFLOW" >/dev/null 2>&1 \
    && pass "failure distillation workflow remains proposal-gated" \
    || fail "failure distillation workflow must remain proposal-gated"

  yq -e '.promotion_mode == "proposal_gated" and .auto_promote == false and .generated_outputs_non_authoritative == true' "$DISTILLATION_WORKFLOW" >/dev/null 2>&1 \
    && pass "evidence distillation workflow remains proposal-gated and non-authoritative" \
    || fail "evidence distillation workflow must remain proposal-gated and non-authoritative"

  yq -e '.schema_version == "distillation-bundle-v1" and .bundle_kind == "failure-distillation" and .promotion_mode == "proposal_gated"' "$FAILURE_BUNDLE_DIR/bundle.yml" >/dev/null 2>&1 \
    && pass "failure bundle uses distillation-bundle-v1" \
    || fail "failure bundle must use distillation-bundle-v1"

  yq -e '.classifications[]? | select(.schema_version == "failure-classification-v1")' "$FAILURE_BUNDLE_DIR/bundle.yml" >/dev/null 2>&1 \
    && pass "failure bundle retains canonical failure classifications" \
    || fail "failure bundle must retain canonical failure classifications"

  yq -e '.recommendations[]? | select(.schema_version == "hardening-recommendation-v1" and .promotion_path == "proposal_gated")' "$FAILURE_BUNDLE_DIR/bundle.yml" >/dev/null 2>&1 \
    && pass "failure bundle recommendations remain proposal-gated" \
    || fail "failure bundle recommendations must remain proposal-gated"

  yq -e '.schema_version == "distillation-bundle-v1" and .bundle_kind == "evidence-distillation" and .promotion_mode == "proposal_gated"' "$DISTILLATION_BUNDLE_DIR/bundle.yml" >/dev/null 2>&1 \
    && pass "evidence distillation bundle uses distillation-bundle-v1" \
    || fail "evidence distillation bundle must use distillation-bundle-v1"

  if grep -Fq "Non-authoritative" "$SUMMARY_FILE"; then
    pass "generated distillation summary is explicitly non-authoritative"
  else
    fail "generated distillation summary must be explicitly non-authoritative"
  fi

  echo "Validation summary: errors=$errors"
  [[ $errors -eq 0 ]]
}

main "$@"

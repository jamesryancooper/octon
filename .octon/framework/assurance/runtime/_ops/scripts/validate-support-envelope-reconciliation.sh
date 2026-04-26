#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
ROOT_DIR="${OCTON_ROOT_DIR:-$(cd -- "$OCTON_DIR/.." && pwd)}"
source "$SCRIPT_DIR/validator-result-common.sh"

RESULT_PATH="$OCTON_DIR/generated/effective/governance/support-envelope-reconciliation.yml"
SCHEMA_PATH="$OCTON_DIR/framework/engine/runtime/spec/support-envelope-reconciliation-result-v1.schema.json"
SPEC_PATH="$OCTON_DIR/framework/engine/runtime/spec/support-envelope-reconciliation-v1.md"
EVIDENCE_DIR="${OCTON_SUPPORT_ENVELOPE_EVIDENCE_DIR:-}"

errors=0
fail() { echo "[ERROR] $1"; errors=$((errors + 1)); }
pass() { echo "[OK] $1"; }

hash_file() {
  if command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "$1" | awk '{print $1}'
  else
    sha256sum "$1" | awk '{print $1}'
  fi
}

emit_evidence() {
  local fresh_result="$1"
  local result_status="$2"
  [[ -n "$EVIDENCE_DIR" ]] || return 0
  mkdir -p "$EVIDENCE_DIR"
  cp "$fresh_result" "$EVIDENCE_DIR/reconciliation-result.yml"
  {
    printf 'schema_version: "support-envelope-validation-receipt-v1"\n'
    printf 'validator_id: "validate-support-envelope-reconciliation.sh"\n'
    printf 'result: "%s"\n' "$result_status"
    printf 'validated_at: "%s"\n' "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
    printf 'generated_result_ref: ".octon/generated/effective/governance/support-envelope-reconciliation.yml"\n'
    printf 'generated_result_sha256: "%s"\n' "$(hash_file "$fresh_result")"
    printf 'contract_refs:\n'
    printf '  - ".octon/framework/engine/runtime/spec/support-envelope-reconciliation-v1.md"\n'
    printf '  - ".octon/framework/engine/runtime/spec/support-envelope-reconciliation-result-v1.schema.json"\n'
    printf 'source_refs:\n'
    yq -r '.source_refs[]?' "$fresh_result" | while IFS= read -r ref; do
      [[ -n "$ref" ]] && printf '  - "%s"\n' "$ref"
    done
    diagnostics_file="$EVIDENCE_DIR/.blocked-diagnostics.tmp"
    yq -r '.tuples[]?.diagnostics[]?' "$fresh_result" | sort -u | awk 'NF' >"$diagnostics_file"
    if [[ -s "$diagnostics_file" ]]; then
      printf 'blocked_diagnostics:\n'
      while IFS= read -r diag; do
        [[ -n "$diag" ]] && printf '  - "%s"\n' "$diag"
      done <"$diagnostics_file"
    else
      printf 'blocked_diagnostics: []\n'
    fi
    rm -f "$diagnostics_file"
  } >"$EVIDENCE_DIR/validation-receipt.yml"
}

reset_validator_result_metadata
validator_result_add_evidence \
  ".octon/generated/effective/governance/support-envelope-reconciliation.yml"
validator_result_add_runtime_test \
  ".octon/framework/assurance/runtime/_ops/tests/test-support-envelope-reconciliation.sh"
validator_result_add_negative_control \
  "declared_live_without_fresh_proof" \
  "route_stage_only_but_support_declares_live" \
  "pack_route_widens_runtime_route" \
  "generated_matrix_widens_authority" \
  "generated_matrix_omits_declared_live_claim" \
  "support_card_overclaims_reconciled_support" \
  "excluded_target_presented_live" \
  "stale_lock_or_missing_freshness"
validator_result_add_contract \
  ".octon/framework/engine/runtime/spec/support-envelope-reconciliation-v1.md" \
  ".octon/framework/engine/runtime/spec/support-envelope-reconciliation-result-v1.schema.json"
validator_result_add_schema_version "support-envelope-reconciliation-result-v1"

echo "== Support Envelope Reconciliation Validation =="

command -v yq >/dev/null 2>&1 || {
  fail "yq is required"
  echo "Validation summary: errors=$errors"
  exit 1
}

[[ -f "$SPEC_PATH" ]] && pass "support-envelope spec present" || fail "missing support-envelope spec"
[[ -f "$SCHEMA_PATH" ]] && pass "support-envelope result schema present" || fail "missing support-envelope result schema"

tmpdir="$(mktemp -d)"
cleanup_tmpdir() {
  local dir="$1"
  [[ -d "$dir" ]] || return 0
  find "$dir" -depth -mindepth 1 \( -type f -o -type l \) -exec rm -f {} +
  find "$dir" -depth -type d -empty -exec rmdir {} +
}
trap 'cleanup_tmpdir "$tmpdir"' EXIT

fresh_result="$tmpdir/support-envelope-reconciliation.yml"
OCTON_DIR_OVERRIDE="$OCTON_DIR" OCTON_ROOT_DIR="$ROOT_DIR" bash "$SCRIPT_DIR/generate-support-envelope-reconciliation.sh" "$fresh_result"

[[ "$(yq -r '.schema_version // ""' "$fresh_result")" == "support-envelope-reconciliation-result-v1" ]] \
  && pass "generated result schema version current" \
  || fail "generated result schema version invalid"

case "$(yq -r '.status // ""' "$fresh_result")" in
  reconciled|failed) pass "generated result status is valid" ;;
  *) fail "generated result status invalid" ;;
esac

[[ "$(yq -r '.non_authority_classification // ""' "$fresh_result")" == "derived-runtime-handle" ]] \
  && pass "generated result remains non-authority" \
  || fail "generated result must be non-authority"

[[ "$(yq -r '.freshness.mode // ""' "$fresh_result")" == "digest_bound" ]] \
  && pass "generated result uses digest-bound freshness" \
  || fail "generated result must use digest-bound freshness"

yq -e '.freshness.invalidation_conditions | length > 0' "$fresh_result" >/dev/null 2>&1 \
  && pass "generated result declares invalidation conditions" \
  || fail "generated result missing invalidation conditions"

yq -e '.forbidden_consumers[] | select(. == "support-claim-widening")' "$fresh_result" >/dev/null 2>&1 \
  && pass "generated result forbids support widening" \
  || fail "generated result must forbid support widening"

if [[ -f "$RESULT_PATH" ]]; then
  if cmp -s "$fresh_result" "$RESULT_PATH"; then
    pass "published support-envelope reconciliation is current"
  else
    fail "published support-envelope reconciliation is stale; regenerate it"
  fi
else
  validator_result_add_limitation "generated support-envelope reconciliation has not been published yet"
fi

live_blockers="$(yq -r '.tuples[]? | select(.declared == "live" and .effective != "live") | .tuple_ref' "$fresh_result" | awk 'NF')"
if [[ -z "$live_blockers" ]]; then
  pass "all declared live tuples reconcile to live"
else
  fail "declared live tuples failed reconciliation: $live_blockers"
fi

generated_widening="$(yq -r '.tuples[]? | select((.diagnostics // [])[]? == "generated_matrix_widens_authority" or (.diagnostics // [])[]? == "pack_route_widens_runtime_route" or (.diagnostics // [])[]? == "route_live_without_declared_support" or (.diagnostics // [])[]? == "support_card_overclaims_reconciled_support" or (.diagnostics // [])[]? == "disclosure_overclaims_reconciled_support") | .tuple_ref' "$fresh_result" | awk 'NF')"
if [[ -z "$generated_widening" ]]; then
  pass "generated outputs do not widen support"
else
  fail "generated outputs widen support: $generated_widening"
fi

stale_live="$(yq -r '.tuples[]? | select(.declared == "live" and (.proof != "fresh" or (.diagnostics // [])[]? == "stale_lock_or_missing_freshness")) | .tuple_ref' "$fresh_result" | awk 'NF')"
if [[ -z "$stale_live" ]]; then
  pass "live tuples are proof-backed and freshness-valid"
else
  fail "live tuples are stale or proof-incomplete: $stale_live"
fi

excluded_live="$(yq -r '.tuples[]? | select(.declared == "live" and ((.diagnostics // [])[]? == "excluded_target_presented_live" or (.diagnostics // [])[]? == "revoked_support_evidence")) | .tuple_ref' "$fresh_result" | awk 'NF')"
if [[ -z "$excluded_live" ]]; then
  pass "live tuples are not excluded or revoked"
else
  fail "live tuples are excluded or revoked: $excluded_live"
fi

if [[ "$(yq -r '.status // ""' "$fresh_result")" == "reconciled" ]]; then
  pass "support envelope status reconciled"
else
  fail "support envelope status failed"
fi

result_status="pass"
if [[ "$errors" -gt 0 ]]; then
  result_status="fail"
fi
emit_evidence "$fresh_result" "$result_status"

echo "Validation summary: errors=$errors"
if [[ "$errors" -eq 0 ]]; then
  emit_validator_result "validate-support-envelope-reconciliation.sh" "support_envelope_reconciliation" "proof" "proof" "pass"
else
  emit_validator_result "validate-support-envelope-reconciliation.sh" "support_envelope_reconciliation" "proof" "semantic" "fail"
fi
[[ "$errors" -eq 0 ]]

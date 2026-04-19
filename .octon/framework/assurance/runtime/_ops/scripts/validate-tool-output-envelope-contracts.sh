#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
ROOT_DIR="${OCTON_ROOT_DIR:-$(cd -- "$OCTON_DIR/.." && pwd)}"

SCHEMA_FILE="$OCTON_DIR/framework/constitution/contracts/adapters/tool-output-envelope-v1.schema.json"
BUDGET_FILE="$OCTON_DIR/instance/execution-roles/runtime/tool-output-budgets.yml"
DIR="$OCTON_DIR/state/evidence/validation/tool-output-envelope/2026-04-11-selected-harness-concepts-integration"
ENVELOPE_FILE="$DIR/envelope.yml"
RAW_FILE="$DIR/raw-payload.json"
RECEIPT_FILE="$DIR/receipt.yml"

errors=0
fail() { echo "[ERROR] $1"; errors=$((errors + 1)); }
pass() { echo "[OK] $1"; }

main() {
  echo "== Tool Output Envelope Validation =="

  for path in "$SCHEMA_FILE" "$BUDGET_FILE" "$ENVELOPE_FILE" "$RAW_FILE" "$RECEIPT_FILE"; do
    [[ -f "$path" ]] && pass "found ${path#$ROOT_DIR/}" || fail "missing ${path#$ROOT_DIR/}"
  done

  yq -e '.schema_version == "tool-output-envelope-v1"' "$ENVELOPE_FILE" >/dev/null 2>&1 \
    && pass "envelope uses tool-output-envelope-v1" \
    || fail "envelope must use tool-output-envelope-v1"

  local max_summary_bytes summary_bytes evidence_ref_count raw_ref receipt_raw_ref
  max_summary_bytes="$(yq -r '.tools."proposal-integrator".max_summary_bytes // .defaults.max_summary_bytes' "$BUDGET_FILE")"
  summary_bytes="$(yq -r '.summary' "$ENVELOPE_FILE" | wc -c | tr -d ' ')"
  evidence_ref_count="$(yq -r '.evidence_refs | length' "$ENVELOPE_FILE")"
  raw_ref="$(yq -r '.raw_payload_ref' "$ENVELOPE_FILE")"
  receipt_raw_ref="$(yq -r '.raw_payload_ref' "$RECEIPT_FILE")"

  if [[ "$summary_bytes" -le "$max_summary_bytes" ]]; then
    pass "envelope summary stays within repo-owned byte budget"
  else
    fail "envelope summary exceeds repo-owned byte budget"
  fi

  if [[ "$evidence_ref_count" -le "$(yq -r '.defaults.max_evidence_refs' "$BUDGET_FILE")" ]]; then
    pass "envelope evidence ref count stays within budget"
  else
    fail "envelope evidence ref count exceeds budget"
  fi

  if [[ "$raw_ref" == "$receipt_raw_ref" && -f "$ROOT_DIR/$raw_ref" ]]; then
    pass "raw payload remains recoverable through retained evidence"
  else
    fail "raw payload ref must resolve through retained evidence"
  fi

  yq -e '.within_budget == true and .budget_profile_ref == ".octon/instance/execution-roles/runtime/tool-output-budgets.yml"' "$RECEIPT_FILE" >/dev/null 2>&1 \
    && pass "receipt records budget validation against the repo-owned profile" \
    || fail "receipt must record budget validation against the repo-owned profile"

  echo "Validation summary: errors=$errors"
  [[ $errors -eq 0 ]]
}

main "$@"

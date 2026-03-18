#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ASSURANCE_DIR="$(cd -- "$SCRIPT_DIR/../../.." && pwd)"
OCTON_DIR="$(cd -- "$ASSURANCE_DIR/.." && pwd)"
ROOT_DIR="$(cd -- "$OCTON_DIR/.." && pwd)"

errors=0
warnings=0

fail() {
  echo "[ERROR] $1"
  errors=$((errors + 1))
}

warn() {
  echo "[WARN] $1"
  warnings=$((warnings + 1))
}

pass() {
  echo "[OK] $1"
}

require_file() {
  local file="$1"
  if [[ ! -f "$file" ]]; then
    fail "missing file: ${file#$ROOT_DIR/}"
  else
    pass "found file: ${file#$ROOT_DIR/}"
  fi
}

require_jq_expr() {
  local file="$1"
  local expr="$2"
  local label="$3"
  if jq -e "$expr" "$file" >/dev/null 2>&1; then
    pass "$label"
  else
    fail "$label"
  fi
}

require_rg() {
  local pattern="$1"
  local file="$2"
  local label="$3"
  if rg -n -m 1 "$pattern" "$file" >/dev/null 2>&1; then
    pass "$label"
  else
    fail "$label"
  fi
}

main() {
  echo "== Intent Layer Validation =="

  local intent_schema="$OCTON_DIR/engine/runtime/spec/intent-contract-v1.schema.json"
  local boundary_contract="$OCTON_DIR/agency/governance/delegation-boundaries-v1.yml"
  local boundary_schema="$OCTON_DIR/agency/governance/delegation-boundaries-v1.schema.json"
  local capability_map="$OCTON_DIR/orchestration/governance/capability-map-v1.yml"
  local capability_map_schema="$OCTON_DIR/orchestration/governance/capability-map-v1.schema.json"
  local policy_receipt_schema="$OCTON_DIR/engine/runtime/spec/policy-receipt-v1.schema.json"
  local policy_interface_spec="$OCTON_DIR/engine/runtime/spec/policy-interface-v1.md"
  local policy_file="$OCTON_DIR/capabilities/governance/policy/deny-by-default.v2.yml"
  local receipt_writer="$OCTON_DIR/capabilities/_ops/scripts/policy-receipt-write.sh"

  require_file "$intent_schema"
  require_file "$boundary_contract"
  require_file "$boundary_schema"
  require_file "$capability_map"
  require_file "$capability_map_schema"
  require_file "$policy_receipt_schema"
  require_file "$policy_interface_spec"
  require_file "$policy_file"
  require_file "$receipt_writer"

  require_jq_expr "$intent_schema" '.required | index("intent_id")' "intent schema requires intent_id"
  require_jq_expr "$intent_schema" '.required | index("objective_signals")' "intent schema requires objective_signals"
  require_jq_expr "$intent_schema" '.required | index("authorized_actions")' "intent schema requires authorized_actions"
  require_jq_expr "$intent_schema" '.required | index("hard_boundaries")' "intent schema requires hard_boundaries"

  require_jq_expr "$boundary_schema" '.properties.boundaries' "boundary schema declares boundaries array"
  require_jq_expr "$capability_map_schema" '.properties.workflows' "capability map schema declares workflows"
  require_jq_expr "$policy_receipt_schema" '.properties.intent_ref and .properties.boundary_id and .properties.workflow_mode and .properties.capability_classification' "policy receipt schema exposes intent/boundary/mode/classification fields"

  require_rg "intent_ref" "$policy_interface_spec" "policy interface requires intent_ref"
  require_rg "MODE_VIOLATION_AUTONOMY_NOT_ALLOWED" "$policy_interface_spec" "policy interface declares autonomy mode violation deny"
  require_rg "acp-service-execute-mode-violation" "$policy_file" "policy contains mode-violation routing rule"
  require_rg "acp-service-execute-boundary-escalate" "$policy_file" "policy contains boundary escalate routing rule"
  require_rg "acp-service-execute-boundary-block" "$policy_file" "policy contains boundary block routing rule"
  require_rg "intent_ref|boundary_id|workflow_mode|capability_classification" "$receipt_writer" "receipt writer emits intent-layer provenance fields"

  if [[ $warnings -gt 0 ]]; then
    warn "intent-layer validation warnings=$warnings"
  fi
  echo "Validation summary: errors=$errors warnings=$warnings"
  if [[ $errors -gt 0 ]]; then
    exit 1
  fi
}

main "$@"

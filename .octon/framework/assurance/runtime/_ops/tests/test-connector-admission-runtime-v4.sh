#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
VALIDATOR="$SCRIPT_DIR/../scripts/validate-connector-admission-runtime-v4.sh"
ROOT_DIR="${OCTON_ROOT_DIR:-$(cd -- "$SCRIPT_DIR/../../../../../.." && pwd)}"

"$VALIDATOR" --root "$ROOT_DIR" --connector mcp --operation observe-context "$@"

tmp="$(mktemp -d)"
trap 'rm -r -f "$tmp"' EXIT
cp -R "$ROOT_DIR/.octon" "$tmp/.octon"

expect_fail() {
  local label="$1"
  shift
  if "$VALIDATOR" --root "$tmp" --connector mcp --operation observe-context >"$tmp/$label.out" 2>&1; then
    echo "[ERROR] validator accepted negative control: $label" >&2
    cat "$tmp/$label.out" >&2
    exit 1
  fi
  echo "[OK] negative control failed closed: $label"
}

op="$tmp/.octon/instance/governance/connectors/mcp/operations/observe-context.yml"
admission="$tmp/.octon/instance/governance/connector-admissions/mcp/observe-context/admission.yml"
support_card="$tmp/.octon/generated/cognition/projections/materialized/connectors/support-cards/mcp-observe-context.yml"
drift="$tmp/.octon/state/control/connectors/mcp/operations/observe-context/drift.yml"
quarantine="$tmp/.octon/state/control/connectors/mcp/operations/observe-context/quarantine.yml"
status="$tmp/.octon/state/control/connectors/mcp/operations/observe-context/status.yml"
admission_state="$tmp/.octon/state/control/connectors/mcp/operations/observe-context/admission-state.yml"

cp "$op" "$tmp/op.bak"
yq -i 'del(.material_effect_class)' "$op"
expect_fail "missing-material-effect"
cp "$tmp/op.bak" "$op"

cp "$op" "$tmp/op-allowed-modes.bak"
yq -i '.allowed_modes = ["observe_only"]' "$op"
expect_fail "admission-mode-not-allowed"
cp "$tmp/op-allowed-modes.bak" "$op"

cp "$admission" "$tmp/admission.bak"
yq -i '.live_effects_authorized = true' "$admission"
expect_fail "live-effectful-without-proof"
cp "$tmp/admission.bak" "$admission"

cp "$support_card" "$tmp/support-card.bak"
yq -i '.generated_support_matrix_can_widen_support = true' "$support_card"
expect_fail "generated-support-widening"
cp "$tmp/support-card.bak" "$support_card"

cp "$drift" "$tmp/drift.bak"
yq -i '.current_digest = "baseline-stage-only"' "$drift"
expect_fail "placeholder-drift-digest"
cp "$tmp/drift.bak" "$drift"

cp "$quarantine" "$tmp/quarantine.bak"
cp "$status" "$tmp/status.bak"
cp "$admission_state" "$tmp/admission-state.bak"
yq -i '.status = "quarantined" | .active = true' "$quarantine"
yq -i '.status = "stage_only"' "$status"
yq -i '.admission_state = "stage_only"' "$admission_state"
expect_fail "active-quarantine-status-mismatch"
cp "$tmp/quarantine.bak" "$quarantine"
cp "$tmp/status.bak" "$status"
cp "$tmp/admission-state.bak" "$admission_state"

echo "[OK] Connector Admission Runtime v4 negative controls passed."

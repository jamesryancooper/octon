#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../.." && pwd)"
VALIDATOR="$OCTON_DIR/framework/assurance/runtime/_ops/scripts/validate-delegated-governance-negative-controls.sh"
TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/octon-delegated-governance-negative-controls.XXXXXX")"
trap 'rm -rf "$TMP_DIR"' EXIT

run_fixture() {
  local case_id="$1"
  local failure_class="$2"
  local proof_state="$3"
  local fixture="$TMP_DIR/$case_id.yml"

  cat > "$fixture" <<YAML
schema_version: delegated-governance-negative-control-fixture-v1
case_id: $case_id
failure_class: $failure_class
expected_result: deny
dispatch_allowed: false
fallback_to_generic_approval: false
generated_authority_used: false
read_model_authority_used: false
child_authority_takeover: false
external_irreversible_effect_without_proof: false
proof_state: $proof_state
YAML

  bash "$VALIDATOR" --fixture "$fixture" >/dev/null
}

run_bad_fixture_must_fail() {
  local fixture="$TMP_DIR/generated-authority-misuse.yml"

  cat > "$fixture" <<'YAML'
schema_version: delegated-governance-negative-control-fixture-v1
case_id: generated-authority-misuse
failure_class: generated-output-authority-misuse
expected_result: allow
dispatch_allowed: true
fallback_to_generic_approval: true
generated_authority_used: true
read_model_authority_used: false
child_authority_takeover: false
external_irreversible_effect_without_proof: false
proof_state: proof-valid
YAML

  if bash "$VALIDATOR" --fixture "$fixture" >/dev/null 2>&1; then
    echo "[ERROR] generated authority misuse fixture unexpectedly passed" >&2
    return 1
  fi
}

OCTON_ROOT_DIR="$(cd -- "$OCTON_DIR/.." && pwd)" bash "$VALIDATOR" >/dev/null

run_fixture approval-default-primitive approval-default-primitive not-applicable
run_fixture dispatch-without-retained-proof dispatch-without-retained-proof proof-missing
run_fixture missing-proof missing-proof proof-missing
run_fixture stale-digest stale-digest proof-stale
run_fixture scope-mismatch scope-mismatch proof-scope-mismatch
run_fixture generated-output-authority-misuse generated-output-authority-misuse proof-failed
run_fixture read-model-authority-misuse read-model-authority-misuse proof-failed
run_fixture child-authority-takeover child-authority-takeover proof-failed
run_fixture unsupported-mode unsupported-mode proof-failed
run_fixture unsafe-resume unsafe-resume proof-failed
run_fixture policy-override policy-override proof-failed
run_fixture governance-mutation-without-typed-exception governance-mutation-without-typed-exception proof-failed
run_fixture external-irreversible-effect-without-proof external-irreversible-effect-without-proof proof-failed
run_bad_fixture_must_fail

echo "[OK] delegated governance negative controls reject every named failure class"

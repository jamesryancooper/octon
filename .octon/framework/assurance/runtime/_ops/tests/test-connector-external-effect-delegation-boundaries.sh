#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../../../../../.." && pwd)"
TMP_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/connector-external-effect-boundaries.XXXXXX")"
trap 'rm -rf "$TMP_ROOT"' EXIT

copy_ref() {
  local fixture="$1"
  local ref="$2"
  mkdir -p "$fixture/$(dirname "$ref")"
  cp "$ROOT_DIR/$ref" "$fixture/$ref"
}

create_fixture() {
  local fixture
  fixture="$(mktemp -d "$TMP_ROOT/fixture.XXXXXX")"
  copy_ref "$fixture" ".octon/framework/constitution/contracts/adapters/connector-operation-v1.schema.json"
  copy_ref "$fixture" ".octon/framework/engine/runtime/spec/connector-operation-v1.schema.json"
  copy_ref "$fixture" ".octon/framework/engine/runtime/spec/connector-replay-rollback-posture-v1.schema.json"
  copy_ref "$fixture" ".octon/instance/governance/connectors/external-effect-delegation-boundaries.yml"
  printf '%s\n' "$fixture"
}

validate_fixture() {
  local fixture="$1"
  local adapter_schema="$fixture/.octon/framework/constitution/contracts/adapters/connector-operation-v1.schema.json"
  local runtime_schema="$fixture/.octon/framework/engine/runtime/spec/connector-operation-v1.schema.json"
  local replay_schema="$fixture/.octon/framework/engine/runtime/spec/connector-replay-rollback-posture-v1.schema.json"
  local boundary="$fixture/.octon/instance/governance/connectors/external-effect-delegation-boundaries.yml"

  jq -e '.allOf[] | select(.if.properties.side_effect_class.enum | index("external_effect")) | .then.required | index("effect_delegation_boundaries")' "$adapter_schema" >/dev/null || return 1
  jq -e '.allOf[] | select(.if.properties.side_effect_class.enum | index("destructive")) | .then.required | index("effect_delegation_boundaries")' "$runtime_schema" >/dev/null || return 1
  jq -e '.properties.effect_delegation_boundaries.properties.generated_outputs_authorize_execution.const == false' "$runtime_schema" >/dev/null || return 1
  jq -e '.properties.effect_delegation_boundaries.properties.permission_widening_requires_typed_human_boundary.const == true' "$runtime_schema" >/dev/null || return 1
  jq -e '.properties.effect_delegation_boundaries.properties.irreversible_external_effect_route.enum | index("human_required")' "$runtime_schema" >/dev/null || return 1
  jq -e '.properties.machine_delegation_allowed_for_irreversible_external_effects.const == false' "$replay_schema" >/dev/null || return 1

  yq -e '.machine_delegation_requires[] | select(. == "authorized-effect-token-proof")' "$boundary" >/dev/null || return 1
  yq -e '.machine_delegation_requires[] | select(. == "scope-containment-proof")' "$boundary" >/dev/null || return 1
  yq -e '.machine_delegation_requires[] | select(. == "egress-policy-or-empty-egress-proof")' "$boundary" >/dev/null || return 1
  yq -e '.machine_delegation_requires[] | select(. == "replay-or-compensation-proof")' "$boundary" >/dev/null || return 1
  yq -e '.machine_delegation_requires[] | select(. == "retained-connector-and-run-receipts")' "$boundary" >/dev/null || return 1
  yq -e '.irreversible_external_effect_default == "human_required"' "$boundary" >/dev/null || return 1
  yq -e '.irreversible_external_effect_machine_delegation_allowed == false' "$boundary" >/dev/null || return 1
  yq -e '.generated_connector_summaries_authorize_execution == false' "$boundary" >/dev/null || return 1
  yq -e '.permission_widening_requires_typed_human_boundary == true' "$boundary" >/dev/null || return 1
  yq -e '.required_negative_controls[] | select(. == "generated connector summary authority misuse")' "$boundary" >/dev/null || return 1
  yq -e '.required_negative_controls[] | select(. == "irreversible external effect without explicit rollback or compensation proof")' "$boundary" >/dev/null || return 1
}

expect_fail() {
  local label="$1"
  local fixture="$2"
  if validate_fixture "$fixture" >/dev/null 2>&1; then
    echo "[ERROR] negative control passed unexpectedly: $label" >&2
    exit 1
  fi
  echo "[OK] negative control failed closed: $label"
}

fixture="$(create_fixture)"
validate_fixture "$fixture"
echo "[OK] connector external-effect boundary fixture validates"

fixture="$(create_fixture)"
yq -i 'del(.machine_delegation_requires[] | select(. == "authorized-effect-token-proof"))' "$fixture/.octon/instance/governance/connectors/external-effect-delegation-boundaries.yml"
expect_fail "missing-authorized-effect-token-proof" "$fixture"

fixture="$(create_fixture)"
yq -i '.generated_connector_summaries_authorize_execution = true' "$fixture/.octon/instance/governance/connectors/external-effect-delegation-boundaries.yml"
expect_fail "generated-summary-authority-misuse" "$fixture"

fixture="$(create_fixture)"
yq -i 'del(.machine_delegation_requires[] | select(. == "scope-containment-proof"))' "$fixture/.octon/instance/governance/connectors/external-effect-delegation-boundaries.yml"
expect_fail "missing-scope-containment-proof" "$fixture"

fixture="$(create_fixture)"
yq -i 'del(.machine_delegation_requires[] | select(. == "retained-connector-and-run-receipts"))' "$fixture/.octon/instance/governance/connectors/external-effect-delegation-boundaries.yml"
expect_fail "missing-retained-receipt-proof" "$fixture"

echo "[OK] Connector external-effect delegation boundary negative controls passed."

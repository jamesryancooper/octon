#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
ROOT_DIR="${OCTON_ROOT_DIR:-$(cd -- "$OCTON_DIR/.." && pwd)}"

SCHEMA_FILE="$OCTON_DIR/framework/constitution/contracts/runtime/instruction-layer-manifest-v2.schema.json"
BUDGET_FILE="$OCTON_DIR/instance/execution-roles/runtime/tool-output-budgets.yml"

errors=0

fail() {
  echo "[ERROR] $1"
  errors=$((errors + 1))
}

pass() {
  echo "[OK] $1"
}

require_file() {
  local path="$1"
  if [[ -f "$path" ]]; then
    pass "found ${path#$ROOT_DIR/}"
  else
    fail "missing ${path#$ROOT_DIR/}"
  fi
}

require_yq() {
  local path="$1"
  local expr="$2"
  local label="$3"
  if yq -e "$expr" "$path" >/dev/null 2>&1; then
    pass "$label"
  else
    fail "$label"
  fi
}

require_schema_array_ref() {
  local field="$1"
  require_yq \
    "$SCHEMA_FILE" \
    ".properties.\"$field\".type == \"array\" and .properties.\"$field\".items.\"\$ref\" == \"#/\$defs/non_empty_string\"" \
    "instruction-layer manifest exposes $field as non-empty string refs"
}

require_sequence_value() {
  local path="$1"
  local expr="$2"
  local value="$3"
  local label="$4"
  require_yq "$path" "$expr[] | select(. == \"$value\")" "$label"
}

main() {
  echo "== Instruction Layer Manifest Depth Validation =="

  require_file "$SCHEMA_FILE"
  require_file "$BUDGET_FILE"

  if [[ ! -f "$SCHEMA_FILE" || ! -f "$BUDGET_FILE" ]]; then
    echo "Validation summary: errors=$errors"
    [[ "$errors" -eq 0 ]]
    return
  fi

  require_yq "$SCHEMA_FILE" '.schema_version? == null or true' "instruction-layer schema parses"
  require_yq "$SCHEMA_FILE" '.properties.schema_version.const == "instruction-layer-manifest-v2"' "instruction-layer manifest version is v2"
  require_schema_array_ref "capability_pack_refs"
  require_schema_array_ref "execution_class_refs"
  require_schema_array_ref "tool_budget_policy_refs"
  require_schema_array_ref "compaction_refs"
  require_schema_array_ref "raw_payload_refs"

  require_yq "$SCHEMA_FILE" '.properties.context_layers.type == "array"' "instruction-layer manifest exposes context_layers"
  require_yq "$SCHEMA_FILE" '."$defs".context_layer.type == "object"' "context_layer definition exists"
  require_sequence_value "$SCHEMA_FILE" '."$defs".context_layer.required' "layer_id" "context_layer requires layer_id"
  require_sequence_value "$SCHEMA_FILE" '."$defs".context_layer.required' "source_refs" "context_layer requires source_refs"
  require_sequence_value "$SCHEMA_FILE" '."$defs".context_layer.required' "disclosure_mode" "context_layer requires disclosure_mode"
  for mode in loaded summarized compacted offloaded; do
    require_sequence_value \
      "$SCHEMA_FILE" \
      '."$defs".context_layer.properties.disclosure_mode.enum' \
      "$mode" \
      "context_layer supports $mode disclosure mode"
  done
  require_yq "$SCHEMA_FILE" '."$defs".context_layer.properties.raw_payload_refs.type == "array"' "context_layer can cite raw payload refs"

  require_yq "$BUDGET_FILE" '.schema_version == "tool-output-budgets-v1"' "tool-output budget schema version is stable"
  require_yq "$BUDGET_FILE" '.policy_id == "repo-tool-output-envelope-policy"' "tool-output budget policy id is explicit"
  require_yq "$BUDGET_FILE" '.policy_ref == ".octon/instance/execution-roles/runtime/tool-output-budgets.yml"' "tool-output budget authority path is current"
  require_yq "$BUDGET_FILE" '.defaults.require_raw_payload_ref == true' "tool-output defaults require raw payload refs"
  require_yq "$BUDGET_FILE" '.defaults.output_envelope_policy_ref == ".octon/instance/execution-roles/runtime/tool-output-budgets.yml#defaults"' "tool-output defaults expose envelope policy ref"
  require_yq "$BUDGET_FILE" '.capability_packs.shell.output_envelope_policy_ref == ".octon/instance/execution-roles/runtime/tool-output-budgets.yml#capability_packs/shell"' "shell pack budget policy ref exists"
  require_yq "$BUDGET_FILE" '.capability_packs.repo.output_envelope_policy_ref == ".octon/instance/execution-roles/runtime/tool-output-budgets.yml#capability_packs/repo"' "repo pack budget policy ref exists"

  local class_id class_ref
  for class_id in safe-read-only workspace-write broad-verification blocked-out-of-workspace blocked-undeclared-shell-mutation; do
    class_ref=".octon/instance/execution-roles/runtime/tool-output-budgets.yml#execution_classes/$class_id"
    require_sequence_value "$BUDGET_FILE" '.capability_packs.shell.execution_class_refs' "$class_id" "shell budget policy lists $class_id"
    require_yq "$BUDGET_FILE" ".execution_classes.\"$class_id\".output_envelope_policy_ref == \"$class_ref\"" "$class_id budget policy ref is normalized"
    require_yq "$BUDGET_FILE" ".execution_classes.\"$class_id\".require_raw_payload_ref == true" "$class_id requires raw payload refs"
  done

  for tool_id in proposal-integrator repo-search policy-evaluator; do
    require_yq "$BUDGET_FILE" ".tools.\"$tool_id\".output_envelope_policy_ref == \".octon/instance/execution-roles/runtime/tool-output-budgets.yml#tools/$tool_id\"" "$tool_id tool budget exposes envelope policy ref"
  done

  if rg -Fq ".octon/instance/agency/runtime/tool-output-budgets.yml" "$SCHEMA_FILE" "$BUDGET_FILE"; then
    fail "durable instruction-layer budget surfaces do not reference retired agency budget path"
  else
    pass "durable instruction-layer budget surfaces use current execution-roles path"
  fi

  echo "Validation summary: errors=$errors"
  [[ "$errors" -eq 0 ]]
}

main "$@"

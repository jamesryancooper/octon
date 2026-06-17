#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
ROOT_DIR="${OCTON_ROOT_DIR:-$(cd -- "$OCTON_DIR/.." && pwd)}"

REQUEST_SCHEMA="$OCTON_DIR/framework/engine/runtime/spec/execution-request-v2.schema.json"
GRANT_SCHEMA="$OCTON_DIR/framework/engine/runtime/spec/execution-grant-v1.schema.json"
RECEIPT_SCHEMA="$OCTON_DIR/framework/engine/runtime/spec/execution-receipt-v2.schema.json"
CLASS_POLICY="$OCTON_DIR/instance/governance/policies/repo-shell-execution-classes.yml"
SHELL_PACK="$OCTON_DIR/framework/capabilities/packs/shell/manifest.yml"
REPO_PACK="$OCTON_DIR/framework/capabilities/packs/repo/manifest.yml"
SHELL_GOVERNANCE="$OCTON_DIR/instance/governance/capability-packs/shell.yml"
SHELL_ADMISSION="$OCTON_DIR/instance/capabilities/runtime/packs/admissions/shell.yml"

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

require_schema_field_type() {
  local path="$1"
  local field="$2"
  local type="$3"
  local label="$4"
  require_yq "$path" ".properties.\"$field\".type == \"$type\"" "$label"
}

require_sequence_value() {
  local path="$1"
  local expr="$2"
  local value="$3"
  local label="$4"
  require_yq "$path" "$expr[] | select(. == \"$value\")" "$label"
}

require_receipt_field_list() {
  local path="$1"
  local expr="$2"
  local label_prefix="$3"
  local field
  for field in requested_pack_ids granted_pack_ids execution_class_id output_envelope_policy_ref raw_payload_refs; do
    require_sequence_value "$path" "$expr" "$field" "$label_prefix requires $field"
  done
}

main() {
  echo "== Capability Envelope Normalization Validation =="

  for path in \
    "$REQUEST_SCHEMA" \
    "$GRANT_SCHEMA" \
    "$RECEIPT_SCHEMA" \
    "$CLASS_POLICY" \
    "$SHELL_PACK" \
    "$REPO_PACK" \
    "$SHELL_GOVERNANCE" \
    "$SHELL_ADMISSION"; do
    require_file "$path"
  done

  if [[ ! -f "$REQUEST_SCHEMA" || ! -f "$GRANT_SCHEMA" || ! -f "$RECEIPT_SCHEMA" || ! -f "$CLASS_POLICY" ]]; then
    echo "Validation summary: errors=$errors"
    [[ "$errors" -eq 0 ]]
    return
  fi

  require_schema_field_type "$REQUEST_SCHEMA" "requested_pack_ids" "array" "request schema exposes requested_pack_ids"
  require_schema_field_type "$REQUEST_SCHEMA" "execution_class_id" "string" "request schema exposes execution_class_id"
  require_schema_field_type "$REQUEST_SCHEMA" "execution_class_policy_ref" "string" "request schema exposes execution_class_policy_ref"
  require_schema_field_type "$REQUEST_SCHEMA" "output_envelope_policy_ref" "string" "request schema exposes output_envelope_policy_ref"
  require_schema_field_type "$REQUEST_SCHEMA" "raw_payload_required" "boolean" "request schema exposes raw_payload_required"

  require_schema_field_type "$GRANT_SCHEMA" "granted_pack_ids" "array" "grant schema exposes granted_pack_ids"
  require_schema_field_type "$GRANT_SCHEMA" "execution_class_id" "string" "grant schema exposes execution_class_id"
  require_schema_field_type "$GRANT_SCHEMA" "execution_class_policy_ref" "string" "grant schema exposes execution_class_policy_ref"
  require_schema_field_type "$GRANT_SCHEMA" "output_envelope_policy_ref" "string" "grant schema exposes output_envelope_policy_ref"
  require_schema_field_type "$GRANT_SCHEMA" "raw_payload_required" "boolean" "grant schema exposes raw_payload_required"

  require_schema_field_type "$RECEIPT_SCHEMA" "requested_pack_ids" "array" "receipt schema exposes requested_pack_ids"
  require_schema_field_type "$RECEIPT_SCHEMA" "granted_pack_ids" "array" "receipt schema exposes granted_pack_ids"
  require_schema_field_type "$RECEIPT_SCHEMA" "execution_class_id" "string" "receipt schema exposes execution_class_id"
  require_schema_field_type "$RECEIPT_SCHEMA" "execution_class_policy_ref" "string" "receipt schema exposes execution_class_policy_ref"
  require_schema_field_type "$RECEIPT_SCHEMA" "output_envelope_policy_ref" "string" "receipt schema exposes output_envelope_policy_ref"
  require_schema_field_type "$RECEIPT_SCHEMA" "raw_payload_required" "boolean" "receipt schema exposes raw_payload_required"
  require_schema_field_type "$RECEIPT_SCHEMA" "raw_payload_refs" "array" "receipt schema exposes raw_payload_refs"
  require_schema_field_type "$RECEIPT_SCHEMA" "output_envelope_ref" "string" "receipt schema exposes output_envelope_ref"
  require_schema_field_type "$RECEIPT_SCHEMA" "output_summary_ref" "string" "receipt schema exposes output_summary_ref"

  require_yq "$CLASS_POLICY" '.schema_version == "repo-shell-execution-classes-policy-v1"' "repo-shell class policy schema version is stable"
  require_yq "$CLASS_POLICY" '.capability_pack_id == "shell"' "repo-shell policy names shell capability pack"
  require_yq "$CLASS_POLICY" '.capability_pack_ref == ".octon/framework/capabilities/packs/shell/manifest.yml"' "repo-shell policy links shell pack manifest"
  require_yq "$CLASS_POLICY" '.output_envelope_policy_ref == ".octon/instance/execution-roles/runtime/tool-output-budgets.yml"' "repo-shell policy links output envelope budget policy"
  require_sequence_value "$CLASS_POLICY" '.normalization_contract_refs' ".octon/framework/engine/runtime/spec/execution-request-v2.schema.json" "repo-shell policy links request schema"
  require_sequence_value "$CLASS_POLICY" '.normalization_contract_refs' ".octon/framework/engine/runtime/spec/execution-grant-v1.schema.json" "repo-shell policy links grant schema"
  require_sequence_value "$CLASS_POLICY" '.normalization_contract_refs' ".octon/framework/engine/runtime/spec/execution-receipt-v2.schema.json" "repo-shell policy links receipt schema"

  local class_id class_ref
  while IFS= read -r class_id; do
    [[ -n "$class_id" ]] || continue
    class_ref=".octon/instance/execution-roles/runtime/tool-output-budgets.yml#execution_classes/$class_id"
    require_yq "$CLASS_POLICY" ".classes[] | select(.class_id == \"$class_id\") | .execution_class_id == \"$class_id\"" "$class_id mirrors class_id into execution_class_id"
    require_yq "$CLASS_POLICY" ".classes[] | select(.class_id == \"$class_id\") | .capability_pack_id == \"shell\"" "$class_id remains in shell capability pack"
    require_yq "$CLASS_POLICY" ".classes[] | select(.class_id == \"$class_id\") | .output_envelope_policy_ref == \"$class_ref\"" "$class_id links normalized envelope policy"
    require_yq "$CLASS_POLICY" ".classes[] | select(.class_id == \"$class_id\") | .raw_payload_ref_required == true" "$class_id requires raw payload refs"
    require_yq "$CLASS_POLICY" ".classes[] | select(.class_id == \"$class_id\") | .receipt_reason | length > 0" "$class_id has receipt reason"
    require_receipt_field_list "$CLASS_POLICY" ".classes[] | select(.class_id == \"$class_id\") | .receipt_required_fields" "$class_id receipt contract"
  done < <(yq -r '.classes[].class_id' "$CLASS_POLICY")

  require_yq "$CLASS_POLICY" '.classes[] | select(.class_id == "broad-verification" and .route == "require-preflight")' "broad-verification class requires preflight route"
  require_yq "$CLASS_POLICY" '.classes[] | select(.class_id == "broad-verification" and .requires_workflow == "repo-consequential-preflight")' "broad-verification class cites preflight workflow"
  require_yq "$CLASS_POLICY" '.classes[] | select(.class_id == "broad-verification" and .required_preflight_ref == ".octon/framework/orchestration/runtime/workflows/tasks/repo-consequential-preflight/workflow.yml")' "broad-verification class links preflight workflow path"
  require_yq "$CLASS_POLICY" '.classes[] | select(.class_id == "broad-verification" and .receipt_reason == "REPO_SHELL_BROAD_VERIFICATION_REQUIRES_PREFLIGHT")' "broad-verification class keeps receipt reason linkage"

  require_yq "$SHELL_PACK" '.pack_id == "shell"' "shell pack id is stable"
  require_yq "$SHELL_PACK" '.execution_class_policy_ref == ".octon/instance/governance/policies/repo-shell-execution-classes.yml"' "shell pack links execution class policy"
  require_yq "$SHELL_PACK" '.output_envelope_policy_ref == ".octon/instance/execution-roles/runtime/tool-output-budgets.yml#capability_packs/shell"' "shell pack links envelope policy"
  require_receipt_field_list "$SHELL_PACK" '.normalized_receipt_fields' "shell pack normalized receipt"
  require_sequence_value "$SHELL_PACK" '.required_evidence' "execution-request" "shell pack requires execution request evidence"
  require_sequence_value "$SHELL_PACK" '.required_evidence' "execution-grant" "shell pack requires execution grant evidence"
  require_sequence_value "$SHELL_PACK" '.required_evidence' "execution-receipt" "shell pack requires execution receipt evidence"
  require_sequence_value "$SHELL_PACK" '.required_evidence' "raw-payload-ref" "shell pack requires raw payload ref evidence"

  require_yq "$REPO_PACK" '.pack_id == "repo"' "repo pack id is stable"
  require_yq "$REPO_PACK" '.output_envelope_policy_ref == ".octon/instance/execution-roles/runtime/tool-output-budgets.yml#capability_packs/repo"' "repo pack links envelope policy"
  require_receipt_field_list "$REPO_PACK" '.normalized_receipt_fields' "repo pack normalized receipt"
  require_sequence_value "$REPO_PACK" '.required_evidence' "execution-receipt" "repo pack requires execution receipt evidence"
  require_sequence_value "$REPO_PACK" '.required_evidence' "raw-payload-ref" "repo pack requires raw payload ref evidence"

  require_yq "$SHELL_GOVERNANCE" '.pack_id == "shell" and .status == "admitted"' "shell governance keeps admitted pack status"
  require_yq "$SHELL_GOVERNANCE" '.execution_class_policy_ref == ".octon/instance/governance/policies/repo-shell-execution-classes.yml"' "shell governance links execution class policy"
  require_yq "$SHELL_GOVERNANCE" '.output_envelope_policy_ref == ".octon/instance/execution-roles/runtime/tool-output-budgets.yml#capability_packs/shell"' "shell governance links envelope policy"
  require_receipt_field_list "$SHELL_GOVERNANCE" '.required_receipt_fields' "shell governance"

  require_yq "$SHELL_ADMISSION" '.pack_id == "shell" and .status == "admitted"' "shell admission keeps admitted pack status"
  require_yq "$SHELL_ADMISSION" '.contract_ref == ".octon/framework/capabilities/packs/shell/manifest.yml"' "shell admission links pack manifest"
  require_yq "$SHELL_ADMISSION" '.execution_class_policy_ref == ".octon/instance/governance/policies/repo-shell-execution-classes.yml"' "shell admission links execution class policy"
  require_yq "$SHELL_ADMISSION" '.output_envelope_policy_ref == ".octon/instance/execution-roles/runtime/tool-output-budgets.yml#capability_packs/shell"' "shell admission links envelope policy"
  require_receipt_field_list "$SHELL_ADMISSION" '.required_receipt_fields' "shell admission"
  require_sequence_value "$SHELL_ADMISSION" '.required_proof' "envelope-normalization" "shell admission requires envelope-normalization proof"
  require_sequence_value "$SHELL_ADMISSION" '.validator_refs' ".octon/framework/assurance/runtime/_ops/scripts/validate-capability-envelope-normalization.sh" "shell admission cites envelope normalization validator"

  if rg -Fq ".octon/instance/agency/runtime/tool-output-budgets.yml" \
    "$REQUEST_SCHEMA" \
    "$GRANT_SCHEMA" \
    "$RECEIPT_SCHEMA" \
    "$CLASS_POLICY" \
    "$SHELL_PACK" \
    "$REPO_PACK" \
    "$SHELL_GOVERNANCE" \
    "$SHELL_ADMISSION"; then
    fail "durable capability envelope surfaces do not reference retired agency budget path"
  else
    pass "durable capability envelope surfaces use current execution-roles path"
  fi

  echo "Validation summary: errors=$errors"
  [[ "$errors" -eq 0 ]]
}

main "$@"

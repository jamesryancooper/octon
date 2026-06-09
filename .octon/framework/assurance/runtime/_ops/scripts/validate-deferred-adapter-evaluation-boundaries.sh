#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
ROOT_DIR="${OCTON_ROOT_DIR:-$(cd -- "$OCTON_DIR/.." && pwd)}"

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
  [[ -f "$ROOT_DIR/$path" ]] && pass "found $path" || fail "missing $path"
}

require_yq() {
  local path="$1"
  local expr="$2"
  local label="$3"
  yq -e "$expr" "$ROOT_DIR/$path" >/dev/null 2>&1 && pass "$label" || fail "$label"
}

check_tools() {
  command -v yq >/dev/null 2>&1 || fail "yq is required"
}

check_contract() {
  local contract=".octon/framework/constitution/contracts/adapters/deferred-adapter-evaluation-boundaries-v1.yml"
  require_file "$contract"
  require_yq "$contract" '.schema_version == "deferred-adapter-evaluation-boundaries-v1"' "boundary contract schema is current"
  require_yq "$contract" '.required_boundaries.live_support_claim_authorized == false' "boundary contract denies live support claims"
  require_yq "$contract" '.required_boundaries.adapter_availability_is_authority == false' "boundary contract denies adapter availability authority"
  require_yq "$contract" '.required_boundaries.external_state_is_authority == false' "boundary contract denies external state authority"
  require_yq "$contract" '.required_boundaries.admission_authorizes_execution == false' "boundary contract denies admission execution authority"
}

check_registry() {
  local registry=".octon/framework/lab/adapter-evaluations/registry.yml"
  require_file "$registry"
  require_yq "$registry" '.schema_version == "adapter-evaluation-registry-v1"' "adapter evaluation registry schema is current"
  require_yq "$registry" '.authority_boundary.live_support_claim_authorized == false' "registry denies live support claims"
  require_yq "$registry" '.authority_boundary.adapter_availability_is_authority == false' "registry denies adapter availability authority"
  require_yq "$registry" '.authority_boundary.external_state_is_authority == false' "registry denies external state authority"
}

check_evaluation() {
  local id="$1"
  local admission="$2"
  local eval=".octon/framework/lab/adapter-evaluations/$id.yml"
  local proof=".octon/state/evidence/lab/adapter-evaluations/$id/evaluation-proof.yml"

  require_file "$eval"
  require_file "$admission"
  require_file "$proof"

  require_yq "$eval" ".schema_version == \"deferred-adapter-evaluation-v1\" and .evaluation_id == \"$id\"" "$id evaluation identity is valid"
  require_yq "$eval" '.live_support_claim_authorized == false' "$id denies live support claims"
  require_yq "$eval" '.adapter_availability_is_authority == false' "$id denies adapter availability authority"
  require_yq "$eval" '.external_state_is_authority == false' "$id denies external state authority"
  require_yq "$eval" '.admission_authorizes_execution == false' "$id denies admission execution authority"
  require_yq "$eval" '.canonical_control_truth_owner == "octon-local" and .canonical_evidence_owner == "octon-local" and .closeout_truth_owner == "octon-local"' "$id keeps canonical truth local"
  require_yq "$eval" '([.negative_controls[]?.expected_result] | length >= 3) and ([.negative_controls[]?.expected_result] | map(select(. == "pass")) | length == 3)' "$id negative controls pass"

  require_yq "$admission" '.schema_version == "connector-admission-v1"' "$id admission schema is connector-admission-v1"
  require_yq "$admission" '.live_effects_authorized == false and .admission_authorizes_execution == false and .connector_availability_is_authority == false' "$id admission is non-authorizing"
  require_yq "$admission" '.retained_receipts_required == true and .context_pack_inclusion_required == true' "$id admission keeps receipts and context binding required"
  require_yq "$admission" '.broad_effectful_connector_autonomy == "denied" or .broad_effectful_connector_autonomy == "deferred"' "$id broad effectful autonomy is denied or deferred"
  require_yq "$admission" '.support_posture == "non_live_lab_only"' "$id admission remains lab-only"

  require_yq "$proof" ".schema_version == \"deferred-adapter-evaluation-proof-v1\" and .evaluation_id == \"$id\" and .verdict == \"pass\"" "$id retained proof passes"
  require_yq "$proof" '.live_support_claim_authorized == false' "$id proof denies live support claims"
  require_yq "$proof" '([.negative_controls[]?.result] | length >= 3) and ([.negative_controls[]?.result] | map(select(. == "pass")) | length == 3)' "$id proof has passing negative controls"
  require_yq "$proof" '.authority_boundary.canonical_control_truth_owner == "octon-local" and .authority_boundary.canonical_evidence_owner == "octon-local" and .authority_boundary.closeout_truth_owner == "octon-local"' "$id proof keeps authority local"
}

check_tools
check_contract
check_registry
check_evaluation "mcp-integration-evaluation" ".octon/instance/governance/connector-admissions/mcp/integration-evaluation/admission.yml"
check_evaluation "durable-coordination-adapter-evaluation" ".octon/instance/governance/connector-admissions/durable-coordination-adapter/evaluate-adapter/admission.yml"
check_evaluation "external-workflow-engine-adapter-evaluation" ".octon/instance/governance/connector-admissions/external-workflow-engine-adapter/evaluate-adapter/admission.yml"

echo "Validation summary: errors=$errors"
[[ "$errors" -eq 0 ]]

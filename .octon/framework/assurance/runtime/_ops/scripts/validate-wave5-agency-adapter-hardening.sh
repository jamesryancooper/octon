#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
ROOT_DIR="${OCTON_ROOT_DIR:-$(cd -- "$OCTON_DIR/.." && pwd)}"

CONTRACT_REGISTRY="$OCTON_DIR/framework/constitution/contracts/registry.yml"
ADAPTER_FAMILY="$OCTON_DIR/framework/constitution/contracts/adapters/family.yml"
SUPPORT_TARGETS="$OCTON_DIR/instance/governance/support-targets.yml"
SUPPORT_SCHEMA="$OCTON_DIR/framework/constitution/support-targets.schema.json"
CAPABILITY_PACK_SCHEMA="$OCTON_DIR/framework/constitution/contracts/adapters/capability-pack-v1.schema.json"
FRAMEWORK_PACK_REGISTRY="$OCTON_DIR/framework/capabilities/packs/registry.yml"
RUNTIME_PACK_REGISTRY="$OCTON_DIR/instance/capabilities/runtime/packs/registry.yml"
ROOT_MANIFEST="$OCTON_DIR/octon.yml"
POLICY_CONFIG="$OCTON_DIR/framework/engine/runtime/config/policy-interface.yml"
CHARTER="$OCTON_DIR/framework/constitution/CHARTER.md"
NORMATIVE_PRECEDENCE="$OCTON_DIR/framework/constitution/precedence/normative.yml"
AGENCY_MANIFEST="$OCTON_DIR/framework/agency/manifest.yml"
INGRESS="$OCTON_DIR/instance/ingress/AGENTS.md"

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
  local expr="$1"
  local file="$2"
  local label="$3"
  if yq -e "$expr" "$file" >/dev/null 2>&1; then
    pass "$label"
  else
    fail "$label"
  fi
}

require_text() {
  local needle="$1"
  local file="$2"
  local label="$3"
  if command -v rg >/dev/null 2>&1; then
    if rg -Fq "$needle" "$file"; then
      pass "$label"
    else
      fail "$label"
    fi
  else
    if grep -Fq -- "$needle" "$file"; then
      pass "$label"
    else
      fail "$label"
    fi
  fi
}

main() {
  echo "== Wave 5 Agency And Adapter Hardening Validation =="

  require_file "$ADAPTER_FAMILY"
  require_file "$SUPPORT_TARGETS"
  require_file "$SUPPORT_SCHEMA"
  require_file "$CAPABILITY_PACK_SCHEMA"
  require_file "$FRAMEWORK_PACK_REGISTRY"
  require_file "$RUNTIME_PACK_REGISTRY"

  require_yq '.families[] | select(.family_id == "adapters" and .status == "active")' "$CONTRACT_REGISTRY" "constitutional registry activates adapter contract family"
  require_yq '.integration_surfaces.adapter_contract_family.root == ".octon/framework/constitution/contracts/adapters/**"' "$CONTRACT_REGISTRY" "constitutional registry exposes adapter contract family root"
  require_yq '.integration_surfaces.runtime_adapter_roots.host == ".octon/framework/engine/runtime/adapters/host/**"' "$CONTRACT_REGISTRY" "constitutional registry exposes host adapter runtime root"
  require_yq '.integration_surfaces.runtime_adapter_roots.model == ".octon/framework/engine/runtime/adapters/model/**"' "$CONTRACT_REGISTRY" "constitutional registry exposes model adapter runtime root"
  require_yq '.integration_surfaces.runtime_capability_pack_roots.framework == ".octon/framework/capabilities/packs/**"' "$CONTRACT_REGISTRY" "constitutional registry exposes framework capability pack root"
  require_yq '.integration_surfaces.runtime_capability_pack_roots.instance == ".octon/instance/capabilities/runtime/packs/**"' "$CONTRACT_REGISTRY" "constitutional registry exposes runtime capability pack root"

  require_yq '.resolution.runtime_inputs.adapter_contract_family == ".octon/framework/constitution/contracts/adapters"' "$ROOT_MANIFEST" "root manifest exposes adapter contract family"
  require_yq '.resolution.runtime_inputs.host_adapter_root == ".octon/framework/engine/runtime/adapters/host"' "$ROOT_MANIFEST" "root manifest exposes host adapter root"
  require_yq '.resolution.runtime_inputs.model_adapter_root == ".octon/framework/engine/runtime/adapters/model"' "$ROOT_MANIFEST" "root manifest exposes model adapter root"
  require_yq '.resolution.runtime_inputs.framework_capability_pack_root == ".octon/framework/capabilities/packs"' "$ROOT_MANIFEST" "root manifest exposes framework capability pack root"
  require_yq '.resolution.runtime_inputs.runtime_capability_pack_root == ".octon/instance/capabilities/runtime/packs"' "$ROOT_MANIFEST" "root manifest exposes runtime capability pack root"

  require_yq '.paths.adapter_contract_family == ".octon/framework/constitution/contracts/adapters"' "$POLICY_CONFIG" "policy config exposes adapter contract family"
  require_yq '.paths.host_adapter_root == ".octon/framework/engine/runtime/adapters/host"' "$POLICY_CONFIG" "policy config exposes host adapter root"
  require_yq '.paths.model_adapter_root == ".octon/framework/engine/runtime/adapters/model"' "$POLICY_CONFIG" "policy config exposes model adapter root"
  require_yq '.paths.framework_capability_pack_root == ".octon/framework/capabilities/packs"' "$POLICY_CONFIG" "policy config exposes framework capability pack root"
  require_yq '.paths.runtime_capability_pack_root == ".octon/instance/capabilities/runtime/packs"' "$POLICY_CONFIG" "policy config exposes runtime capability pack root"

  require_yq '.adapter_conformance_criteria | length > 0' "$SUPPORT_TARGETS" "support-target declarations publish adapter conformance criteria"
  require_yq '.host_adapters | length > 0' "$SUPPORT_TARGETS" "support-target declarations publish host adapter envelopes"
  require_yq '.model_adapters | length > 0' "$SUPPORT_TARGETS" "support-target declarations publish model adapter envelopes"
  require_yq '.host_adapters[] | select(.adapter_id == "repo-shell" and .replaceable == true)' "$SUPPORT_TARGETS" "repo-shell host adapter is declared as replaceable"
  require_yq '.host_adapters[] | select(.adapter_id == "github-control-plane" and .authority_mode == "non_authoritative")' "$SUPPORT_TARGETS" "github control-plane host adapter is non-authoritative"
  require_yq '.host_adapters[] | select(.adapter_id == "ci-control-plane" and .authority_mode == "projection_only")' "$SUPPORT_TARGETS" "CI control-plane adapter is declared"
  require_yq '.host_adapters[] | select(.adapter_id == "studio-control-plane" and .authority_mode == "non_authoritative")' "$SUPPORT_TARGETS" "Studio control-plane adapter is declared"
  require_yq '.model_adapters[] | select(.adapter_id == "repo-local-governed" and .replaceable == true)' "$SUPPORT_TARGETS" "repo-local-governed model adapter is declared as replaceable"
  require_yq '.compatibility_matrix[] | select(.allowed_capability_packs | length > 0)' "$SUPPORT_TARGETS" "support-target matrix publishes allowed capability packs"

  require_text '"adapter_conformance_criteria"' "$SUPPORT_SCHEMA" "support-target schema requires adapter conformance criteria"
  require_text '"host_adapters"' "$SUPPORT_SCHEMA" "support-target schema requires host adapter declarations"
  require_text '"model_adapters"' "$SUPPORT_SCHEMA" "support-target schema requires model adapter declarations"
  require_text '"allowed_capability_packs"' "$SUPPORT_SCHEMA" "support-target schema requires allowed capability packs"

  require_yq '.support_target_ref == ".octon/instance/governance/support-targets.yml"' "$OCTON_DIR/framework/engine/runtime/adapters/host/repo-shell.yml" "repo-shell host manifest points to support-target declaration"
  require_yq '.host_family == "ci"' "$OCTON_DIR/framework/engine/runtime/adapters/host/ci-control-plane.yml" "CI manifest declares ci host family"
  require_yq '.host_family == "studio"' "$OCTON_DIR/framework/engine/runtime/adapters/host/studio-control-plane.yml" "Studio manifest declares studio host family"
  require_yq '.support_target_ref == ".octon/instance/governance/support-targets.yml"' "$OCTON_DIR/framework/engine/runtime/adapters/model/repo-local-governed.yml" "repo-local-governed model manifest points to support-target declaration"
  require_yq '.conformance_suite_refs | length > 0' "$OCTON_DIR/framework/engine/runtime/adapters/model/repo-local-governed.yml" "repo-local-governed model manifest declares conformance suites"
  require_yq '.contamination_reset_policy.hard_reset_on_signature == true' "$OCTON_DIR/framework/engine/runtime/adapters/model/repo-local-governed.yml" "repo-local-governed model manifest declares hard reset posture"
  require_yq '.packs[] | select(.pack_id == "browser" and .contract_ref == ".octon/framework/capabilities/packs/browser/manifest.yml")' "$FRAMEWORK_PACK_REGISTRY" "framework pack registry declares browser pack"
  require_yq '.packs[] | select(.pack_id == "api" and .admission_status == "unadmitted" and .default_route == "deny")' "$RUNTIME_PACK_REGISTRY" "runtime pack registry keeps api pack unadmitted"
  require_yq '.packs[] | select(.pack_id == "browser" and .admission_status == "unadmitted" and .default_route == "deny")' "$RUNTIME_PACK_REGISTRY" "runtime pack registry keeps browser pack unadmitted"

  require_text "one accountable orchestrator" "$CHARTER" "charter states one accountable orchestrator rule"
  require_text "replaceable, non-authoritative" "$CHARTER" "charter states adapters are replaceable and non-authoritative"
  require_text ".octon/framework/constitution/contracts/adapters/**" "$NORMATIVE_PRECEDENCE" "normative precedence includes adapter contract family"
  require_text ".octon/framework/engine/runtime/adapters/**" "$NORMATIVE_PRECEDENCE" "normative precedence includes runtime adapter roots"
  require_text ".octon/instance/capabilities/runtime/packs/**" "$NORMATIVE_PRECEDENCE" "normative precedence includes runtime capability pack root"

  require_yq '.default_agent == "orchestrator"' "$AGENCY_MANIFEST" "agency manifest defaults to orchestrator"
  require_yq '.policy.default_execution_model == "single-accountable-orchestrator"' "$AGENCY_MANIFEST" "agency manifest encodes single-orchestrator execution model"
  require_text ".octon/framework/agency/runtime/agents/orchestrator/AGENT.md" "$INGRESS" "instance ingress points to orchestrator execution contract"

  echo "Validation summary: errors=$errors"
  [[ $errors -eq 0 ]]
}

main "$@"

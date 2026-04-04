#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
ROOT_DIR="${OCTON_ROOT_DIR:-$(cd -- "$OCTON_DIR/.." && pwd)}"

CONTRACT_REGISTRY="$OCTON_DIR/framework/constitution/contracts/registry.yml"
SUPPORT_TARGETS="$OCTON_DIR/instance/governance/support-targets.yml"
RUNTIME_PACK_REGISTRY="$OCTON_DIR/instance/capabilities/runtime/packs/registry.yml"
ROOT_MANIFEST="$OCTON_DIR/octon.yml"
POLICY_CONFIG="$OCTON_DIR/framework/engine/runtime/config/policy-interface.yml"

errors=0
fail() { echo "[ERROR] $1"; errors=$((errors + 1)); }
pass() { echo "[OK] $1"; }
require_file() { [[ -f "$1" ]] && pass "found ${1#$ROOT_DIR/}" || fail "missing ${1#$ROOT_DIR/}"; }
require_yq() { yq -e "$1" "$2" >/dev/null 2>&1 && pass "$3" || fail "$3"; }

main() {
  echo "== Global Adapter And Pack Hardening Validation =="

  require_file "$CONTRACT_REGISTRY"
  require_file "$SUPPORT_TARGETS"
  require_file "$RUNTIME_PACK_REGISTRY"
  require_file "$OCTON_DIR/framework/engine/runtime/adapters/host/repo-shell.yml"
  require_file "$OCTON_DIR/framework/engine/runtime/adapters/host/studio-control-plane.yml"
  require_file "$OCTON_DIR/framework/engine/runtime/adapters/host/github-control-plane.yml"
  require_file "$OCTON_DIR/framework/engine/runtime/adapters/host/ci-control-plane.yml"
  require_file "$OCTON_DIR/framework/engine/runtime/adapters/model/repo-local-governed.yml"
  require_file "$OCTON_DIR/framework/engine/runtime/adapters/model/frontier-governed.yml"
  require_file "$OCTON_DIR/framework/capabilities/packs/browser/tests/browser-pack-admission.yml"
  require_file "$OCTON_DIR/framework/capabilities/packs/api/tests/api-pack-admission.yml"

  require_yq '.integration_surfaces.runtime_service_roots.replay_store == ".octon/framework/engine/runtime/crates/replay_store/**"' "$CONTRACT_REGISTRY" "contract registry exposes replay_store"
  require_yq '.integration_surfaces.runtime_service_roots.telemetry_sink == ".octon/framework/engine/runtime/crates/telemetry_sink/**"' "$CONTRACT_REGISTRY" "contract registry exposes telemetry_sink"
  require_yq '.integration_surfaces.runtime_service_roots.runtime_bus == ".octon/framework/engine/runtime/crates/runtime_bus/**"' "$CONTRACT_REGISTRY" "contract registry exposes runtime_bus"
  require_yq '.resolution.runtime_inputs.governance_exclusions == ".octon/instance/governance/exclusions/action-classes.yml"' "$ROOT_MANIFEST" "root manifest exposes governance exclusions"
  require_yq '.paths.governance_exclusions == ".octon/instance/governance/exclusions/action-classes.yml"' "$POLICY_CONFIG" "policy config exposes governance exclusions"
  require_yq '.paths.runtime_bus_root == ".octon/framework/engine/runtime/crates/runtime_bus"' "$POLICY_CONFIG" "policy config exposes runtime_bus"

  require_yq '[.host_adapters[] | select(.support_status == "supported")] | length == 4' "$SUPPORT_TARGETS" "all retained host adapters are supported"
  require_yq '[.model_adapters[] | select(.support_status == "supported")] | length == 2' "$SUPPORT_TARGETS" "all retained model adapters are supported"
  require_yq '.packs[] | select(.pack_id == "browser" and .admission_status == "admitted" and .default_route == "allow")' "$RUNTIME_PACK_REGISTRY" "browser pack is admitted"
  require_yq '.packs[] | select(.pack_id == "api" and .admission_status == "admitted" and .default_route == "allow")' "$RUNTIME_PACK_REGISTRY" "api pack is admitted"

  require_yq '.host_adapters[] | select(.adapter_id == "studio-control-plane" and .allowed_locale_tiers[] == "spanish-secondary")' "$SUPPORT_TARGETS" "Studio supports the final locale universe"
  require_yq '.model_adapters[] | select(.adapter_id == "frontier-governed" and .allowed_workload_tiers[] == "boundary-sensitive")' "$SUPPORT_TARGETS" "frontier-governed supports boundary-sensitive work"

  echo "Validation summary: errors=$errors"
  [[ $errors -eq 0 ]]
}

main "$@"

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

  local github_dossier_ref github_dossier_path
  github_dossier_ref="$(yq -r '.tuple_admissions[] | select(.tuple_id == "tuple://repo-local-governed/repo-consequential/reference-owned/english-primary/github-control-plane") | .support_dossier_ref // ""' "$SUPPORT_TARGETS")"
  github_dossier_path="$ROOT_DIR/$github_dossier_ref"

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

  require_yq '.live_support_universe.host_adapters[] | select(. == "repo-shell")' "$SUPPORT_TARGETS" "repo-shell is live supported"
  require_yq '.live_support_universe.host_adapters[] | select(. == "github-control-plane")' "$SUPPORT_TARGETS" "github-control-plane is live supported"
  require_yq '.tuple_admissions[] | select(.tuple_id == "tuple://repo-local-governed/repo-consequential/reference-owned/english-primary/github-control-plane" and .claim_effect == "admitted-live-claim")' "$SUPPORT_TARGETS" "github-control-plane tuple stays admitted live"
  require_yq '.admitted_capability_packs | length == 4' "$github_dossier_path" "github-control-plane live claim stays narrow"
  require_yq '.admitted_capability_packs[] | select(. == "repo")' "$github_dossier_path" "github-control-plane includes repo pack"
  require_yq '.admitted_capability_packs[] | select(. == "git")' "$github_dossier_path" "github-control-plane includes git pack"
  require_yq '.admitted_capability_packs[] | select(. == "shell")' "$github_dossier_path" "github-control-plane includes shell pack"
  require_yq '.admitted_capability_packs[] | select(. == "telemetry")' "$github_dossier_path" "github-control-plane includes telemetry pack"
  require_yq '.known_exclusions[] | select(test("api-client remains unadmitted"))' "$github_dossier_path" "github-control-plane excludes broader api surfaces"
  require_yq '.live_support_universe.host_adapters[] | select(. == "ci-control-plane")' "$SUPPORT_TARGETS" "ci-control-plane is live supported"
  require_yq '.resolved_non_live_surfaces.host_adapters[] | select(. == "studio-control-plane")' "$SUPPORT_TARGETS" "studio-control-plane is explicitly non-live"
  require_yq '.live_support_universe.model_adapters[] | select(. == "repo-local-governed")' "$SUPPORT_TARGETS" "repo-local-governed is live supported"
  require_yq '.resolved_non_live_surfaces.model_adapters[] | select(. == "frontier-governed")' "$SUPPORT_TARGETS" "frontier-governed is explicitly non-live"
  require_yq '.packs[] | select(.pack_id == "browser" and .admission_status == "unadmitted")' "$RUNTIME_PACK_REGISTRY" "browser pack is unadmitted"
  require_yq '.packs[] | select(.pack_id == "api" and .admission_status == "unadmitted")' "$RUNTIME_PACK_REGISTRY" "api pack is unadmitted"

  require_yq '.resolved_non_live_surfaces.locale_classes[] | select(. == "spanish-secondary")' "$SUPPORT_TARGETS" "spanish-secondary locale is explicitly non-live"
  require_yq '.resolved_non_live_surfaces.workload_classes[] | select(. == "boundary-sensitive")' "$SUPPORT_TARGETS" "boundary-sensitive work is explicitly non-live"

  echo "Validation summary: errors=$errors"
  [[ $errors -eq 0 ]]
}

main "$@"

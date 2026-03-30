#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
ROOT_DIR="${OCTON_ROOT_DIR:-$(cd -- "$OCTON_DIR/.." && pwd)}"

RUNTIME_FAMILY_DIR="$OCTON_DIR/framework/constitution/contracts/runtime"
RUNTIME_FAMILY_FILE="$RUNTIME_FAMILY_DIR/family.yml"
CONTRACT_REGISTRY="$OCTON_DIR/framework/constitution/contracts/registry.yml"
ROOT_MANIFEST="$OCTON_DIR/octon.yml"
POLICY_CONFIG="$OCTON_DIR/framework/engine/runtime/config/policy-interface.yml"
RUN_CONTROL_README="$OCTON_DIR/state/control/execution/runs/README.md"
RUN_EVIDENCE_README="$OCTON_DIR/state/evidence/runs/README.md"
WRITE_RUN_SCRIPT="$OCTON_DIR/framework/orchestration/runtime/_ops/scripts/write-run.sh"
AUTHORIZATION_RS="$OCTON_DIR/framework/engine/runtime/crates/kernel/src/authorization.rs"
SYNC_SCRIPT="$OCTON_DIR/framework/cognition/_ops/runtime/scripts/sync-runtime-artifacts.sh"
MISSION_VIEW_SCHEMA="$OCTON_DIR/framework/engine/runtime/spec/mission-view-v1.schema.json"
MIGRATION_PLAN="$OCTON_DIR/instance/cognition/context/shared/migrations/2026-03-29-unified-execution-constitution-phase3-runtime-evidence-normalization/plan.md"

errors=0
fail() { echo "[ERROR] $1"; errors=$((errors + 1)); }
pass() { echo "[OK] $1"; }

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
  echo "== Runtime Lifecycle Normalization Validation =="

  require_file "$RUNTIME_FAMILY_FILE"
  require_file "$MIGRATION_PLAN"
  require_file "$MISSION_VIEW_SCHEMA"
  require_file "$WRITE_RUN_SCRIPT"
  require_file "$AUTHORIZATION_RS"
  require_file "$SYNC_SCRIPT"

  require_yq '.families[] | select(.family_id == "runtime" and .status == "active")' "$CONTRACT_REGISTRY" "constitutional registry activates runtime contract family"
  require_yq '.integration_surfaces.runtime_contract_family.root == ".octon/framework/constitution/contracts/runtime/**"' "$CONTRACT_REGISTRY" "constitutional registry exposes runtime contract family root"
  require_yq '.integration_surfaces.run_evidence_root.path == ".octon/state/evidence/runs/**"' "$CONTRACT_REGISTRY" "constitutional registry exposes canonical run evidence root"
  require_yq '.schema_version == "octon-constitutional-runtime-family-v1"' "$RUNTIME_FAMILY_FILE" "runtime family schema version is correct"
  require_yq '.release_state == "pre-1.0"' "$RUNTIME_FAMILY_FILE" "runtime family records release_state"
  require_yq '.change_profile == "atomic"' "$RUNTIME_FAMILY_FILE" "runtime family records atomic profile"
  require_yq '.profile_selection_receipt_ref == ".octon/instance/cognition/context/shared/migrations/2026-03-29-unified-execution-constitution-phase3-runtime-evidence-normalization/plan.md"' "$RUNTIME_FAMILY_FILE" "runtime family points to the Phase 3 profile receipt"
  require_yq '.run_lifecycle.run_manifest.canonical_file == "run-manifest.yml"' "$RUNTIME_FAMILY_FILE" "runtime family defines run-manifest placement"
  require_yq '.run_lifecycle.runtime_state.canonical_file == "runtime-state.yml"' "$RUNTIME_FAMILY_FILE" "runtime family defines runtime-state placement"
  require_yq '.run_lifecycle.rollback_posture.canonical_file == "rollback-posture.yml"' "$RUNTIME_FAMILY_FILE" "runtime family defines rollback-posture placement"
  require_yq '.run_lifecycle.checkpoints.canonical_dir == "checkpoints"' "$RUNTIME_FAMILY_FILE" "runtime family defines checkpoint placement"
  require_yq '.run_lifecycle.replay_pointers.canonical_file == "replay-pointers.yml"' "$RUNTIME_FAMILY_FILE" "runtime family defines replay pointer placement"

  require_yq '.resolution.runtime_inputs.runtime_contract_family == ".octon/framework/constitution/contracts/runtime"' "$ROOT_MANIFEST" "root manifest exposes runtime contract family"
  require_yq '.resolution.runtime_inputs.run_manifest_file == ".octon/state/control/execution/runs/<run-id>/run-manifest.yml"' "$ROOT_MANIFEST" "root manifest exposes run-manifest placement"
  require_yq '.resolution.runtime_inputs.run_evidence_root == ".octon/state/evidence/runs"' "$ROOT_MANIFEST" "root manifest exposes canonical run evidence root"
  require_yq '.resolution.runtime_inputs.run_evidence_classification_file == ".octon/state/evidence/runs/<run-id>/evidence-classification.yml"' "$ROOT_MANIFEST" "root manifest exposes evidence classification placement"
  require_yq '.paths.runtime_contract_family == ".octon/framework/constitution/contracts/runtime"' "$POLICY_CONFIG" "policy config exposes runtime contract family"
  require_yq '.paths.run_manifest_file == ".octon/state/control/execution/runs/<run-id>/run-manifest.yml"' "$POLICY_CONFIG" "policy config exposes run-manifest placement"
  require_yq '.paths.run_evidence_root == ".octon/state/evidence/runs"' "$POLICY_CONFIG" "policy config exposes canonical run evidence root"
  require_yq '.paths.run_evidence_classification_file == ".octon/state/evidence/runs/<run-id>/evidence-classification.yml"' "$POLICY_CONFIG" "policy config exposes evidence classification placement"
  require_yq '.required[] | select(. == "run_evidence_refs")' "$MISSION_VIEW_SCHEMA" "mission-view schema requires run_evidence_refs"

  require_text "run-manifest.yml" "$RUN_CONTROL_README" "run control README documents run-manifest placement"
  require_text "runtime-state.yml" "$RUN_CONTROL_README" "run control README documents runtime-state placement"
  require_text "rollback-posture.yml" "$RUN_CONTROL_README" "run control README documents rollback posture placement"
  require_text "replay-pointers.yml" "$RUN_EVIDENCE_README" "run evidence README documents replay pointers"
  require_text "evidence-classification.yml" "$RUN_EVIDENCE_README" "run evidence README documents evidence classification"
  require_text "retained-run-evidence.yml" "$RUN_EVIDENCE_README" "run evidence README documents retained evidence manifest"

  require_text "write_run_manifest_file" "$WRITE_RUN_SCRIPT" "write-run script seeds run-manifest"
  require_text "write_runtime_state_file" "$WRITE_RUN_SCRIPT" "write-run script seeds runtime-state"
  require_text "write_rollback_posture_file" "$WRITE_RUN_SCRIPT" "write-run script seeds rollback posture"
  require_text "write_replay_pointer_file" "$WRITE_RUN_SCRIPT" "write-run script seeds replay pointers"
  require_text "write_evidence_classification_file" "$WRITE_RUN_SCRIPT" "write-run script seeds evidence classification"
  require_text "bind_run_lifecycle" "$AUTHORIZATION_RS" "authorization path binds canonical run lifecycle roots"
  require_text "bound_run_from_grant" "$AUTHORIZATION_RS" "execution start/finalize reuse canonical bound run roots"
  require_text "run_evidence_refs:" "$SYNC_SCRIPT" "mission generator emits per-run evidence refs"

  echo "Validation summary: errors=$errors"
  [[ $errors -eq 0 ]]
}

main "$@"

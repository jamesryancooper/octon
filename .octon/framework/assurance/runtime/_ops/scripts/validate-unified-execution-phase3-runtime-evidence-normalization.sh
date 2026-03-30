#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
ROOT_DIR="${OCTON_ROOT_DIR:-$(cd -- "$OCTON_DIR/.." && pwd)}"

RUN3_ID="run-wave3-runtime-bridge-20260327"
RUN4_ID="run-wave4-benchmark-evaluator-20260327"
RUN3_MANIFEST="$OCTON_DIR/state/control/execution/runs/$RUN3_ID/run-manifest.yml"
RUN4_MANIFEST="$OCTON_DIR/state/control/execution/runs/$RUN4_ID/run-manifest.yml"
RUN3_STATE="$OCTON_DIR/state/control/execution/runs/$RUN3_ID/runtime-state.yml"
RUN4_STATE="$OCTON_DIR/state/control/execution/runs/$RUN4_ID/runtime-state.yml"
RUN3_CONTINUITY="$OCTON_DIR/state/continuity/runs/$RUN3_ID/handoff.yml"
RUN4_CONTINUITY="$OCTON_DIR/state/continuity/runs/$RUN4_ID/handoff.yml"
RUN3_CLASSIFICATION="$OCTON_DIR/state/evidence/runs/$RUN3_ID/evidence-classification.yml"
RUN4_CLASSIFICATION="$OCTON_DIR/state/evidence/runs/$RUN4_ID/evidence-classification.yml"
RUN3_REPLAY="$OCTON_DIR/state/evidence/runs/$RUN3_ID/replay-pointers.yml"
RUN4_REPLAY="$OCTON_DIR/state/evidence/runs/$RUN4_ID/replay-pointers.yml"
RUN4_REPLAY_MANIFEST="$OCTON_DIR/state/evidence/runs/$RUN4_ID/replay/manifest.yml"
RUN4_EXTERNAL_INDEX="$OCTON_DIR/state/evidence/external-index/runs/$RUN4_ID.yml"
RETENTION_FAMILY="$OCTON_DIR/framework/constitution/contracts/retention/family.yml"
DISCLOSURE_RETENTION="$OCTON_DIR/instance/governance/contracts/disclosure-retention.yml"

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

main() {
  echo "== Unified Execution Constitution Phase 3 Validation =="

  require_file "$RUN3_MANIFEST"
  require_file "$RUN4_MANIFEST"
  require_file "$RUN3_STATE"
  require_file "$RUN4_STATE"
  require_file "$RUN3_CONTINUITY"
  require_file "$RUN4_CONTINUITY"
  require_file "$RUN3_CLASSIFICATION"
  require_file "$RUN4_CLASSIFICATION"
  require_file "$RUN3_REPLAY"
  require_file "$RUN4_REPLAY"
  require_file "$RUN4_REPLAY_MANIFEST"
  require_file "$RUN4_EXTERNAL_INDEX"
  require_file "$RETENTION_FAMILY"
  require_file "$DISCLOSURE_RETENTION"

  require_yq '.run_manifest_ref == ".octon/state/control/execution/runs/run-wave3-runtime-bridge-20260327/run-manifest.yml"' "$RUN3_STATE" "Wave 3 runtime-state points at run manifest"
  require_yq '.run_manifest_ref == ".octon/state/control/execution/runs/run-wave4-benchmark-evaluator-20260327/run-manifest.yml"' "$RUN4_STATE" "Wave 4 runtime-state points at run manifest"
  require_yq '.replay_pointers_ref | test("/replay-pointers\\.yml$")' "$RUN3_CONTINUITY" "Wave 3 continuity points at replay pointers"
  require_yq '.replay_pointers_ref | test("/replay-pointers\\.yml$")' "$RUN4_CONTINUITY" "Wave 4 continuity points at replay pointers"
  require_yq '.evidence_classification_ref | test("/evidence-classification\\.yml$")' "$RUN3_CONTINUITY" "Wave 3 continuity points at evidence classification"
  require_yq '.evidence_classification_ref | test("/evidence-classification\\.yml$")' "$RUN4_CONTINUITY" "Wave 4 continuity points at evidence classification"

  require_yq '.evidence_classes[] | select(.class_id == "A" and .canonical_storage_class == "git-inline")' "$RETENTION_FAMILY" "Retention family defines Class A"
  require_yq '.evidence_classes[] | select(.class_id == "B" and .canonical_storage_class == "git-pointer")' "$RETENTION_FAMILY" "Retention family defines Class B"
  require_yq '.evidence_classes[] | select(.class_id == "C" and .canonical_storage_class == "external-immutable")' "$RETENTION_FAMILY" "Retention family defines Class C"
  require_yq '.supported_run_classes."release-and-boundary-sensitive".external_index_required == true' "$DISCLOSURE_RETENTION" "Boundary-sensitive run class requires external replay index"

  require_yq '.artifacts[] | select(.artifact_id == "run-manifest" and .evidence_class == "A")' "$RUN3_CLASSIFICATION" "Wave 3 classification records manifest as Class A"
  require_yq '.artifacts[] | select(.artifact_id == "replay-manifest" and .evidence_class == "B" and .storage_class == "git-pointer")' "$RUN3_CLASSIFICATION" "Wave 3 classification records replay manifest as Class B"
  require_yq '.artifacts[] | select(.artifact_id == "external-replay-index" and .evidence_class == "C" and .storage_class == "external-immutable")' "$RUN4_CLASSIFICATION" "Wave 4 classification records external replay index as Class C"

  require_yq '.external_index_refs | length > 0' "$RUN4_REPLAY" "Wave 4 replay pointers cite external index"
  require_yq '.replay_payload_class == "external-immutable"' "$RUN4_REPLAY_MANIFEST" "Wave 4 replay manifest requires external immutable payload"
  require_yq '.external_index_refs[] == ".octon/state/evidence/external-index/runs/run-wave4-benchmark-evaluator-20260327.yml"' "$RUN4_REPLAY_MANIFEST" "Wave 4 replay manifest links canonical external index"
  require_yq '.entries[] | select(.artifact_kind == "replay-payload" and .storage_class == "external-immutable")' "$RUN4_EXTERNAL_INDEX" "Wave 4 external index retains immutable replay payload"
  require_yq '.entries[] | select(.artifact_kind == "trace-payload" and .storage_class == "external-immutable")' "$RUN4_EXTERNAL_INDEX" "Wave 4 external index retains immutable trace payload"

  echo "Validation summary: errors=$errors"
  [[ $errors -eq 0 ]]
}

main "$@"

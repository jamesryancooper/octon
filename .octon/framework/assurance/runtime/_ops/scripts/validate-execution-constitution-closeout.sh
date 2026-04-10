#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
ROOT_DIR="${OCTON_ROOT_DIR:-$(cd -- "$OCTON_DIR/.." && pwd)}"

CONTRACT_REGISTRY="$OCTON_DIR/framework/constitution/contracts/registry.yml"
RETENTION_FAMILY="$OCTON_DIR/framework/constitution/contracts/retention/family.yml"
RUN_CONTINUITY_ROOT="$OCTON_DIR/state/continuity/runs"
EXTERNAL_INDEX_ROOT="$OCTON_DIR/state/evidence/external-index"
GOVERNANCE_CONTRACTS="$OCTON_DIR/instance/governance/contracts"
RETIREMENT_POLICY="$GOVERNANCE_CONTRACTS/retirement-policy.yml"
RETIREMENT_REGISTRY="$GOVERNANCE_CONTRACTS/retirement-registry.yml"
DRIFT_REVIEW_CONTRACT="$GOVERNANCE_CONTRACTS/drift-review.yml"
SUPPORT_TARGET_REVIEW_CONTRACT="$GOVERNANCE_CONTRACTS/support-target-review.yml"
ADAPTER_REVIEW_CONTRACT="$GOVERNANCE_CONTRACTS/adapter-review.yml"
RETIREMENT_REVIEW_CONTRACT="$GOVERNANCE_CONTRACTS/retirement-review.yml"
ABLATION_WORKFLOW_CONTRACT="$GOVERNANCE_CONTRACTS/ablation-deletion-workflow.yml"
CLOSEOUT_REVIEWS_CONTRACT="$GOVERNANCE_CONTRACTS/closeout-reviews.yml"
BUILD_TO_DELETE_REVIEWS="$(yq -r '.latest_review_packet // ""' "$CLOSEOUT_REVIEWS_CONTRACT" 2>/dev/null || true)"
RUN3="$OCTON_DIR/framework/orchestration/runtime/runs/run-wave3-runtime-bridge-20260327.yml"
RUN4="$OCTON_DIR/framework/orchestration/runtime/runs/run-wave4-benchmark-evaluator-20260327.yml"
RUNCARD3="$OCTON_DIR/state/evidence/disclosure/runs/run-wave3-runtime-bridge-20260327/run-card.yml"
RUNCARD4="$OCTON_DIR/state/evidence/disclosure/runs/run-wave4-benchmark-evaluator-20260327/run-card.yml"
HARNESS_CARD_SOURCE="$OCTON_DIR/instance/governance/disclosure/harness-card.yml"
HARNESS_CARD_RELEASE="$OCTON_DIR/state/evidence/disclosure/releases/2026-03-30-unified-execution-constitution-atomic-cutover/harness-card.yml"
RUN3_MANIFEST="$OCTON_DIR/state/control/execution/runs/run-wave3-runtime-bridge-20260327/run-manifest.yml"
RUN4_MANIFEST="$OCTON_DIR/state/control/execution/runs/run-wave4-benchmark-evaluator-20260327/run-manifest.yml"
RUN3_CLASSIFICATION="$OCTON_DIR/state/evidence/runs/run-wave3-runtime-bridge-20260327/evidence-classification.yml"
RUN4_CLASSIFICATION="$OCTON_DIR/state/evidence/runs/run-wave4-benchmark-evaluator-20260327/evidence-classification.yml"
RUN4_EXTERNAL_INDEX="$OCTON_DIR/state/evidence/external-index/runs/run-wave4-benchmark-evaluator-20260327.yml"

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

require_dir() {
  local path="$1"
  if [[ -d "$path" ]]; then
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
  echo "== Execution Constitution Closeout Validation =="

  require_file "$CONTRACT_REGISTRY"
  require_file "$RETENTION_FAMILY"
  require_dir "$RUN_CONTINUITY_ROOT"
  require_dir "$EXTERNAL_INDEX_ROOT"
  require_dir "$OCTON_DIR/state/evidence/disclosure"
  require_dir "$OCTON_DIR/instance/governance/disclosure"
  require_dir "$GOVERNANCE_CONTRACTS"
  if [[ -f "$OCTON_DIR/state/control/execution/exception-leases.yml" ]]; then
    fail "legacy flat exception-leases.yml must be deleted"
  else
    pass "legacy flat exception-leases.yml is deleted"
  fi
  if [[ -z "$BUILD_TO_DELETE_REVIEWS" ]]; then
    fail "closeout review contract does not publish latest_review_packet"
  elif [[ "$BUILD_TO_DELETE_REVIEWS" == .octon/* ]]; then
    BUILD_TO_DELETE_REVIEWS="$ROOT_DIR/${BUILD_TO_DELETE_REVIEWS#./}"
  fi
  require_dir "$BUILD_TO_DELETE_REVIEWS"
  require_file "$RETIREMENT_POLICY"
  require_file "$RETIREMENT_REGISTRY"
  require_file "$DRIFT_REVIEW_CONTRACT"
  require_file "$SUPPORT_TARGET_REVIEW_CONTRACT"
  require_file "$ADAPTER_REVIEW_CONTRACT"
  require_file "$RETIREMENT_REVIEW_CONTRACT"
  require_file "$ABLATION_WORKFLOW_CONTRACT"
  require_file "$CLOSEOUT_REVIEWS_CONTRACT"
  require_file "$GOVERNANCE_CONTRACTS/disclosure-retention.yml"
  require_file "$RUN3"
  require_file "$RUN4"
  require_file "$RUN3_MANIFEST"
  require_file "$RUN4_MANIFEST"
  require_file "$RUNCARD3"
  require_file "$RUNCARD4"
  require_file "$HARNESS_CARD_SOURCE"
  require_file "$HARNESS_CARD_RELEASE"
  require_file "$RUN3_CLASSIFICATION"
  require_file "$RUN4_CLASSIFICATION"
  require_file "$RUN4_EXTERNAL_INDEX"
  require_file "$RUN_CONTINUITY_ROOT/run-wave3-runtime-bridge-20260327/handoff.yml"
  require_file "$RUN_CONTINUITY_ROOT/run-wave4-benchmark-evaluator-20260327/handoff.yml"
  require_file "$BUILD_TO_DELETE_REVIEWS/drift-review.yml"
  require_file "$BUILD_TO_DELETE_REVIEWS/support-target-review.yml"
  require_file "$BUILD_TO_DELETE_REVIEWS/adapter-review.yml"
  require_file "$BUILD_TO_DELETE_REVIEWS/retirement-review.yml"
  require_file "$BUILD_TO_DELETE_REVIEWS/ablation-deletion-receipt.yml"

  require_yq '.families[] | select(.family_id == "retention" and .status == "active")' "$CONTRACT_REGISTRY" "constitutional registry activates retention family"
  require_yq '.required[] | select(. == "support_target")' "$OCTON_DIR/framework/constitution/contracts/objective/run-contract-v1.schema.json" "run-contract schema requires support_target tuple"
  require_yq '.required[] | select(. == "support_target")' "$OCTON_DIR/framework/constitution/contracts/runtime/run-manifest-v1.schema.json" "run-manifest schema requires support_target tuple"
  require_yq '.required[] | select(. == "support_target_tuple")' "$OCTON_DIR/framework/constitution/contracts/disclosure/run-card-v1.schema.json" "run-card schema requires support_target_tuple"
  require_yq '.integration_surfaces.run_continuity_root.path == ".octon/state/continuity/runs/**"' "$CONTRACT_REGISTRY" "contract registry exposes run continuity root"
  require_yq '.integration_surfaces.external_evidence_index_root.path == ".octon/state/evidence/external-index/**"' "$CONTRACT_REGISTRY" "contract registry exposes external evidence index root"
  require_yq '.integration_surfaces.build_to_delete_review_evidence_root.path == ".octon/state/evidence/validation/publication/build-to-delete/**"' "$CONTRACT_REGISTRY" "contract registry exposes build-to-delete review evidence root"
  require_yq '.status == "active"' "$RETENTION_FAMILY" "retention family is active"

  require_yq '.schema_version == "repo-retirement-policy-v2"' "$RETIREMENT_POLICY" "retirement policy upgraded to Phase 7 schema"
  require_yq '.registry_ref == ".octon/instance/governance/contracts/retirement-registry.yml"' "$RETIREMENT_POLICY" "retirement policy points at retirement registry"
  require_yq '.ablation_workflow_ref == ".octon/instance/governance/contracts/ablation-deletion-workflow.yml"' "$RETIREMENT_POLICY" "retirement policy points at ablation workflow"
  require_yq '.review_set_ref == ".octon/instance/governance/contracts/closeout-reviews.yml"' "$RETIREMENT_POLICY" "retirement policy points at closeout review set"

  require_yq '.review_set_id == "execution-constitution-build-to-delete"' "$CLOSEOUT_REVIEWS_CONTRACT" "closeout review set upgraded to build-to-delete packet"
  require_yq '.latest_review_packet | test("^\\.octon/state/evidence/validation/publication/build-to-delete/[0-9]{4}-[0-9]{2}-[0-9]{2}([-/][A-Za-z0-9._-]+)?$")' "$CLOSEOUT_REVIEWS_CONTRACT" "closeout reviews publish a canonical latest review packet path"
  require_yq '.required_reviews[] | select(.review_id == "drift-review" and .contract_ref == ".octon/instance/governance/contracts/drift-review.yml")' "$CLOSEOUT_REVIEWS_CONTRACT" "closeout reviews require drift review"
  require_yq '.required_reviews[] | select(.review_id == "support-target-review" and .contract_ref == ".octon/instance/governance/contracts/support-target-review.yml")' "$CLOSEOUT_REVIEWS_CONTRACT" "closeout reviews require support-target review"
  require_yq '.required_reviews[] | select(.review_id == "adapter-review" and .contract_ref == ".octon/instance/governance/contracts/adapter-review.yml")' "$CLOSEOUT_REVIEWS_CONTRACT" "closeout reviews require adapter review"
  require_yq '.required_reviews[] | select(.review_id == "retirement-review" and .contract_ref == ".octon/instance/governance/contracts/retirement-review.yml")' "$CLOSEOUT_REVIEWS_CONTRACT" "closeout reviews require retirement review"
  require_yq '.required_workflows[] | select(.workflow_id == "ablation-driven-deletion" and .contract_ref == ".octon/instance/governance/contracts/ablation-deletion-workflow.yml")' "$CLOSEOUT_REVIEWS_CONTRACT" "closeout reviews require ablation workflow"

  require_yq '.entries[] | select(.target_id == "workspace-objective-compatibility-shims" and .status == "retained-noncritical")' "$RETIREMENT_REGISTRY" "retirement registry tracks workspace-objective compatibility shims"
  require_yq '.entries[] | select(.target_id == "duplicate-constitutional-shims" and .status == "historical-retained-noncritical")' "$RETIREMENT_REGISTRY" "retirement registry tracks duplicate constitutional shims"
  require_yq '.entries[] | select(.target_id == "runtime-agent-soul-overlays" and .status == "retired")' "$RETIREMENT_REGISTRY" "retirement registry records retired SOUL overlays"
  require_yq '.entries[] | select(.target_id == "label-native-authority-lane-projections" and .status == "retired")' "$RETIREMENT_REGISTRY" "retirement registry records retired label projections"

  require_yq '.status == "approved"' "$BUILD_TO_DELETE_REVIEWS/drift-review.yml" "drift review receipt is approved"
  require_yq '.status == "approved"' "$BUILD_TO_DELETE_REVIEWS/support-target-review.yml" "support-target review receipt is approved"
  require_yq '.status == "approved"' "$BUILD_TO_DELETE_REVIEWS/adapter-review.yml" "adapter review receipt is approved"
  require_yq '.status == "approved"' "$BUILD_TO_DELETE_REVIEWS/retirement-review.yml" "retirement review receipt is approved"
  require_yq '.status == "completed"' "$BUILD_TO_DELETE_REVIEWS/ablation-deletion-receipt.yml" "ablation deletion receipt is completed"
  require_yq '.targets_evaluated[] | select(.target_id == "runtime-agent-soul-overlays" and .decision == "delete")' "$BUILD_TO_DELETE_REVIEWS/ablation-deletion-receipt.yml" "ablation receipt records deleted SOUL overlays"
  require_yq '.targets_evaluated[] | select(.target_id == "label-native-authority-lane-projections" and .decision == "delete")' "$BUILD_TO_DELETE_REVIEWS/ablation-deletion-receipt.yml" "ablation receipt records deleted label projections"

  require_yq '.continuity_run_path == ".octon/state/continuity/runs/run-wave3-runtime-bridge-20260327/"' "$RUN3" "Wave 3 run projection points at run continuity root"
  require_yq '.continuity_run_path == ".octon/state/continuity/runs/run-wave4-benchmark-evaluator-20260327/"' "$RUN4" "Wave 4 run projection points at run continuity root"
  require_yq '.run_manifest_path == ".octon/state/control/execution/runs/run-wave3-runtime-bridge-20260327/run-manifest.yml"' "$RUN3" "Wave 3 run projection points at canonical run manifest"
  require_yq '.run_manifest_path == ".octon/state/control/execution/runs/run-wave4-benchmark-evaluator-20260327/run-manifest.yml"' "$RUN4" "Wave 4 run projection points at canonical run manifest"
  require_yq '.run_card_path == ".octon/state/evidence/disclosure/runs/run-wave3-runtime-bridge-20260327/run-card.yml"' "$RUN3" "Wave 3 run projection points at canonical run disclosure"
  require_yq '.run_card_path == ".octon/state/evidence/disclosure/runs/run-wave4-benchmark-evaluator-20260327/run-card.yml"' "$RUN4" "Wave 4 run projection points at canonical run disclosure"
  require_yq '.authority_decision_ref | test("^\\.octon/state/evidence/control/execution/")' "$RUN3" "Wave 3 run projection points at canonical authority evidence"
  require_yq '.authority_decision_ref | test("^\\.octon/state/evidence/control/execution/")' "$RUN4" "Wave 4 run projection points at canonical authority evidence"
  require_yq '.disclosure_root | test("^\\.octon/state/evidence/disclosure/runs/")' "$RUN3_MANIFEST" "Wave 3 manifest points at canonical disclosure root"
  require_yq '.disclosure_root | test("^\\.octon/state/evidence/disclosure/runs/")' "$RUN4_MANIFEST" "Wave 4 manifest points at canonical disclosure root"
  require_yq '.evidence_classification_ref | test("/evidence-classification\\.yml$")' "$RUN3_MANIFEST" "Wave 3 manifest points at evidence classification"
  require_yq '.evidence_classification_ref | test("/evidence-classification\\.yml$")' "$RUN4_MANIFEST" "Wave 4 manifest points at evidence classification"
  require_yq '.external_replay_index_ref | test("^\\.octon/state/evidence/external-index/")' "$RUN4_MANIFEST" "Wave 4 manifest points at external replay index"
  require_yq '.artifacts[] | select(.artifact_id == "external-replay-index" and .evidence_class == "C")' "$RUN4_CLASSIFICATION" "Wave 4 evidence classification records Class C external payload"
  require_yq '.entries[] | select(.artifact_kind == "replay-payload" and .storage_class == "external-immutable")' "$RUN4_EXTERNAL_INDEX" "Wave 4 external replay index records immutable replay payload"

  require_yq '.authority_refs.decision_artifact | test("^\\.octon/state/evidence/control/execution/")' "$RUNCARD3" "Wave 3 RunCard cites canonical authority decision"
  require_yq '.authority_refs.grant_bundle | test("^\\.octon/state/evidence/control/execution/")' "$RUNCARD3" "Wave 3 RunCard cites canonical authority grant bundle"
  require_yq '.proof_plane_refs.structural | test("/assurance/structural\\.yml$")' "$RUNCARD3" "Wave 3 RunCard cites structural proof"
  require_yq '.proof_plane_refs.governance | test("/assurance/governance\\.yml$")' "$RUNCARD3" "Wave 3 RunCard cites governance proof"
  require_yq '.authority_refs.decision_artifact | test("^\\.octon/state/evidence/control/execution/")' "$RUNCARD4" "Wave 4 RunCard cites canonical authority decision"
  require_yq '.authority_refs.grant_bundle | test("^\\.octon/state/evidence/control/execution/")' "$RUNCARD4" "Wave 4 RunCard cites canonical authority grant bundle"
  require_yq '.proof_plane_refs.structural | test("/assurance/structural\\.yml$")' "$RUNCARD4" "Wave 4 RunCard cites structural proof"
  require_yq '.proof_plane_refs.governance | test("/assurance/governance\\.yml$")' "$RUNCARD4" "Wave 4 RunCard cites governance proof"
  require_yq '.schema_version == "harness-card-v2"' "$HARNESS_CARD_SOURCE" "governance disclosure source publishes a HarnessCard"
  require_yq '.claim_kind == "release"' "$HARNESS_CARD_RELEASE" "release disclosure packet publishes the live release HarnessCard"

  echo "Validation summary: errors=$errors"
  [[ $errors -eq 0 ]]
}

main "$@"

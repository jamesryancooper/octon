#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../.." && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
ROOT_DIR="${OCTON_ROOT_DIR:-$(cd -- "$OCTON_DIR/.." && pwd)}"

CLOSURE_MANIFEST="$OCTON_DIR/instance/governance/closure/unified-execution-constitution.yml"
STATUS_MATRIX="$OCTON_DIR/instance/governance/closure/unified-execution-constitution-status.yml"
CLLOSEOUT_REVIEWS="$OCTON_DIR/instance/governance/contracts/closeout-reviews.yml"
SUPPORT_TARGETS="$OCTON_DIR/instance/governance/support-targets.yml"
CONTRACT_REGISTRY="$OCTON_DIR/framework/constitution/contracts/registry.yml"
RETIREMENT_REGISTRY="$OCTON_DIR/instance/governance/contracts/retirement-registry.yml"
AUTHORED_HARNESS_CARD="$OCTON_DIR/instance/governance/disclosure/harness-card.yml"
REQUIRED_BROWNFIELD_PLAYBOOK="$OCTON_DIR/instance/governance/adoption/brownfield-retrofit.md"
RUN_CARD_SCHEMA="$OCTON_DIR/framework/constitution/contracts/disclosure/run-card-v1.schema.json"
HARNESS_CARD_SCHEMA="$OCTON_DIR/framework/constitution/contracts/disclosure/harness-card-v1.schema.json"
BUILD_TO_DELETE_RECEIPT="$OCTON_DIR/state/evidence/validation/publication/build-to-delete/2026-03-30/ablation-deletion-receipt.yml"
PR_AUTONOMY_WORKFLOW="$ROOT_DIR/.github/workflows/pr-autonomy-policy.yml"
PR_AUTO_MERGE_WORKFLOW="$ROOT_DIR/.github/workflows/pr-auto-merge.yml"
RELEASE_WORKFLOW="$ROOT_DIR/.github/workflows/unified-execution-constitution-closure.yml"
AUTONOMY_SCRIPT="$OCTON_DIR/framework/assurance/governance/_ops/scripts/evaluate-pr-autonomy-policy.sh"

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

require_text() {
  local needle="$1"
  local file="$2"
  local label="$3"
  if command -v rg >/dev/null 2>&1; then
    if rg -Fq -- "$needle" "$file"; then
      pass "$label"
    else
      fail "$label"
    fi
  elif grep -Fq -- "$needle" "$file"; then
    pass "$label"
  else
    fail "$label"
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

resolve_ref() {
  local ref="$1"
  if [[ -z "$ref" || "$ref" == "null" ]]; then
    return 1
  fi
  if [[ "$ref" == /* ]]; then
    printf '%s\n' "$ref"
    return 0
  fi
  if [[ "$ref" == .octon/* ]]; then
    printf '%s/%s\n' "$ROOT_DIR" "$ref"
    return 0
  fi
  printf '%s/%s\n' "$OCTON_DIR" "$ref"
}

require_ref_file() {
  local ref="$1"
  local label="$2"
  local path
  if ! path="$(resolve_ref "$ref")"; then
    fail "$label"
    return
  fi
  if [[ -f "$path" ]]; then
    pass "$label"
  else
    fail "$label"
  fi
}

require_ref_dir() {
  local ref="$1"
  local label="$2"
  local path
  if ! path="$(resolve_ref "$ref")"; then
    fail "$label"
    return
  fi
  if [[ -d "$path" ]]; then
    pass "$label"
  else
    fail "$label"
  fi
}

fixture_field() {
  local fixture_id="$1"
  local field="$2"
  yq -r ".fixtures[] | select(.fixture_id == \"$fixture_id\") | .$field // \"\"" "$FIXTURES_FILE"
}

validate_harness_card() {
  local card_path="$1"
  local label_prefix="$2"
  local permitted_wording
  permitted_wording="$(yq -r '.permitted_release_wording' "$CLOSURE_MANIFEST")"

  require_file "$card_path"
  require_yq '.schema_version == "harness-card-v1"' "$card_path" "$label_prefix uses HarnessCard schema"
  require_yq ".claim_summary == $(printf '%s' "$permitted_wording" | jq -R '.') " "$card_path" "$label_prefix wording matches closure manifest"
  require_yq '.compatibility_tuple.model_tier == "MT-B" and .compatibility_tuple.workload_tier == "WT-2" and .compatibility_tuple.language_resource_tier == "LT-REF" and .compatibility_tuple.locale_tier == "LOC-EN" and .compatibility_tuple.support_status == "supported"' "$card_path" "$label_prefix tuple matches closure manifest"
  require_yq '.adapter_support.host_adapter == "repo-shell" and .adapter_support.model_adapter == "repo-local-governed"' "$card_path" "$label_prefix adapters match closure manifest"

  while IFS= read -r ref; do
    [[ -z "$ref" ]] && continue
    require_ref_file "$ref" "$label_prefix proof bundle resolves: $ref"
  done < <(yq -r '.proof_bundle_refs[]' "$card_path")
}

validate_run_card_schema_refs() {
  local run_card_ref="$1"
  local run_contract_ref="$2"
  local run_card_path
  run_card_path="$(resolve_ref "$run_card_ref")"

  require_file "$run_card_path"
  require_yq '.schema_version == "run-card-v1"' "$run_card_path" "RunCard uses run-card schema"
  require_yq ".authority_refs.run_contract == $(printf '%s' "$run_contract_ref" | jq -R '.') " "$run_card_path" "RunCard points at the supported fixture run contract"

  while IFS= read -r key; do
    [[ -z "$key" ]] && continue
    require_yq ".${key}" "$run_card_path" "RunCard includes top-level field ${key}"
  done < <(yq -r '.required[]' "$RUN_CARD_SCHEMA")

  while IFS= read -r key; do
    [[ -z "$key" ]] && continue
    local ref
    ref="$(yq -r ".authority_refs.${key} // \"\"" "$run_card_path")"
    require_ref_file "$ref" "RunCard authority ref resolves: ${key}"
  done < <(yq -r '.properties.authority_refs.required[]' "$RUN_CARD_SCHEMA")

  while IFS= read -r key; do
    [[ -z "$key" ]] && continue
    local ref
    ref="$(yq -r ".proof_plane_refs.${key} // \"\"" "$run_card_path")"
    require_ref_file "$ref" "RunCard proof-plane ref resolves: ${key}"
  done < <(yq -r '.properties.proof_plane_refs.required[]' "$RUN_CARD_SCHEMA")

  require_ref_file "$(yq -r '.measurement_ref // ""' "$run_card_path")" "RunCard measurement ref resolves"
  require_ref_file "$(yq -r '.intervention_ref // ""' "$run_card_path")" "RunCard intervention ref resolves"
  require_ref_file "$(yq -r '.replay_ref // ""' "$run_card_path")" "RunCard replay ref resolves"
}

bundle_ref_for_token() {
  local fixture_id="$1"
  local token="$2"

  case "$token" in
    authority-decision-artifact) fixture_field "$fixture_id" "decision_artifact_ref" ;;
    authority-grant-bundle) fixture_field "$fixture_id" "grant_bundle_ref" ;;
    run-manifest) fixture_field "$fixture_id" "run_manifest_ref" ;;
    runtime-state) fixture_field "$fixture_id" "runtime_state_ref" ;;
    rollback-posture) fixture_field "$fixture_id" "rollback_posture_ref" ;;
    stage-attempt-root) fixture_field "$fixture_id" "stage_attempt_root" ;;
    checkpoint-root) fixture_field "$fixture_id" "checkpoint_root" ;;
    evidence-classification) fixture_field "$fixture_id" "evidence_classification_ref" ;;
    replay-pointers) fixture_field "$fixture_id" "replay_pointers_ref" ;;
    external-replay-index) fixture_field "$fixture_id" "external_replay_index_ref" ;;
    intervention-log) fixture_field "$fixture_id" "intervention_log_ref" ;;
    measurement-summary) fixture_field "$fixture_id" "measurement_summary_ref" ;;
    run-card) fixture_field "$fixture_id" "run_card_ref" ;;
    *) printf '\n' ;;
  esac
}

validate_fixture_route() {
  local fixture_id="$1"
  local expected_route="$2"
  local expected_status="$3"
  local model_tier workload_tier language_tier locale_tier host_adapter model_adapter

  model_tier="$(fixture_field "$fixture_id" "model_tier")"
  workload_tier="$(fixture_field "$fixture_id" "workload_tier")"
  language_tier="$(fixture_field "$fixture_id" "language_resource_tier")"
  locale_tier="$(fixture_field "$fixture_id" "locale_tier")"
  host_adapter="$(fixture_field "$fixture_id" "host_adapter")"
  model_adapter="$(fixture_field "$fixture_id" "model_adapter")"

  require_yq ".compatibility_matrix[] | select(.model_tier == \"$model_tier\" and .workload_tier == \"$workload_tier\" and .language_resource_tier == \"$language_tier\" and .locale_tier == \"$locale_tier\" and .support_status == \"$expected_status\" and .default_route == \"$expected_route\")" "$SUPPORT_TARGETS" "$fixture_id matches support-target route"

  if [[ "$expected_route" != "deny" ]]; then
    require_yq ".host_adapters[] | select(.adapter_id == \"$host_adapter\" and (.allowed_model_tiers[] == \"$model_tier\") and (.allowed_workload_tiers[] == \"$workload_tier\") and (.allowed_language_resource_tiers[] == \"$language_tier\") and (.allowed_locale_tiers[] == \"$locale_tier\"))" "$SUPPORT_TARGETS" "$fixture_id host adapter admits tuple"
    require_yq ".model_adapters[] | select(.adapter_id == \"$model_adapter\" and (.allowed_model_tiers[] == \"$model_tier\") and (.allowed_workload_tiers[] == \"$workload_tier\") and (.allowed_language_resource_tiers[] == \"$language_tier\") and (.allowed_locale_tiers[] == \"$locale_tier\"))" "$SUPPORT_TARGETS" "$fixture_id model adapter admits tuple"
  fi
}

validate_decision_fixture() {
  local fixture_id="$1"
  local expected_decision="$2"
  local expected_status="$3"
  local ref path model_tier workload_tier language_tier locale_tier

  ref="$(fixture_field "$fixture_id" "decision_artifact_ref")"
  path="$(resolve_ref "$ref")"
  model_tier="$(fixture_field "$fixture_id" "model_tier")"
  workload_tier="$(fixture_field "$fixture_id" "workload_tier")"
  language_tier="$(fixture_field "$fixture_id" "language_resource_tier")"
  locale_tier="$(fixture_field "$fixture_id" "locale_tier")"

  require_file "$path"
  require_yq ".decision == \"$expected_decision\"" "$path" "$fixture_id decision artifact records ${expected_decision}"
  require_yq ".support_tier.model_tier_id == \"$model_tier\" and .support_tier.workload_tier_id == \"$workload_tier\" and .support_tier.language_resource_tier_id == \"$language_tier\" and .support_tier.locale_tier_id == \"$locale_tier\" and .support_tier.support_status == \"$expected_status\"" "$path" "$fixture_id decision artifact encodes the expected tuple"
}

validate_status_matrix() {
  require_yq '.status_summary.claim_status == "ready"' "$STATUS_MATRIX" "status matrix marks the final claim ready"
  require_yq '.status_summary.final_verdict == "ready_for_closeout"' "$STATUS_MATRIX" "status matrix final verdict is ready_for_closeout"
  require_yq '.findings | length == 24' "$STATUS_MATRIX" "status matrix tracks all packet findings"
  require_yq '.claim_criteria | length == 11' "$STATUS_MATRIX" "status matrix tracks all packet claim criteria"
  require_yq '.checklists | length == 3' "$STATUS_MATRIX" "status matrix tracks all required packet checklists"
  require_yq '[.findings[] | select(.status != "green")] | length == 0' "$STATUS_MATRIX" "all findings are green in the status matrix"
  require_yq '[.claim_criteria[] | select(.status != "green")] | length == 0' "$STATUS_MATRIX" "all claim criteria are green in the status matrix"
  require_yq '[.checklists[] | select(.status != "green")] | length == 0' "$STATUS_MATRIX" "all required checklists are green in the status matrix"
}

validate_closeout_reviews() {
  require_yq '.claim_status_matrix_ref == ".octon/instance/governance/closure/unified-execution-constitution-status.yml"' "$CLLOSEOUT_REVIEWS" "closeout reviews bind the authoritative status matrix"
  require_yq '.required_reviews | length >= 4' "$CLLOSEOUT_REVIEWS" "closeout reviews require the build-to-delete review set"
  require_yq '.required_checklists | length == 3' "$CLLOSEOUT_REVIEWS" "closeout reviews bind the packet closeout checklists"
}

run_shim_audit() {
  local -a allowlisted_files=(
    "$OCTON_DIR/framework/assurance/runtime/_ops/scripts/validate-phase6-simplification-deletion.sh"
  )
  local line file shim
  local matched=0

  while IFS= read -r shim; do
    [[ -z "$shim" ]] && continue
    while IFS= read -r line; do
      [[ -z "$line" ]] && continue
      file="${line%%:*}"
      case "$file" in
        "${allowlisted_files[0]}") continue ;;
      esac
      matched=1
      fail "historical shim referenced in certification-critical path: ${line#$ROOT_DIR/}"
    done < <(
      if command -v rg >/dev/null 2>&1; then
        rg -n -F -- "$shim" .github/workflows "$OCTON_DIR/framework/assurance" "$OCTON_DIR/instance/ingress" "$OCTON_DIR/instance/bootstrap" "$OCTON_DIR/framework/engine/runtime" || true
      else
        grep -RFn -- "$shim" .github/workflows "$OCTON_DIR/framework/assurance" "$OCTON_DIR/instance/ingress" "$OCTON_DIR/instance/bootstrap" "$OCTON_DIR/framework/engine/runtime" 2>/dev/null || true
      fi
    )
  done < <(yq -r '.shim_surfaces | to_entries[] | select(.value.status == "historical-shim") | .value.path, .value.paths[]?' "$CONTRACT_REGISTRY")

  if [[ $matched -eq 0 ]]; then
    pass "shim-independence audit found no historical-shim reads in certification-critical paths"
  fi
}

main() {
  echo "== Unified Execution Constitution Closure Validation =="

  require_file "$CLOSURE_MANIFEST"
  require_file "$STATUS_MATRIX"
  require_file "$CLLOSEOUT_REVIEWS"
  require_file "$SUPPORT_TARGETS"
  require_file "$CONTRACT_REGISTRY"
  require_file "$RETIREMENT_REGISTRY"
  require_file "$AUTHORED_HARNESS_CARD"
  require_file "$REQUIRED_BROWNFIELD_PLAYBOOK"
  require_file "$RUN_CARD_SCHEMA"
  require_file "$HARNESS_CARD_SCHEMA"
  require_file "$BUILD_TO_DELETE_RECEIPT"
  require_file "$PR_AUTONOMY_WORKFLOW"
  require_file "$PR_AUTO_MERGE_WORKFLOW"
  require_file "$RELEASE_WORKFLOW"
  require_file "$AUTONOMY_SCRIPT"

  require_yq '.supported_claim.model_tier == "MT-B" and .supported_claim.workload_tier == "WT-2" and .supported_claim.language_resource_tier == "LT-REF" and .supported_claim.locale_tier == "LOC-EN" and .supported_claim.host_adapter == "repo-shell" and .supported_claim.model_adapter == "repo-local-governed"' "$CLOSURE_MANIFEST" "closure manifest freezes the bounded live tuple and adapters"
  require_yq '.status_matrix_ref == ".octon/instance/governance/closure/unified-execution-constitution-status.yml"' "$CLOSURE_MANIFEST" "closure manifest binds the authoritative status matrix"
  require_yq '.closeout_contract_ref == ".octon/instance/governance/contracts/closeout-reviews.yml"' "$CLOSURE_MANIFEST" "closure manifest binds the closeout contract"
  require_yq '.excluded_or_reduced_surfaces[] | select(.surface_id == "MT-A/WT-1" and .status == "experimental" and .route == "stage_only")' "$CLOSURE_MANIFEST" "closure manifest records MT-A / WT-1 as experimental"
  require_yq '.excluded_or_reduced_surfaces[] | select(.surface_id == "studio-control-plane" and .status == "experimental" and .route == "stage_only")' "$CLOSURE_MANIFEST" "closure manifest records Studio as experimental"
  require_yq '.excluded_or_reduced_surfaces[] | select(.surface_id == "github-control-plane" and .status == "experimental" and .route == "stage_only")' "$CLOSURE_MANIFEST" "closure manifest records GitHub as experimental"
  require_yq '.excluded_or_reduced_surfaces[] | select(.surface_id == "ci-control-plane" and .status == "experimental" and .route == "stage_only")' "$CLOSURE_MANIFEST" "closure manifest records CI as experimental"
  require_yq '.integration_surfaces.closure_claim_manifest.path == ".octon/instance/governance/closure/unified-execution-constitution.yml"' "$CONTRACT_REGISTRY" "contract registry exposes the closure manifest"
  require_yq '.integration_surfaces.closure_claim_status_matrix.path == ".octon/instance/governance/closure/unified-execution-constitution-status.yml"' "$CONTRACT_REGISTRY" "contract registry exposes the closure status matrix"
  require_yq '.entries[] | select(.target_id == "ingress-projection-adapters" and .status == "registered")' "$RETIREMENT_REGISTRY" "retirement registry records ingress projection adapters"
  require_yq '.shim_surfaces.assurance_governance_charter.status == "subordinate-governance"' "$CONTRACT_REGISTRY" "assurance-governance charter is subordinate rather than historical"
  require_yq '.runtime_surface.interface_ref == ".github/workflows/pr-autonomy-policy.yml"' "$OCTON_DIR/framework/engine/runtime/adapters/host/github-control-plane.yml" "GitHub host adapter points at the PR-autonomy binding surface"
  require_yq '.runtime_surface.interface_ref == ".github/workflows/unified-execution-constitution-closure.yml"' "$OCTON_DIR/framework/engine/runtime/adapters/host/ci-control-plane.yml" "CI host adapter points at the closure workflow"

  validate_status_matrix
  validate_closeout_reviews
  validate_harness_card "$AUTHORED_HARNESS_CARD" "authored HarnessCard"

  require_yq '.owner == "Octon governance" and .status == "completed"' "$BUILD_TO_DELETE_RECEIPT" "build-to-delete receipt is retained and completed"
  require_yq '.targets_evaluated[] | select(.target_id == "label-native-authority-lane-projections")' "$BUILD_TO_DELETE_RECEIPT" "build-to-delete receipt records label-native authority retirement"
  require_yq '.targets_evaluated[] | select(.target_id == "run-local-disclosure-mirrors")' "$BUILD_TO_DELETE_RECEIPT" "build-to-delete receipt records disclosure mirror retirement"

  require_text '.octon/framework/assurance/governance/_ops/scripts/evaluate-pr-autonomy-policy.sh' "$PR_AUTONOMY_WORKFLOW" "PR autonomy workflow binds the canonical classifier"
  require_text '.octon/framework/assurance/governance/_ops/scripts/evaluate-pr-autonomy-policy.sh' "$PR_AUTO_MERGE_WORKFLOW" "PR auto-merge workflow binds the canonical classifier"
  require_text '.octon/framework/assurance/governance/_ops/scripts/assert-unified-execution-closure.sh' "$RELEASE_WORKFLOW" "release closure workflow binds the canonical validator"

  run_shim_audit

  echo "Validation summary: errors=$errors"
  [[ $errors -eq 0 ]]
}

main "$@"

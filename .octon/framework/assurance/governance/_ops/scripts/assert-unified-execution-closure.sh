#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../.." && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
ROOT_DIR="${OCTON_ROOT_DIR:-$(cd -- "$OCTON_DIR/.." && pwd)}"

CLOSURE_MANIFEST="$OCTON_DIR/instance/governance/closure/unified-execution-constitution.yml"
STATUS_MATRIX="$OCTON_DIR/instance/governance/closure/unified-execution-constitution-status.yml"
PACKET_ISSUES="$OCTON_DIR/instance/governance/closure/unified-execution-constitution-packet-issues.yml"
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

require_no_absolute_repo_paths() {
  local file="$1"
  local label="$2"
  if command -v rg >/dev/null 2>&1; then
    if rg -n '/Users/|/home/' "$file" >/dev/null 2>&1; then
      fail "$label"
    else
      pass "$label"
    fi
  elif grep -En '/Users/|/home/' "$file" >/dev/null 2>&1; then
    fail "$label"
  else
    pass "$label"
  fi
}

validate_harness_card() {
  local card_path="$1"
  local label_prefix="$2"
  local claim_status
  local expected_wording
  claim_status="$(yq -r '.claim_status' "$CLOSURE_MANIFEST")"
  expected_wording="$(yq -r ".claim_wording.${claim_status}" "$CLOSURE_MANIFEST")"

  require_file "$card_path"
  require_yq '.schema_version == "harness-card-v1"' "$card_path" "$label_prefix uses HarnessCard schema"
  require_yq ".claim_status == $(printf '%s' "$claim_status" | jq -R '.') " "$card_path" "$label_prefix claim_status matches closure manifest"
  require_yq ".claim_summary == $(printf '%s' "$expected_wording" | jq -R '.') " "$card_path" "$label_prefix wording matches closure manifest"
  require_yq '.compatibility_tuple.model_tier == "MT-B" and .compatibility_tuple.workload_tier == "WT-2" and .compatibility_tuple.language_resource_tier == "LT-REF" and .compatibility_tuple.locale_tier == "LOC-EN" and .compatibility_tuple.support_status == "supported"' "$card_path" "$label_prefix tuple matches closure manifest"
  require_yq '.adapter_support.host_adapter == "repo-shell" and .adapter_support.model_adapter == "repo-local-governed"' "$card_path" "$label_prefix adapters match closure manifest"

  while IFS= read -r ref; do
    [[ -z "$ref" ]] && continue
    require_ref_file "$ref" "$label_prefix proof bundle resolves: $ref"
    if [[ "$ref" == *.octon/state/evidence/disclosure/runs/*/run-card.yml || "$ref" == .octon/state/evidence/disclosure/runs/*/run-card.yml ]]; then
      local run_card_path
      run_card_path="$(resolve_ref "$ref")"
      require_yq '.workflow_mode != "human-only"' "$run_card_path" "$label_prefix cited RunCard is not human-only"
      require_yq '.support_target_tuple.model_tier == "MT-B" and .support_target_tuple.workload_tier == "WT-2" and .support_target_tuple.language_resource_tier == "LT-REF" and .support_target_tuple.locale_tier == "LOC-EN" and .support_target_tuple.support_status == "supported"' "$run_card_path" "$label_prefix cited RunCard carries the supported tuple"
      validate_supported_run_card_bundle "$run_card_path" "$label_prefix cited RunCard bundle"
    fi
  done < <(yq -r '.proof_bundle_refs[]' "$card_path")
}

validate_supported_run_card_bundle() {
  local run_card_path="$1"
  local label_prefix="$2"
  local run_contract_ref run_manifest_ref runtime_state_ref continuity_ref replay_ref replay_pointers_ref trace_pointers_ref evidence_classification_ref external_index_ref last_checkpoint_ref decision_ref retained_evidence_ref grant_bundle_ref

  run_contract_ref="$(yq -r '.authority_refs.run_contract // ""' "$run_card_path")"
  retained_evidence_ref="$(yq -r '.authority_refs.retained_run_evidence // ""' "$run_card_path")"
  decision_ref="$(yq -r '.authority_refs.decision_artifact // ""' "$run_card_path")"
  grant_bundle_ref="$(yq -r '.authority_refs.grant_bundle // ""' "$run_card_path")"

  require_ref_file "$run_contract_ref" "$label_prefix run contract resolves"
  require_ref_file "$retained_evidence_ref" "$label_prefix retained run evidence resolves"
  require_ref_file "$decision_ref" "$label_prefix decision artifact resolves"
  require_ref_file "$grant_bundle_ref" "$label_prefix authority grant bundle resolves"

  local run_contract_path run_manifest_path
  run_contract_path="$(resolve_ref "$run_contract_ref")"
  run_manifest_ref="$(yq -r '.run_manifest_ref // ""' "$run_contract_path")"
  runtime_state_ref="$(yq -r '.runtime_state_ref // ""' "$run_contract_path")"

  require_ref_file "$run_manifest_ref" "$label_prefix run manifest resolves"
  require_ref_file "$runtime_state_ref" "$label_prefix runtime state resolves"
  require_no_absolute_repo_paths "$run_contract_path" "$label_prefix run contract has no absolute host paths"
  require_no_absolute_repo_paths "$(resolve_ref "$grant_bundle_ref")" "$label_prefix grant bundle has no absolute host paths"

  run_manifest_path="$(resolve_ref "$run_manifest_ref")"
  continuity_ref="$(yq -r '.run_continuity_ref // ""' "$run_manifest_path")"
  replay_pointers_ref="$(yq -r '.replay_pointers_ref // ""' "$run_manifest_path")"
  trace_pointers_ref="$(yq -r '.trace_pointers_ref // ""' "$run_manifest_path")"
  evidence_classification_ref="$(yq -r '.evidence_classification_ref // ""' "$run_manifest_path")"
  external_index_ref="$(yq -r '.external_replay_index_ref // ""' "$run_manifest_path")"

  require_ref_file "$continuity_ref" "$label_prefix continuity artifact resolves"
  require_ref_file "$replay_pointers_ref" "$label_prefix replay pointers resolve"
  require_ref_file "$trace_pointers_ref" "$label_prefix trace pointers resolve"
  require_ref_file "$evidence_classification_ref" "$label_prefix evidence classification resolves"
  require_ref_file "$external_index_ref" "$label_prefix external replay index resolves"

  replay_ref="$(yq -r '.replay_ref // ""' "$run_card_path")"
  require_ref_file "$replay_ref" "$label_prefix replay manifest resolves"
  require_yq '.external_index_refs | length > 0' "$(resolve_ref "$replay_ref")" "$label_prefix replay manifest cites external index"
  require_yq '.external_index_refs | length > 0' "$(resolve_ref "$replay_pointers_ref")" "$label_prefix replay pointers cite external index"
  require_yq '.trace_refs != null' "$(resolve_ref "$trace_pointers_ref")" "$label_prefix trace pointers are well formed"

  require_yq '.artifacts[] | select(.artifact_id == "run-contract")' "$(resolve_ref "$evidence_classification_ref")" "$label_prefix evidence classification covers run contract"
  require_yq '.artifacts[] | select(.artifact_id == "run-manifest")' "$(resolve_ref "$evidence_classification_ref")" "$label_prefix evidence classification covers run manifest"
  require_yq '.artifacts[] | select(.artifact_id == "runtime-state")' "$(resolve_ref "$evidence_classification_ref")" "$label_prefix evidence classification covers runtime state"
  require_yq '.artifacts[] | select(.artifact_id == "decision-artifact")' "$(resolve_ref "$evidence_classification_ref")" "$label_prefix evidence classification covers decision artifact"
  require_yq '.artifacts[] | select(.artifact_id == "run-card")' "$(resolve_ref "$evidence_classification_ref")" "$label_prefix evidence classification covers run card"
  require_yq '.artifacts[] | select(.artifact_id == "replay-pointers")' "$(resolve_ref "$evidence_classification_ref")" "$label_prefix evidence classification covers replay pointers"
  require_yq '.artifacts[] | select(.artifact_id == "trace-pointers")' "$(resolve_ref "$evidence_classification_ref")" "$label_prefix evidence classification covers trace pointers"
  require_yq '.artifacts[] | select(.artifact_id == "external-replay-index")' "$(resolve_ref "$evidence_classification_ref")" "$label_prefix evidence classification covers external replay index"
  require_yq '.artifacts[] | select(.artifact_id == "measurement-summary")' "$(resolve_ref "$evidence_classification_ref")" "$label_prefix evidence classification covers measurements"
  require_yq '.artifacts[] | select(.artifact_id == "intervention-log")' "$(resolve_ref "$evidence_classification_ref")" "$label_prefix evidence classification covers interventions"
  require_yq '.artifacts[] | select(.artifact_id == "assurance-structural")' "$(resolve_ref "$evidence_classification_ref")" "$label_prefix evidence classification covers assurance"

  last_checkpoint_ref="$(yq -r '.last_checkpoint_ref // ""' "$(resolve_ref "$continuity_ref")")"
  require_ref_file "$last_checkpoint_ref" "$label_prefix latest checkpoint resolves"
  require_no_absolute_repo_paths "$(resolve_ref "$last_checkpoint_ref")" "$label_prefix checkpoint has no absolute host paths"

  if yq -e '.decision == "ALLOW"' "$(resolve_ref "$decision_ref")" >/dev/null 2>&1 && \
     (
       (command -v rg >/dev/null 2>&1 && rg -Fq 'ACP_EVIDENCE_INVALID' "$(resolve_ref "$decision_ref")") || \
       (! command -v rg >/dev/null 2>&1 && grep -Fq 'ACP_EVIDENCE_INVALID' "$(resolve_ref "$decision_ref")")
     ); then
    fail "$label_prefix decision artifact reason codes match allow state"
  else
    pass "$label_prefix decision artifact reason codes match allow state"
  fi
}

validate_run_card_schema_refs() {
  local run_card_ref="$1"
  local run_contract_ref="$2"
  local run_card_path
  run_card_path="$(resolve_ref "$run_card_ref")"

  require_file "$run_card_path"
  require_yq '.schema_version == "run-card-v1"' "$run_card_path" "RunCard uses run-card schema"
  require_yq ".authority_refs.run_contract == $(printf '%s' "$run_contract_ref" | jq -R '.') " "$run_card_path" "RunCard points at the supported fixture run contract"
  require_yq '.workflow_mode != "human-only"' "$run_card_path" "RunCard workflow mode is not human-only"
  require_yq '.support_target_tuple.model_tier == "MT-B" and .support_target_tuple.workload_tier == "WT-2" and .support_target_tuple.language_resource_tier == "LT-REF" and .support_target_tuple.locale_tier == "LOC-EN" and .support_target_tuple.support_status == "supported"' "$run_card_path" "RunCard carries the bounded supported tuple"

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
  local claim_status
  claim_status="$(yq -r '.status_summary.claim_status' "$STATUS_MATRIX")"
  if [[ "$claim_status" == "complete" ]]; then
    require_yq '.status_summary.final_verdict == "claim_complete"' "$STATUS_MATRIX" "status matrix final verdict is claim_complete"
    require_yq '[.findings[] | select(.status != "green")] | length == 0' "$STATUS_MATRIX" "all findings are green in the status matrix"
    require_yq '[.claim_criteria[] | select(.status != "green")] | length == 0' "$STATUS_MATRIX" "all claim criteria are green in the status matrix"
    require_yq '[.checklists[] | select(.status != "green")] | length == 0' "$STATUS_MATRIX" "all required checklists are green in the status matrix"
  else
    require_yq '.status_summary.claim_status == "provisional"' "$STATUS_MATRIX" "status matrix marks the claim provisional"
    require_yq '.status_summary.current_blocker != null' "$STATUS_MATRIX" "status matrix names the current blocker"
  fi
  require_yq '.findings | length == 24' "$STATUS_MATRIX" "status matrix tracks all packet findings"
  require_yq '.claim_criteria | length == 11' "$STATUS_MATRIX" "status matrix tracks all packet claim criteria"
  require_yq '.checklists | length == 3' "$STATUS_MATRIX" "status matrix tracks all required packet checklists"
}

validate_packet_issue_status() {
  local claim_status
  claim_status="$(yq -r '.claim_status' "$CLOSURE_MANIFEST")"

  require_file "$PACKET_ISSUES"
  require_yq '.summary.total_count == 18' "$PACKET_ISSUES" "packet issue register tracks all 18 packet issues"
  require_yq '.summary.partial_count == 0' "$PACKET_ISSUES" "packet issue register records zero partial issues"
  require_yq '.summary.deferred_count == 0' "$PACKET_ISSUES" "packet issue register records zero deferred issues"
  if [[ "$claim_status" == "complete" ]]; then
    require_yq '.summary.open_count == 0 and .summary.closed_count == 18 and .summary.closure_ready == true' "$PACKET_ISSUES" "complete claim requires a fully closed packet issue register"
  else
    require_yq '.summary.open_count > 0 and .summary.closure_ready == false' "$PACKET_ISSUES" "provisional claim requires an open packet issue register"
  fi
}

validate_complete_claim_prerequisites() {
  require_yq '.status_summary.blocking_gates | length == 0' "$STATUS_MATRIX" "complete claim has no blocking gates"
  if command -v rg >/dev/null 2>&1; then
    rg -qi 'hidden-check|held-out|anti-overfitting' "$AUTHORED_HARNESS_CARD"
  else
    grep -Eqi 'hidden-check|held-out|anti-overfitting' "$AUTHORED_HARNESS_CARD"
  fi && {
    pass "complete claim discloses hidden-check posture"
  } || {
    fail "complete claim discloses hidden-check posture"
  }
  if command -v rg >/dev/null 2>&1; then
    rg -l 'workflow_mode:[[:space:]]*"agent-augmented"|workflow_mode:[[:space:]]*agent-augmented' \
      "$OCTON_DIR/state/control/execution/approvals/requests"/*.yml >/dev/null 2>&1
  else
    grep -El 'workflow_mode:[[:space:]]*"agent-augmented"|workflow_mode:[[:space:]]*agent-augmented' \
      "$OCTON_DIR/state/control/execution/approvals/requests"/*.yml >/dev/null 2>&1
  fi && {
    pass "complete claim retains a live approval exercise"
  } || {
    fail "complete claim retains a live approval exercise"
  }
  if yq -e '.leases[] | select(.run_id != null and (.run_id | test("^uec-")))' "$OCTON_DIR/state/control/execution/exceptions/leases.yml" >/dev/null 2>&1 && \
     yq -e '.revocations[] | select(.run_id != null and (.run_id | test("^uec-")))' "$OCTON_DIR/state/control/execution/revocations/grants.yml" >/dev/null 2>&1; then
    pass "complete claim retains a live lease and revocation exercise"
  else
    fail "complete claim retains a live lease and revocation exercise"
  fi
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
  local claim_status
  claim_status="$(yq -r '.claim_status' "$CLOSURE_MANIFEST")"

  require_file "$CLOSURE_MANIFEST"
  require_file "$STATUS_MATRIX"
  require_file "$PACKET_ISSUES"
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

  require_yq '.claim_status == "provisional" or .claim_status == "complete"' "$CLOSURE_MANIFEST" "closure manifest exposes packet claim_status"
  require_yq '.supported_claim.model_tier == "MT-B" and .supported_claim.workload_tier == "WT-2" and .supported_claim.language_resource_tier == "LT-REF" and .supported_claim.locale_tier == "LOC-EN" and .supported_claim.host_adapter == "repo-shell" and .supported_claim.model_adapter == "repo-local-governed"' "$CLOSURE_MANIFEST" "closure manifest freezes the bounded live tuple and adapters"
  require_yq '.status_matrix_ref == ".octon/instance/governance/closure/unified-execution-constitution-status.yml"' "$CLOSURE_MANIFEST" "closure manifest binds the authoritative status matrix"
  require_yq '.packet_issue_status_ref == ".octon/instance/governance/closure/unified-execution-constitution-packet-issues.yml"' "$CLOSURE_MANIFEST" "closure manifest binds the packet issue register"
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
  require_text 'Run-first lifecycle execution commands' "$OCTON_DIR/framework/engine/runtime/crates/kernel/src/main.rs" "kernel exposes run-first command surface"
  require_text 'workflow run is a compatibility wrapper' "$OCTON_DIR/framework/engine/runtime/crates/kernel/src/main.rs" "workflow run is documented as a compatibility wrapper"

  validate_status_matrix
  validate_packet_issue_status
  if [[ "$claim_status" == "complete" ]]; then
    validate_complete_claim_prerequisites
  fi
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

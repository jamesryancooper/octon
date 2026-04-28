#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
ROOT_DIR="${OCTON_ROOT_DIR:-$(cd -- "$OCTON_DIR/.." && pwd)}"
PROGRAM_ID="octon-self-evolution"
CANDIDATE_ID="evolution-candidate-v5-validation"
PROMOTION_ID="evolution-promotion-v5-validation"
RECERTIFICATION_ID="evolution-recertification-v5-validation"
PROPOSAL_ID="octon-self-evolution-proposal-to-promotion-runtime-v5"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --root)
      ROOT_DIR="$2"
      OCTON_DIR="${OCTON_DIR_OVERRIDE:-$ROOT_DIR/.octon}"
      shift 2
      ;;
    --program-id)
      PROGRAM_ID="$2"
      shift 2
      ;;
    --candidate-id)
      CANDIDATE_ID="$2"
      shift 2
      ;;
    --promotion-id)
      PROMOTION_ID="$2"
      shift 2
      ;;
    -h|--help)
      echo "Usage: validate-self-evolution-runtime-v5.sh [--root <repo-root>] [--program-id <id>] [--candidate-id <id>] [--promotion-id <id>]"
      exit 0
      ;;
    *)
      echo "[ERROR] unknown argument: $1" >&2
      exit 2
      ;;
  esac
done

errors=0

fail() {
  echo "[ERROR] $1"
  errors=$((errors + 1))
}

pass() {
  echo "[OK] $1"
}

rel() {
  local path="$1"
  printf '%s\n' "${path#$ROOT_DIR/}"
}

require_file() {
  local file="$1"
  [[ -f "$file" ]] && pass "found $(rel "$file")" || fail "missing $(rel "$file")"
}

require_dir() {
  local dir="$1"
  [[ -d "$dir" ]] && pass "found $(rel "$dir")" || fail "missing $(rel "$dir")"
}

require_json_schema() {
  local file="$1"
  local label="$2"
  require_file "$file"
  [[ -f "$file" ]] || return 0
  jq -e 'type == "object" and has("$schema") and has("$id") and has("title") and (has("type") or has("allOf") or has("anyOf") or has("oneOf"))' "$file" >/dev/null 2>&1 \
    && pass "$label is a JSON Schema" \
    || fail "$label must be a JSON Schema"
}

require_yaml_schema() {
  local file="$1"
  local schema="$2"
  require_file "$file"
  [[ -f "$file" ]] || return 0
  yq -e '.' "$file" >/dev/null 2>&1 || {
    fail "$(rel "$file") must parse as YAML"
    return 0
  }
  [[ "$(yq -r '.schema_version // ""' "$file")" == "$schema" ]] \
    && pass "$(rel "$file") schema_version is $schema" \
    || fail "$(rel "$file") schema_version must be $schema"
}

require_schema_valid() {
  local file="$1"
  local schema="$2"
  local label="$3"
  [[ -f "$file" && -f "$schema" ]] || return 0
  if python3 - "$file" "$schema" <<'PY' >/dev/null 2>&1
import json
import sys

import jsonschema
import yaml

data_path, schema_path = sys.argv[1], sys.argv[2]
with open(data_path, "r", encoding="utf-8") as fh:
    data = yaml.safe_load(fh)
with open(schema_path, "r", encoding="utf-8") as fh:
    schema = json.load(fh)
jsonschema.Draft202012Validator.check_schema(schema)
jsonschema.Draft202012Validator(schema).validate(data)
PY
  then
    pass "$label validates against schema"
  else
    fail "$label must validate against $(rel "$schema")"
  fi
}

require_yq() {
  local file="$1"
  local expr="$2"
  local label="$3"
  yq -e "$expr" "$file" >/dev/null 2>&1 && pass "$label" || fail "$label"
}

require_same_string_set() {
  local left_file="$1"
  local left_expr="$2"
  local right_file="$3"
  local right_expr="$4"
  local label="$5"
  local left_tmp right_tmp diff_tmp
  left_tmp="$(mktemp)"
  right_tmp="$(mktemp)"
  diff_tmp="$(mktemp)"
  yq -r "$left_expr[]? // \"\"" "$left_file" | sed '/^$/d' | sort -u >"$left_tmp"
  yq -r "$right_expr[]? // \"\"" "$right_file" | sed '/^$/d' | sort -u >"$right_tmp"
  if diff -u "$left_tmp" "$right_tmp" >"$diff_tmp"; then
    pass "$label"
  else
    fail "$label"
    cat "$diff_tmp"
  fi
  rm -f "$left_tmp" "$right_tmp" "$diff_tmp"
}

require_jq() {
  local file="$1"
  local expr="$2"
  local label="$3"
  jq -e "$expr" "$file" >/dev/null 2>&1 && pass "$label" || fail "$label"
}

resolve_repo_path() {
  local ref="$1"
  case "$ref" in
    .octon/*) printf '%s/%s\n' "$ROOT_DIR" "$ref" ;;
    /.octon/*) printf '%s/%s\n' "$ROOT_DIR" "${ref#/}" ;;
    *) printf '%s\n' "$ref" ;;
  esac
}

resolve_proposal_dir() {
  local active="$OCTON_DIR/inputs/exploratory/proposals/architecture/$PROPOSAL_ID"
  local archived="$OCTON_DIR/inputs/exploratory/proposals/.archive/architecture/$PROPOSAL_ID"
  if [[ -f "$active/proposal.yml" ]]; then
    printf '%s\n' "$active"
  elif [[ -f "$archived/proposal.yml" ]]; then
    printf '%s\n' "$archived"
  else
    printf '%s\n' "$active"
  fi
}

effective_implemented_status() {
  local proposal="$1"
  local status
  status="$(yq -r '.status // ""' "$proposal" 2>/dev/null || true)"
  case "$status" in
    implemented)
      printf '%s\n' "implemented"
      ;;
    archived)
      if yq -e '(.archive.disposition == "implemented") or (.archive.archived_from_status == "implemented")' "$proposal" >/dev/null 2>&1; then
        printf '%s\n' "implemented"
      else
        printf '%s\n' "archived"
      fi
      ;;
    *)
      printf '%s\n' "$status"
      ;;
  esac
}

check_tools() {
  command -v yq >/dev/null 2>&1 || fail "yq is required"
  command -v jq >/dev/null 2>&1 || fail "jq is required"
}

check_static_contracts() {
  echo "== Self-Evolution Runtime v5 Contract Validation =="
  local runtime_schemas=(
    evolution-program-v1
    evolution-candidate-v1
    evidence-to-candidate-distillation-record-v1
    governance-impact-simulation-v1
    assurance-lab-promotion-gate-v1
    self-evolution-decision-request-v1
    constitutional-amendment-request-v1
    promotion-request-v1
    promotion-receipt-v1
    recertification-request-v1
    recertification-result-v1
    evolution-rollback-retirement-posture-v1
    evolution-evidence-profile-v1
    evolution-ledger-v1
  )
  local schema
  for schema in "${runtime_schemas[@]}"; do
    require_json_schema "$OCTON_DIR/framework/engine/runtime/spec/${schema}.schema.json" "$schema runtime schema"
  done
  require_file "$OCTON_DIR/framework/engine/runtime/spec/evolution-proposal-compiler-v1.md"
  require_file "$OCTON_DIR/framework/engine/runtime/spec/promotion-runtime-v1.md"
  require_file "$OCTON_DIR/framework/engine/runtime/spec/recertification-runtime-v1.md"
  require_file "$OCTON_DIR/framework/orchestration/practices/evolution-lifecycle-standards.md"

  local mirrors=(
    framework/constitution/contracts/runtime/evolution-program-v1.schema.json
    framework/constitution/contracts/runtime/evolution-candidate-v1.schema.json
    framework/constitution/contracts/runtime/evolution-ledger-v1.schema.json
    framework/constitution/contracts/runtime/evolution-rollback-retirement-posture-v1.schema.json
    framework/constitution/contracts/runtime/evolution-evidence-profile-v1.schema.json
    framework/constitution/contracts/runtime/promotion-request-v1.schema.json
    framework/constitution/contracts/runtime/recertification-request-v1.schema.json
    framework/constitution/contracts/assurance/evidence-to-candidate-distillation-record-v1.schema.json
    framework/constitution/contracts/assurance/governance-impact-simulation-v1.schema.json
    framework/constitution/contracts/assurance/assurance-lab-promotion-gate-v1.schema.json
    framework/constitution/contracts/assurance/recertification-result-v1.schema.json
    framework/constitution/contracts/authority/self-evolution-decision-request-v1.schema.json
    framework/constitution/contracts/authority/constitutional-amendment-request-v1.schema.json
    framework/constitution/contracts/authority/self-evolution-promotion-receipt-v1.schema.json
  )
  local mirror
  for mirror in "${mirrors[@]}"; do
    require_json_schema "$OCTON_DIR/$mirror" "$mirror"
  done

  require_jq "$OCTON_DIR/framework/engine/runtime/spec/evolution-candidate-v1.schema.json" '.required | index("source_evidence_refs") and index("authority_impact") and index("constitutional_impact") and index("current_disposition") and index("candidate_authorizes_change")' "candidate schema requires evidence, impact, disposition, and non-authority"
  require_jq "$OCTON_DIR/framework/engine/runtime/spec/constitutional-amendment-request-v1.schema.json" '.required | index("human_or_quorum_approval_required") and index("approval_refs") and index("post_promotion_recertification_required")' "amendment schema requires approval and recertification"
  require_yq "$OCTON_DIR/framework/constitution/contracts/registry.yml" '.integration_surfaces.self_evolution_runtime_v5_contracts.rule | test("do not authorize Octon")' "constitutional registry captures anti-self-authorization rule"
  require_yq "$OCTON_DIR/framework/cognition/_meta/architecture/contract-registry.yml" '.path_families.self_evolution_runtime_v5.forbidden_consumers[] | select(. == "self-authorization")' "architecture registry forbids self-authorization"
  require_yq "$OCTON_DIR/framework/constitution/obligations/evidence.yml" '.retained_evidence_roots[] | select(. == ".octon/state/evidence/evolution/**")' "evolution evidence root is retained"
}

check_instance_and_control() {
  echo "== Self-Evolution Authority, Control, and Evidence Validation =="
  local program="$OCTON_DIR/instance/governance/evolution/programs/$PROGRAM_ID/program.yml"
  local candidate="$OCTON_DIR/state/control/evolution/candidates/$CANDIDATE_ID.yml"
  local distillation="$OCTON_DIR/state/control/evolution/distillation/evolution-distillation-v5-validation.yml"
  local simulation="$OCTON_DIR/state/control/evolution/simulations/evolution-simulation-v5-validation.yml"
  local lab="$OCTON_DIR/state/control/evolution/lab-gates/evolution-lab-gate-v5-validation.yml"
  local amendment="$OCTON_DIR/state/control/evolution/amendment-requests/evolution-amendment-v5-validation.yml"
  local promotion="$OCTON_DIR/state/control/evolution/promotions/$PROMOTION_ID.yml"
  local recert_request="$OCTON_DIR/state/control/evolution/recertification-requests/$RECERTIFICATION_ID.yml"
  local recert="$OCTON_DIR/state/control/evolution/recertifications/$RECERTIFICATION_ID.yml"
  local ledger="$OCTON_DIR/state/control/evolution/ledger.yml"
  local rollback="$OCTON_DIR/state/control/evolution/rollbacks/evolution-rollback-v5-validation.yml"
  local retirement="$OCTON_DIR/state/control/evolution/retirements/evolution-retirement-v5-validation.yml"
  local decision="$OCTON_DIR/state/control/evolution/decisions/evolution-decision-v5-validation.yml"
  local approval_request="$OCTON_DIR/state/control/execution/approvals/requests/evolution-promotion-v5-validation.yml"
  local approval_grant="$OCTON_DIR/state/control/execution/approvals/grants/grant-evolution-promotion-v5-validation.yml"
  local quorum_policy="$OCTON_DIR/instance/governance/contracts/quorum-policies/default.yml"
  local recert_policy="$OCTON_DIR/instance/governance/evolution/policies/recertification-policy.yml"

  require_yaml_schema "$program" "evolution-program-v1"
  require_yaml_schema "$candidate" "evolution-candidate-v1"
  require_yaml_schema "$distillation" "evidence-to-candidate-distillation-record-v1"
  require_yaml_schema "$simulation" "governance-impact-simulation-v1"
  require_yaml_schema "$lab" "assurance-lab-promotion-gate-v1"
  require_yaml_schema "$amendment" "constitutional-amendment-request-v1"
  require_yaml_schema "$promotion" "promotion-request-v1"
  require_yaml_schema "$recert_request" "recertification-request-v1"
  require_yaml_schema "$recert" "recertification-result-v1"
  require_yaml_schema "$ledger" "evolution-ledger-v1"
  require_yaml_schema "$rollback" "evolution-rollback-retirement-posture-v1"
  require_yaml_schema "$retirement" "evolution-rollback-retirement-posture-v1"
  require_yaml_schema "$decision" "self-evolution-decision-request-v1"
  require_yaml_schema "$approval_request" "authority-approval-request-v1"
  require_yaml_schema "$approval_grant" "authority-approval-grant-v1"
  require_yaml_schema "$quorum_policy" "authority-quorum-policy-v1"

  require_schema_valid "$program" "$OCTON_DIR/framework/engine/runtime/spec/evolution-program-v1.schema.json" "Evolution Program"
  require_schema_valid "$candidate" "$OCTON_DIR/framework/engine/runtime/spec/evolution-candidate-v1.schema.json" "Evolution Candidate"
  require_schema_valid "$distillation" "$OCTON_DIR/framework/engine/runtime/spec/evidence-to-candidate-distillation-record-v1.schema.json" "Evidence-to-Candidate Distillation Record"
  require_schema_valid "$simulation" "$OCTON_DIR/framework/engine/runtime/spec/governance-impact-simulation-v1.schema.json" "Governance Impact Simulation"
  require_schema_valid "$lab" "$OCTON_DIR/framework/engine/runtime/spec/assurance-lab-promotion-gate-v1.schema.json" "Assurance Lab Promotion Gate"
  require_schema_valid "$amendment" "$OCTON_DIR/framework/engine/runtime/spec/constitutional-amendment-request-v1.schema.json" "Constitutional Amendment Request"
  require_schema_valid "$promotion" "$OCTON_DIR/framework/engine/runtime/spec/promotion-request-v1.schema.json" "Promotion Request"
  require_schema_valid "$recert_request" "$OCTON_DIR/framework/engine/runtime/spec/recertification-request-v1.schema.json" "Recertification Request"
  require_schema_valid "$recert" "$OCTON_DIR/framework/engine/runtime/spec/recertification-result-v1.schema.json" "Recertification Result"
  require_schema_valid "$ledger" "$OCTON_DIR/framework/engine/runtime/spec/evolution-ledger-v1.schema.json" "Evolution Ledger"
  require_schema_valid "$rollback" "$OCTON_DIR/framework/engine/runtime/spec/evolution-rollback-retirement-posture-v1.schema.json" "Evolution Rollback Posture"
  require_schema_valid "$retirement" "$OCTON_DIR/framework/engine/runtime/spec/evolution-rollback-retirement-posture-v1.schema.json" "Evolution Retirement Posture"
  require_schema_valid "$decision" "$OCTON_DIR/framework/engine/runtime/spec/self-evolution-decision-request-v1.schema.json" "Self-Evolution Decision Request"
  require_schema_valid "$approval_request" "$OCTON_DIR/framework/constitution/contracts/authority/approval-request-v1.schema.json" "Approval Request"
  require_schema_valid "$approval_grant" "$OCTON_DIR/framework/constitution/contracts/authority/approval-grant-v1.schema.json" "Approval Grant"
  require_schema_valid "$quorum_policy" "$OCTON_DIR/framework/constitution/contracts/authority/quorum-policy-v1.schema.json" "Quorum Policy"

  require_yq "$program" '.program_mutates_authority_directly == false' "Evolution Program cannot mutate authority"
  require_yq "$candidate" '(.source_evidence_refs | length) > 0 and .candidate_authorizes_change == false' "candidate has evidence refs and cannot authorize change"
  require_yq "$candidate" '.constitutional_impact == "none" or (.constitutional_amendment_request_ref != null)' "constitutional-impact candidate has amendment request"
  local candidate_ref=".octon/state/control/evolution/candidates/$CANDIDATE_ID.yml"
  local amendment_ref=".octon/state/control/evolution/amendment-requests/evolution-amendment-v5-validation.yml"
  candidate_ref="$candidate_ref" amendment_ref="$amendment_ref" require_yq "$candidate" '.constitutional_amendment_request_ref == env(amendment_ref)' "candidate links canonical amendment request"
  require_file "$(resolve_repo_path "$amendment_ref")"
  candidate_ref="$candidate_ref" require_yq "$amendment" '.candidate_ref == env(candidate_ref)' "amendment request links back to candidate"
  require_yq "$distillation" '.distillation_authorizes_promotion == false' "distillation cannot auto-promote"
  require_yq "$simulation" '.simulation_success_approves_change == false' "simulation success does not approve change"
  require_yq "$lab" '.lab_success_approves_change == false and .result == "passed"' "lab gate passed and lab success does not approve change"
  if yq -e '.risk_materiality == "constitutional"' "$candidate" >/dev/null 2>&1; then
    require_yq "$lab" '(.replay_refs | length) > 0 and (.shadow_run_refs | length) > 0' "constitutional candidate has replay and shadow proof"
  fi
  require_yq "$lab" '.generated_effective_freshness_refs[] | select(. == ".octon/generated/effective/runtime/route-bundle.lock.yml")' "lab gate cites generated/effective lock freshness"
  require_yq "$amendment" '.human_or_quorum_approval_required == true and (.approval_refs | length) > 0 and .amendment_request_authorizes_change == false' "constitutional amendment request requires approval and is non-authorizing"
  require_yq "$decision" '.status == "resolved_approved" and .resolution == "approval" and .decision_request_authorizes_promotion == false and .decision_request_authorizes_material_execution == false' "self-evolution Decision Request is resolved but non-authorizing"
  local promotion_ref=".octon/state/control/evolution/promotions/$PROMOTION_ID.yml"
  local recert_ref=".octon/state/control/evolution/recertifications/$RECERTIFICATION_ID.yml"
  candidate_ref="$candidate_ref" require_yq "$decision" '.subject_refs[] | select(. == env(candidate_ref))' "decision subject includes candidate"
  promotion_ref="$promotion_ref" require_yq "$decision" '.subject_refs[] | select(. == env(promotion_ref))' "decision subject includes promotion"
  promotion_ref="$promotion_ref" require_yq "$decision" '.canonical_resolution_targets[] | select(. == env(promotion_ref))' "decision resolves to promotion control"
  recert_ref="$recert_ref" require_yq "$decision" '.canonical_resolution_targets[] | select(. == env(recert_ref))' "decision resolves to recertification control"
  require_yq "$decision" '(.approval_refs | length) > 0 and .evidence_root == ".octon/state/evidence/evolution/decisions/evolution-decision-v5-validation"' "decision has approval refs and evidence root"
  require_yq "$approval_request" '.status == "granted" and (.workflow_mode == "role-mediated" or .workflow_mode == "human-only")' "approval request uses canonical granted workflow mode"
  require_yq "$approval_grant" '.state == "active" and .issued_by != null' "approval grant is active"
  require_yq "$quorum_policy" '.policy_id == "default" and .policy_ref != null and (.quorum_levels | length) > 0' "quorum policy matches schema shape"
  require_yq "$promotion" '.promotion_runtime_self_approves == false and .target_root_legality == "valid" and .recertification_required == true and .proposal_path_dependency_scan == "pass" and .support_no_widening == "pass" and (.support_no_widening_evidence_refs | length) > 0 and (.durable_decision_refs | length) > 0 and (.generated_projection_refresh_refs | length) > 0' "promotion request is gated, non-self-approving, and no-widening"
  require_yq "$recert_request" '.blocks_closure_until_terminal == true and (.required_checks | length) >= 15' "recertification request blocks closure and requires full dimensions"
  require_yq "$recert" '.status == "passed" and .failure_blocks_closure == true and .authority_placement == "passed" and .root_boundaries == "passed" and .runtime_authorization_coverage == "passed" and .support_target_claims == "passed" and .capability_pack_routes == "passed" and .connector_admissions == "passed" and .generated_effective_handles == "passed" and .context_pack_behavior == "passed" and .run_lifecycle == "passed" and .evidence_completeness == "passed" and .rollback_posture == "passed" and .operator_read_model_non_authority == "passed" and .documentation_runtime_consistency == "passed" and .validator_health == "passed-by-cli-dry-run" and .proof_plane_completeness == "passed"' "recertification result covers all required dimensions"
  require_yq "$ledger" '.role == "index-and-rollup-not-source-truth" and .ledger_replaces_source_truth == false' "Evolution Ledger does not replace source truth"
  require_yq "$rollback" '.owner_ref != null and .rollback_available == true and .rollback_plan != null and (.evidence_refs | length) > 0' "rollback posture has owner, plan, availability, and evidence"
  require_yq "$retirement" '.owner_ref != null and .retirement_available == true and .retirement_trigger != null and (.evidence_refs | length) > 0' "retirement posture has owner, trigger, availability, and evidence"

  while IFS= read -r source_ref; do
    [[ -n "$source_ref" ]] || continue
    [[ -e "$(resolve_repo_path "$source_ref")" ]] && pass "candidate evidence exists: $source_ref" || fail "candidate evidence missing: $source_ref"
  done < <(yq -r '.source_evidence_refs[]? // ""' "$candidate")

  local lab_ref field
  for field in replay_refs shadow_run_refs rollback_simulation_refs generated_effective_freshness_refs evidence_completeness_refs evidence_refs; do
    while IFS= read -r lab_ref; do
      [[ -n "$lab_ref" ]] || continue
      [[ -e "$(resolve_repo_path "$lab_ref")" ]] && pass "lab $field exists: $lab_ref" || fail "lab $field missing: $lab_ref"
    done < <(field="$field" yq -r '.[env(field)][]? // ""' "$lab")
  done

  local approval_ref approval_path
  while IFS= read -r approval_ref; do
    [[ -n "$approval_ref" ]] || continue
    approval_path="$(resolve_repo_path "$approval_ref")"
    require_file "$approval_path"
    require_yq "$approval_path" '.state == "active"' "approval ref is active: $approval_ref"
  done < <(yq -r '.approval_refs[]? // ""' "$amendment")

  local posture_evidence posture_path
  for posture_path in "$rollback" "$retirement"; do
    while IFS= read -r posture_evidence; do
      [[ -n "$posture_evidence" ]] || continue
      [[ -e "$(resolve_repo_path "$posture_evidence")" ]] && pass "posture evidence exists: $posture_evidence" || fail "posture evidence missing: $posture_evidence"
    done < <(yq -r '.evidence_refs[]? // ""' "$posture_path")
  done

  local required_evidence=(
    state/evidence/evolution/candidates/$CANDIDATE_ID/receipt.yml
    state/evidence/evolution/distillation/evolution-distillation-v5-validation/receipt.yml
    state/evidence/evolution/simulations/evolution-simulation-v5-validation/receipt.yml
    state/evidence/evolution/lab-gates/evolution-lab-gate-v5-validation/receipt.yml
    state/evidence/evolution/lab-gates/evolution-lab-gate-v5-validation/negative-control-results.yml
    state/evidence/evolution/lab-gates/evolution-lab-gate-v5-validation/replay-proof.yml
    state/evidence/evolution/lab-gates/evolution-lab-gate-v5-validation/shadow-run-proof.yml
    state/evidence/evolution/proposals/octon-self-evolution-proposal-to-promotion-runtime-v5/compilation-receipt.yml
    state/evidence/evolution/decisions/evolution-decision-v5-validation/receipt.yml
    state/evidence/evolution/amendment-requests/evolution-amendment-v5-validation/receipt.yml
    state/evidence/evolution/promotions/$PROMOTION_ID/receipt.yml
    state/evidence/evolution/recertifications/$RECERTIFICATION_ID/receipt.yml
    state/evidence/evolution/rollbacks/evolution-rollback-v5-validation/receipt.yml
    state/evidence/evolution/retirements/evolution-retirement-v5-validation/receipt.yml
  )
  local evidence
  for evidence in "${required_evidence[@]}"; do
    require_file "$OCTON_DIR/$evidence"
  done
  require_yq "$OCTON_DIR/state/evidence/evolution/amendment-requests/evolution-amendment-v5-validation/receipt.yml" '(.approval_refs | length) > 0' "amendment evidence retains approval refs"
  local recert_receipt="$OCTON_DIR/state/evidence/evolution/recertifications/$RECERTIFICATION_ID/receipt.yml"
  require_yq "$recert_receipt" '(.required_dimensions | length) >= 15 and (.dimension_evidence_refs | length) >= 15' "recertification evidence covers required dimensions"
  require_same_string_set "$recert_policy" ".required_dimensions" "$recert_request" ".required_checks" "recertification request exactly matches policy dimensions"
  require_same_string_set "$recert_policy" ".required_dimensions" "$recert_receipt" ".required_dimensions" "recertification receipt exactly matches policy dimensions"
  local dimension dimension_ref
  while IFS= read -r dimension; do
    [[ -n "$dimension" ]] || continue
    dimension_ref="$(dimension="$dimension" yq -r '.dimension_evidence_refs[env(dimension)] // ""' "$recert_receipt")"
    if [[ -z "$dimension_ref" ]]; then
      fail "recertification dimension evidence missing: $dimension"
    elif [[ -e "$(resolve_repo_path "$dimension_ref")" ]]; then
      pass "recertification dimension evidence exists: $dimension"
    else
      fail "recertification dimension evidence path missing: $dimension -> $dimension_ref"
    fi
  done < <(yq -r '.required_dimensions[]? // ""' "$recert_policy")
}

check_proposal_and_promotion() {
  echo "== Proposal, Promotion, and Recertification Validation =="
  local proposal_dir
  proposal_dir="$(resolve_proposal_dir)"
  local proposal="$proposal_dir/proposal.yml"
  local promotion="$OCTON_DIR/state/control/evolution/promotions/$PROMOTION_ID.yml"
  local recert="$OCTON_DIR/state/control/evolution/recertifications/$RECERTIFICATION_ID.yml"
  local receipt="$OCTON_DIR/state/evidence/evolution/promotions/$PROMOTION_ID/receipt.yml"
  require_yaml_schema "$proposal" "proposal-v1"
  require_yq "$proposal" '.status == "implemented" or (.status == "archived" and ((.archive.disposition == "implemented") or (.archive.archived_from_status == "implemented")))' "v5 proposal status is implemented or archived as implemented"
  require_yq "$proposal" '.lifecycle.temporary == true' "proposal remains temporary non-authoritative"

  local proposal_status control_status
  proposal_status="$(effective_implemented_status "$proposal")"
  control_status="$(yq -r '.proposal_status // ""' "$promotion")"
  [[ "$proposal_status" == "$control_status" ]] && pass "promotion status matches proposal manifest effective implemented state" || fail "promotion proposal_status must match actual proposal manifest effective implemented state"

  while IFS= read -r target; do
    [[ -n "$target" ]] || continue
    if target="$target" yq -e '.promotion_targets[] | select(. == env(target))' "$proposal" >/dev/null 2>&1; then
      pass "promotion target declared in proposal: $target"
    else
      fail "promotion target is missing from proposal manifest: $target"
    fi
    case "$target" in
      .octon/framework/*|.octon/instance/*|.octon/state/control/*|.octon/state/evidence/*|.octon/state/continuity/*|.octon/generated/*)
        case "$target" in
          .octon/generated/effective/*)
            fail "runtime-facing generated/effective promotion target requires publication and handle receipt gate: $target"
            ;;
          .octon/generated/cognition/projections/materialized/evolution/*)
            pass "generated promotion target is a non-authority evolution projection refresh: $target"
            ;;
          .octon/generated/*)
            fail "generated promotion target root is too broad: $target"
            ;;
          *)
            pass "promotion target root is legal: $target"
            ;;
        esac
        ;;
      *)
        fail "promotion target root is illegal: $target"
        ;;
    esac
  done < <(yq -r '.declared_promotion_targets[]? // ""' "$promotion")

  require_same_string_set "$promotion" ".declared_promotion_targets" "$receipt" ".target_refs" "promotion receipt target_refs exactly match declared promotion targets"
  while IFS= read -r target; do
    [[ -n "$target" ]] || continue
    local target_path
    target_path="$(resolve_repo_path "$target")"
    if [[ "$target" == */ ]]; then
      [[ -d "$target_path" ]] && pass "promotion receipt target directory exists: $target" || fail "promotion receipt target directory missing: $target"
    else
      [[ -f "$target_path" ]] && pass "promotion receipt target file exists: $target" || fail "promotion receipt target file missing: $target"
    fi
  done < <(yq -r '.target_refs[]? // ""' "$receipt")

  local proposal_dep_pattern
  proposal_dep_pattern="\\.octon/inputs/exploratory/proposals/(\\.archive/)?architecture/${PROPOSAL_ID}"
  if rg -n "$proposal_dep_pattern" \
    "$OCTON_DIR/framework" "$OCTON_DIR/instance" \
    -g '!**/validate-self-evolution-runtime-v5.sh' \
    -g '!**/test-self-evolution-runtime-v5.sh' \
    >/tmp/octon-v5-proposal-deps.$$ 2>/dev/null; then
    fail "framework/instance durable outputs must not retain proposal-path dependencies"
    cat /tmp/octon-v5-proposal-deps.$$
  else
    pass "durable framework/instance outputs contain no v5 proposal-path dependency"
  fi
  rm -f /tmp/octon-v5-proposal-deps.$$

  require_yq "$receipt" '.receipt_authorizes_future_change == false and .recertification_request_ref == ".octon/state/control/evolution/recertification-requests/evolution-recertification-v5-validation.yml" and .recertification_result_ref == ".octon/state/control/evolution/recertifications/evolution-recertification-v5-validation.yml" and .non_authority_attestation.proposal_packet_remains_non_authoritative == true and .non_authority_attestation.generated_projections_remain_non_authoritative == true and .non_authority_attestation.lab_success_was_not_approval == true and .non_authority_attestation.simulation_success_was_not_approval == true and .non_authority_attestation.self_authorization_denied == true' "promotion receipt preserves non-authority attestations and recertification split"
  require_yq "$recert" '.status == "passed" and .failure_blocks_closure == true' "recertification has passed and failures block closure"
}

check_generated_and_runtime_boundaries() {
  echo "== Generated, Runtime, and CLI Boundary Validation =="
  require_dir "$OCTON_DIR/generated/cognition/projections/materialized/evolution"
  local projection
  for projection in "$OCTON_DIR"/generated/cognition/projections/materialized/evolution/*.yml; do
    require_yq "$projection" '.generated_projection == true and .authority == "derived-non-authority"' "$(rel "$projection") is derived non-authority"
  done
  require_yq "$OCTON_DIR/instance/governance/non-authority-register.yml" '.entries[] | select(.surface_id == "evolution-operator-read-models" and .authority_mode == "derived-non-authority")' "non-authority register includes evolution projections"

  local runtime="$OCTON_DIR/framework/engine/runtime/crates/kernel/src/commands/evolution.rs"
  require_file "$runtime"
  if rg -n 'cmd_run|cmd_tool|cmd_publish|ProcessCommand|authorize_execution|issue_repo_mutation_effect' "$runtime" >/tmp/octon-v5-runtime-bypass.$$ 2>/dev/null; then
    fail "self-evolution runtime must not bypass run lifecycle or direct material effects"
    cat /tmp/octon-v5-runtime-bypass.$$
  else
    pass "self-evolution runtime has no direct run/tool/publication/material-effect bypass"
  fi
  rm -f /tmp/octon-v5-runtime-bypass.$$
  if rg -n 'write_yaml|fs::write|create_dir_all|now_rfc3339' "$runtime" >/tmp/octon-v5-runtime-write.$$ 2>/dev/null; then
    fail "self-evolution runtime CLI must not directly mutate control/evidence state"
    cat /tmp/octon-v5-runtime-write.$$
  else
    pass "self-evolution runtime CLI is read-only/fail-closed for state writes"
  fi
  rm -f /tmp/octon-v5-runtime-write.$$

  if rg -n '\.octon/inputs/' "$runtime" >/tmp/octon-v5-inputs.$$ 2>/dev/null; then
    fail "runtime and policy must not depend on inputs/**"
    cat /tmp/octon-v5-inputs.$$
  else
    pass "no inputs/** runtime or policy dependency in v5 runtime/policy"
  fi
  rm -f /tmp/octon-v5-inputs.$$
  require_yq "$OCTON_DIR/instance/governance/evolution/path-families.yml" '.input_root_runtime_or_policy_dependency_allowed == false and .proposal_packet_authority_allowed == false and .generated_projection_authority_allowed == false' "evolution path families explicitly deny input/proposal/generated authority"

  rg -n 'Evolve|Amend|Promote|Recertify' "$OCTON_DIR/framework/engine/runtime/crates/kernel/src/main.rs" >/dev/null \
    && pass "v5 top-level CLI commands are wired" \
    || fail "v5 top-level CLI commands must be wired"
  rg -n 'cmd_evolve|cmd_amend|cmd_promote|cmd_recertify' "$OCTON_DIR/framework/engine/runtime/crates/kernel/src/commands/mod.rs" >/dev/null \
    && pass "v5 CLI dispatch is wired" \
    || fail "v5 CLI dispatch must be wired"
}

main() {
  check_tools
  check_static_contracts
  check_instance_and_control
  check_proposal_and_promotion
  check_generated_and_runtime_boundaries
  echo "Validation summary: errors=$errors"
  [[ $errors -eq 0 ]]
}

main "$@"

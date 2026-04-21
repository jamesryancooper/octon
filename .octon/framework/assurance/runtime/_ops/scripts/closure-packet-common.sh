#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../.." && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
ROOT_DIR="${OCTON_ROOT_DIR:-$(cd -- "$OCTON_DIR/.." && pwd)}"
SUPPORT_DOSSIER_ROOT="$OCTON_DIR/instance/governance/support-dossiers"
SUPPORT_TARGETS_DECLARATION="$OCTON_DIR/instance/governance/support-targets.yml"
RELEASE_LINEAGE_PATH="$OCTON_DIR/instance/governance/disclosure/release-lineage.yml"
RETIREMENT_REGISTRY_PATH="$OCTON_DIR/instance/governance/contracts/retirement-registry.yml"
RETIREMENT_DISCLOSURE_PATH="$OCTON_DIR/instance/governance/retirement-register.yml"
LAB_SCENARIO_REGISTRY_PATH="$OCTON_DIR/framework/lab/scenarios/registry.yml"
LAB_SCENARIO_INDEX_PATH="$OCTON_DIR/state/evidence/lab/index/by-scenario.yml"

require_yq() {
  command -v yq >/dev/null 2>&1 || {
    echo "yq is required" >&2
    exit 1
  }
}

resolve_release_id() {
  if [[ $# -gt 0 && -n "${1:-}" ]]; then
    printf '%s\n' "$1"
  elif [[ -n "${CLOSURE_RELEASE_ID:-}" ]]; then
    printf '%s\n' "$CLOSURE_RELEASE_ID"
  elif command -v yq >/dev/null 2>&1 && [[ -f "$RELEASE_LINEAGE_PATH" ]]; then
    yq -r '.active_release.release_id' "$RELEASE_LINEAGE_PATH"
  else
    echo "unable to resolve active release id" >&2
    exit 1
  fi
}

release_root() {
  local release_id
  release_id="$(resolve_release_id "${1:-}")"
  printf '%s/state/evidence/disclosure/releases/%s\n' "$OCTON_DIR" "$release_id"
}

closure_root() {
  printf '%s/closure\n' "$(release_root "${1:-}")"
}

closure_report_path() {
  local release_id="$1"
  local report_name="$2"
  printf '%s/%s\n' "$(closure_root "$release_id")" "$report_name"
}

support_dossier_files() {
  find "$SUPPORT_DOSSIER_ROOT" -name dossier.yml -print | sort
}

tuple_inventory_files() {
  yq -r '.tuple_admissions[].admission_ref' "$SUPPORT_TARGETS_DECLARATION" 2>/dev/null \
    | awk 'NF' \
    | while IFS= read -r ref; do
        printf '%s/%s\n' "$ROOT_DIR" "$ref"
      done \
    | sort
}

supported_dossier_files() {
  local dossier
  while IFS= read -r dossier; do
    yq -e 'select(.status == "supported")' "$dossier" >/dev/null 2>&1 || continue
    printf '%s\n' "$dossier"
  done < <(support_dossier_files)
}

non_live_dossier_files() {
  local dossier
  while IFS= read -r dossier; do
    yq -e 'select(.status != "supported")' "$dossier" >/dev/null 2>&1 || continue
    printf '%s\n' "$dossier"
  done < <(support_dossier_files)
}

stage_only_dossier_files() {
  non_live_dossier_files
}

all_representative_run_contracts() {
  local dossier
  while IFS= read -r dossier; do
    yq -r '.representative_retained_runs[]?' "$dossier"
  done < <(support_dossier_files)
}

representative_run_contracts() {
  local dossier
  while IFS= read -r dossier; do
    yq -r '.representative_retained_runs[]?' "$dossier"
  done < <(supported_dossier_files)
}

run_id_from_contract_ref() {
  basename "$(dirname "$1")"
}

representative_run_ids() {
  local ref
  while IFS= read -r ref; do
    [[ -n "$ref" ]] || continue
    run_id_from_contract_ref "$ref"
  done < <(representative_run_contracts) | sort -u
}

stage_only_representative_run_ids() {
  local ref dossier
  while IFS= read -r dossier; do
    while IFS= read -r ref; do
      [[ -n "$ref" ]] || continue
      run_id_from_contract_ref "$ref"
    done < <(yq -r '.representative_retained_runs[]?' "$dossier")
  done < <(stage_only_dossier_files) | sort -u
}

run_contract_path() { printf '%s/state/control/execution/runs/%s/run-contract.yml\n' "$OCTON_DIR" "$1"; }
run_manifest_path() { printf '%s/state/control/execution/runs/%s/run-manifest.yml\n' "$OCTON_DIR" "$1"; }
runtime_state_path() { printf '%s/state/control/execution/runs/%s/runtime-state.yml\n' "$OCTON_DIR" "$1"; }
rollback_posture_path() { printf '%s/state/control/execution/runs/%s/rollback-posture.yml\n' "$OCTON_DIR" "$1"; }
stage_attempt_path() {
  local run_id="$1"
  local runtime_state contract notes_ref stage_attempt_id candidate

  runtime_state="$(runtime_state_path "$run_id")"
  if [[ -f "$runtime_state" ]]; then
    stage_attempt_id="$(yq -r '.current_stage_attempt_id // ""' "$runtime_state" 2>/dev/null || true)"
    if [[ -n "$stage_attempt_id" ]]; then
      candidate="$OCTON_DIR/state/control/execution/runs/$run_id/stage-attempts/$stage_attempt_id.yml"
      if [[ -f "$candidate" ]]; then
        printf '%s\n' "$candidate"
        return 0
      fi
    fi
  fi

  contract="$(run_contract_path "$run_id")"
  if [[ -f "$contract" ]]; then
    notes_ref="$(yq -r '.notes_ref // ""' "$contract" 2>/dev/null || true)"
    if [[ -n "$notes_ref" && -f "$ROOT_DIR/$notes_ref" ]]; then
      printf '%s\n' "$ROOT_DIR/$notes_ref"
      return 0
    fi
  fi

  printf '%s/state/control/execution/runs/%s/stage-attempts/initial.yml\n' "$OCTON_DIR" "$run_id"
}
classification_path() { printf '%s/state/evidence/runs/%s/evidence-classification.yml\n' "$OCTON_DIR" "$1"; }
run_card_path() { printf '%s/state/evidence/disclosure/runs/%s/run-card.yml\n' "$OCTON_DIR" "$1"; }
retained_evidence_path() { printf '%s/state/evidence/runs/%s/retained-run-evidence.yml\n' "$OCTON_DIR" "$1"; }
measurement_summary_path() { printf '%s/state/evidence/runs/%s/measurements/summary.yml\n' "$OCTON_DIR" "$1"; }
intervention_log_path() { printf '%s/state/evidence/runs/%s/interventions/log.yml\n' "$OCTON_DIR" "$1"; }
replay_manifest_path() { printf '%s/state/evidence/runs/%s/replay/manifest.yml\n' "$OCTON_DIR" "$1"; }
external_index_path() { printf '%s/state/evidence/external-index/runs/%s.yml\n' "$OCTON_DIR" "$1"; }

dossier_for_run() {
  local run_id="$1"
  local dossier
  while IFS= read -r dossier; do
    if yq -e ".representative_retained_runs[]? | select(. == \".octon/state/control/execution/runs/$run_id/run-contract.yml\")" "$dossier" >/dev/null 2>&1; then
      printf '%s\n' "$dossier"
      return 0
    fi
  done < <(support_dossier_files)
  return 1
}

admission_for_run() {
  local dossier
  dossier="$(dossier_for_run "$1")"
  local ref
  ref="$(yq -r '.support_admission_ref // ""' "$dossier")"
  [[ -n "$ref" ]] || return 1
  printf '%s/%s\n' "$ROOT_DIR" "$ref"
}

tuple_id_for_run() {
  local admission
  admission="$(admission_for_run "$1")"
  yq -r '.tuple_id // ""' "$admission"
}

admission_ref_for_run() {
  local dossier
  dossier="$(dossier_for_run "$1")"
  yq -r '.support_admission_ref // ""' "$dossier"
}

support_dossier_ref_for_run() {
  local dossier
  dossier="$(dossier_for_run "$1")"
  yq -r '.support_dossier_ref // ""' "$dossier"
}

admission_value_for_run() {
  local run_id="$1"
  local expr="$2"
  local admission
  admission="$(admission_for_run "$run_id")"
  yq -r "$expr" "$admission"
}

route_for_run() { admission_value_for_run "$1" '.route // ""'; }
requires_mission_for_run() { admission_value_for_run "$1" '.requires_mission // false'; }

sorted_admission_packs_for_run() {
  admission_value_for_run "$1" '.allowed_capability_packs[]' 2>/dev/null | awk 'NF' | sort
}

dossier_status_for_run() {
  local dossier
  dossier="$(dossier_for_run "$1")"
  yq -r '.status' "$dossier"
}

sorted_array() {
  local expr="$1"
  local file="$2"
  yq -r "$expr" "$file" 2>/dev/null | awk 'NF' | sort
}

tuple_value_from_contract() {
  local run_id="$1"
  local key="$2"
  yq -r ".support_target_tuple.$key // .support_target.$key // \"\"" "$(run_contract_path "$run_id")"
}

tuple_value_from_manifest() {
  local run_id="$1"
  local key="$2"
  yq -r ".support_target.$key // \"\"" "$(run_manifest_path "$run_id")"
}

tuple_value_from_run_card() {
  local run_id="$1"
  local key="$2"
  yq -r ".support_target_tuple.$key // \"\"" "$(run_card_path "$run_id")"
}

run_contract_support_ref() {
  yq -r '.support_target_ref // ""' "$(run_contract_path "$1")"
}

run_contract_support_admission_ref() {
  yq -r '.support_target_admission_ref // ""' "$(run_contract_path "$1")"
}

run_contract_support_tuple_id() {
  yq -r '.support_target_tuple_id // ""' "$(run_contract_path "$1")"
}

run_contract_support_component() {
  local run_id="$1"
  local key="$2"

  case "$key" in
    workload_tier)
      yq -r '.support_target.workload_tier // .support_target_tuple.workload_tier // .support_tier // ""' "$(run_contract_path "$run_id")"
      ;;
    *)
      yq -r ".support_target.$key // .support_target_tuple.$key // \"\"" "$(run_contract_path "$run_id")"
      ;;
  esac
}

run_contract_support_semantics_match_admission() {
  local run_id="$1"
  local admission="$2"
  local key expected actual

  for key in model_tier workload_tier language_resource_tier locale_tier model_adapter; do
    expected="$(yq -r ".tuple.$key // \"\"" "$admission")"
    actual="$(run_contract_support_component "$run_id" "$key")"
    [[ "$actual" == "$expected" ]] || return 1
  done

  return 0
}

sha256_file() {
  shasum -a 256 "$1" | awk '{print "sha256:" $1}'
}

deterministic_generated_at() {
  if command -v yq >/dev/null 2>&1 && [[ -f "$RELEASE_LINEAGE_PATH" ]]; then
    yq -r '.updated_at // ""' "$RELEASE_LINEAGE_PATH"
  else
    git log -1 --format=%cI 2>/dev/null || date -u +"%Y-%m-%dT%H:%M:%SZ"
  fi
}

effective_closure_root() { printf '%s/generated/effective/closure\n' "$OCTON_DIR"; }
effective_claim_status_path() { printf '%s/claim-status.yml\n' "$(effective_closure_root)"; }
effective_recertification_status_path() { printf '%s/recertification-status.yml\n' "$(effective_closure_root)"; }

migration_run_id_for_release() {
  local release_id="$1"
  local release_date release_slug
  release_date="$(printf '%s\n' "$release_id" | awk -F- '{print $1 "-" $2 "-" $3}')"
  release_slug="$(printf '%s\n' "$release_id" | cut -d- -f4-)"
  printf '%s-octon-%s\n' "$release_date" "$release_slug"
}

migration_plan_ref_for_release() {
  local release_id
  release_id="$(resolve_release_id "${1:-}")"
  printf '.octon/instance/cognition/context/shared/migrations/%s/plan.md\n' "$(migration_run_id_for_release "$release_id")"
}

forbidden_phrase_pattern() {
  printf '%s\n' 'globally complete support universe'
}

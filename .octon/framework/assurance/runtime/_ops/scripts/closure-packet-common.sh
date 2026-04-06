#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../.." && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
ROOT_DIR="${OCTON_ROOT_DIR:-$(cd -- "$OCTON_DIR/.." && pwd)}"
SUPPORT_DOSSIER_ROOT="$OCTON_DIR/instance/governance/support-dossiers"
RELEASE_LINEAGE_PATH="$OCTON_DIR/instance/governance/disclosure/release-lineage.yml"

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

support_dossier_files() {
  find "$SUPPORT_DOSSIER_ROOT" -name dossier.yml -print | sort
}

representative_run_contracts() {
  local dossier
  while IFS= read -r dossier; do
    yq -r '.representative_retained_runs[]?' "$dossier"
  done < <(support_dossier_files)
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

run_contract_path() { printf '%s/state/control/execution/runs/%s/run-contract.yml\n' "$OCTON_DIR" "$1"; }
run_manifest_path() { printf '%s/state/control/execution/runs/%s/run-manifest.yml\n' "$OCTON_DIR" "$1"; }
runtime_state_path() { printf '%s/state/control/execution/runs/%s/runtime-state.yml\n' "$OCTON_DIR" "$1"; }
rollback_posture_path() { printf '%s/state/control/execution/runs/%s/rollback-posture.yml\n' "$OCTON_DIR" "$1"; }
stage_attempt_path() { printf '%s/state/control/execution/runs/%s/stage-attempts/initial.yml\n' "$OCTON_DIR" "$1"; }
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
    if yq -r '.representative_retained_runs[]?' "$dossier" | grep -Fxq ".octon/state/control/execution/runs/$run_id/run-contract.yml"; then
      printf '%s\n' "$dossier"
      return 0
    fi
  done < <(support_dossier_files)
  return 1
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

forbidden_phrase_pattern() {
  printf '%s\n' 'global complete|globally complete support universe'
}

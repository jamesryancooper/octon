#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
REGISTRY="$OCTON_DIR/instance/orchestration/missions/registry.yml"

errors=0
fail() { echo "[ERROR] $1"; errors=$((errors + 1)); }
pass() { echo "[OK] $1"; }

valid_boundary_class() {
  case "$1" in
    file_batch_boundary|task_boundary|resource_batch_boundary|chunk_boundary|deployment_step_boundary|api_page_boundary|playbook_step_boundary|publish_gate|contract_phase_boundary) return 0 ;;
    *) return 1 ;;
  esac
}

main() {
  echo "== Mission Route Normalization Validation =="

  while IFS= read -r mission_id; do
    [[ -n "$mission_id" ]] || continue

    local route_file="$OCTON_DIR/generated/effective/orchestration/missions/$mission_id/scenario-resolution.yml"
    local scenario_family boundary_class scenario_source boundary_source recovery_source current_action_slice

    [[ -f "$route_file" ]] || { fail "missing route for $mission_id"; continue; }

    scenario_family="$(yq -r '.effective.effective_scenario_family // ""' "$route_file")"
    boundary_class="$(yq -r '.effective.safe_interrupt_boundary_class // ""' "$route_file")"
    scenario_source="$(yq -r '.effective.scenario_family_source // ""' "$route_file")"
    boundary_source="$(yq -r '.effective.boundary_source // ""' "$route_file")"
    recovery_source="$(yq -r '.effective.recovery_source // ""' "$route_file")"
    current_action_slice="$(yq -r '.source_refs.current_action_slice // ""' "$route_file")"

    [[ -n "$scenario_family" ]] && pass "route family present for $mission_id" || fail "route family missing for $mission_id"
    [[ "$scenario_family" == *.* ]] && pass "route family is normalized for $mission_id" || fail "route family must be normalized for $mission_id"

    if valid_boundary_class "$boundary_class"; then
      pass "boundary class normalized for $mission_id"
    else
      fail "boundary class must use the normalized taxonomy for $mission_id"
    fi

    [[ -n "$scenario_source" ]] && pass "scenario family source recorded for $mission_id" || fail "scenario family source missing for $mission_id"
    [[ -n "$boundary_source" ]] && pass "boundary source recorded for $mission_id" || fail "boundary source missing for $mission_id"
    [[ -n "$recovery_source" ]] && pass "recovery source recorded for $mission_id" || fail "recovery source missing for $mission_id"

    if yq -e '.effective.tightening_overlays' "$route_file" >/dev/null 2>&1; then
      pass "tightening overlays recorded for $mission_id"
    else
      fail "tightening overlays missing for $mission_id"
    fi

    if [[ -n "$current_action_slice" ]]; then
      [[ "$boundary_source" != "" ]] && pass "current action slice has a boundary source for $mission_id" || fail "current action slice requires a boundary source for $mission_id"
    fi
  done < <(yq -r '.active[]?' "$REGISTRY" 2>/dev/null || true)

  echo "Validation summary: errors=$errors"
  [[ $errors -eq 0 ]]
}

main "$@"

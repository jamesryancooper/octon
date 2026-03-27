#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
REGISTRY="$OCTON_DIR/instance/orchestration/missions/registry.yml"
SYNC_SCRIPT="$OCTON_DIR/framework/cognition/_ops/runtime/scripts/sync-runtime-artifacts.sh"
MISSION_VIEW_ROOT="$OCTON_DIR/generated/cognition/projections/materialized/missions"

errors=0
fail() { echo "[ERROR] $1"; errors=$((errors + 1)); }
pass() { echo "[OK] $1"; }

main() {
  echo "== Mission View Generation Validation =="

  [[ -x "$SYNC_SCRIPT" ]] && bash "$SYNC_SCRIPT" --target missions >/dev/null 2>&1 || true

  while IFS= read -r mission_id; do
    [[ -n "$mission_id" ]] || continue
    local mission_view="$MISSION_VIEW_ROOT/$mission_id/mission-view.yml"
    local current_slice_ref

    [[ -f "$mission_view" ]] && pass "mission view exists for $mission_id" || { fail "missing mission view for $mission_id"; continue; }
    [[ "$(yq -r '.schema_version // ""' "$mission_view")" == "mission-view-v1" ]] && pass "mission view schema is correct for $mission_id" || fail "mission view schema is invalid for $mission_id"

    for path_key in mission route mode_state intent_register continuity control_evidence_root run_evidence_root run_control_root; do
      if [[ -n "$(yq -r ".source_refs.${path_key} // \"\"" "$mission_view" 2>/dev/null || true)" ]]; then
        pass "mission view source_refs.$path_key present for $mission_id"
      else
        fail "mission view source_refs.$path_key missing for $mission_id"
      fi
    done

    current_slice_ref="$(yq -r '.current_slice_ref // ""' "$mission_view" 2>/dev/null || true)"
    if [[ -n "$current_slice_ref" && "$current_slice_ref" != "null" ]]; then
      if [[ "$(yq -r '.source_refs.current_action_slice // ""' "$mission_view" 2>/dev/null || true)" == "$current_slice_ref" ]]; then
        pass "mission view cites current action slice for $mission_id"
      else
        fail "mission view must cite current action slice for $mission_id"
      fi
    fi

    for summary_ref in now next recent recover; do
      local summary_path
      summary_path="$(yq -r ".summary_refs.${summary_ref} // \"\"" "$mission_view" 2>/dev/null || true)"
      if [[ -n "$summary_path" && -f "$OCTON_DIR/${summary_path#/.octon/}" ]]; then
        pass "mission view summary_refs.$summary_ref resolves for $mission_id"
      else
        fail "mission view summary_refs.$summary_ref missing or unresolved for $mission_id"
      fi
    done

    for refs_key in active_run_ids run_contracts runtime_states rollback_postures checkpoints receipts replay_pointers retained_evidence trace_pointers; do
      if yq -e ".run_evidence_refs.${refs_key}" "$mission_view" >/dev/null 2>&1; then
        pass "mission view run_evidence_refs.$refs_key present for $mission_id"
      else
        fail "mission view run_evidence_refs.$refs_key missing for $mission_id"
      fi
    done

    for route_key in scenario_family_source boundary_source recovery_source; do
      if [[ -n "$(yq -r ".effective_route.${route_key} // \"\"" "$mission_view" 2>/dev/null || true)" ]]; then
        pass "mission view effective_route.$route_key present for $mission_id"
      else
        fail "mission view effective_route.$route_key missing for $mission_id"
      fi
    done
  done < <(yq -r '.active[]?' "$REGISTRY" 2>/dev/null || true)

  echo "Validation summary: errors=$errors"
  [[ $errors -eq 0 ]]
}

main "$@"

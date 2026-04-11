#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
ROOT_DIR="${OCTON_ROOT_DIR:-$(cd -- "$OCTON_DIR/.." && pwd)}"
REGISTRY="$OCTON_DIR/instance/orchestration/missions/registry.yml"
MISSION_ROOT="$OCTON_DIR/instance/orchestration/missions"
CONTROL_ROOT="$OCTON_DIR/state/control/execution/missions"
CONTINUITY_ROOT="$OCTON_DIR/state/continuity/repo/missions"
ROUTE_ROOT="$OCTON_DIR/generated/effective/orchestration/missions"
SUMMARIES_ROOT="$OCTON_DIR/generated/cognition/summaries/missions"
PROJECTION_ROOT="$OCTON_DIR/generated/cognition/projections/materialized/missions"
CONTROL_EVIDENCE_ROOT="$OCTON_DIR/state/evidence/control/execution"
SEED_HELPER="$OCTON_DIR/framework/orchestration/runtime/_ops/scripts/seed-mission-autonomy-state.sh"
SYNC_SCRIPT="$OCTON_DIR/framework/cognition/_ops/runtime/scripts/sync-runtime-artifacts.sh"

errors=0
fail() { echo "[ERROR] $1"; errors=$((errors + 1)); }
pass() { echo "[OK] $1"; }

main() {
  echo "== Mission Lifecycle Cutover Validation =="

  [[ -x "$SYNC_SCRIPT" ]] && bash "$SYNC_SCRIPT" --target missions >/dev/null 2>&1 || true
  [[ -x "$SEED_HELPER" ]] && pass "mission seed helper exists" || fail "missing mission seed helper"

  if find "$MISSION_ROOT/_scaffold" \( -name 'lease.yml' -o -name 'mode-state.yml' -o -name 'intent-register.yml' -o -name 'mission-classification.yml' -o -name 'schedule.yml' -o -name 'autonomy-budget.yml' -o -name 'circuit-breakers.yml' -o -name 'subscriptions.yml' \) | grep -q .; then
    fail "mission scaffold must remain authority-only"
  else
    pass "mission scaffold remains authority-only"
  fi

  while IFS= read -r mission_id; do
    [[ -n "$mission_id" ]] || continue

    local mission_file="$MISSION_ROOT/$mission_id/mission.yml"
    local control_dir="$CONTROL_ROOT/$mission_id"
    local continuity_dir="$CONTINUITY_ROOT/$mission_id"
    local route_file="$ROUTE_ROOT/$mission_id/scenario-resolution.yml"
    local mode_state_file="$control_dir/mode-state.yml"
    local seed_receipt

    [[ -f "$mission_file" ]] && pass "mission authority exists for $mission_id" || { fail "missing mission authority for $mission_id"; continue; }

    for file in lease.yml mode-state.yml intent-register.yml mission-classification.yml directives.yml authorize-updates.yml schedule.yml autonomy-budget.yml circuit-breakers.yml subscriptions.yml; do
      [[ -f "$control_dir/$file" ]] && pass "found $mission_id/$file" || fail "missing $mission_id/$file"
    done
    [[ -d "$control_dir/action-slices" ]] && pass "found $mission_id/action-slices/" || fail "missing $mission_id/action-slices/"

    for file in next-actions.yml handoff.md; do
      [[ -f "$continuity_dir/$file" ]] && pass "found continuity $mission_id/$file" || fail "missing continuity $mission_id/$file"
    done

    [[ -f "$route_file" ]] && pass "effective route exists for $mission_id" || fail "missing effective route for $mission_id"
    [[ "$(yq -r '.effective_scenario_resolution_ref // ""' "$mode_state_file" 2>/dev/null)" == ".octon/generated/effective/orchestration/missions/$mission_id/scenario-resolution.yml" ]] \
      && pass "mode-state links route for $mission_id" \
      || fail "mode-state must link effective route for $mission_id"

    for summary in now.md next.md recent.md recover.md; do
      [[ -f "$SUMMARIES_ROOT/$mission_id/$summary" ]] && pass "found generated summary $mission_id/$summary" || fail "missing generated summary $mission_id/$summary"
    done
    [[ -f "$PROJECTION_ROOT/$mission_id/mission-view.yml" ]] && pass "found mission view for $mission_id" || fail "missing mission view for $mission_id"

    seed_receipt="$(grep -R -l "mission_id: \"$mission_id\"" "$CONTROL_EVIDENCE_ROOT" 2>/dev/null | xargs grep -l 'control_mutation_class: "mission_seed"' 2>/dev/null | head -n1 || true)"
    if [[ -n "$seed_receipt" ]]; then
      pass "mission seed receipt exists for $mission_id"
    else
      fail "missing mission seed receipt for $mission_id"
    fi
  done < <(yq -r '.active[]?' "$REGISTRY" 2>/dev/null || true)

  echo "Validation summary: errors=$errors"
  [[ $errors -eq 0 ]]
}

main "$@"

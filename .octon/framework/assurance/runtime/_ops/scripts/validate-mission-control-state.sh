#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
ROOT_DIR="${OCTON_ROOT_DIR:-$(cd -- "$OCTON_DIR/.." && pwd)}"
REGISTRY="$OCTON_DIR/instance/orchestration/missions/registry.yml"
CONTROL_ROOT="$OCTON_DIR/state/control/execution/missions"
CONTINUITY_ROOT="$OCTON_DIR/state/continuity/repo/missions"
SEED_HELPER="$OCTON_DIR/framework/orchestration/runtime/_ops/scripts/seed-mission-autonomy-state.sh"
CLOSE_HELPER="$OCTON_DIR/framework/orchestration/runtime/_ops/scripts/close-mission-autonomy-state.sh"
CONTROL_EVALUATOR="$OCTON_DIR/framework/orchestration/runtime/_ops/scripts/evaluate-mission-control-state.sh"
AUTHORIZE_UPDATE_HELPER="$OCTON_DIR/framework/orchestration/runtime/_ops/scripts/apply-mission-authorize-update.sh"

errors=0
fail() { echo "[ERROR] $1"; errors=$((errors + 1)); }
pass() { echo "[OK] $1"; }

main() {
  echo "== Mission Control State Validation =="

  [[ -d "$CONTROL_ROOT" ]] && pass "mission control root exists" || fail "missing mission control root"
  [[ -d "$CONTINUITY_ROOT" ]] && pass "mission continuity root exists" || fail "missing mission continuity root"
  [[ -x "$SEED_HELPER" ]] && pass "mission seed helper exists" || fail "missing mission seed helper"
  [[ -x "$CLOSE_HELPER" ]] && pass "mission close helper exists" || fail "missing mission close helper"
  [[ -x "$CONTROL_EVALUATOR" ]] && pass "mission control evaluator exists" || fail "missing mission control evaluator"
  [[ -x "$AUTHORIZE_UPDATE_HELPER" ]] && pass "mission authorize-update helper exists" || fail "missing mission authorize-update helper"

  while IFS= read -r mission_id; do
    [[ -n "$mission_id" ]] || continue
    local dir="$CONTROL_ROOT/$mission_id"
    local continuity="$CONTINUITY_ROOT/$mission_id"
    for file in lease.yml mode-state.yml intent-register.yml mission-classification.yml directives.yml authorize-updates.yml schedule.yml autonomy-budget.yml circuit-breakers.yml subscriptions.yml; do
      [[ -f "$dir/$file" ]] && pass "found $mission_id/$file" || fail "missing $mission_id/$file"
    done
    [[ -d "$dir/action-slices" ]] && pass "found $mission_id/action-slices/" || fail "missing $mission_id/action-slices/"
    for file in next-actions.yml handoff.md; do
      [[ -f "$continuity/$file" ]] && pass "found continuity $mission_id/$file" || fail "missing continuity $mission_id/$file"
    done
  done < <(yq -r '.active[]?' "$REGISTRY" 2>/dev/null || true)

  echo "Validation summary: errors=$errors"
  [[ $errors -eq 0 ]]
}

main "$@"

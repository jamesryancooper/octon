#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
ROOT_DIR="${OCTON_ROOT_DIR:-$(cd -- "$OCTON_DIR/.." && pwd)}"
REGISTRY="$OCTON_DIR/instance/orchestration/missions/registry.yml"
ROUTE_ROOT="$OCTON_DIR/generated/effective/orchestration/missions"
PUBLISH_SCRIPT="$OCTON_DIR/framework/orchestration/runtime/_ops/scripts/publish-mission-effective-route.sh"

errors=0
fail() { echo "[ERROR] $1"; errors=$((errors + 1)); }
pass() { echo "[OK] $1"; }

main() {
  echo "== Mission Effective Route Validation =="

  [[ -d "$ROUTE_ROOT" ]] && pass "mission effective route root exists" || fail "missing mission effective route root"
  [[ -x "$PUBLISH_SCRIPT" ]] && pass "mission effective route publisher exists" || fail "missing mission effective route publisher"

  while IFS= read -r mission_id; do
    [[ -n "$mission_id" ]] || continue
    local route_file="$ROUTE_ROOT/$mission_id/scenario-resolution.yml"
    if [[ ! -f "$route_file" ]]; then
      fail "missing scenario resolution for $mission_id"
      continue
    fi
    [[ "$(yq -r '.schema_version // ""' "$route_file")" == "scenario-resolution-v1" ]] && pass "scenario-resolution schema version valid for $mission_id" || fail "invalid scenario-resolution schema version for $mission_id"
    local generated_at fresh_until
    generated_at="$(yq -r '.generated_at // ""' "$route_file")"
    fresh_until="$(yq -r '.fresh_until // ""' "$route_file")"
    [[ -n "$generated_at" && -n "$fresh_until" ]] && pass "scenario-resolution freshness fields present for $mission_id" || fail "scenario-resolution freshness fields missing for $mission_id"
    if [[ -n "$generated_at" && -n "$fresh_until" && "$generated_at" < "$fresh_until" ]]; then
      pass "scenario-resolution freshness window is forward-moving for $mission_id"
    else
      fail "scenario-resolution freshness window invalid for $mission_id"
    fi
  done < <(yq -r '.active[]?' "$REGISTRY" 2>/dev/null || true)

  echo "Validation summary: errors=$errors"
  [[ $errors -eq 0 ]]
}

main "$@"

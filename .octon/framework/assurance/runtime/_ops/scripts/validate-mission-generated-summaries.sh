#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
ROOT_DIR="${OCTON_ROOT_DIR:-$(cd -- "$OCTON_DIR/.." && pwd)}"
REGISTRY="$OCTON_DIR/instance/orchestration/missions/registry.yml"
SYNC_SCRIPT="$OCTON_DIR/framework/cognition/_ops/runtime/scripts/sync-runtime-artifacts.sh"
MISSION_SUMMARIES="$OCTON_DIR/generated/cognition/summaries/missions"
OPERATOR_DIGESTS="$OCTON_DIR/generated/cognition/summaries/operators"
MISSION_PROJECTIONS="$OCTON_DIR/generated/cognition/projections/materialized/missions"

errors=0
fail() { echo "[ERROR] $1"; errors=$((errors + 1)); }
pass() { echo "[OK] $1"; }
has_pattern() {
  local pattern="$1"
  local file="$2"
  if command -v rg >/dev/null 2>&1; then
    rg -q -- "$pattern" "$file"
  else
    grep -Eq -- "$pattern" "$file"
  fi
}

main() {
  echo "== Mission Generated Summaries Validation =="

  [[ -d "$MISSION_SUMMARIES" ]] && pass "mission summaries root exists" || fail "missing mission summaries root"
  [[ -d "$OPERATOR_DIGESTS" ]] && pass "operator digests root exists" || fail "missing operator digests root"
  [[ -d "$MISSION_PROJECTIONS" ]] && pass "mission projections root exists" || fail "missing mission projections root"
  has_pattern 'generate_mission_autonomy_views' "$SYNC_SCRIPT" && pass "sync-runtime-artifacts includes mission generator" || fail "sync-runtime-artifacts missing mission generator"
  has_pattern 'missions' "$SYNC_SCRIPT" && pass "sync-runtime-artifacts advertises missions target" || fail "sync-runtime-artifacts missing missions target"

  while IFS= read -r mission_id; do
    [[ -n "$mission_id" ]] || continue
    for file in now.md next.md recent.md recover.md; do
      [[ -f "$MISSION_SUMMARIES/$mission_id/$file" ]] && pass "found mission summary $mission_id/$file" || fail "missing mission summary $mission_id/$file"
    done
    [[ -f "$MISSION_PROJECTIONS/$mission_id.json" ]] && pass "found mission projection $mission_id.json" || fail "missing mission projection $mission_id.json"
  done < <(yq -r '.active[]?' "$REGISTRY" 2>/dev/null || true)

  echo "Validation summary: errors=$errors"
  [[ $errors -eq 0 ]]
}

main "$@"

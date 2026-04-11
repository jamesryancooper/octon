#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
ROOT_DIR="${OCTON_ROOT_DIR:-$(cd -- "$OCTON_DIR/.." && pwd)}"
MISSIONS_DIR="$OCTON_DIR/instance/orchestration/missions"
REGISTRY="$MISSIONS_DIR/registry.yml"
TEMPLATE_YML="$MISSIONS_DIR/_scaffold/template/mission.yml"
TEMPLATE_MD="$MISSIONS_DIR/_scaffold/template/mission.md"
MISSION_POLICY="$OCTON_DIR/instance/governance/policies/mission-autonomy.yml"
OWNERSHIP_REGISTRY="$OCTON_DIR/instance/governance/ownership/registry.yml"

errors=0

fail() { echo "[ERROR] $1"; errors=$((errors + 1)); }
pass() { echo "[OK] $1"; }

main() {
  echo "== Mission Authority Validation =="

  [[ -f "$REGISTRY" ]] || fail "missing ${REGISTRY#$ROOT_DIR/}"
  [[ -f "$TEMPLATE_YML" ]] || fail "missing ${TEMPLATE_YML#$ROOT_DIR/}"
  [[ -f "$TEMPLATE_MD" ]] || fail "missing ${TEMPLATE_MD#$ROOT_DIR/}"
  [[ -f "$MISSION_POLICY" ]] || fail "missing ${MISSION_POLICY#$ROOT_DIR/}"
  [[ -f "$OWNERSHIP_REGISTRY" ]] || fail "missing ${OWNERSHIP_REGISTRY#$ROOT_DIR/}"

  if yq -e '.schema_version == "octon-mission-registry-v2"' "$REGISTRY" >/dev/null; then
    pass "mission registry uses octon-mission-registry-v2"
  else
    fail "mission registry must use octon-mission-registry-v2"
  fi

  if yq -e '.schema_version == "octon-mission-v2"' "$TEMPLATE_YML" >/dev/null; then
    pass "mission scaffold uses octon-mission-v2"
  else
    fail "mission scaffold must use octon-mission-v2"
  fi

  for field in mission_class owner_ref risk_ceiling allowed_action_classes default_safing_subset default_schedule_hint default_overlap_policy scope_ids success_criteria failure_conditions; do
    if yq -e ".$field" "$TEMPLATE_YML" >/dev/null 2>&1; then
      pass "mission template defines $field"
    else
      fail "mission template missing $field"
    fi
  done

  if yq -e '.schema_version == "mission-autonomy-policy-v1"' "$MISSION_POLICY" >/dev/null; then
    pass "mission autonomy policy schema version is correct"
  else
    fail "mission autonomy policy schema version must be mission-autonomy-policy-v1"
  fi

  if yq -e '.proposal_classification_defaults.by_mission_class.maintenance.classification_id == "maintenance-operational-known-pattern"' "$MISSION_POLICY" >/dev/null; then
    pass "mission autonomy policy exposes proposal-classification defaults"
  else
    fail "mission autonomy policy must expose proposal-classification defaults"
  fi

  if yq -e '.schema_version == "ownership-registry-v1"' "$OWNERSHIP_REGISTRY" >/dev/null; then
    pass "ownership registry schema version is correct"
  else
    fail "ownership registry schema version must be ownership-registry-v1"
  fi

  while IFS= read -r mission_id; do
    [[ -n "$mission_id" ]] || continue
    local mission_file="$MISSIONS_DIR/$mission_id/mission.yml"
    local control_dir="$OCTON_DIR/state/control/execution/missions/$mission_id"
    local continuity_dir="$OCTON_DIR/state/continuity/repo/missions/$mission_id"
    [[ -f "$mission_file" ]] || fail "active mission missing charter: ${mission_file#$ROOT_DIR/}"
    [[ -d "$control_dir" ]] || fail "active mission missing control dir: ${control_dir#$ROOT_DIR/}"
    [[ -d "$continuity_dir" ]] || fail "active mission missing continuity dir: ${continuity_dir#$ROOT_DIR/}"
    [[ -f "$control_dir/mission-classification.yml" ]] || fail "active mission missing classification control: ${control_dir#$ROOT_DIR/}/mission-classification.yml"
  done < <(yq -r '.active[]?' "$REGISTRY" 2>/dev/null || true)

  echo "Validation summary: errors=$errors"
  [[ $errors -eq 0 ]]
}

main "$@"

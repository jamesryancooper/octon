#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
ROOT_DIR="${OCTON_ROOT_DIR:-$(cd -- "$OCTON_DIR/.." && pwd)}"
REGISTRY="$OCTON_DIR/instance/orchestration/missions/registry.yml"

errors=0
fail() { echo "[ERROR] $1"; errors=$((errors + 1)); }
pass() { echo "[OK] $1"; }

normalize_slice_ref() {
  local mission_id="$1"
  local raw="$2"
  if [[ -z "$raw" ]]; then
    printf ''
  elif [[ "$raw" == .octon/* || "$raw" == */*.yml ]]; then
    printf '%s' "$raw"
  else
    printf '.octon/state/control/execution/missions/%s/action-slices/%s.yml' "$mission_id" "$raw"
  fi
}

main() {
  echo "== Mission Intent Invariants Validation =="

  while IFS= read -r mission_id; do
    [[ -n "$mission_id" ]] || continue

    local mission_file="$OCTON_DIR/instance/orchestration/missions/$mission_id/mission.yml"
    local control_dir="$OCTON_DIR/state/control/execution/missions/$mission_id"
    local intent_file="$control_dir/intent-register.yml"
    local mode_state_file="$control_dir/mode-state.yml"
    local route_file="$OCTON_DIR/generated/effective/orchestration/missions/$mission_id/scenario-resolution.yml"
    local mission_class active_entry_count active_slice_ref current_slice_ref route_action_class

    mission_class="$(yq -r '.mission_class // ""' "$mission_file" 2>/dev/null || true)"
    active_entry_count="$(yq -r '[.entries[]? | select((.state // .status) == "active" or (.state // .status) == "queued" or (.state // .status) == "published")] | length' "$intent_file" 2>/dev/null || printf '0')"
    active_slice_ref="$(yq -r '.entries[]? | select((.state // .status) == "active" or (.state // .status) == "queued" or (.state // .status) == "published") | .action_slice_ref // .slice_ref.path // .slice_ref.id // ""' "$intent_file" 2>/dev/null | awk 'NF {print; exit}')"
    active_slice_ref="$(normalize_slice_ref "$mission_id" "$active_slice_ref")"
    current_slice_ref="$(yq -r '.current_slice_ref.path // .current_slice_ref // ""' "$mode_state_file" 2>/dev/null || true)"
    route_action_class="$(yq -r '.effective.effective_action_class // .effective.recovery_profile.action_class // ""' "$route_file" 2>/dev/null || true)"

    if [[ "$mission_class" == "observe" ]]; then
      if [[ "$active_entry_count" -eq 0 ]]; then
        if [[ "$route_action_class" == "mission.idle" ]]; then
          pass "observe mission $mission_id may remain empty-intent while idle"
        else
          fail "observe mission $mission_id must remain mission.idle when empty-intent"
        fi
      fi
      continue
    fi

    if [[ "$active_entry_count" -gt 0 ]]; then
      pass "material mission $mission_id has an active intent entry"
    else
      fail "material mission $mission_id is missing an active intent entry"
      continue
    fi

    if [[ -n "$active_slice_ref" ]]; then
      pass "material mission $mission_id links current intent to a slice"
    else
      fail "material mission $mission_id is missing an action-slice reference"
      continue
    fi

    if [[ -f "$ROOT_DIR/$active_slice_ref" ]]; then
      pass "material mission $mission_id action-slice exists"
    else
      fail "material mission $mission_id action-slice is missing: $active_slice_ref"
    fi

    if [[ "$current_slice_ref" == "$active_slice_ref" ]]; then
      pass "mode-state current_slice_ref matches active intent for $mission_id"
    else
      fail "mode-state current_slice_ref must match active intent for $mission_id"
    fi

    if [[ "$route_action_class" != "" && "$route_action_class" != "mission.idle" ]]; then
      pass "route derives a material action class for $mission_id"
    else
      fail "route must derive a material action class for $mission_id"
    fi

    if [[ "$(yq -r '.source_refs.current_action_slice // ""' "$route_file" 2>/dev/null || true)" == "$active_slice_ref" ]]; then
      pass "route cites the current action slice for $mission_id"
    else
      fail "route must cite the current action slice for $mission_id"
    fi

    if [[ -n "$(yq -r '.entries[]? | select((.state // .status) == "active" or (.state // .status) == "queued" or (.state // .status) == "published") | .intent_ref.id // .intent_id // ""' "$intent_file" 2>/dev/null | awk 'NF {print; exit}')" ]]; then
      pass "active intent carries canonical intent identity for $mission_id"
    else
      fail "active intent must carry canonical intent identity for $mission_id"
    fi
  done < <(yq -r '.active[]?' "$REGISTRY" 2>/dev/null || true)

  echo "Validation summary: errors=$errors"
  [[ $errors -eq 0 ]]
}

main "$@"

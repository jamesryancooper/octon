#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
COMMON_SCRIPT="$SCRIPT_DIR/../../../_ops/scripts/validate-surface-common.sh"
source "$COMMON_SCRIPT"

surface_common_init "${BASH_SOURCE[0]}" "missions"

if ! command -v yq >/dev/null 2>&1; then
  fail "yq is required for missions validation"
  finish_surface_validation "missions"
fi

require_file_rel "README.md"
require_file_rel "registry.yml"
require_dir_rel "_scaffold/template"
require_file_rel "_scaffold/template/mission.yml"
require_file_rel "_scaffold/template/mission.md"
require_file_rel "_scaffold/template/tasks.json"
require_file_rel "_scaffold/template/log.md"
require_dir_rel "_scaffold/template/context"

validate_mission_object() {
  local rel_dir="$1"
  local mission_file="$SURFACE_DIR/$rel_dir/mission.yml"
  local expected_id="$2"
  local is_template="$3"
  local schema_version mission_id title summary status owner_ref created_at success_count mission_class risk_ceiling

  schema_version="$(yq -r '.schema_version // ""' "$mission_file")"
  mission_id="$(yq -r '.mission_id // ""' "$mission_file")"
  title="$(yq -r '.title // ""' "$mission_file")"
  summary="$(yq -r '.summary // ""' "$mission_file")"
  status="$(yq -r '.status // ""' "$mission_file")"
  owner_ref="$(yq -r '.owner_ref // ""' "$mission_file")"
  created_at="$(yq -r '.created_at // ""' "$mission_file")"
  success_count="$(yq -r '.success_criteria | length' "$mission_file")"
  mission_class="$(yq -r '.mission_class // ""' "$mission_file")"
  risk_ceiling="$(yq -r '.risk_ceiling // ""' "$mission_file")"

  [[ "$schema_version" == "octon-mission-v2" ]] && pass "mission object '$rel_dir' schema version valid" || fail "mission object '$rel_dir' missing schema_version octon-mission-v2"

  if [[ "$is_template" == "true" ]]; then
    [[ "$mission_id" == "<mission-id>" ]] && pass "mission template mission_id placeholder present" || fail "mission template mission_id placeholder missing"
  else
    [[ "$mission_id" == "$expected_id" ]] && pass "mission '$expected_id' mission_id matches directory" || fail "mission '$expected_id' mission_id must match directory name"
  fi

  [[ -n "$title" && "$title" != "null" ]] && pass "mission object '$rel_dir' title present" || fail "mission object '$rel_dir' missing title"
  [[ "$summary" != "null" ]] && pass "mission object '$rel_dir' summary present" || fail "mission object '$rel_dir' missing summary"

  case "$status" in
    created|active|completed|cancelled|archived) pass "mission object '$rel_dir' status valid: $status" ;;
    *) fail "mission object '$rel_dir' has invalid status '$status'" ;;
  esac

  [[ -n "$owner_ref" && "$owner_ref" != "null" ]] && pass "mission object '$rel_dir' owner_ref present" || fail "mission object '$rel_dir' missing owner_ref"
  [[ -n "$mission_class" && "$mission_class" != "null" ]] && pass "mission object '$rel_dir' mission_class present" || fail "mission object '$rel_dir' missing mission_class"
  [[ -n "$risk_ceiling" && "$risk_ceiling" != "null" ]] && pass "mission object '$rel_dir' risk_ceiling present" || fail "mission object '$rel_dir' missing risk_ceiling"

  if [[ "$is_template" == "true" ]]; then
    [[ "$created_at" == "YYYY-MM-DD" ]] && pass "mission template created_at placeholder present" || fail "mission template created_at placeholder missing"
  elif [[ "$created_at" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ || "$created_at" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}T.+$ ]]; then
    pass "mission '$expected_id' created_at is date-like"
  else
    fail "mission '$expected_id' created_at must be date-like"
  fi

  [[ "$success_count" -gt 0 ]] && pass "mission object '$rel_dir' success criteria present" || fail "mission object '$rel_dir' missing success criteria"
}

check_registry_projection() {
  local rel_dir="$1"
  local expected_id="$2"
  local found_count

  found_count="$(yq -r --arg id "$expected_id" '[.active[]? | select(.id == $id)] + [.archived[]? | select(.id == $id)] | length' "$SURFACE_DIR/registry.yml")"
  if [[ "$found_count" -gt 0 ]]; then
    pass "mission '$expected_id' registry projection exists"
  else
    fail "mission '$expected_id' missing registry projection entry"
  fi
}

check_mission_unit() {
  local rel_dir="$1"
  local expected_id="$2"

  require_file_rel "$rel_dir/mission.yml"
  require_file_rel "$rel_dir/mission.md"
  require_file_rel "$rel_dir/tasks.json"
  require_file_rel "$rel_dir/log.md"
  require_dir_rel "$rel_dir/context"
  validate_mission_object "$rel_dir" "$expected_id" "false"
  check_registry_projection "$rel_dir" "$expected_id"
}

validate_mission_object "_scaffold/template" "[mission-id]" "true"

while IFS= read -r mission_dir; do
  rel_dir="${mission_dir#$SURFACE_DIR/}"
  check_mission_unit "$rel_dir" "${rel_dir##*/}"
done < <(find "$SURFACE_DIR" -mindepth 1 -maxdepth 1 -type d ! -name '_*' ! -name '.archive' | sort)

if [[ -d "$SURFACE_DIR/.archive" ]]; then
  while IFS= read -r mission_dir; do
    rel_dir="${mission_dir#$SURFACE_DIR/}"
    check_mission_unit "$rel_dir" "${rel_dir##*/}"
  done < <(find "$SURFACE_DIR/.archive" -mindepth 1 -maxdepth 1 -type d | sort)
fi

finish_surface_validation "missions"

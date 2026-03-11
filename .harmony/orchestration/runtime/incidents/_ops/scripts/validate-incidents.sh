#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
COMMON_SCRIPT="$SCRIPT_DIR/../../../_ops/scripts/validate-surface-common.sh"
source "$COMMON_SCRIPT"

surface_common_init "${BASH_SOURCE[0]}" "incidents"

if ! command -v yq >/dev/null 2>&1 || ! command -v jq >/dev/null 2>&1; then
  fail "yq and jq are required for incidents validation"
  finish_surface_validation "incidents"
fi

if ! surface_has_any_marker "README.md" "index.yml"; then
  surface_skip_not_promoted
fi

require_file_rel "README.md"
require_file_rel "index.yml"

validate_incident_unit() {
  local rel_dir="$1"
  local incident_file="$SURFACE_DIR/$rel_dir/incident.yml"
  local incident_id status severity owner created_at summary closed_at closed_by

  incident_id="$(yq -r '.incident_id // ""' "$incident_file")"
  status="$(yq -r '.status // ""' "$incident_file")"
  severity="$(yq -r '.severity // ""' "$incident_file")"
  owner="$(yq -r '.owner // ""' "$incident_file")"
  created_at="$(yq -r '.created_at // ""' "$incident_file")"
  summary="$(yq -r '.summary // ""' "$incident_file")"
  closed_at="$(yq -r '.closed_at // ""' "$incident_file")"
  closed_by="$(yq -r '.closed_by // ""' "$incident_file")"

  [[ "$incident_id" == "${rel_dir##*/}" ]] && pass "incident '$rel_dir' id matches directory" || fail "incident '$rel_dir' id must match directory"
  case "$severity" in
    sev0|sev1|sev2|sev3) pass "incident '$incident_id' severity valid: $severity" ;;
    *) fail "incident '$incident_id' invalid severity '$severity'" ;;
  esac
  case "$status" in
    open|acknowledged|mitigating|monitoring|resolved|closed|cancelled) pass "incident '$incident_id' status valid: $status" ;;
    *) fail "incident '$incident_id' invalid status '$status'" ;;
  esac
  [[ -n "$owner" ]] && pass "incident '$incident_id' owner present" || fail "incident '$incident_id' missing owner"
  [[ "$created_at" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}T.+$ ]] && pass "incident '$incident_id' created_at is ISO-like" || fail "incident '$incident_id' invalid created_at"
  [[ -n "$summary" ]] && pass "incident '$incident_id' summary present" || fail "incident '$incident_id' missing summary"

  require_file_rel "$rel_dir/timeline.md"
  if [[ -f "$SURFACE_DIR/$rel_dir/actions.yml" ]]; then
    require_file_rel "$rel_dir/actions.yml"
  fi

  if [[ "$status" == "closed" ]]; then
    require_file_rel "$rel_dir/closure.md"
    [[ "$closed_at" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}T.+$ ]] && pass "incident '$incident_id' closed_at is ISO-like" || fail "incident '$incident_id' closed status requires closed_at"
    [[ -n "$closed_by" ]] && pass "incident '$incident_id' closed_by present" || fail "incident '$incident_id' closed status requires closed_by"
  fi
}

while IFS= read -r incident_dir; do
  rel_dir="${incident_dir#$SURFACE_DIR/}"
  require_file_rel "$rel_dir/incident.yml"
  validate_incident_unit "$rel_dir"
done < <(find "$SURFACE_DIR" -mindepth 1 -maxdepth 1 -type d ! -name '_*' | sort)

finish_surface_validation "incidents"

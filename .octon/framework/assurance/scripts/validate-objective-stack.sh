#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/_validator_common.sh"
release_id="$(resolve_validator_release_id "${1:-}")"
for file in "$OCTON_DIR"/state/control/execution/runs/*/run-contract.yml; do
  schema_version="$(yq -r '.schema_version // ""' "$file")"
  [[ "$schema_version" == "run-contract-v3" ]] || continue
  requires_mission="$(yq -r '.requires_mission' "$file")"
  mission_mode="$(yq -r '.mission_mode' "$file")"
  mission_id="$(yq -r '.mission_id // "null"' "$file")"
  [[ "$requires_mission" == "true" || "$requires_mission" == "false" ]]
  [[ "$mission_mode" != "none" ]]
  if [[ "$requires_mission" == "true" ]]; then
    [[ "$mission_mode" == "mission-bound" ]]
    [[ "$mission_id" != "null" ]]
  else
    [[ "$mission_mode" == "run-only" ]]
  fi
done
write_validator_report "$release_id" "objective-stack-legality-report.yml" "V-OBJ-001" "pass" "Run contracts encode only legal workspace, mission, run, and stage relationships."

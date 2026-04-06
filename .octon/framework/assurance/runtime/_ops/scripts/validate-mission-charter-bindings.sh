#!/usr/bin/env bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/closure-packet-common.sh"
MISSION_FILE="$OCTON_DIR/instance/orchestration/missions/mission-autonomy-live-validation/mission.yml"
require_yq
yq -e '.schema_version == "octon-mission-charter-v1"' "$MISSION_FILE" >/dev/null
yq -e '.quorum_policy_ref == ".octon/instance/governance/contracts/quorum-policies/default.yml"' "$MISSION_FILE" >/dev/null
yq -e '.continuity_root_ref == ".octon/state/continuity/missions/mission-autonomy-live-validation"' "$MISSION_FILE" >/dev/null


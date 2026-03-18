#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/orchestration-runtime-common.sh"
orchestration_runtime_init "${BASH_SOURCE[0]}"
require_tools jq yq

usage() {
  cat <<'EOF'
Usage:
  load-orchestration-discovery.sh list-workflows
  load-orchestration-discovery.sh resolve-workflow --workflow-group <group> --workflow-id <id>
  load-orchestration-discovery.sh list-missions
  load-orchestration-discovery.sh resolve-mission --mission-id <id>
EOF
}

cmd="${1:-}"
shift || true

case "$cmd" in
  list-workflows)
    yq -o=json '.workflows' "$WORKFLOWS_DIR/manifest.yml"
    ;;
  resolve-workflow)
    workflow_group=""
    workflow_id=""
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --workflow-group) workflow_group="$2"; shift 2 ;;
        --workflow-id) workflow_id="$2"; shift 2 ;;
        *) echo "unknown argument: $1" >&2; exit 1 ;;
      esac
    done
    [[ -n "$workflow_group" && -n "$workflow_id" ]] || { usage; exit 1; }
    workflow_path="$(yq -o=json '.workflows' "$WORKFLOWS_DIR/manifest.yml" | jq -r --arg id "$workflow_id" '.[] | select(.id == $id) | .path' | head -n1)"
    [[ -n "$workflow_path" && "$workflow_path" != "null" ]] || { echo "workflow not found: $workflow_id" >&2; exit 1; }
    [[ "$workflow_path" == "$workflow_group/"* ]] || { echo "workflow group mismatch for $workflow_id" >&2; exit 1; }
    workflow_file="$WORKFLOWS_DIR/$workflow_path/workflow.yml"
    [[ -f "$workflow_file" ]] || { echo "workflow file missing: $workflow_file" >&2; exit 1; }
    yq -o=json '.' "$workflow_file" | jq --arg workflow_group "$workflow_group" '. + {workflow_ref:{workflow_group:$workflow_group,workflow_id:.name}}'
    ;;
  list-missions)
    yq -o=json '.' "$MISSIONS_DIR/registry.yml"
    ;;
  resolve-mission)
    mission_id=""
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --mission-id) mission_id="$2"; shift 2 ;;
        *) echo "unknown argument: $1" >&2; exit 1 ;;
      esac
    done
    [[ -n "$mission_id" ]] || { usage; exit 1; }
    mission_file=""
    if [[ -f "$MISSIONS_DIR/$mission_id/mission.yml" ]]; then
      mission_file="$MISSIONS_DIR/$mission_id/mission.yml"
    elif [[ -f "$MISSIONS_DIR/.archive/$mission_id/mission.yml" ]]; then
      mission_file="$MISSIONS_DIR/.archive/$mission_id/mission.yml"
    fi
    [[ -n "$mission_file" ]] || { echo "mission not found: $mission_id" >&2; exit 1; }
    yq -o=json '.' "$mission_file"
    ;;
  *)
    usage
    exit 1
    ;;
esac

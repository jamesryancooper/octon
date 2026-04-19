#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
MATERIALIZE_SCRIPT="$SCRIPT_DIR/materialize-authority-approval.sh"

REQUEST_ID=""
RUN_ID=""
TARGET_ID=""
ACTION_TYPE=""
ISSUED_BY=""
STATUS=""
SUPPORT_TIER="repo-consequential"
WORKFLOW_MODE="role-mediated"
OUTPUT_JSON=""
declare -a OWNERSHIP_REFS=()
declare -a REQUIRED_EVIDENCE=()
declare -a REASON_CODES=()
declare -a PROJECTION_KINDS=()
declare -a PROJECTION_REFS=()

usage() {
  cat <<'USAGE'
Usage:
  project-github-control-approval.sh \
    --request-id <id> \
    --run-id <id> \
    --target-id <id> \
    --action-type <type> \
    --issued-by <ref> \
    --status <granted|staged|pending|denied> \
    [--support-tier <tier>] \
    [--workflow-mode <mode>] \
    [--ownership-ref <ref>] \
    [--required-evidence <token>] \
    [--reason-code <code>] \
    [--projection-kind <kind> --projection-ref <ref>] \
    [--projection-label <ref>] \
    [--projection-check <ref>] \
    [--projection-comment <ref>] \
    [--output-json <path>]
USAGE
}

main() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --request-id) REQUEST_ID="$2"; shift 2 ;;
      --run-id) RUN_ID="$2"; shift 2 ;;
      --target-id) TARGET_ID="$2"; shift 2 ;;
      --action-type) ACTION_TYPE="$2"; shift 2 ;;
      --issued-by) ISSUED_BY="$2"; shift 2 ;;
      --status) STATUS="$2"; shift 2 ;;
      --support-tier) SUPPORT_TIER="$2"; shift 2 ;;
      --workflow-mode) WORKFLOW_MODE="$2"; shift 2 ;;
      --ownership-ref) OWNERSHIP_REFS+=("$2"); shift 2 ;;
      --required-evidence) REQUIRED_EVIDENCE+=("$2"); shift 2 ;;
      --reason-code) REASON_CODES+=("$2"); shift 2 ;;
      --projection-kind) PROJECTION_KINDS+=("$2"); shift 2 ;;
      --projection-ref) PROJECTION_REFS+=("$2"); shift 2 ;;
      --projection-label) PROJECTION_KINDS+=("github-label"); PROJECTION_REFS+=("$2"); shift 2 ;;
      --projection-check) PROJECTION_KINDS+=("github-check"); PROJECTION_REFS+=("$2"); shift 2 ;;
      --projection-comment) PROJECTION_KINDS+=("github-comment"); PROJECTION_REFS+=("$2"); shift 2 ;;
      --output-json) OUTPUT_JSON="$2"; shift 2 ;;
      -h|--help) usage; exit 0 ;;
      *) echo "Unknown option: $1" >&2; usage >&2; exit 1 ;;
    esac
  done

  [[ -n "$REQUEST_ID" ]] || { echo "--request-id is required" >&2; exit 1; }
  [[ -n "$RUN_ID" ]] || { echo "--run-id is required" >&2; exit 1; }
  [[ -n "$TARGET_ID" ]] || { echo "--target-id is required" >&2; exit 1; }
  [[ -n "$ACTION_TYPE" ]] || { echo "--action-type is required" >&2; exit 1; }
  [[ -n "$ISSUED_BY" ]] || { echo "--issued-by is required" >&2; exit 1; }
  [[ -n "$STATUS" ]] || { echo "--status is required" >&2; exit 1; }

  if [[ "${#PROJECTION_KINDS[@]}" -ne "${#PROJECTION_REFS[@]}" ]]; then
    echo "projection kinds and refs must be provided in pairs" >&2
    exit 1
  fi

  local request_state grant_state reason default_reason json_output
  case "$STATUS" in
    granted)
      request_state="granted"
      grant_state="active"
      default_reason="Canonical GitHub control projection granted."
      ;;
    staged)
      request_state="staged"
      grant_state=""
      default_reason="Canonical GitHub control projection staged pending further authority."
      ;;
    pending)
      request_state="pending"
      grant_state=""
      default_reason="Canonical GitHub control projection pending."
      ;;
    denied)
      request_state="denied"
      grant_state=""
      default_reason="Canonical GitHub control projection denied."
      ;;
    *)
      echo "invalid --status: $STATUS" >&2
      exit 1
      ;;
  esac

  local args=(
    --request-id "$REQUEST_ID"
    --run-id "$RUN_ID"
    --target-id "$TARGET_ID"
    --action-type "$ACTION_TYPE"
    --issued-by "$ISSUED_BY"
    --workflow-mode "$WORKFLOW_MODE"
    --support-tier "$SUPPORT_TIER"
    --request-state "$request_state"
    --reason "$default_reason"
  )

  if [[ -n "$grant_state" ]]; then
    args+=(--grant-state "$grant_state")
  fi

  local ref
  for ref in "${OWNERSHIP_REFS[@]}"; do
    args+=(--ownership-ref "$ref")
  done
  for ref in "${REQUIRED_EVIDENCE[@]}"; do
    args+=(--required-evidence "$ref")
  done
  for ref in "${REASON_CODES[@]}"; do
    args+=(--reason-code "$ref")
  done
  local idx
  for idx in "${!PROJECTION_KINDS[@]}"; do
    args+=(--projection-kind "${PROJECTION_KINDS[$idx]}")
    args+=(--projection-ref "${PROJECTION_REFS[$idx]}")
  done

  json_output="$(bash "$MATERIALIZE_SCRIPT" "${args[@]}")"
  if [[ -n "$OUTPUT_JSON" ]]; then
    mkdir -p "$(dirname "$OUTPUT_JSON")"
    printf '%s\n' "$json_output" > "$OUTPUT_JSON"
  else
    printf '%s\n' "$json_output"
  fi
}

main "$@"

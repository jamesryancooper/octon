#!/usr/bin/env bash
set -euo pipefail

POLICY_FILE=""
CONTROL_FILE=""

usage() {
  cat <<'USAGE'
Usage:
  evaluate-review-dispositions.sh --policy <path> --control <path>
USAGE
}

main() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --policy) POLICY_FILE="$2"; shift 2 ;;
      --control) CONTROL_FILE="$2"; shift 2 ;;
      -h|--help) usage; exit 0 ;;
      *) echo "Unknown option: $1" >&2; usage >&2; exit 1 ;;
    esac
  done

  [[ -n "$POLICY_FILE" && -n "$CONTROL_FILE" ]] || {
    echo "missing required arguments" >&2
    exit 1
  }
  [[ -f "$POLICY_FILE" && -f "$CONTROL_FILE" ]] || {
    echo "policy or control file missing" >&2
    exit 1
  }

  local unresolved_blocking non_progressing deferred_missing_follow_up gate_status exit_code
  local disposition
  unresolved_blocking="$(yq -r '[.entries[]? | select(.blocking == true and .disposition != "accepted")] | length' "$CONTROL_FILE")"
  non_progressing=0
  while IFS= read -r disposition; do
    [[ -n "$disposition" ]] || continue
    if [[ "$(yq -o=json '.dispositions' "$POLICY_FILE" | jq -r --arg disposition "$disposition" 'if .[$disposition].allows_progression == null then true else .[$disposition].allows_progression end')" == "false" ]]; then
      non_progressing=$((non_progressing + 1))
    fi
  done < <(yq -r '.entries[]?.disposition // ""' "$CONTROL_FILE")
  deferred_missing_follow_up="$(yq -r '[.entries[]? | select((.disposition == "deferred" or .disposition == "backlog") and ((.follow_up_ref // "") == "" or (.follow_up_ref // "") == "null"))] | length' "$CONTROL_FILE")"

  gate_status="pass"
  exit_code=0

  if [[ "$(yq -r '.fail_closed.unresolved_blocking_entry // true' "$POLICY_FILE")" == "true" && "$unresolved_blocking" -gt 0 ]]; then
    gate_status="blocked"
    exit_code=1
  fi

  if [[ "$non_progressing" -gt 0 ]]; then
    gate_status="blocked"
    exit_code=1
  fi

  if [[ "$(yq -r '.fail_closed.deferred_without_follow_up // true' "$POLICY_FILE")" == "true" && "$deferred_missing_follow_up" -gt 0 ]]; then
    gate_status="blocked"
    exit_code=1
  fi

  jq -n \
    --arg gate_status "$gate_status" \
    --argjson unresolved_blocking "$unresolved_blocking" \
    --argjson non_progressing "$non_progressing" \
    --argjson deferred_missing_follow_up "$deferred_missing_follow_up" \
    '{
      gate_status: $gate_status,
      unresolved_blocking: $unresolved_blocking,
      non_progressing: $non_progressing,
      deferred_missing_follow_up: $deferred_missing_follow_up
    }'

  exit "$exit_code"
}

main "$@"

#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
AGENCY_DIR="$(cd -- "$SCRIPT_DIR/../.." && pwd)"
FRAMEWORK_DIR="$(cd -- "$AGENCY_DIR/../.." && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$(cd -- "$FRAMEWORK_DIR/.." && pwd)}"
APPROVAL_WRITER="$FRAMEWORK_DIR/engine/_ops/scripts/materialize-authority-approval.sh"

PR_NUMBER=""
LABELS_JSON='[]'
REQUEST_SCOPE=""
SUPPORT_TIER="repo-local-transitional"
ISSUED_BY=""
declare -a REQUIRED_LABELS=()
declare -a EXTRA_PROJECTION_REFS=()
OUTPUT_PATH=""

usage() {
  cat <<'USAGE'
Usage:
  materialize-pr-authority.sh \
    --pr-number <n> \
    --labels-json '<json-array>' \
    --request-scope <scope> \
    --issued-by <ref> \
    [--support-tier <tier>] \
    [--required-label <label>] ... \
    [--projection-ref <ref>] ... \
    [--output <path>]
USAGE
}

main() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --pr-number) PR_NUMBER="$2"; shift 2 ;;
      --labels-json) LABELS_JSON="$2"; shift 2 ;;
      --request-scope) REQUEST_SCOPE="$2"; shift 2 ;;
      --support-tier) SUPPORT_TIER="$2"; shift 2 ;;
      --issued-by) ISSUED_BY="$2"; shift 2 ;;
      --required-label) REQUIRED_LABELS+=("$2"); shift 2 ;;
      --projection-ref) EXTRA_PROJECTION_REFS+=("$2"); shift 2 ;;
      --output) OUTPUT_PATH="$2"; shift 2 ;;
      -h|--help) usage; exit 0 ;;
      *) echo "Unknown option: $1" >&2; usage >&2; exit 1 ;;
    esac
  done

  [[ -n "$PR_NUMBER" ]] || { echo "--pr-number is required" >&2; exit 1; }
  [[ -n "$REQUEST_SCOPE" ]] || { echo "--request-scope is required" >&2; exit 1; }
  [[ -n "$ISSUED_BY" ]] || { echo "--issued-by is required" >&2; exit 1; }
  jq -e 'type == "array"' <<<"$LABELS_JSON" >/dev/null 2>&1 || { echo "--labels-json must be a JSON array" >&2; exit 1; }

  local granted=true
  local label
  for label in "${REQUIRED_LABELS[@]}"; do
    if ! jq -e --arg label "$label" 'index($label) != null' <<<"$LABELS_JSON" >/dev/null 2>&1; then
      granted=false
      break
    fi
  done

  local request_id="github-pr-${PR_NUMBER}-${REQUEST_SCOPE}"
  local args=(
    --request-id "$request_id"
    --run-id "$request_id"
    --target-id "github-pr:${PR_NUMBER}"
    --action-type "$REQUEST_SCOPE"
    --workflow-mode "human-only"
    --support-tier "$SUPPORT_TIER"
    --request-state "$( [[ "$granted" == "true" ]] && printf 'granted' || printf 'pending' )"
    --issued-by "$ISSUED_BY"
    --ownership-ref "operator://octon-maintainers"
    --required-evidence "approval-grant"
    --reason-code "HOST_APPROVAL_PROJECTION"
  )

  for label in "${REQUIRED_LABELS[@]}"; do
    args+=(--projection-kind "github-label" --projection-ref "github://pull/${PR_NUMBER}/label/${label}")
  done
  for ref in "${EXTRA_PROJECTION_REFS[@]}"; do
    args+=(--projection-kind "github-check" --projection-ref "$ref")
  done
  if [[ "$granted" == "true" ]]; then
    args+=(--grant-state active)
  fi

  local json
  json="$(bash "$APPROVAL_WRITER" "${args[@]}")"
  json="$(jq --argjson granted "$granted" '.approval_granted = $granted' <<<"$json")"
  if [[ -n "$OUTPUT_PATH" ]]; then
    printf '%s\n' "$json" > "$OUTPUT_PATH"
  else
    printf '%s\n' "$json"
  fi
}

main "$@"

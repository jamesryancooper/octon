#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ENGINE_DIR="$(cd -- "$SCRIPT_DIR/../.." && pwd)"
FRAMEWORK_DIR="$(cd -- "$ENGINE_DIR/.." && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$(cd -- "$FRAMEWORK_DIR/.." && pwd)}"
ROOT_DIR="${OCTON_ROOT_DIR:-$(cd -- "$OCTON_DIR/.." && pwd)}"
RECEIPT_WRITER="$SCRIPT_DIR/write-authority-control-receipt.sh"

REQUEST_ID=""
RUN_ID=""
TARGET_ID=""
ACTION_TYPE=""
WORKFLOW_MODE="human-only"
SUPPORT_TIER="repo-local-transitional"
REQUEST_STATE="pending"
GRANT_STATE=""
ISSUED_BY=""
REASON=""
declare -a OWNERSHIP_REFS=()
declare -a REQUIRED_EVIDENCE=()
declare -a REASON_CODES=()
declare -a PROJECTION_KINDS=()
declare -a PROJECTION_REFS=()

usage() {
  cat <<'USAGE'
Usage:
  materialize-authority-approval.sh \
    --request-id <id> \
    --run-id <id> \
    --target-id <id> \
    --action-type <type> \
    --issued-by <ref> \
    [--workflow-mode <mode>] \
    [--support-tier <tier>] \
    [--request-state pending|granted|staged|denied|expired] \
    [--grant-state active|revoked|expired] \
    [--ownership-ref <ref>] \
    [--required-evidence <token>] \
    [--reason-code <code>] \
    [--reason <text>] \
    [--projection-kind <kind> --projection-ref <ref>] ...
USAGE
}

yaml_quote() {
  local value="$1"
  value="${value//\\/\\\\}"
  value="${value//\"/\\\"}"
  printf '"%s"' "$value"
}

ensure_projection_pairs() {
  if [[ "${#PROJECTION_KINDS[@]}" -ne "${#PROJECTION_REFS[@]}" ]]; then
    echo "projection kinds and refs must be provided in pairs" >&2
    exit 1
  fi
}

write_projection_sources() {
  if [[ "${#PROJECTION_KINDS[@]}" -eq 0 ]]; then
    printf '  []\n'
    return
  fi
  local idx
  for idx in "${!PROJECTION_KINDS[@]}"; do
    printf '  - kind: %s\n' "$(yaml_quote "${PROJECTION_KINDS[$idx]}")"
    printf '    ref: %s\n' "$(yaml_quote "${PROJECTION_REFS[$idx]}")"
  done
}

main() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --request-id) REQUEST_ID="$2"; shift 2 ;;
      --run-id) RUN_ID="$2"; shift 2 ;;
      --target-id) TARGET_ID="$2"; shift 2 ;;
      --action-type) ACTION_TYPE="$2"; shift 2 ;;
      --workflow-mode) WORKFLOW_MODE="$2"; shift 2 ;;
      --support-tier) SUPPORT_TIER="$2"; shift 2 ;;
      --request-state) REQUEST_STATE="$2"; shift 2 ;;
      --grant-state) GRANT_STATE="$2"; shift 2 ;;
      --issued-by) ISSUED_BY="$2"; shift 2 ;;
      --ownership-ref) OWNERSHIP_REFS+=("$2"); shift 2 ;;
      --required-evidence) REQUIRED_EVIDENCE+=("$2"); shift 2 ;;
      --reason-code) REASON_CODES+=("$2"); shift 2 ;;
      --reason) REASON="$2"; shift 2 ;;
      --projection-kind) PROJECTION_KINDS+=("$2"); shift 2 ;;
      --projection-ref) PROJECTION_REFS+=("$2"); shift 2 ;;
      -h|--help) usage; exit 0 ;;
      *) echo "Unknown option: $1" >&2; usage >&2; exit 1 ;;
    esac
  done

  [[ -n "$REQUEST_ID" ]] || { echo "--request-id is required" >&2; exit 1; }
  [[ -n "$RUN_ID" ]] || { echo "--run-id is required" >&2; exit 1; }
  [[ -n "$TARGET_ID" ]] || { echo "--target-id is required" >&2; exit 1; }
  [[ -n "$ACTION_TYPE" ]] || { echo "--action-type is required" >&2; exit 1; }
  [[ -n "$ISSUED_BY" ]] || { echo "--issued-by is required" >&2; exit 1; }
  ensure_projection_pairs

  local approvals_root="$OCTON_DIR/state/control/execution/approvals"
  local request_path="$approvals_root/requests/${REQUEST_ID}.yml"
  local grant_path="$approvals_root/grants/grant-${REQUEST_ID}.yml"
  local now
  now="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

  mkdir -p "$approvals_root/requests" "$approvals_root/grants"

  {
    printf 'schema_version: "authority-approval-request-v1"\n'
    printf 'request_id: %s\n' "$(yaml_quote "$REQUEST_ID")"
    printf 'run_id: %s\n' "$(yaml_quote "$RUN_ID")"
    printf 'status: %s\n' "$(yaml_quote "$REQUEST_STATE")"
    printf 'target_id: %s\n' "$(yaml_quote "$TARGET_ID")"
    printf 'action_type: %s\n' "$(yaml_quote "$ACTION_TYPE")"
    printf 'workflow_mode: %s\n' "$(yaml_quote "$WORKFLOW_MODE")"
    printf 'support_tier: %s\n' "$(yaml_quote "$SUPPORT_TIER")"
    printf 'ownership_refs:\n'
    if [[ "${#OWNERSHIP_REFS[@]}" -eq 0 ]]; then
      printf '  []\n'
    else
      for ref in "${OWNERSHIP_REFS[@]}"; do
        printf '  - %s\n' "$(yaml_quote "$ref")"
      done
    fi
    printf 'reversibility_class: null\n'
    printf 'reason_codes:\n'
    if [[ "${#REASON_CODES[@]}" -eq 0 ]]; then
      printf '  []\n'
    else
      for code in "${REASON_CODES[@]}"; do
        printf '  - %s\n' "$(yaml_quote "$code")"
      done
    fi
    printf 'required_evidence:\n'
    if [[ "${#REQUIRED_EVIDENCE[@]}" -eq 0 ]]; then
      printf '  []\n'
    else
      for item in "${REQUIRED_EVIDENCE[@]}"; do
        printf '  - %s\n' "$(yaml_quote "$item")"
      done
    fi
    printf 'projection_sources:\n'
    write_projection_sources
    printf 'created_at: %s\n' "$(yaml_quote "$now")"
    printf 'updated_at: %s\n' "$(yaml_quote "$now")"
  } > "$request_path"

  local request_ref=".octon/state/control/execution/approvals/requests/${REQUEST_ID}.yml"
  local receipt_args=()
  local code
  for code in "${REASON_CODES[@]}"; do
    receipt_args+=(--reason-code "$code")
  done
  local projection_ref
  for projection_ref in "${PROJECTION_REFS[@]}"; do
    receipt_args+=(--projection-ref "$projection_ref")
  done
  bash "$RECEIPT_WRITER" \
    --receipt-type "approval_request_materialized" \
    --issued-by "$ISSUED_BY" \
    --source-ref "$request_ref" \
    --applied-to-ref "$request_ref" \
    --affected-path "$request_ref" \
    --reason "${REASON:-Materialize canonical approval request}" \
    "${receipt_args[@]}" \
    --approval-request-ref "$request_ref" \
    --linked-run-id "$RUN_ID" \
    >/dev/null

  local grant_ref=""
  if [[ -n "$GRANT_STATE" ]]; then
    {
      printf 'schema_version: "authority-approval-grant-v1"\n'
      printf 'grant_id: %s\n' "$(yaml_quote "grant-${REQUEST_ID}")"
      printf 'request_id: %s\n' "$(yaml_quote "$REQUEST_ID")"
      printf 'run_id: %s\n' "$(yaml_quote "$RUN_ID")"
      printf 'state: %s\n' "$(yaml_quote "$GRANT_STATE")"
      printf 'issued_by: %s\n' "$(yaml_quote "$ISSUED_BY")"
      printf 'issued_at: %s\n' "$(yaml_quote "$now")"
      printf 'expires_at: null\n'
      printf 'projection_sources:\n'
      write_projection_sources
      printf 'review_metadata: {}\n'
      printf 'required_evidence:\n'
      if [[ "${#REQUIRED_EVIDENCE[@]}" -eq 0 ]]; then
        printf '  []\n'
      else
        for item in "${REQUIRED_EVIDENCE[@]}"; do
          printf '  - %s\n' "$(yaml_quote "$item")"
        done
      fi
    } > "$grant_path"
    grant_ref=".octon/state/control/execution/approvals/grants/grant-${REQUEST_ID}.yml"
    bash "$RECEIPT_WRITER" \
      --receipt-type "approval_grant_materialized" \
      --issued-by "$ISSUED_BY" \
      --source-ref "$grant_ref" \
      --applied-to-ref "$grant_ref" \
      --affected-path "$grant_ref" \
      --reason "${REASON:-Materialize canonical approval grant}" \
      "${receipt_args[@]}" \
      --approval-request-ref "$request_ref" \
      --approval-grant-ref "$grant_ref" \
      --linked-run-id "$RUN_ID" \
      >/dev/null
  fi

  jq -n \
    --arg request_ref "$request_ref" \
    --arg grant_ref "$grant_ref" \
    --argjson granted "$( [[ -n "$GRANT_STATE" && "$GRANT_STATE" == "active" ]] && printf 'true' || printf 'false' )" \
    '{approval_request_ref:$request_ref, approval_grant_ref:($grant_ref | select(length > 0)), approval_granted:$granted}'
}

main "$@"

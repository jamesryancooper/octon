#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ENGINE_DIR="$(cd -- "$SCRIPT_DIR/../.." && pwd)"
FRAMEWORK_DIR="$(cd -- "$ENGINE_DIR/.." && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$(cd -- "$FRAMEWORK_DIR/.." && pwd)}"
ROOT_DIR="${OCTON_ROOT_DIR:-$(cd -- "$OCTON_DIR/.." && pwd)}"
OUTPUT_ROOT="${OUTPUT_ROOT_OVERRIDE:-$OCTON_DIR/state/evidence/control/execution}"

RECEIPT_TYPE=""
ISSUED_BY=""
SOURCE_REF=""
APPLIED_TO_REF=""
RESULT="applied"
REASON=""
declare -a AFFECTED_PATHS=()
declare -a REASON_CODES=()
declare -a POLICY_REFS=()
declare -a PROJECTION_REFS=()
APPROVAL_REQUEST_REF=""
APPROVAL_GRANT_REF=""
EXCEPTION_LEASE_REF=""
REVOCATION_REF=""
LINKED_RUN_ID=""

usage() {
  cat <<'USAGE'
Usage:
  write-authority-control-receipt.sh \
    --receipt-type <type> \
    --issued-by <ref> \
    --source-ref <path> \
    --applied-to-ref <path> \
    --affected-path <path> [--affected-path <path> ...] \
    [--result applied|rejected|cleared|expired] \
    [--reason <text>] \
    [--reason-code <code>] \
    [--policy-ref <path>] \
    [--projection-ref <ref>] \
    [--approval-request-ref <path>] \
    [--approval-grant-ref <path>] \
    [--exception-lease-ref <path>] \
    [--revocation-ref <path>] \
    [--linked-run-id <run-id>]
USAGE
}

yaml_quote() {
  local value="$1"
  value="${value//\\/\\\\}"
  value="${value//\"/\\\"}"
  printf '"%s"' "$value"
}

main() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --receipt-type) RECEIPT_TYPE="$2"; shift 2 ;;
      --issued-by) ISSUED_BY="$2"; shift 2 ;;
      --source-ref) SOURCE_REF="$2"; shift 2 ;;
      --applied-to-ref) APPLIED_TO_REF="$2"; shift 2 ;;
      --affected-path) AFFECTED_PATHS+=("$2"); shift 2 ;;
      --result) RESULT="$2"; shift 2 ;;
      --reason) REASON="$2"; shift 2 ;;
      --reason-code) REASON_CODES+=("$2"); shift 2 ;;
      --policy-ref) POLICY_REFS+=("$2"); shift 2 ;;
      --projection-ref) PROJECTION_REFS+=("$2"); shift 2 ;;
      --approval-request-ref) APPROVAL_REQUEST_REF="$2"; shift 2 ;;
      --approval-grant-ref) APPROVAL_GRANT_REF="$2"; shift 2 ;;
      --exception-lease-ref) EXCEPTION_LEASE_REF="$2"; shift 2 ;;
      --revocation-ref) REVOCATION_REF="$2"; shift 2 ;;
      --linked-run-id) LINKED_RUN_ID="$2"; shift 2 ;;
      -h|--help) usage; exit 0 ;;
      *) echo "Unknown option: $1" >&2; usage >&2; exit 1 ;;
    esac
  done

  [[ -n "$RECEIPT_TYPE" ]] || { echo "--receipt-type is required" >&2; exit 1; }
  [[ -n "$ISSUED_BY" ]] || { echo "--issued-by is required" >&2; exit 1; }
  [[ -n "$SOURCE_REF" ]] || { echo "--source-ref is required" >&2; exit 1; }
  [[ -n "$APPLIED_TO_REF" ]] || { echo "--applied-to-ref is required" >&2; exit 1; }
  [[ "${#AFFECTED_PATHS[@]}" -gt 0 ]] || { echo "at least one --affected-path is required" >&2; exit 1; }

  mkdir -p "$OUTPUT_ROOT"

  local ts ts_slug slug receipt_id file
  ts="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  ts_slug="$(date -u +"%Y%m%dT%H%M%SZ")"
  slug="$(printf '%s' "$RECEIPT_TYPE" | tr '[:upper:]' '[:lower:]' | tr -cs 'a-z0-9' '-')"
  receipt_id="${ts_slug}-${slug}"
  file="$OUTPUT_ROOT/${receipt_id}.yml"

  {
    printf 'schema_version: "authority-control-receipt-v1"\n'
    printf 'receipt_id: %s\n' "$(yaml_quote "$receipt_id")"
    printf 'control_mutation_class: %s\n' "$(yaml_quote "$RECEIPT_TYPE")"
    printf 'source_ref: %s\n' "$(yaml_quote "$SOURCE_REF")"
    printf 'applied_to_ref: %s\n' "$(yaml_quote "$APPLIED_TO_REF")"
    printf 'issuer_ref: %s\n' "$(yaml_quote "$ISSUED_BY")"
    printf 'timestamp: %s\n' "$(yaml_quote "$ts")"
    printf 'result: %s\n' "$(yaml_quote "$RESULT")"
    if [[ -n "$REASON" ]]; then
      printf 'reason: %s\n' "$(yaml_quote "$REASON")"
    else
      printf 'reason: null\n'
    fi
    printf 'reason_codes:\n'
    if [[ "${#REASON_CODES[@]}" -eq 0 ]]; then
      printf '  - %s\n' "$(yaml_quote "$RECEIPT_TYPE")"
    else
      for code in "${REASON_CODES[@]}"; do
        printf '  - %s\n' "$(yaml_quote "$code")"
      done
    fi
    printf 'affected_paths:\n'
    for path in "${AFFECTED_PATHS[@]}"; do
      printf '  - %s\n' "$(yaml_quote "$path")"
    done
    printf 'policy_refs:\n'
    if [[ "${#POLICY_REFS[@]}" -eq 0 ]]; then
      printf '  []\n'
    else
      for ref in "${POLICY_REFS[@]}"; do
        printf '  - %s\n' "$(yaml_quote "$ref")"
      done
    fi
    printf 'projection_refs:\n'
    if [[ "${#PROJECTION_REFS[@]}" -eq 0 ]]; then
      printf '  []\n'
    else
      for ref in "${PROJECTION_REFS[@]}"; do
        printf '  - %s\n' "$(yaml_quote "$ref")"
      done
    fi
    if [[ -n "$APPROVAL_REQUEST_REF" ]]; then
      printf 'approval_request_ref: %s\n' "$(yaml_quote "$APPROVAL_REQUEST_REF")"
    else
      printf 'approval_request_ref: null\n'
    fi
    if [[ -n "$APPROVAL_GRANT_REF" ]]; then
      printf 'approval_grant_ref: %s\n' "$(yaml_quote "$APPROVAL_GRANT_REF")"
    else
      printf 'approval_grant_ref: null\n'
    fi
    if [[ -n "$EXCEPTION_LEASE_REF" ]]; then
      printf 'exception_lease_ref: %s\n' "$(yaml_quote "$EXCEPTION_LEASE_REF")"
    else
      printf 'exception_lease_ref: null\n'
    fi
    if [[ -n "$REVOCATION_REF" ]]; then
      printf 'revocation_ref: %s\n' "$(yaml_quote "$REVOCATION_REF")"
    else
      printf 'revocation_ref: null\n'
    fi
    if [[ -n "$LINKED_RUN_ID" ]]; then
      printf 'linked_run_id: %s\n' "$(yaml_quote "$LINKED_RUN_ID")"
    else
      printf 'linked_run_id: null\n'
    fi
  } > "$file"

  printf '%s\n' "$file"
}

main "$@"

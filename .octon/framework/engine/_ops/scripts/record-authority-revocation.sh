#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ENGINE_DIR="$(cd -- "$SCRIPT_DIR/../.." && pwd)"
FRAMEWORK_DIR="$(cd -- "$ENGINE_DIR/.." && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$(cd -- "$FRAMEWORK_DIR/.." && pwd)}"
RECEIPT_WRITER="$SCRIPT_DIR/write-authority-control-receipt.sh"

REVOCATION_ID=""
GRANT_ID=""
REQUEST_ID=""
RUN_ID=""
STATE="active"
REVOKED_BY=""
NOTES=""
declare -a REASON_CODES=()

usage() {
  cat <<'USAGE'
Usage:
  record-authority-revocation.sh \
    --revocation-id <id> \
    --revoked-by <ref> \
    [--grant-id <id>] \
    [--request-id <id>] \
    [--run-id <id>] \
    [--state active|cleared] \
    [--reason-code <code>] \
    [--notes <text>]
USAGE
}

main() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --revocation-id) REVOCATION_ID="$2"; shift 2 ;;
      --grant-id) GRANT_ID="$2"; shift 2 ;;
      --request-id) REQUEST_ID="$2"; shift 2 ;;
      --run-id) RUN_ID="$2"; shift 2 ;;
      --state) STATE="$2"; shift 2 ;;
      --revoked-by) REVOKED_BY="$2"; shift 2 ;;
      --reason-code) REASON_CODES+=("$2"); shift 2 ;;
      --notes) NOTES="$2"; shift 2 ;;
      -h|--help) usage; exit 0 ;;
      *) echo "Unknown option: $1" >&2; usage >&2; exit 1 ;;
    esac
  done

  [[ -n "$REVOCATION_ID" ]] || { echo "--revocation-id is required" >&2; exit 1; }
  [[ -n "$REVOKED_BY" ]] || { echo "--revoked-by is required" >&2; exit 1; }

  local revocations_file="$OCTON_DIR/state/control/execution/revocations/grants.yml"
  mkdir -p "$(dirname "$revocations_file")"
  [[ -f "$revocations_file" ]] || printf 'schema_version: "authority-revocation-set-v1"\nrevocations: []\n' > "$revocations_file"
  local ts
  ts="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

  local tmp_json tmp_yaml
  tmp_json="$(mktemp "${TMPDIR:-/tmp}/authority-revocation.XXXXXX.json")"
  tmp_yaml="$(mktemp "${TMPDIR:-/tmp}/authority-revocation.XXXXXX.yml")"
  local reason_codes_json
  reason_codes_json="$(printf '%s\n' "${REASON_CODES[@]:-}" | jq -R . | jq -s 'map(select(length > 0))')"
  yq -o=json '.' "$revocations_file" | jq \
    --arg revocation_id "$REVOCATION_ID" \
    --arg grant_id "$GRANT_ID" \
    --arg request_id "$REQUEST_ID" \
    --arg run_id "$RUN_ID" \
    --arg state "$STATE" \
    --arg revoked_at "$ts" \
    --arg revoked_by "$REVOKED_BY" \
    --arg notes "$NOTES" \
    --argjson reason_codes "$reason_codes_json" \
    '
      .schema_version = "authority-revocation-set-v1" |
      .revocations = ((.revocations // []) | map(select(.revocation_id != $revocation_id))) |
      .revocations += [{
        schema_version: "authority-revocation-v1",
        revocation_id: $revocation_id,
        grant_id: (if ($grant_id | length) > 0 then $grant_id else null end),
        request_id: (if ($request_id | length) > 0 then $request_id else null end),
        run_id: (if ($run_id | length) > 0 then $run_id else null end),
        state: $state,
        revoked_at: $revoked_at,
        revoked_by: $revoked_by,
        reason_codes: $reason_codes,
        notes: (if ($notes | length) > 0 then $notes else null end)
      }]
    ' > "$tmp_json"
  yq -oy -p=json '.' "$tmp_json" > "$tmp_yaml"
  mv "$tmp_yaml" "$revocations_file"
  rm -f "$tmp_json"

  if [[ "${#REASON_CODES[@]}" -gt 0 ]]; then
    local args=()
    local code
    for code in "${REASON_CODES[@]}"; do
      args+=(--reason-code "$code")
    done
    bash "$RECEIPT_WRITER" \
      --receipt-type "authority_revocation_upsert" \
      --issued-by "$REVOKED_BY" \
      --source-ref ".octon/state/control/execution/revocations/grants.yml#${REVOCATION_ID}" \
      --applied-to-ref ".octon/state/control/execution/revocations/grants.yml#${REVOCATION_ID}" \
      --affected-path ".octon/state/control/execution/revocations/grants.yml" \
      "${args[@]}" \
      --revocation-ref ".octon/state/control/execution/revocations/grants.yml#${REVOCATION_ID}" \
      --linked-run-id "$RUN_ID" \
      >/dev/null
  else
    bash "$RECEIPT_WRITER" \
      --receipt-type "authority_revocation_upsert" \
      --issued-by "$REVOKED_BY" \
      --source-ref ".octon/state/control/execution/revocations/grants.yml#${REVOCATION_ID}" \
      --applied-to-ref ".octon/state/control/execution/revocations/grants.yml#${REVOCATION_ID}" \
      --affected-path ".octon/state/control/execution/revocations/grants.yml" \
      --reason-code "AUTHORITY_REVOCATION_UPSERTED" \
      --revocation-ref ".octon/state/control/execution/revocations/grants.yml#${REVOCATION_ID}" \
      --linked-run-id "$RUN_ID" \
      >/dev/null
  fi

  printf '%s\n' ".octon/state/control/execution/revocations/grants.yml#${REVOCATION_ID}"
}

main "$@"

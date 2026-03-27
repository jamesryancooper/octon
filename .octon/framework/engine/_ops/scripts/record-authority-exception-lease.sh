#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ENGINE_DIR="$(cd -- "$SCRIPT_DIR/../.." && pwd)"
FRAMEWORK_DIR="$(cd -- "$ENGINE_DIR/.." && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$(cd -- "$FRAMEWORK_DIR/.." && pwd)}"
RECEIPT_WRITER="$SCRIPT_DIR/write-authority-control-receipt.sh"

LEASE_ID=""
LEASE_KIND=""
STATE="active"
ISSUED_BY=""
REQUEST_ID=""
RUN_ID=""
SERVICE=""
ADAPTER=""
METHOD=""
SCHEME=""
HOST=""
PORT=""
PATH_PREFIX=""
EXPIRES_AT=""
TTL_SECONDS=""
REASON=""

usage() {
  cat <<'USAGE'
Usage:
  record-authority-exception-lease.sh \
    --lease-id <id> \
    --lease-kind <kind> \
    --issued-by <ref> \
    [--state active|revoked|expired] \
    [--request-id <id>] \
    [--run-id <id>] \
    [--service <id>] \
    [--adapter <id>] \
    [--method <verb>] \
    [--scheme <scheme>] \
    [--host <host>] \
    [--port <n>] \
    [--path-prefix <prefix>] \
    [--expires-at <ts> | --ttl-seconds <n>] \
    [--reason <text>]
USAGE
}

main() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --lease-id) LEASE_ID="$2"; shift 2 ;;
      --lease-kind) LEASE_KIND="$2"; shift 2 ;;
      --state) STATE="$2"; shift 2 ;;
      --issued-by) ISSUED_BY="$2"; shift 2 ;;
      --request-id) REQUEST_ID="$2"; shift 2 ;;
      --run-id) RUN_ID="$2"; shift 2 ;;
      --service) SERVICE="$2"; shift 2 ;;
      --adapter) ADAPTER="$2"; shift 2 ;;
      --method) METHOD="$2"; shift 2 ;;
      --scheme) SCHEME="$2"; shift 2 ;;
      --host) HOST="$2"; shift 2 ;;
      --port) PORT="$2"; shift 2 ;;
      --path-prefix) PATH_PREFIX="$2"; shift 2 ;;
      --expires-at) EXPIRES_AT="$2"; shift 2 ;;
      --ttl-seconds) TTL_SECONDS="$2"; shift 2 ;;
      --reason) REASON="$2"; shift 2 ;;
      -h|--help) usage; exit 0 ;;
      *) echo "Unknown option: $1" >&2; usage >&2; exit 1 ;;
    esac
  done

  [[ -n "$LEASE_ID" ]] || { echo "--lease-id is required" >&2; exit 1; }
  [[ -n "$LEASE_KIND" ]] || { echo "--lease-kind is required" >&2; exit 1; }
  [[ -n "$ISSUED_BY" ]] || { echo "--issued-by is required" >&2; exit 1; }

  local leases_file="$OCTON_DIR/state/control/execution/exceptions/leases.yml"
  mkdir -p "$(dirname "$leases_file")"
  [[ -f "$leases_file" ]] || printf 'schema_version: "authority-exception-lease-set-v1"\nleases: []\n' > "$leases_file"
  local ts
  ts="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  if [[ -z "$EXPIRES_AT" && -n "$TTL_SECONDS" ]]; then
    EXPIRES_AT="$(jq -nr --arg ts "$ts" --argjson seconds "$TTL_SECONDS" '$ts | fromdateiso8601 + $seconds | todateiso8601')"
  fi
  [[ -n "$EXPIRES_AT" ]] || EXPIRES_AT="2099-01-01T00:00:00Z"

  local tmp_json tmp_yaml
  tmp_json="$(mktemp "${TMPDIR:-/tmp}/authority-exception.XXXXXX.json")"
  tmp_yaml="$(mktemp "${TMPDIR:-/tmp}/authority-exception.XXXXXX.yml")"
  yq -o=json '.' "$leases_file" | jq \
    --arg lease_id "$LEASE_ID" \
    --arg lease_kind "$LEASE_KIND" \
    --arg state "$STATE" \
    --arg request_id "$REQUEST_ID" \
    --arg run_id "$RUN_ID" \
    --arg issued_by "$ISSUED_BY" \
    --arg issued_at "$ts" \
    --arg expires_at "$EXPIRES_AT" \
    --arg reason "$REASON" \
    --arg service "$SERVICE" \
    --arg adapter "$ADAPTER" \
    --arg method "$METHOD" \
    --arg scheme "$SCHEME" \
    --arg host "$HOST" \
    --arg port "$PORT" \
    --arg path_prefix "$PATH_PREFIX" \
    '
      .schema_version = "authority-exception-lease-set-v1" |
      .leases = ((.leases // []) | map(select(.id != $lease_id))) |
      .leases += [{
        schema_version: "authority-exception-lease-v1",
        id: $lease_id,
        state: $state,
        lease_kind: $lease_kind,
        request_id: (if ($request_id | length) > 0 then $request_id else null end),
        run_id: (if ($run_id | length) > 0 then $run_id else null end),
        service: (if ($service | length) > 0 then $service else null end),
        adapter: (if ($adapter | length) > 0 then $adapter else null end),
        method: (if ($method | length) > 0 then $method else null end),
        scheme: (if ($scheme | length) > 0 then $scheme else null end),
        host: (if ($host | length) > 0 then $host else null end),
        port: (if ($port | length) > 0 then ($port | tonumber) else null end),
        path_prefix: (if ($path_prefix | length) > 0 then $path_prefix else null end),
        issued_by: $issued_by,
        issued_at: $issued_at,
        expires_at: $expires_at,
        reason: (if ($reason | length) > 0 then $reason else null end)
      }]
    ' > "$tmp_json"
  yq -oy -p=json '.' "$tmp_json" > "$tmp_yaml"
  mv "$tmp_yaml" "$leases_file"
  rm -f "$tmp_json"

  local lease_ref=".octon/state/control/execution/exceptions/leases.yml#${LEASE_ID}"
  bash "$RECEIPT_WRITER" \
    --receipt-type "exception_lease_upsert" \
    --issued-by "$ISSUED_BY" \
    --source-ref "$lease_ref" \
    --applied-to-ref "$lease_ref" \
    --affected-path ".octon/state/control/execution/exceptions/leases.yml" \
    --reason "${REASON:-Upsert canonical authority exception lease}" \
    --reason-code "EXCEPTION_LEASE_UPSERTED" \
    --exception-lease-ref "$lease_ref" \
    --linked-run-id "$RUN_ID" \
    >/dev/null

  printf '%s\n' "$lease_ref"
}

main "$@"

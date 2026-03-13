#!/usr/bin/env bash
# policy-grant-broker.sh - Ephemeral grant broker for deny-by-default.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CAPABILITIES_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
REPO_ROOT="$(cd "$CAPABILITIES_DIR/../.." && pwd)"
POLICY_FILE="${OCTON_DDB_POLICY_FILE:-$CAPABILITIES_DIR/governance/policy/deny-by-default.v2.yml}"
POLICY_RUNNER="$REPO_ROOT/.octon/engine/runtime/policy"

usage() {
  cat <<'USAGE'
Usage:
  policy-grant-broker.sh create --subject <subject> --tier <low|medium|high> [--tool <token>]... [--write-scope <scope>]... [--ttl-seconds <n>] --request-id <id> --agent-id <id> --plan-step-id <id> [--review-evidence] [--quorum-evidence]
  policy-grant-broker.sh inspect --grant-id <id>
  policy-grant-broker.sh renew --grant-id <id> [--ttl-seconds <n>]
  policy-grant-broker.sh revoke --grant-id <id> [--reason <text>]
  policy-grant-broker.sh sweep-expired
USAGE
}

require_jq() {
  if ! command -v jq >/dev/null 2>&1; then
    echo "jq is required for policy-grant-broker.sh" >&2
    exit 1
  fi
}

policy_grants_state_dir() {
  awk '
    /^grants:/ {in_grants=1; next}
    in_grants && /^[[:space:]]*state_dir:/ {
      line=$0
      sub(/^[[:space:]]*state_dir:[[:space:]]*/, "", line)
      gsub(/["'\'' ]/, "", line)
      print line
      exit
    }
    in_grants && /^[[:space:]]*[a-z_]+:/ && $1 != "state_dir:" && $1 != "default_ttl_seconds:" && $1 != "max_ttl_seconds_by_tier:" && $1 != "allow_auto_grant_low:" && $1 != "allow_auto_grant_medium:" && $1 != "allow_auto_grant_high:" && $1 != "require_provenance:" {
      in_grants=0
    }
  ' "$POLICY_FILE"
}

default_ttl_seconds() {
  awk '
    /^grants:/ {in_grants=1; next}
    in_grants && /^[[:space:]]*default_ttl_seconds:/ {
      print $2
      exit
    }
  ' "$POLICY_FILE"
}

epoch_to_date() {
  local epoch="$1"
  if date -u -r "$epoch" +"%Y-%m-%d" >/dev/null 2>&1; then
    date -u -r "$epoch" +"%Y-%m-%d"
    return 0
  fi
  if date -u -d "@$epoch" +"%Y-%m-%d" >/dev/null 2>&1; then
    date -u -d "@$epoch" +"%Y-%m-%d"
    return 0
  fi
  echo "Unable to format epoch timestamp with local date implementation" >&2
  return 1
}

ensure_state_dir() {
  GRANTS_DIR="$(policy_grants_state_dir)"
  [[ -n "$GRANTS_DIR" ]] || { echo "grants.state_dir missing in $POLICY_FILE" >&2; exit 1; }
  mkdir -p "$GRANTS_DIR"
}

json_array_from_values() {
  if [[ $# -eq 0 ]]; then
    echo "[]"
    return 0
  fi

  printf '%s\n' "$@" | jq -R . | jq -s .
}

grant_file() {
  local grant_id="$1"
  echo "$GRANTS_DIR/$grant_id.json"
}

cmd_create() {
  local subject="" tier="low" ttl=""
  local request_id="" agent_id="" plan_step_id=""
  local has_review=false has_quorum=false
  local -a tools=()
  local -a write_scopes=()

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --subject) subject="$2"; shift 2 ;;
      --tier) tier="$2"; shift 2 ;;
      --tool) tools+=("$2"); shift 2 ;;
      --write-scope) write_scopes+=("$2"); shift 2 ;;
      --ttl-seconds) ttl="$2"; shift 2 ;;
      --request-id) request_id="$2"; shift 2 ;;
      --agent-id) agent_id="$2"; shift 2 ;;
      --plan-step-id) plan_step_id="$2"; shift 2 ;;
      --review-evidence) has_review=true; shift ;;
      --quorum-evidence) has_quorum=true; shift ;;
      *) echo "Unknown option for create: $1" >&2; exit 1 ;;
    esac
  done

  [[ -n "$subject" ]] || { echo "--subject is required" >&2; exit 1; }
  [[ -n "$request_id" ]] || { echo "--request-id is required" >&2; exit 1; }
  [[ -n "$agent_id" ]] || { echo "--agent-id is required" >&2; exit 1; }
  [[ -n "$plan_step_id" ]] || { echo "--plan-step-id is required" >&2; exit 1; }

  local -a eval_args
  eval_args=(grant-eval --policy "$POLICY_FILE" --tier "$tier")

  local t
  for t in "${tools[@]}"; do
    eval_args+=(--tool "$t")
  done

  for t in "${write_scopes[@]}"; do
    eval_args+=(--write-scope "$t")
  done

  if [[ -n "$ttl" ]]; then
    eval_args+=(--ttl-seconds "$ttl")
  fi

  eval_args+=(--request-id "$request_id" --agent-id "$agent_id" --plan-step-id "$plan_step_id")
  [[ "$has_review" == true ]] && eval_args+=(--has-review-evidence)
  [[ "$has_quorum" == true ]] && eval_args+=(--has-quorum-evidence)

  local eval_output rc=0
  eval_output="$("$POLICY_RUNNER" "${eval_args[@]}" 2>&1)" || rc=$?
  if [[ $rc -ne 0 && $rc -ne 13 ]]; then
    echo "$eval_output" >&2
    exit $rc
  fi

  if [[ $rc -eq 13 ]]; then
    echo "$eval_output" >&2
    exit 13
  fi

  local allowed effective_ttl
  allowed="$(jq -r '.allow // false' <<<"$eval_output")"
  effective_ttl="$(jq -r '.effective_ttl_seconds // empty' <<<"$eval_output")"

  if [[ "$allowed" != "true" ]]; then
    echo "$eval_output" >&2
    exit 13
  fi

  if [[ -z "$effective_ttl" ]]; then
    effective_ttl="$(default_ttl_seconds)"
  fi

  local now_epoch expires_epoch created expires grant_id file
  now_epoch="$(date -u +%s)"
  expires_epoch=$((now_epoch + effective_ttl))
  created="$(date -u +"%Y-%m-%d")"
  expires="$(epoch_to_date "$expires_epoch")"
  grant_id="grant-$(date -u +%Y%m%dT%H%M%SZ)-$$"
  file="$(grant_file "$grant_id")"

  jq -n \
    --arg id "$grant_id" \
    --arg subject "$subject" \
    --arg tier "$tier" \
    --arg created "$created" \
    --arg expires "$expires" \
    --arg request_id "$request_id" \
    --arg agent_id "$agent_id" \
    --arg plan_step_id "$plan_step_id" \
    --argjson tools "$(json_array_from_values "${tools[@]}")" \
    --argjson write_scopes "$(json_array_from_values "${write_scopes[@]}")" \
    --argjson eval_result "$eval_output" \
    '{
      id:$id,
      subject:$subject,
      state:"active",
      tier:$tier,
      created:$created,
      expires:$expires,
      tools:$tools,
      write_scopes:$write_scopes,
      provenance:{request_id:$request_id,agent_id:$agent_id,plan_step_id:$plan_step_id},
      evaluation:$eval_result
    }' > "$file"

  jq -c . "$file"
}

cmd_inspect() {
  local grant_id=""
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --grant-id) grant_id="$2"; shift 2 ;;
      *) echo "Unknown option for inspect: $1" >&2; exit 1 ;;
    esac
  done

  [[ -n "$grant_id" ]] || { echo "--grant-id is required" >&2; exit 1; }
  local file
  file="$(grant_file "$grant_id")"
  [[ -f "$file" ]] || { echo "Grant not found: $grant_id" >&2; exit 1; }
  jq -c . "$file"
}

cmd_renew() {
  local grant_id="" ttl=""
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --grant-id) grant_id="$2"; shift 2 ;;
      --ttl-seconds) ttl="$2"; shift 2 ;;
      *) echo "Unknown option for renew: $1" >&2; exit 1 ;;
    esac
  done

  [[ -n "$grant_id" ]] || { echo "--grant-id is required" >&2; exit 1; }
  local file
  file="$(grant_file "$grant_id")"
  [[ -f "$file" ]] || { echo "Grant not found: $grant_id" >&2; exit 1; }

  if [[ -z "$ttl" ]]; then
    ttl="$(default_ttl_seconds)"
  fi
  [[ "$ttl" =~ ^[0-9]+$ ]] || { echo "--ttl-seconds must be numeric" >&2; exit 1; }

  local now_epoch expires_epoch expires
  now_epoch="$(date -u +%s)"
  expires_epoch=$((now_epoch + ttl))
  expires="$(epoch_to_date "$expires_epoch")"

  jq --arg expires "$expires" '.expires=$expires | .state="active"' "$file" > "$file.tmp"
  mv "$file.tmp" "$file"
  jq -c . "$file"
}

cmd_revoke() {
  local grant_id="" reason="revoked"
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --grant-id) grant_id="$2"; shift 2 ;;
      --reason) reason="$2"; shift 2 ;;
      *) echo "Unknown option for revoke: $1" >&2; exit 1 ;;
    esac
  done

  [[ -n "$grant_id" ]] || { echo "--grant-id is required" >&2; exit 1; }
  local file
  file="$(grant_file "$grant_id")"
  [[ -f "$file" ]] || { echo "Grant not found: $grant_id" >&2; exit 1; }

  jq --arg reason "$reason" '.state="revoked" | .revoked_at=(now|strftime("%Y-%m-%d")) | .revoke_reason=$reason' "$file" > "$file.tmp"
  mv "$file.tmp" "$file"
  jq -c . "$file"
}

cmd_sweep_expired() {
  local today file expired=0
  today="$(date -u +"%Y-%m-%d")"

  for file in "$GRANTS_DIR"/*.json; do
    [[ -e "$file" ]] || continue
    if ! jq -e '.state == "active"' "$file" >/dev/null 2>&1; then
      continue
    fi

    local expires
    expires="$(jq -r '.expires // empty' "$file")"
    if [[ -z "$expires" || "$expires" < "$today" ]]; then
      jq '.state="expired" | .expired_at=(now|strftime("%Y-%m-%d"))' "$file" > "$file.tmp"
      mv "$file.tmp" "$file"
      expired=$((expired + 1))
    fi
  done

  echo "expired_grants=$expired"
}

main() {
  require_jq
  [[ -x "$POLICY_RUNNER" ]] || { echo "Missing policy runner: $POLICY_RUNNER" >&2; exit 1; }
  [[ -f "$POLICY_FILE" ]] || { echo "Missing policy file: $POLICY_FILE" >&2; exit 1; }
  ensure_state_dir

  local cmd="${1:-}"
  shift || true

  case "$cmd" in
    create) cmd_create "$@" ;;
    inspect) cmd_inspect "$@" ;;
    renew) cmd_renew "$@" ;;
    revoke) cmd_revoke "$@" ;;
    sweep-expired) cmd_sweep_expired "$@" ;;
    ""|-h|--help|help) usage ;;
    *) echo "Unknown command: $cmd" >&2; usage >&2; exit 1 ;;
  esac
}

main "$@"

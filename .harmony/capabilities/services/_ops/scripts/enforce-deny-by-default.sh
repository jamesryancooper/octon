#!/usr/bin/env bash
# enforce-deny-by-default.sh - Runtime deny-by-default guard for shell service entrypoints.

set -o pipefail

harmony_ddb_split_allowed_tools() {
  local raw="$1"
  local token=""
  local depth=0
  local ch
  local i

  for ((i=0; i<${#raw}; i++)); do
    ch="${raw:i:1}"
    case "$ch" in
      "(")
        depth=$((depth + 1))
        token+="$ch"
        ;;
      ")")
        if [[ $depth -gt 0 ]]; then
          depth=$((depth - 1))
        fi
        token+="$ch"
        ;;
      " " | $'\t')
        if [[ $depth -eq 0 ]]; then
          if [[ -n "$token" ]]; then
            echo "$token"
            token=""
          fi
        else
          token+="$ch"
        fi
        ;;
      *)
        token+="$ch"
        ;;
    esac
  done

  if [[ -n "$token" ]]; then
    echo "$token"
  fi
}

harmony_ddb_manifest_field() {
  local manifest="$1"
  local service_id="$2"
  local field="$3"

  awk -v target="$service_id" -v field="$field" '
    /^services:/ {in_services=1; next}
    in_services && /^[[:space:]]*- id:/ {
      id=$3
      gsub(/["'\'' ]/, "", id)
      found=(id==target)
      next
    }
    found && $1 == field":" {
      line=$0
      sub("^[[:space:]]*"field":[[:space:]]*", "", line)
      gsub(/["'\'' ]/, "", line)
      print line
      exit
    }
    found && /^[[:space:]]*- id:/ {exit}
  ' "$manifest"
}

harmony_ddb_log_enforcement() {
  local log_file="$1"
  local service_id="$2"
  local requested="$3"
  local rc="$4"

  mkdir -p "$(dirname "$log_file")"
  printf '%s\t%s\t%s\t%s\n' "$(date -u +"%Y-%m-%dT%H:%M:%SZ")" "$service_id" "$rc" "$requested" >> "$log_file"
}

harmony_ddb_log_decision_json() {
  local json_log_file="$1"
  local service_id="$2"
  local decision_json="$3"

  mkdir -p "$(dirname "$json_log_file")"

  if command -v jq >/dev/null 2>&1; then
    local compact
    compact="$(jq -c --arg service "$service_id" --arg ts "$(date -u +"%Y-%m-%dT%H:%M:%SZ")" '. + {service:$service,timestamp:$ts}' <<<"$decision_json" 2>/dev/null || true)"
    if [[ -n "$compact" ]]; then
      printf '%s\n' "$compact" >> "$json_log_file"
      return 0
    fi
  fi

  local flattened
  flattened="$(echo "$decision_json" | tr '\n' ' ' | sed 's/[[:space:]]\+/ /g')"
  printf '{"timestamp":"%s","service":"%s","raw":"%s"}\n' "$(date -u +"%Y-%m-%dT%H:%M:%SZ")" "$service_id" "$flattened" >> "$json_log_file"
}

harmony_ddb_emit_deny() {
  local decision_json="$1"

  if command -v jq >/dev/null 2>&1; then
    local code message hint
    code="$(jq -r '.deny.code // "DDB025_RUNTIME_DECISION_ENGINE_ERROR"' <<<"$decision_json" 2>/dev/null)"
    message="$(jq -r '.deny.message // "Denied by policy"' <<<"$decision_json" 2>/dev/null)"
    hint="$(jq -r '.deny.remediation_hint // empty' <<<"$decision_json" 2>/dev/null)"

    echo "[deny-by-default][$code] $message" >&2
    if [[ -n "$hint" ]]; then
      echo "[deny-by-default] remediation: $hint" >&2
    fi
  else
    echo "[deny-by-default] $decision_json" >&2
  fi
}

harmony_enforce_service_policy() {
  local service_id="$1"
  local script_path="$2"
  shift 2 || true

  local script_dir services_root harmony_root repo_root service_dir service_md manifest policy_file exceptions_file
  local policy_runner enforcement_log decision_json_log requested_command category

  script_dir="$(cd "$(dirname "$script_path")" && pwd)"
  services_root="$(cd "$script_dir/../../.." && pwd)"
  harmony_root="$(cd "$services_root/../.." && pwd)"
  repo_root="$(cd "$harmony_root/.." && pwd)"
  service_dir="$(cd "$script_dir/.." && pwd)"

  service_md="$service_dir/SERVICE.md"
  manifest="$services_root/manifest.yml"
  policy_file="$harmony_root/capabilities/_ops/policy/deny-by-default.v2.yml"
  exceptions_file="$harmony_root/capabilities/_ops/state/deny-by-default-exceptions.yml"
  policy_runner="$harmony_root/capabilities/_ops/scripts/run-harmony-policy.sh"
  enforcement_log="$services_root/_ops/state/logs/deny-by-default-enforcement.log"
  decision_json_log="$harmony_root/capabilities/_ops/state/logs/deny-by-default-decisions.jsonl"

  if [[ ! -x "$policy_runner" ]]; then
    echo "[deny-by-default] missing policy runner script: $policy_runner" >&2
    exit 13
  fi
  if [[ ! -f "$manifest" ]]; then
    echo "[deny-by-default] missing services manifest: $manifest" >&2
    exit 13
  fi
  if [[ ! -f "$service_md" ]]; then
    echo "[deny-by-default] missing SERVICE.md: $service_md" >&2
    exit 13
  fi
  if [[ ! -f "$policy_file" ]]; then
    echo "[deny-by-default] missing policy file: $policy_file" >&2
    exit 13
  fi

  local script_rel
  script_rel="${script_path#$services_root/}"
  requested_command="bash ${script_rel}"
  if [[ $# -gt 0 ]]; then
    requested_command+=" $*"
  fi

  category="$(harmony_ddb_manifest_field "$manifest" "$service_id" "category")"

  # Agent-only checks are always enforced by the policy engine.
  export HARMONY_AGENT_ID="${HARMONY_AGENT_ID:-agent-local}"
  export HARMONY_AGENT_IDS="${HARMONY_AGENT_IDS:-$HARMONY_AGENT_ID}"
  export HARMONY_RISK_TIER="${HARMONY_RISK_TIER:-low}"

  local decision_output
  local rc=0

  if [[ -n "$category" ]]; then
    decision_output="$(
      "$policy_runner" enforce \
        --kind service \
        --id "$service_id" \
        --manifest "$manifest" \
        --artifact "$service_md" \
        --policy "$policy_file" \
        --exceptions "$exceptions_file" \
        --requested-command "$requested_command" \
        --category "$category" 2>&1
    )" || rc=$?
  else
    decision_output="$(
      "$policy_runner" enforce \
        --kind service \
        --id "$service_id" \
        --manifest "$manifest" \
        --artifact "$service_md" \
        --policy "$policy_file" \
        --exceptions "$exceptions_file" \
        --requested-command "$requested_command" 2>&1
    )" || rc=$?
  fi

  harmony_ddb_log_enforcement "$enforcement_log" "$service_id" "$requested_command" "$rc"
  harmony_ddb_log_decision_json "$decision_json_log" "$service_id" "$decision_output"

  case "$rc" in
    0)
      return 0
      ;;
    13)
      harmony_ddb_emit_deny "$decision_output"
      exit 13
      ;;
    *)
      echo "[deny-by-default] policy engine failed; failing closed" >&2
      harmony_ddb_emit_deny "$decision_output"
      exit 13
      ;;
  esac
}

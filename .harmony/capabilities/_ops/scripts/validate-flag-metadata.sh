#!/usr/bin/env bash
# validate-flag-metadata.sh - Validate feature flag metadata contract for ACP promotion.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CAPABILITIES_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
DEFAULT_POLICY="$CAPABILITIES_DIR/governance/policy/deny-by-default.v2.yml"
DEFAULT_METADATA="$CAPABILITIES_DIR/governance/policy/flags.metadata.json"
DEFAULT_SCHEMA="$CAPABILITIES_DIR/governance/policy/flags.metadata.schema.json"

usage() {
  cat <<'EOF'
Usage:
  validate-flag-metadata.sh [--policy <path>] [--metadata <path>] [--schema <path>]
EOF
}

require_jq() {
  if ! command -v jq >/dev/null 2>&1; then
    echo "jq is required for validate-flag-metadata.sh" >&2
    exit 1
  fi
}

extract_required_fields() {
  local policy_file="$1"
  local fields_raw
  fields_raw="$(awk '
    /^[[:space:]]*flags_metadata:/ {in_section=1; next}
    in_section && /^[[:space:]]*required_fields:[[:space:]]*\[/ {
      line=$0
      sub(/^[[:space:]]*required_fields:[[:space:]]*\[/, "", line)
      sub(/\][[:space:]]*$/, "", line)
      gsub(/[[:space:]]+/, "", line)
      print line
      exit
    }
    in_section && /^[[:space:]]*[a-z_]+:/ && $1 !~ /^contract_file:|^schema_file:|^required_fields:/ {
      in_section=0
    }
  ' "$policy_file")"

  if [[ -z "$fields_raw" ]]; then
    echo "flag_id,owner,created,expires,cleanup_by,default,description,risk,links"
    return 0
  fi
  echo "$fields_raw"
}

main() {
  require_jq

  local policy_file="$DEFAULT_POLICY"
  local metadata_file="$DEFAULT_METADATA"
  local schema_file="$DEFAULT_SCHEMA"

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --policy) policy_file="$2"; shift 2 ;;
      --metadata) metadata_file="$2"; shift 2 ;;
      --schema) schema_file="$2"; shift 2 ;;
      -h|--help|help) usage; exit 0 ;;
      *) echo "Unknown option: $1" >&2; usage >&2; exit 1 ;;
    esac
  done

  [[ -f "$policy_file" ]] || { echo "Missing policy file: $policy_file" >&2; exit 1; }
  [[ -f "$metadata_file" ]] || { echo "Missing flag metadata file: $metadata_file" >&2; exit 1; }
  [[ -f "$schema_file" ]] || { echo "Missing flag metadata schema file: $schema_file" >&2; exit 1; }

  local required_csv
  required_csv="$(extract_required_fields "$policy_file")"
  IFS=',' read -r -a required_fields <<<"$required_csv"

  local errors=0

  if ! jq -e '.schema_version | type == "string"' "$metadata_file" >/dev/null; then
    echo "flags metadata must contain string field: schema_version" >&2
    errors=$((errors + 1))
  fi

  if ! jq -e '.flags | type == "array"' "$metadata_file" >/dev/null; then
    echo "flags metadata must contain array field: flags" >&2
    errors=$((errors + 1))
  fi

  local count idx field
  count="$(jq -r '.flags | length' "$metadata_file" 2>/dev/null || echo "0")"
  if ! [[ "$count" =~ ^[0-9]+$ ]]; then
    echo "flags metadata has invalid flags array length" >&2
    exit 1
  fi

  for ((idx=0; idx<count; idx++)); do
    for field in "${required_fields[@]}"; do
      if ! jq -e --argjson i "$idx" --arg f "$field" '.flags[$i] | has($f)' "$metadata_file" >/dev/null; then
        echo "flags[$idx] missing required field '$field'" >&2
        errors=$((errors + 1))
      fi
    done

    if ! jq -e --argjson i "$idx" '.flags[$i].flag_id | type == "string" and (length > 0)' "$metadata_file" >/dev/null; then
      echo "flags[$idx].flag_id must be a non-empty string" >&2
      errors=$((errors + 1))
    fi
    if ! jq -e --argjson i "$idx" '.flags[$i].owner | type == "string" and (length > 0)' "$metadata_file" >/dev/null; then
      echo "flags[$idx].owner must be a non-empty string" >&2
      errors=$((errors + 1))
    fi
    if ! jq -e --argjson i "$idx" '.flags[$i].default | type == "boolean"' "$metadata_file" >/dev/null; then
      echo "flags[$idx].default must be boolean" >&2
      errors=$((errors + 1))
    fi
    if ! jq -e --argjson i "$idx" '.flags[$i].description | type == "string" and (length > 0)' "$metadata_file" >/dev/null; then
      echo "flags[$idx].description must be a non-empty string" >&2
      errors=$((errors + 1))
    fi
    if ! jq -e --argjson i "$idx" '.flags[$i].risk | type == "string" and (. == "low" or . == "medium" or . == "high")' "$metadata_file" >/dev/null; then
      echo "flags[$idx].risk must be one of: low|medium|high" >&2
      errors=$((errors + 1))
    fi
    if ! jq -e --argjson i "$idx" '.flags[$i].links | type == "array" and (length > 0) and all(.[]; type == "string" and length > 0)' "$metadata_file" >/dev/null; then
      echo "flags[$idx].links must be a non-empty array of non-empty strings" >&2
      errors=$((errors + 1))
    fi

    for field in created expires cleanup_by; do
      if ! jq -e --argjson i "$idx" --arg f "$field" '.flags[$i][$f] | type == "string" and test("^[0-9]{4}-[0-9]{2}-[0-9]{2}$")' "$metadata_file" >/dev/null; then
        echo "flags[$idx].$field must be YYYY-MM-DD" >&2
        errors=$((errors + 1))
      fi
    done

    if ! jq -e --argjson i "$idx" '.flags[$i] | (.created <= .expires) and (.expires <= .cleanup_by)' "$metadata_file" >/dev/null; then
      echo "flags[$idx] requires created <= expires <= cleanup_by" >&2
      errors=$((errors + 1))
    fi
  done

  if [[ "$errors" -gt 0 ]]; then
    echo "Flag metadata contract validation failed with $errors issue(s)." >&2
    exit 1
  fi

  jq -n --argjson checked "$count" --arg metadata "$metadata_file" \
    '{valid:true,checked_flags:$checked,metadata:$metadata}' | jq -c .
}

main "$@"

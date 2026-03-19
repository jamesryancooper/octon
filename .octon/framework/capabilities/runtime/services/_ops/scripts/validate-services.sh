#!/usr/bin/env bash
# validate-services.sh - Validate services subsystem structure, manifests, and deny-by-default policy conformance.
#
# Usage:
#   ./validate-services.sh [--profile strict|dev-fast] [service-id]
#
# Profiles:
#   strict   - full validation (default)
#   dev-fast - deny-by-default + structural core checks optimized for fast local iteration

set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SERVICES_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
OCTON_DIR="$(cd "$SERVICES_DIR/../../.." && pwd)"
MANIFEST="$SERVICES_DIR/manifest.yml"
REGISTRY="$SERVICES_DIR/registry.yml"
CAPABILITIES="$SERVICES_DIR/capabilities.yml"
EXCEPTIONS_FILE="$OCTON_DIR/../state/control/capabilities/deny-by-default-exceptions.yml"
AGENT_ONLY_POLICY_FILE="$OCTON_DIR/capabilities/governance/policy/agent-only-governance.yml"
AGENT_ONLY_VALIDATOR="$OCTON_DIR/capabilities/_ops/scripts/validate-agent-only-governance.sh"
POLICY_V2_FILE="$OCTON_DIR/capabilities/governance/policy/deny-by-default.v2.yml"
POLICY_RUNNER="$OCTON_DIR/engine/runtime/policy"
TODAY="$(date +%F)"
VALIDATION_PROFILE="${OCTON_VALIDATION_PROFILE:-strict}"
TARGET_SERVICE_ID=""

errors=0
warnings=0

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

log_error() {
  echo -e "${RED}ERROR:${NC} $1"
  ((errors++)) || true
}

log_warning() {
  echo -e "${YELLOW}WARNING:${NC} $1"
  ((warnings++)) || true
}

log_success() {
  echo -e "${GREEN}✓${NC} $1"
}

show_help() {
  cat <<'EOF'
Usage:
  ./validate-services.sh [--profile strict|dev-fast] [service-id]

Profiles:
  strict   Full validation (default)
  dev-fast Fast local validation focused on deny-by-default and core structure
EOF
}

has_value() {
  local needle="$1"
  shift
  local item
  for item in "$@"; do
    [[ "$item" == "$needle" ]] && return 0
  done
  return 1
}

trim_value() {
  local value="$1"
  value="${value#\"}"
  value="${value%\"}"
  value="${value#\'}"
  value="${value%\'}"
  echo "$value" | xargs
}

is_valid_date() {
  local value="$1"
  [[ "$value" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]
}

get_capability_values() {
  local key="$1"
  awk -v section="$key" '
    $0 ~ "^"section":" {in_section=1; next}
    in_section && /^[a-z_]+:/ {exit}
    in_section && /^[[:space:]]*-[[:space:]]*/ {
      line=$0
      sub(/^[[:space:]]*-[[:space:]]*/, "", line)
      gsub(/["'\'' ]/, "", line)
      if (length(line) > 0) print line
    }
  ' "$CAPABILITIES"
}

get_manifest_service_ids() {
  awk '
    /^services:/ {in_services=1; next}
    in_services && /^[[:space:]]*- id:/ {
      id=$3
      gsub(/["'\'' ]/, "", id)
      print id
    }
  ' "$MANIFEST"
}

get_manifest_field() {
  local service_id="$1"
  local field="$2"

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
  ' "$MANIFEST"
}

registry_has_service() {
  local service_id="$1"
  grep -q "^  ${service_id}:" "$REGISTRY"
}

split_allowed_tools() {
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

get_service_allowed_tools() {
  local service_md="$1"
  local raw
  raw=$(grep -E "^allowed-tools:" "$service_md" | head -1 | sed 's/allowed-tools:[[:space:]]*//')
  split_allowed_tools "$raw"
}

get_service_policy_fail_closed() {
  local service_md="$1"
  awk '
    /^---/ {
      delim_count++
      if (delim_count == 2) exit
      next
    }
    delim_count == 1 && /^[[:space:]]*fail_closed:/ {
      line=$0
      sub(/^[[:space:]]*fail_closed:[[:space:]]*/, "", line)
      gsub(/["'\'' ]/, "", line)
      print tolower(line)
      exit
    }
  ' "$service_md"
}

validate_allowed_tool_token() {
  local token="$1"
  case "$token" in
    Read|Glob|Grep|Edit|WebFetch|WebSearch|Task|Shell|Bash|Write)
      return 0
      ;;
    Bash\(*\)|Write\(*\)|pack:*)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

get_exception_expiry() {
  local expected_scope="$1"
  local expected_target="$2"
  local expected_rule="$3"

  [[ -f "$EXCEPTIONS_FILE" ]] || return 0

  local in_exceptions=false
  local scope=""
  local target=""
  local rule=""
  local expires=""
  local line trimmed value

  while IFS= read -r line || [[ -n "$line" ]]; do
    trimmed="$(echo "$line" | sed 's/^[[:space:]]*//')"
    [[ -z "$trimmed" || "$trimmed" == \#* ]] && continue

    if [[ "$trimmed" == "exceptions:" ]]; then
      in_exceptions=true
      continue
    fi

    if [[ "$in_exceptions" != true ]]; then
      continue
    fi

    if [[ "$trimmed" == "- id:"* ]]; then
      if [[ "$scope" == "$expected_scope" && "$target" == "$expected_target" && "$rule" == "$expected_rule" ]]; then
        echo "$expires"
        return 0
      fi
      scope=""
      target=""
      rule=""
      expires=""
      continue
    fi

    if [[ "$trimmed" == scope:* ]]; then
      value="${trimmed#scope:}"
      scope="$(trim_value "$value")"
    elif [[ "$trimmed" == target:* ]]; then
      value="${trimmed#target:}"
      target="$(trim_value "$value")"
    elif [[ "$trimmed" == rule:* ]]; then
      value="${trimmed#rule:}"
      rule="$(trim_value "$value")"
    elif [[ "$trimmed" == expires:* ]]; then
      value="${trimmed#expires:}"
      expires="$(trim_value "$value")"
    fi
  done < "$EXCEPTIONS_FILE"

  if [[ "$scope" == "$expected_scope" && "$target" == "$expected_target" && "$rule" == "$expected_rule" ]]; then
    echo "$expires"
  fi
}

require_active_exception() {
  local scope="$1"
  local target="$2"
  local rule="$3"
  local reason="$4"

  local expires
  expires="$(get_exception_expiry "$scope" "$target" "$rule")"

  if [[ -z "$expires" ]]; then
    log_error "$reason requires active exception lease (${scope}/${target}/${rule}) in $EXCEPTIONS_FILE"
    return
  fi

  if ! is_valid_date "$expires"; then
    log_error "Exception lease has invalid expiry format for (${scope}/${target}/${rule}): $expires"
    return
  fi

  if [[ "$expires" < "$TODAY" ]]; then
    log_error "Exception lease expired for (${scope}/${target}/${rule}) on $expires"
    return
  fi

  log_success "Exception lease active for (${scope}/${target}/${rule}) until $expires"
}

service_matches_target() {
  local service_id="$1"
  if [[ -z "$TARGET_SERVICE_ID" ]]; then
    return 0
  fi
  [[ "$service_id" == "$TARGET_SERVICE_ID" ]]
}

parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --help|-h)
        show_help
        exit 0
        ;;
      --profile)
        if [[ $# -lt 2 ]]; then
          log_error "--profile requires a value (strict|dev-fast)"
          exit 1
        fi
        VALIDATION_PROFILE="$2"
        shift 2
        ;;
      --profile=*)
        VALIDATION_PROFILE="${1#--profile=}"
        shift
        ;;
      --*)
        log_error "Unknown option: $1"
        exit 1
        ;;
      *)
        if [[ -n "$TARGET_SERVICE_ID" ]]; then
          log_error "Unexpected extra argument: $1"
          exit 1
        fi
        TARGET_SERVICE_ID="$1"
        shift
        ;;
    esac
  done

  if [[ "$VALIDATION_PROFILE" != "strict" && "$VALIDATION_PROFILE" != "dev-fast" ]]; then
    log_error "Invalid profile '$VALIDATION_PROFILE' (expected strict|dev-fast)"
    exit 1
  fi
}

extract_policy_field() {
  local json="$1"
  local path="$2"

  if command -v jq >/dev/null 2>&1; then
    jq -r "$path // empty" <<<"$json" 2>/dev/null || true
    return
  fi

  echo ""
}

validate_service_permissions() {
  local service_id="$1"
  local service_status="$2"
  local interface_type="$3"
  local service_md="$4"

  local policy_ready=false
  if [[ -x "$POLICY_RUNNER" && -f "$POLICY_V2_FILE" ]]; then
    policy_ready=true
  fi

  if [[ "$policy_ready" == "true" ]]; then
    local output rc=0
    output="$(
      "$POLICY_RUNNER" preflight \
        --kind service \
        --id "$service_id" \
        --manifest "$MANIFEST" \
        --artifact "$service_md" \
        --policy "$POLICY_V2_FILE" \
        --exceptions "$EXCEPTIONS_FILE" 2>&1
    )" || rc=$?

    if [[ $rc -eq 0 ]]; then
      log_success "deny-by-default preflight passed for service '$service_id'"
      return
    fi

    if [[ $rc -eq 13 ]]; then
      local code message hint
      code="$(extract_policy_field "$output" '.deny.code')"
      message="$(extract_policy_field "$output" '.deny.message')"
      hint="$(extract_policy_field "$output" '.deny.remediation_hint')"
      [[ -n "$code" ]] || code="DDB025_RUNTIME_DECISION_ENGINE_ERROR"
      [[ -n "$message" ]] || message="Policy preflight denied."

      log_error "Service '$service_id' failed deny-by-default preflight [$code]: $message"
      if [[ -n "$hint" ]]; then
        log_info "  remediation: $hint"
      fi
      return
    fi

    log_error "Policy engine preflight failed for '$service_id': $output"
    return
  fi

  log_error "Policy runner unavailable: $POLICY_RUNNER"
}

main() {
  parse_args "$@"

  echo "Services validation profile: $VALIDATION_PROFILE"
  if [[ -n "$TARGET_SERVICE_ID" ]]; then
    echo "Target service: $TARGET_SERVICE_ID"
  fi

  local required=(
    "$MANIFEST"
    "$REGISTRY"
    "$CAPABILITIES"
    "$SERVICES_DIR/_scaffold/template/SERVICE.md"
    "$SERVICES_DIR/_scaffold/template/schema/input.schema.json"
    "$SERVICES_DIR/_scaffold/template/schema/output.schema.json"
  )

  local f
  for f in "${required[@]}"; do
    if [[ ! -f "$f" ]]; then
      log_error "Missing required file: $f"
    fi
  done

  if [[ "$VALIDATION_PROFILE" == "strict" ]]; then
    local conventions=(
      "$OCTON_DIR/capabilities/practices/services-conventions/error-codes.md"
      "$OCTON_DIR/capabilities/practices/services-conventions/run-records.md"
      "$OCTON_DIR/capabilities/practices/services-conventions/observability.md"
      "$OCTON_DIR/capabilities/practices/services-conventions/idempotency.md"
      "$OCTON_DIR/capabilities/practices/services-conventions/rich-contracts.md"
      "$OCTON_DIR/capabilities/practices/services-conventions/declarative-rules.md"
      "$OCTON_DIR/capabilities/practices/services-conventions/fixtures.md"
      "$OCTON_DIR/capabilities/practices/services-conventions/validation-tiers.md"
      "$OCTON_DIR/capabilities/practices/services-conventions/implementation-generation.md"
    )
    for f in "${conventions[@]}"; do
      [[ -f "$f" ]] || log_error "Missing convention doc: $f"
    done
  fi

  if [[ ! -f "$EXCEPTIONS_FILE" ]]; then
    log_warning "Deny-by-default exceptions file not found: $EXCEPTIONS_FILE"
  fi

  if [[ -x "$AGENT_ONLY_VALIDATOR" ]]; then
    if ! "$AGENT_ONLY_VALIDATOR" "$AGENT_ONLY_POLICY_FILE" >/dev/null 2>&1; then
      if [[ "$VALIDATION_PROFILE" == "strict" ]]; then
        log_error "Agent-only governance policy validation failed: $AGENT_ONLY_POLICY_FILE"
      else
        log_warning "Agent-only governance policy validation failed: $AGENT_ONLY_POLICY_FILE"
      fi
    else
      log_success "Agent-only governance policy validated"
    fi
  elif [[ "$VALIDATION_PROFILE" == "strict" ]]; then
    log_error "Missing agent-only governance validator: $AGENT_ONLY_VALIDATOR"
  else
    log_warning "Missing agent-only governance validator: $AGENT_ONLY_VALIDATOR"
  fi

  if [[ $errors -gt 0 ]]; then
    echo
    echo "Validation failed: $errors error(s), $warnings warning(s)."
    exit 1
  fi

  local valid_categories valid_interfaces valid_statuses
  mapfile -t valid_categories < <(get_capability_values "service_categories")
  mapfile -t valid_interfaces < <(get_capability_values "valid_interface_types")
  mapfile -t valid_statuses < <(get_capability_values "valid_statuses")

  [[ ${#valid_categories[@]} -gt 0 ]] || log_error "No service_categories found in capabilities.yml"
  [[ ${#valid_interfaces[@]} -gt 0 ]] || log_error "No valid_interface_types found in capabilities.yml"
  [[ ${#valid_statuses[@]} -gt 0 ]] || log_error "No valid_statuses found in capabilities.yml"

  local service_ids
  mapfile -t service_ids < <(get_manifest_service_ids)

  if [[ ${#service_ids[@]} -eq 0 ]]; then
    log_error "No services found in manifest.yml"
  else
    log_success "Found ${#service_ids[@]} service definition(s)"
  fi

  local seen_ids=()
  local target_found=false
  local service_id
  for service_id in "${service_ids[@]}"; do
    if ! service_matches_target "$service_id"; then
      continue
    fi
    target_found=true

    if has_value "$service_id" "${seen_ids[@]}"; then
      log_error "Duplicate service id: $service_id"
      continue
    fi
    seen_ids+=("$service_id")

    local path interface_type category status
    path="$(get_manifest_field "$service_id" "path")"
    interface_type="$(get_manifest_field "$service_id" "interface_type")"
    category="$(get_manifest_field "$service_id" "category")"
    status="$(get_manifest_field "$service_id" "status")"

    if [[ -z "$path" ]]; then
      log_error "Service '$service_id' missing path"
      continue
    fi

    local service_dir="$SERVICES_DIR/$path"
    local service_md="$service_dir/SERVICE.md"
    [[ -d "$service_dir" ]] || log_error "Service directory not found: $service_dir"
    [[ -f "$service_md" ]] || log_error "Missing SERVICE.md for '$service_id'"
    [[ -f "$service_dir/schema/input.schema.json" ]] || log_error "Missing input schema for '$service_id'"
    [[ -f "$service_dir/schema/output.schema.json" ]] || log_error "Missing output schema for '$service_id'"
    [[ -d "$service_dir/impl" ]] || log_error "Missing impl directory for '$service_id'"
    [[ -d "$service_dir/references" ]] || log_error "Missing references directory for '$service_id'"

    if [[ "$service_id" == "query" && -d "$service_dir/adapters" && "$VALIDATION_PROFILE" != "dev-fast" ]]; then
      local adapter_validator="$service_dir/impl/validate-adapters.sh"
      if [[ ! -f "$adapter_validator" ]]; then
        log_error "Missing adapter validator for '$service_id': $adapter_validator"
      else
        local adapter_validation_output
        adapter_validation_output="$(bash "$adapter_validator" 2>&1 || true)"
        if grep -q "Adapter validation passed" <<<"$adapter_validation_output"; then
          log_success "Adapter contracts validated for '$service_id'"
        else
          log_error "Adapter validation failed for '$service_id'"
          echo "$adapter_validation_output"
        fi
      fi
    fi

    if [[ -n "$interface_type" ]]; then
      has_value "$interface_type" "${valid_interfaces[@]}" || log_error "Invalid interface_type '$interface_type' for '$service_id'"
    else
      log_error "Service '$service_id' missing interface_type"
    fi

    if [[ -n "$category" ]]; then
      has_value "$category" "${valid_categories[@]}" || log_error "Invalid category '$category' for '$service_id'"
    else
      log_error "Service '$service_id' missing category"
    fi

    if [[ -n "$status" ]]; then
      has_value "$status" "${valid_statuses[@]}" || log_error "Invalid status '$status' for '$service_id'"
    else
      log_error "Service '$service_id' missing status"
    fi

    if [[ -f "$service_md" ]]; then
      validate_service_permissions "$service_id" "$status" "$interface_type" "$service_md"
    fi

    if registry_has_service "$service_id"; then
      log_success "Registry entry found for '$service_id'"
    else
      log_warning "No registry metadata entry for '$service_id'"
    fi
  done

  if [[ -n "$TARGET_SERVICE_ID" && "$target_found" != "true" ]]; then
    log_error "Service '$TARGET_SERVICE_ID' not found in manifest.yml"
  fi

  echo
  if [[ $errors -gt 0 ]]; then
    echo "Validation failed: $errors error(s), $warnings warning(s)."
    exit 1
  fi

  local policy_compiler
  policy_compiler="$SERVICES_DIR/_ops/scripts/compile-deny-by-default-policy.sh"
  if [[ -x "$policy_compiler" ]]; then
    local catalog_path
    if catalog_path="$("$policy_compiler")"; then
      log_success "Compiled deny-by-default service policy catalog: $catalog_path"
    else
      log_warning "Failed to compile deny-by-default service policy catalog"
    fi
  fi

  echo "Validation passed: 0 errors, $warnings warning(s)."
}

main "$@"

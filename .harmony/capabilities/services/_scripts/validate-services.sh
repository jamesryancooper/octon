#!/usr/bin/env bash
# validate-services.sh - Validate services subsystem structure and manifests.

set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SERVICES_DIR="$(dirname "$SCRIPT_DIR")"
MANIFEST="$SERVICES_DIR/manifest.yml"
REGISTRY="$SERVICES_DIR/registry.yml"
CAPABILITIES="$SERVICES_DIR/capabilities.yml"

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

has_value() {
  local needle="$1"
  shift
  local item
  for item in "$@"; do
    [[ "$item" == "$needle" ]] && return 0
  done
  return 1
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

main() {
  local required=(
    "$MANIFEST"
    "$REGISTRY"
    "$CAPABILITIES"
    "$SERVICES_DIR/_template/SERVICE.md"
    "$SERVICES_DIR/_template/schema/input.schema.json"
    "$SERVICES_DIR/_template/schema/output.schema.json"
  )

  local f
  for f in "${required[@]}"; do
    if [[ ! -f "$f" ]]; then
      log_error "Missing required file: $f"
    fi
  done

  local conventions=(
    "$SERVICES_DIR/conventions/error-codes.md"
    "$SERVICES_DIR/conventions/run-records.md"
    "$SERVICES_DIR/conventions/observability.md"
    "$SERVICES_DIR/conventions/idempotency.md"
    "$SERVICES_DIR/conventions/rich-contracts.md"
    "$SERVICES_DIR/conventions/declarative-rules.md"
    "$SERVICES_DIR/conventions/fixtures.md"
    "$SERVICES_DIR/conventions/validation-tiers.md"
    "$SERVICES_DIR/conventions/implementation-generation.md"
  )
  for f in "${conventions[@]}"; do
    [[ -f "$f" ]] || log_error "Missing convention doc: $f"
  done

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
  local service_id
  for service_id in "${service_ids[@]}"; do
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
    [[ -d "$service_dir" ]] || log_error "Service directory not found: $service_dir"
    [[ -f "$service_dir/SERVICE.md" ]] || log_error "Missing SERVICE.md for '$service_id'"
    [[ -f "$service_dir/schema/input.schema.json" ]] || log_error "Missing input schema for '$service_id'"
    [[ -f "$service_dir/schema/output.schema.json" ]] || log_error "Missing output schema for '$service_id'"
    [[ -d "$service_dir/impl" ]] || log_error "Missing impl directory for '$service_id'"
    [[ -d "$service_dir/references" ]] || log_error "Missing references directory for '$service_id'"

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

    if registry_has_service "$service_id"; then
      log_success "Registry entry found for '$service_id'"
    else
      log_warning "No registry metadata entry for '$service_id'"
    fi
  done

  echo
  if [[ $errors -gt 0 ]]; then
    echo "Validation failed: $errors error(s), $warnings warning(s)."
    exit 1
  fi

  echo "Validation passed: 0 errors, $warnings warning(s)."
}

main "$@"

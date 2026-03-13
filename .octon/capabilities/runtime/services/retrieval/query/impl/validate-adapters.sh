#!/usr/bin/env bash
# validate-adapters.sh - Structural validation for query adapter contracts.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SERVICE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
ADAPTERS_DIR="$SERVICE_DIR/adapters"
REGISTRY_FILE="$ADAPTERS_DIR/registry.yml"
HAS_RG=0

errors=0

if command -v rg >/dev/null 2>&1; then
  HAS_RG=1
fi

log_error() {
  echo "ERROR: $1" >&2
  errors=$((errors + 1))
}

log_ok() {
  echo "✓ $1"
}

matches_file_regex() {
  local pattern="$1"
  local file="$2"

  if [[ "$HAS_RG" -eq 1 ]]; then
    rg -q -- "$pattern" "$file"
  else
    grep -Eq -- "$pattern" "$file"
  fi
}

if [[ ! -f "$REGISTRY_FILE" ]]; then
  log_error "Adapter registry not found: $REGISTRY_FILE"
  exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
  log_error "jq is required"
  exit 6
fi

mapfile -t adapter_ids < <(awk '
  /^[[:space:]]*-[[:space:]]id:[[:space:]]*/ {
    id = $3
    gsub(/["'\'' ]/, "", id)
    if (length(id) > 0) print id
  }
' "$REGISTRY_FILE")

if [[ ${#adapter_ids[@]} -eq 0 ]]; then
  log_error "No adapters found in registry: $REGISTRY_FILE"
  exit 1
fi

for id in "${adapter_ids[@]}"; do
  base="$ADAPTERS_DIR/$id"
  adapter_file="$base/adapter.yml"
  mapping_file="$base/mapping.md"
  compatibility_file="$base/compatibility.yml"
  capabilities_fixture="$base/fixtures/capabilities.json"

  [[ -d "$base" ]] || log_error "Missing adapter directory: $base"
  [[ -f "$adapter_file" ]] || log_error "Missing adapter descriptor: $adapter_file"
  [[ -f "$mapping_file" ]] || log_error "Missing adapter mapping doc: $mapping_file"
  [[ -f "$compatibility_file" ]] || log_error "Missing adapter compatibility profile: $compatibility_file"
  [[ -f "$capabilities_fixture" ]] || log_error "Missing adapter capabilities fixture: $capabilities_fixture"

  if [[ -f "$adapter_file" ]]; then
    matches_file_regex "^id:[[:space:]]*$id$" "$adapter_file" || log_error "Adapter id mismatch in $adapter_file"
    matches_file_regex '^interop_contract_version:[[:space:]]*"?1\.0\.0"?$' "$adapter_file" || log_error "interop_contract_version must be 1.0.0 in $adapter_file"
  fi

  if [[ -f "$capabilities_fixture" ]]; then
    if ! jq -e --arg id "$id" '
      .mode == "adapter"
      and .adapter_id == $id
      and .interop_contract_version == "1.0.0"
      and (.capabilities.keyword.state | type == "string")
      and (.capabilities.semantic.state | type == "string")
      and (.capabilities.graph.state | type == "string")
      and (.capabilities.route_hierarchical.state | type == "string")
      and (.capabilities.route_graph_global.state | type == "string")
    ' "$capabilities_fixture" >/dev/null; then
      log_error "Capabilities fixture validation failed: $capabilities_fixture"
    fi
  fi

  if [[ -f "$adapter_file" && -f "$mapping_file" && -f "$compatibility_file" && -f "$capabilities_fixture" ]]; then
    log_ok "Adapter artifacts valid for '$id'"
  fi
done

if (( errors > 0 )); then
  echo "Adapter validation failed: $errors error(s)." >&2
  exit 1
fi

echo "Adapter validation passed: ${#adapter_ids[@]} adapter(s)."

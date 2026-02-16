#!/usr/bin/env bash
# validate-adapters.sh - Structural validation for flow adapter contracts.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SERVICE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
ADAPTERS_DIR="$SERVICE_DIR/adapters"
REGISTRY_FILE="$ADAPTERS_DIR/registry.yml"

errors=0

log_error() {
  echo "ERROR: $1" >&2
  errors=$((errors + 1))
}

log_ok() {
  echo "✓ $1"
}

if [[ ! -f "$REGISTRY_FILE" ]]; then
  log_error "Adapter registry not found: $REGISTRY_FILE"
  exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
  log_error "jq is required"
  exit 6
fi

default_adapter="$(awk '/^default_adapter:/ {print $2}' "$REGISTRY_FILE" | tr -d '"' | tr -d "'" | tr -d '[:space:]')"
if [[ "$default_adapter" != "native-harmony" ]]; then
  log_error "default_adapter must be native-harmony (found '$default_adapter')"
fi

mapfile -t adapter_ids < <(awk '
  /^[[:space:]]*-[[:space:]]id:[[:space:]]*/ {
    id = $3
    gsub(/["'\'' ]/, "", id)
    if (length(id) > 0) print id
  }
' "$REGISTRY_FILE")

if [[ ${#adapter_ids[@]} -lt 2 ]]; then
  log_error "Expected at least two adapters in registry; found ${#adapter_ids[@]}"
  exit 1
fi

required_adapters=("native-harmony" "langgraph-http")
for required in "${required_adapters[@]}"; do
  if ! printf '%s\n' "${adapter_ids[@]}" | rg -x "$required" >/dev/null 2>&1; then
    log_error "Missing required adapter in registry: $required"
  fi
done

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
    rg -n "^id:[[:space:]]*$id$" "$adapter_file" >/dev/null 2>&1 || log_error "Adapter id mismatch in $adapter_file"
    rg -n '^interop_contract_version:[[:space:]]*"?1\.0\.0"?$' "$adapter_file" >/dev/null 2>&1 || log_error "interop_contract_version must be 1.0.0 in $adapter_file"
  fi

  if [[ -f "$capabilities_fixture" ]]; then
    if ! jq -e --arg id "$id" '
      .mode == "adapter"
      and .adapter_id == $id
      and .interop_contract_version == "1.0.0"
      and (.capabilities.deterministic_run_id.state | type == "string")
      and (.capabilities.native_execution.state | type == "string")
      and (.capabilities.checkpoint_resume.state | type == "string")
      and (.capabilities.http_runtime_bridge.state | type == "string")
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

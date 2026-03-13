#!/usr/bin/env bash
# negotiate-capabilities.sh - Resolve native/adapter capabilities with deterministic fallback.

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
SERVICE_DIR="$(cd -- "$SCRIPT_DIR/.." && pwd)"
ADAPTERS_DIR="$SERVICE_DIR/adapters"

mode="native"
adapter_id=""
require_adapter_major=0
registry="$ADAPTERS_DIR/registry.yml"
native_fixture="$SERVICE_DIR/fixtures/native-capabilities.json"

usage() {
  cat <<USAGE
Usage: $0 [--mode native|adapter] [--adapter-id <id>] [--require-adapter-major <int>]

Resolves capability profile for native mode or an adapter.
Falls back deterministically to native mode for unavailable or stale adapters.
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --mode)
      mode="${2:-}"
      shift 2
      ;;
    --adapter-id)
      adapter_id="${2:-}"
      shift 2
      ;;
    --require-adapter-major)
      require_adapter_major="${2:-0}"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

if [[ "$mode" != "native" && "$mode" != "adapter" ]]; then
  echo "Invalid --mode: $mode" >&2
  exit 2
fi

if ! [[ "$require_adapter_major" =~ ^[0-9]+$ ]]; then
  echo "--require-adapter-major must be a non-negative integer" >&2
  exit 2
fi

if [[ ! -f "$native_fixture" ]]; then
  echo "Native capabilities fixture missing: $native_fixture" >&2
  exit 1
fi

emit_native_fallback() {
  local reason="$1"
  local requested_adapter="$2"

  node - "$native_fixture" "$reason" "$requested_adapter" <<'NODE'
const fs = require('fs');

const fixturePath = process.argv[2];
const reason = process.argv[3];
const adapterId = process.argv[4] || null;

const payload = JSON.parse(fs.readFileSync(fixturePath, 'utf8'));
payload.mode = 'native';
payload.generated_at = new Date().toISOString();
payload.fallback_reason = reason;
if (adapterId) payload.requested_adapter_id = adapterId;

console.log(JSON.stringify(payload, null, 2));
NODE
}

if [[ "$mode" == "native" ]]; then
  cat "$native_fixture"
  exit 0
fi

if [[ -z "$adapter_id" ]]; then
  echo "--adapter-id is required when --mode adapter" >&2
  exit 2
fi

if [[ ! -f "$registry" ]]; then
  emit_native_fallback "adapter-registry-missing" "$adapter_id"
  exit 0
fi

adapter_dir="$ADAPTERS_DIR/$adapter_id"
adapter_file="$adapter_dir/adapter.yml"
fixture_file="$adapter_dir/fixtures/capabilities.json"

if [[ ! -d "$adapter_dir" || ! -f "$adapter_file" || ! -f "$fixture_file" ]]; then
  emit_native_fallback "adapter-unavailable" "$adapter_id"
  exit 0
fi

adapter_version="$(awk '/^adapter_version:[[:space:]]*/ {print $2; exit}' "$adapter_file" | tr -d '"')"
if [[ -z "$adapter_version" ]]; then
  emit_native_fallback "adapter-version-missing" "$adapter_id"
  exit 0
fi

adapter_major="${adapter_version%%.*}"
if ! [[ "$adapter_major" =~ ^[0-9]+$ ]]; then
  emit_native_fallback "adapter-version-invalid" "$adapter_id"
  exit 0
fi

if (( adapter_major < require_adapter_major )); then
  emit_native_fallback "stale-adapter-version" "$adapter_id"
  exit 0
fi

cat "$fixture_file"

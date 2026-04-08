#!/usr/bin/env bash
# validate-filesystem-interfaces.sh - verify split filesystem interface contracts and runtime wiring.

set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SERVICES_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
FRAMEWORK_DIR="$(cd "$SERVICES_DIR/../../.." && pwd)"
OCTON_DIR="$(cd "$FRAMEWORK_DIR/.." && pwd)"
REPO_ROOT="$(cd "$OCTON_DIR/.." && pwd)"
SERVICE_DIR_SNAPSHOT="$SERVICES_DIR/interfaces/filesystem-snapshot"
SERVICE_DIR_DISCOVERY="$SERVICES_DIR/interfaces/filesystem-discovery"
SERVICE_DIR_WATCH="$SERVICES_DIR/interfaces/filesystem-watch"
COMMANDS_MANIFEST="$FRAMEWORK_DIR/capabilities/runtime/commands/manifest.yml"
COMMANDS_DIR="$FRAMEWORK_DIR/capabilities/runtime/commands"
SERVICES_MANIFEST="$FRAMEWORK_DIR/capabilities/runtime/services/manifest.yml"
SERVICES_REGISTRY="$FRAMEWORK_DIR/capabilities/runtime/services/registry.yml"
CONTEXT_INDEX="$OCTON_DIR/instance/cognition/context/index.yml"
RUNTIME_RUN="$OCTON_DIR/framework/engine/runtime/run"
export OCTON_RUNTIME_PREFER_SOURCE="${OCTON_RUNTIME_PREFER_SOURCE:-1}"
export OCTON_SUPPORT_TIER="${OCTON_SUPPORT_TIER:-observe-and-read}"
export OCTON_SUPPORT_MODEL_TIER="${OCTON_SUPPORT_MODEL_TIER:-repo-local-governed}"
export OCTON_SUPPORT_HOST_ADAPTER="${OCTON_SUPPORT_HOST_ADAPTER:-repo-shell}"
export OCTON_SUPPORT_MODEL_ADAPTER="${OCTON_SUPPORT_MODEL_ADAPTER:-repo-local-governed}"
export OCTON_SUPPORT_LANGUAGE_RESOURCE_TIER="${OCTON_SUPPORT_LANGUAGE_RESOURCE_TIER:-reference-owned}"
export OCTON_SUPPORT_LOCALE_TIER="${OCTON_SUPPORT_LOCALE_TIER:-english-primary}"
SMOKE_ROOT=".octon/framework/capabilities/runtime/services/interfaces"

errors=0
validate_slo="${FILESYSTEM_INTERFACES_VALIDATE_SLO:-0}"
validate_perf="${FILESYSTEM_INTERFACES_VALIDATE_PERF:-0}"
HAS_RG=false

if command -v rg >/dev/null 2>&1; then
  HAS_RG=true
fi

has_file_match() {
  local pattern="$1"
  shift

  if [[ "$HAS_RG" == "true" ]]; then
    rg -n "$pattern" "$@" >/dev/null 2>&1
    return $?
  fi

  grep -nE -- "$pattern" "$@" >/dev/null 2>&1
}

has_payload_match() {
  local pattern="$1"
  local payload="$2"

  if [[ "$HAS_RG" == "true" ]]; then
    rg -q "$pattern" <<<"$payload"
    return $?
  fi

  grep -Eq -- "$pattern" <<<"$payload"
}

check_file() {
  local f="$1"
  if [[ ! -f "$f" ]]; then
    echo "ERROR: missing file: $f"
    errors=$((errors + 1))
  fi
}

required_files=(
  "$SERVICE_DIR_SNAPSHOT/SERVICE.md"
  "$SERVICE_DIR_SNAPSHOT/contract.md"
  "$SERVICE_DIR_SNAPSHOT/schema/input.schema.json"
  "$SERVICE_DIR_SNAPSHOT/schema/output.schema.json"
  "$SERVICE_DIR_SNAPSHOT/rules/rules.yml"
  "$SERVICE_DIR_SNAPSHOT/contracts/invariants.md"
  "$SERVICE_DIR_SNAPSHOT/contracts/errors.yml"
  "$SERVICE_DIR_SNAPSHOT/contracts/slo-budgets.tsv"
  "$SERVICE_DIR_SNAPSHOT/contracts/perf-regression-baseline.tsv"
  "$SERVICE_DIR_SNAPSHOT/fixtures/benchmark-profile.tsv"
  "$SERVICE_DIR_DISCOVERY/SERVICE.md"
  "$SERVICE_DIR_DISCOVERY/contract.md"
  "$SERVICE_DIR_DISCOVERY/schema/input.schema.json"
  "$SERVICE_DIR_DISCOVERY/schema/output.schema.json"
  "$SERVICE_DIR_DISCOVERY/rules/rules.yml"
  "$SERVICE_DIR_DISCOVERY/contracts/invariants.md"
  "$SERVICE_DIR_DISCOVERY/contracts/errors.yml"
  "$SERVICE_DIR_WATCH/SERVICE.md"
  "$SERVICE_DIR_WATCH/contract.md"
  "$SERVICE_DIR_WATCH/schema/input.schema.json"
  "$SERVICE_DIR_WATCH/schema/output.schema.json"
  "$SERVICE_DIR_WATCH/rules/rules.yml"
  "$SERVICE_DIR_WATCH/contracts/invariants.md"
  "$SERVICE_DIR_WATCH/contracts/errors.yml"
  "$SERVICE_DIR_WATCH/fixtures/valid-watch-poll.json"
  "$SERVICES_DIR/_ops/scripts/build-filesystem-interfaces-benchmark-fixture.sh"
  "$SERVICES_DIR/_ops/scripts/download-filesystem-interfaces-slo-history.sh"
  "$SERVICES_DIR/_ops/scripts/test-filesystem-interfaces-integration.sh"
  "$SERVICES_DIR/_ops/scripts/test-filesystem-interfaces-slo.sh"
  "$SERVICES_DIR/_ops/scripts/test-filesystem-interfaces-perf-regression.sh"
  "$SERVICES_DIR/_ops/scripts/tune-filesystem-interfaces-slo-budgets.sh"
  "$REPO_ROOT/.github/workflows/filesystem-interfaces-perf-regression.yml"
)

for f in "${required_files[@]}"; do
  check_file "$f"
done

for service_id in filesystem-snapshot filesystem-discovery filesystem-watch; do
  if ! has_file_match "id: ${service_id}" "$SERVICES_MANIFEST"; then
    echo "ERROR: services manifest missing ${service_id} entry"
    errors=$((errors + 1))
  fi
done

for service_key in filesystem-snapshot filesystem-discovery filesystem-watch; do
  if ! has_file_match "^  ${service_key}:" "$SERVICES_REGISTRY"; then
    echo "ERROR: services registry missing ${service_key} entry"
    errors=$((errors + 1))
  fi
done

for cmd_id in snapshot-build snapshot-diff discover-start discover-expand discover-explain discover-resolve watch-poll; do
  if ! has_file_match "id: ${cmd_id}" "$COMMANDS_MANIFEST"; then
    echo "ERROR: commands manifest missing ${cmd_id} command"
    errors=$((errors + 1))
  fi
done

if ! has_file_match "entrypoint:[[:space:]]+engine/runtime/run tool interfaces/filesystem-snapshot" "$SERVICES_REGISTRY"; then
  echo "ERROR: services registry entrypoint is not runtime-direct for filesystem-snapshot"
  errors=$((errors + 1))
fi

if ! has_file_match "entrypoint:[[:space:]]+engine/runtime/run tool interfaces/filesystem-discovery" "$SERVICES_REGISTRY"; then
  echo "ERROR: services registry entrypoint is not runtime-direct for filesystem-discovery"
  errors=$((errors + 1))
fi

if ! has_file_match "entrypoint:[[:space:]]+engine/runtime/run tool interfaces/filesystem-watch" "$SERVICES_REGISTRY"; then
  echo "ERROR: services registry entrypoint is not runtime-direct for filesystem-watch"
  errors=$((errors + 1))
fi

runtime_command_docs=(
  "$COMMANDS_DIR/snapshot-build.md|interfaces/filesystem-snapshot"
  "$COMMANDS_DIR/snapshot-diff.md|interfaces/filesystem-snapshot"
  "$COMMANDS_DIR/discover-start.md|interfaces/filesystem-discovery"
  "$COMMANDS_DIR/discover-expand.md|interfaces/filesystem-discovery"
  "$COMMANDS_DIR/discover-explain.md|interfaces/filesystem-discovery"
  "$COMMANDS_DIR/discover-resolve.md|interfaces/filesystem-discovery"
  "$COMMANDS_DIR/watch-poll.md|interfaces/filesystem-watch"
)

for mapped in "${runtime_command_docs[@]}"; do
  cmd_doc="${mapped%%|*}"
  runtime_service="${mapped##*|}"
  if ! has_file_match "engine/runtime/run tool ${runtime_service}" "$cmd_doc"; then
    echo "ERROR: command doc is not runtime-direct for ${runtime_service}: $cmd_doc"
    errors=$((errors + 1))
  fi
  if has_file_match "impl/(filesystem-interfaces|snapshot-build|snapshot-diff)\\.sh" "$cmd_doc"; then
    echo "ERROR: command doc still references legacy shell wrapper: $cmd_doc"
    errors=$((errors + 1))
  fi
done

if ! has_file_match "id: filesystem-interfaces-interop" "$CONTEXT_INDEX"; then
  echo "ERROR: context index missing filesystem-interfaces-interop entry"
  errors=$((errors + 1))
fi

# Smoke test snapshot build + current pointer via writer-plane service.
SMOKE_PAYLOAD="$(printf '{"root":"%s","set_current":true}' "$SMOKE_ROOT")"
SMOKE_OUT="$("$RUNTIME_RUN" tool interfaces/filesystem-snapshot snapshot.build --json "$SMOKE_PAYLOAD")"
if ! has_payload_match '"ok"[[:space:]]*:[[:space:]]*true' "$SMOKE_OUT" || \
   ! has_payload_match '"snapshot_id"[[:space:]]*:[[:space:]]*"snap-[^"]+"' "$SMOKE_OUT"; then
  echo "ERROR: snapshot-build smoke test failed"
  errors=$((errors + 1))
fi

# Smoke test discovery query-plane service invocation.
DISCOVER_OUT="$("$RUNTIME_RUN" tool interfaces/filesystem-discovery discover.start --json '{"query":"octon","limit":5}')"
if ! has_payload_match '"frontier_node_ids"[[:space:]]*:' "$DISCOVER_OUT"; then
  echo "ERROR: discover-start smoke test failed"
  errors=$((errors + 1))
fi

# Smoke test watch polling service invocation.
WATCH_PAYLOAD="$(printf '{"root":"%s","state_key":"filesystem-watch:validate","max_events":25,"max_files":100000}' "$SMOKE_ROOT")"
WATCH_OUT="$("$RUNTIME_RUN" tool interfaces/filesystem-watch watch.poll --json "$WATCH_PAYLOAD")"
if ! has_payload_match '"cursor"[[:space:]]*:[[:space:]]*"watch-[a-f0-9]{16}"' "$WATCH_OUT"; then
  echo "ERROR: watch-poll smoke test failed"
  errors=$((errors + 1))
fi

# Determinism and runtime-state exclusion regression check.
if ! bash "$SERVICES_DIR/_ops/scripts/test-filesystem-interfaces-determinism.sh" >/dev/null 2>&1; then
  echo "ERROR: filesystem interfaces determinism regression"
  errors=$((errors + 1))
fi

# Runtime integration regression check.
if ! bash "$SERVICES_DIR/_ops/scripts/test-filesystem-interfaces-integration.sh" >/dev/null 2>&1; then
  echo "ERROR: filesystem interfaces integration regression"
  errors=$((errors + 1))
fi

# Optional SLO gate (enabled when FILESYSTEM_INTERFACES_VALIDATE_SLO=1).
if [[ "$validate_slo" == "1" ]]; then
  VALIDATE_TMP_ROOT="${TMPDIR:-/tmp}/filesystem-interfaces-validate-$$"
  mkdir -p "$VALIDATE_TMP_ROOT"
  slo_ok=0
  for attempt in 1 2; do
    if bash "$SERVICES_DIR/_ops/scripts/test-filesystem-interfaces-slo.sh" \
        --profile ci \
        --no-report \
        --raw-out "$VALIDATE_TMP_ROOT/slo.raw.tsv" \
        --summary-out "$VALIDATE_TMP_ROOT/slo.summary.tsv" >/dev/null 2>&1; then
      slo_ok=1
      break
    fi
  done
  if [[ "$slo_ok" -ne 1 ]]; then
    echo "ERROR: filesystem interfaces SLO regression"
    errors=$((errors + 1))
  fi
  rm -rf "$VALIDATE_TMP_ROOT"
fi

# Optional perf regression gate (enabled when FILESYSTEM_INTERFACES_VALIDATE_PERF=1).
if [[ "$validate_perf" == "1" ]]; then
  VALIDATE_TMP_ROOT="${TMPDIR:-/tmp}/filesystem-interfaces-validate-$$"
  mkdir -p "$VALIDATE_TMP_ROOT"
  perf_ok=0
  for attempt in 1 2; do
    if bash "$SERVICES_DIR/_ops/scripts/test-filesystem-interfaces-perf-regression.sh" \
        --profile ci \
        --no-report \
        --raw-out "$VALIDATE_TMP_ROOT/perf.raw.tsv" \
        --summary-out "$VALIDATE_TMP_ROOT/perf.summary.tsv" >/dev/null 2>&1; then
      perf_ok=1
      break
    fi
  done
  if [[ "$perf_ok" -ne 1 ]]; then
    echo "ERROR: filesystem interfaces perf regression"
    errors=$((errors + 1))
  fi
  rm -rf "$VALIDATE_TMP_ROOT"
fi

if [[ "$errors" -gt 0 ]]; then
  echo "filesystem interface validation failed with $errors error(s)."
  exit 1
fi

echo "filesystem interface validation passed"

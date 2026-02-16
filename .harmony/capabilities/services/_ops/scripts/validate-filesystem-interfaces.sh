#!/usr/bin/env bash
# validate-filesystem-interfaces.sh - verify split filesystem interface contracts and runtime wiring.

set -o pipefail

HARMONY_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
REPO_ROOT="$(cd "$HARMONY_DIR/.." && pwd)"
SERVICE_DIR_SNAPSHOT="$HARMONY_DIR/capabilities/services/interfaces/filesystem-snapshot"
SERVICE_DIR_DISCOVERY="$HARMONY_DIR/capabilities/services/interfaces/filesystem-discovery"
SERVICE_DIR_WATCH="$HARMONY_DIR/capabilities/services/interfaces/filesystem-watch"
COMMANDS_MANIFEST="$HARMONY_DIR/capabilities/commands/manifest.yml"
COMMANDS_DIR="$HARMONY_DIR/capabilities/commands"
SERVICES_MANIFEST="$HARMONY_DIR/capabilities/services/manifest.yml"
SERVICES_REGISTRY="$HARMONY_DIR/capabilities/services/registry.yml"
CONTEXT_INDEX="$HARMONY_DIR/cognition/context/index.yml"
RUNTIME_RUN="$HARMONY_DIR/runtime/run"

errors=0
validate_slo="${FILESYSTEM_INTERFACES_VALIDATE_SLO:-0}"
validate_perf="${FILESYSTEM_INTERFACES_VALIDATE_PERF:-0}"

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
  "$HARMONY_DIR/capabilities/services/_ops/scripts/build-filesystem-interfaces-benchmark-fixture.sh"
  "$HARMONY_DIR/capabilities/services/_ops/scripts/download-filesystem-interfaces-slo-history.sh"
  "$HARMONY_DIR/capabilities/services/_ops/scripts/test-filesystem-interfaces-integration.sh"
  "$HARMONY_DIR/capabilities/services/_ops/scripts/test-filesystem-interfaces-slo.sh"
  "$HARMONY_DIR/capabilities/services/_ops/scripts/test-filesystem-interfaces-perf-regression.sh"
  "$HARMONY_DIR/capabilities/services/_ops/scripts/tune-filesystem-interfaces-slo-budgets.sh"
  "$REPO_ROOT/.github/workflows/filesystem-interfaces-perf-regression.yml"
)

for f in "${required_files[@]}"; do
  check_file "$f"
done

for service_id in filesystem-snapshot filesystem-discovery filesystem-watch; do
  if ! rg -n "id: ${service_id}" "$SERVICES_MANIFEST" >/dev/null 2>&1; then
    echo "ERROR: services manifest missing ${service_id} entry"
    errors=$((errors + 1))
  fi
done

for service_key in filesystem-snapshot filesystem-discovery filesystem-watch; do
  if ! rg -n "^  ${service_key}:" "$SERVICES_REGISTRY" >/dev/null 2>&1; then
    echo "ERROR: services registry missing ${service_key} entry"
    errors=$((errors + 1))
  fi
done

for cmd_id in snapshot-build snapshot-diff discover-start discover-expand discover-explain discover-resolve watch-poll; do
  if ! rg -n "id: ${cmd_id}" "$COMMANDS_MANIFEST" >/dev/null 2>&1; then
    echo "ERROR: commands manifest missing ${cmd_id} command"
    errors=$((errors + 1))
  fi
done

if ! rg -n "entrypoint:[[:space:]]+runtime/run tool interfaces/filesystem-snapshot" "$SERVICES_REGISTRY" >/dev/null 2>&1; then
  echo "ERROR: services registry entrypoint is not runtime-direct for filesystem-snapshot"
  errors=$((errors + 1))
fi

if ! rg -n "entrypoint:[[:space:]]+runtime/run tool interfaces/filesystem-discovery" "$SERVICES_REGISTRY" >/dev/null 2>&1; then
  echo "ERROR: services registry entrypoint is not runtime-direct for filesystem-discovery"
  errors=$((errors + 1))
fi

if ! rg -n "entrypoint:[[:space:]]+runtime/run tool interfaces/filesystem-watch" "$SERVICES_REGISTRY" >/dev/null 2>&1; then
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
  if ! rg -n "runtime/run tool ${runtime_service}" "$cmd_doc" >/dev/null 2>&1; then
    echo "ERROR: command doc is not runtime-direct for ${runtime_service}: $cmd_doc"
    errors=$((errors + 1))
  fi
  if rg -n "impl/(filesystem-interfaces|snapshot-build|snapshot-diff)\\.sh" "$cmd_doc" >/dev/null 2>&1; then
    echo "ERROR: command doc still references legacy shell wrapper: $cmd_doc"
    errors=$((errors + 1))
  fi
done

if ! rg -n "id: filesystem-interfaces-interop" "$CONTEXT_INDEX" >/dev/null 2>&1; then
  echo "ERROR: context index missing filesystem-interfaces-interop entry"
  errors=$((errors + 1))
fi

# Smoke test snapshot build + current pointer via writer-plane service.
SMOKE_OUT="$("$RUNTIME_RUN" tool interfaces/filesystem-snapshot snapshot.build --json '{"root":".","set_current":true}')"
if ! rg -q '"ok"[[:space:]]*:[[:space:]]*true' <<<"$SMOKE_OUT" || \
   ! rg -q '"snapshot_id"[[:space:]]*:[[:space:]]*"snap-[^"]+"' <<<"$SMOKE_OUT"; then
  echo "ERROR: snapshot-build smoke test failed"
  errors=$((errors + 1))
fi

# Smoke test discovery query-plane service invocation.
DISCOVER_OUT="$("$RUNTIME_RUN" tool interfaces/filesystem-discovery discover.start --json '{"query":"harmony","limit":5}')"
if ! rg -q '"frontier_node_ids"[[:space:]]*:' <<<"$DISCOVER_OUT"; then
  echo "ERROR: discover-start smoke test failed"
  errors=$((errors + 1))
fi

# Smoke test watch polling service invocation.
WATCH_OUT="$("$RUNTIME_RUN" tool interfaces/filesystem-watch watch.poll --json '{"root":".","state_key":"filesystem-watch:validate","max_events":25,"max_files":50000}')"
if ! rg -q '"cursor"[[:space:]]*:[[:space:]]*"watch-[a-f0-9]{16}"' <<<"$WATCH_OUT"; then
  echo "ERROR: watch-poll smoke test failed"
  errors=$((errors + 1))
fi

# Determinism and runtime-state exclusion regression check.
if ! bash "$HARMONY_DIR/capabilities/services/_ops/scripts/test-filesystem-interfaces-determinism.sh" >/dev/null 2>&1; then
  echo "ERROR: filesystem interfaces determinism regression"
  errors=$((errors + 1))
fi

# Runtime integration regression check.
if ! bash "$HARMONY_DIR/capabilities/services/_ops/scripts/test-filesystem-interfaces-integration.sh" >/dev/null 2>&1; then
  echo "ERROR: filesystem interfaces integration regression"
  errors=$((errors + 1))
fi

# Optional SLO gate (enabled when FILESYSTEM_INTERFACES_VALIDATE_SLO=1).
if [[ "$validate_slo" == "1" ]]; then
  VALIDATE_TMP_ROOT="${TMPDIR:-/tmp}/filesystem-interfaces-validate-$$"
  mkdir -p "$VALIDATE_TMP_ROOT"
  slo_ok=0
  for attempt in 1 2; do
    if bash "$HARMONY_DIR/capabilities/services/_ops/scripts/test-filesystem-interfaces-slo.sh" \
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
    if bash "$HARMONY_DIR/capabilities/services/_ops/scripts/test-filesystem-interfaces-perf-regression.sh" \
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

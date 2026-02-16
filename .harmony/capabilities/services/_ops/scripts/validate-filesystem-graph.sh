#!/usr/bin/env bash
# validate-filesystem-graph.sh - verify filesystem-graph contract and wiring.

set -o pipefail

HARMONY_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
SERVICE_DIR="$HARMONY_DIR/capabilities/services/interfaces/filesystem-graph"
COMMANDS_MANIFEST="$HARMONY_DIR/capabilities/commands/manifest.yml"
COMMANDS_DIR="$HARMONY_DIR/capabilities/commands"
SERVICES_MANIFEST="$HARMONY_DIR/capabilities/services/manifest.yml"
SERVICES_REGISTRY="$HARMONY_DIR/capabilities/services/registry.yml"
CONTEXT_INDEX="$HARMONY_DIR/cognition/context/index.yml"
RUNTIME_RUN="$HARMONY_DIR/runtime/run"

errors=0

check_file() {
  local f="$1"
  if [[ ! -f "$f" ]]; then
    echo "ERROR: missing file: $f"
    errors=$((errors + 1))
  fi
}

required_files=(
  "$SERVICE_DIR/SERVICE.md"
  "$SERVICE_DIR/contract.md"
  "$SERVICE_DIR/schema/input.schema.json"
  "$SERVICE_DIR/schema/output.schema.json"
  "$SERVICE_DIR/schema/node.schema.json"
  "$SERVICE_DIR/schema/edge.schema.json"
  "$SERVICE_DIR/schema/snapshot-manifest.schema.json"
  "$SERVICE_DIR/rules/rules.yml"
  "$SERVICE_DIR/contracts/invariants.md"
  "$SERVICE_DIR/contracts/errors.yml"
  "$SERVICE_DIR/contracts/slo-budgets.tsv"
  "$SERVICE_DIR/fixtures/benchmark-profile.tsv"
  "$HARMONY_DIR/capabilities/services/_ops/scripts/build-filesystem-graph-benchmark-fixture.sh"
  "$HARMONY_DIR/capabilities/services/_ops/scripts/download-filesystem-graph-slo-history.sh"
  "$HARMONY_DIR/capabilities/services/_ops/scripts/test-filesystem-graph-slo.sh"
  "$HARMONY_DIR/capabilities/services/_ops/scripts/tune-filesystem-graph-slo-budgets.sh"
)

for f in "${required_files[@]}"; do
  check_file "$f"
done

if ! rg -n "id: filesystem-graph" "$SERVICES_MANIFEST" >/dev/null 2>&1; then
  echo "ERROR: services manifest missing filesystem-graph entry"
  errors=$((errors + 1))
fi

if ! rg -n "^  filesystem-graph:" "$SERVICES_REGISTRY" >/dev/null 2>&1; then
  echo "ERROR: services registry missing filesystem-graph entry"
  errors=$((errors + 1))
fi

if ! rg -n "id: filesystem-graph" "$COMMANDS_MANIFEST" >/dev/null 2>&1; then
  echo "ERROR: commands manifest missing filesystem-graph command"
  errors=$((errors + 1))
fi

if ! rg -n "entrypoint:[[:space:]]+runtime/run tool interfaces/filesystem-graph" "$SERVICES_REGISTRY" >/dev/null 2>&1; then
  echo "ERROR: services registry entrypoint is not runtime-direct for filesystem-graph"
  errors=$((errors + 1))
fi

runtime_command_docs=(
  "$COMMANDS_DIR/filesystem-graph.md"
  "$COMMANDS_DIR/snapshot-build.md"
  "$COMMANDS_DIR/snapshot-diff.md"
  "$COMMANDS_DIR/discover-start.md"
  "$COMMANDS_DIR/discover-expand.md"
  "$COMMANDS_DIR/discover-explain.md"
  "$COMMANDS_DIR/discover-resolve.md"
)

for cmd_doc in "${runtime_command_docs[@]}"; do
  if ! rg -n "runtime/run tool interfaces/filesystem-graph" "$cmd_doc" >/dev/null 2>&1; then
    echo "ERROR: command doc is not runtime-direct: $cmd_doc"
    errors=$((errors + 1))
  fi
  if rg -n "impl/(filesystem-graph|snapshot-build|snapshot-diff)\\.sh" "$cmd_doc" >/dev/null 2>&1; then
    echo "ERROR: command doc still references legacy shell wrapper: $cmd_doc"
    errors=$((errors + 1))
  fi
done

if ! rg -n "id: filesystem-graph-interop" "$CONTEXT_INDEX" >/dev/null 2>&1; then
  echo "ERROR: context index missing filesystem-graph-interop entry"
  errors=$((errors + 1))
fi

# Smoke test snapshot build + current pointer via runtime service invocation.
SMOKE_OUT="$("$RUNTIME_RUN" tool interfaces/filesystem-graph snapshot.build --json '{"root":".","set_current":true}')"
if ! rg -q '"ok"[[:space:]]*:[[:space:]]*true' <<<"$SMOKE_OUT" || \
   ! rg -q '"snapshot_id"[[:space:]]*:[[:space:]]*"snap-[^"]+"' <<<"$SMOKE_OUT"; then
  echo "ERROR: snapshot-build smoke test failed"
  errors=$((errors + 1))
fi

# Determinism and runtime-state exclusion regression check.
if ! bash "$HARMONY_DIR/capabilities/services/_ops/scripts/test-filesystem-graph-determinism.sh" >/dev/null 2>&1; then
  echo "ERROR: filesystem-graph determinism regression"
  errors=$((errors + 1))
fi

# Optional SLO gate (enabled when FILESYSTEM_GRAPH_VALIDATE_SLO=1).
if [[ "${FILESYSTEM_GRAPH_VALIDATE_SLO:-0}" == "1" ]]; then
  if ! bash "$HARMONY_DIR/capabilities/services/_ops/scripts/test-filesystem-graph-slo.sh" --profile ci >/dev/null 2>&1; then
    echo "ERROR: filesystem-graph SLO regression"
    errors=$((errors + 1))
  fi
fi

if [[ "$errors" -gt 0 ]]; then
  echo "filesystem-graph validation failed with $errors error(s)."
  exit 1
fi

echo "filesystem-graph validation passed"

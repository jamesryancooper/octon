#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd -- "$SCRIPT_DIR/../../../../../.." && pwd)"
WORKFLOW_ROOT="$ROOT_DIR/.octon/framework/orchestration/runtime/workflows/audit"
MANIFEST="$ROOT_DIR/.octon/framework/orchestration/runtime/workflows/manifest.yml"
REGISTRY="$ROOT_DIR/.octon/framework/orchestration/runtime/workflows/registry.yml"
errors=0

pass() { printf '[OK] %s\n' "$1"; }
fail() { printf '[ERROR] %s\n' "$1" >&2; errors=$((errors + 1)); }

for workflow in \
  pre-integration-architecture-review \
  post-integration-architecture-review \
  current-state-mechanism-architecture-review \
  architecture-readiness-audit; do
  dir="$WORKFLOW_ROOT/$workflow"
  [[ -d "$dir" ]] && pass "workflow directory exists: $workflow" || fail "workflow directory exists: $workflow"
  [[ -f "$dir/workflow.yml" ]] && pass "workflow contract exists: $workflow" || fail "workflow contract exists: $workflow"
  if [[ -f "$dir/workflow.yml" ]] && yq -e '.' "$dir/workflow.yml" >/dev/null 2>&1; then
    pass "workflow contract parses: $workflow"
    [[ "$(yq -r '.name // ""' "$dir/workflow.yml")" == "$workflow" ]] && pass "workflow contract name matches directory: $workflow" || fail "workflow contract name matches directory: $workflow"
    [[ "$(yq -r '.schema_version // ""' "$dir/workflow.yml")" == "workflow-contract-v2" ]] && pass "workflow schema current: $workflow" || fail "workflow schema current: $workflow"
  else
    fail "workflow contract parses: $workflow"
  fi
  yq -e ".workflows[]? | select(.id == \"$workflow\" and .path == \"audit/$workflow/\")" "$MANIFEST" >/dev/null 2>&1 && pass "workflow manifest registers $workflow" || fail "workflow manifest registers $workflow"
  yq -e ".workflows.\"$workflow\"" "$REGISTRY" >/dev/null 2>&1 && pass "workflow registry registers $workflow" || fail "workflow registry registers $workflow"
done

[[ ! -e "$WORKFLOW_ROOT/audit-architecture-readiness" ]] && pass "legacy audit-architecture-readiness workflow route absent" || fail "legacy audit-architecture-readiness workflow route absent"

printf 'Validation summary: errors=%s\n' "$errors"
[[ "$errors" -eq 0 ]]

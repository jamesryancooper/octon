#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
EXECUTION_ROLES_DIR="$(cd -- "$SCRIPT_DIR/../../.." && pwd)"
FRAMEWORK_DIR="$(cd -- "$EXECUTION_ROLES_DIR/.." && pwd)"
OCTON_DIR="$(cd -- "$FRAMEWORK_DIR/.." && pwd)"
ROOT_DIR="$(cd -- "$OCTON_DIR/.." && pwd)"

errors=0

fail() {
  echo "[ERROR] $1"
  errors=$((errors + 1))
}

pass() {
  echo "[OK] $1"
}

require_file() {
  local file="$1"
  if [[ -f "$file" ]]; then
    pass "found file: ${file#$ROOT_DIR/}"
  else
    fail "missing file: ${file#$ROOT_DIR/}"
  fi
}

echo "== Execution Roles Validation =="

require_file "$EXECUTION_ROLES_DIR/manifest.yml"
require_file "$EXECUTION_ROLES_DIR/registry.yml"
require_file "$EXECUTION_ROLES_DIR/runtime/orchestrator/ROLE.md"
require_file "$EXECUTION_ROLES_DIR/runtime/orchestrator/role.yml"
require_file "$EXECUTION_ROLES_DIR/runtime/specialists/registry.yml"
require_file "$EXECUTION_ROLES_DIR/runtime/verifiers/registry.yml"
require_file "$EXECUTION_ROLES_DIR/runtime/composition-profiles/registry.yml"
require_file "$EXECUTION_ROLES_DIR/governance/DELEGATION.md"
require_file "$EXECUTION_ROLES_DIR/governance/MEMORY.md"

if rg -n 'framework/agency|runtime/agents/|runtime/assistants/|runtime/teams/' \
  "$EXECUTION_ROLES_DIR/manifest.yml" \
  "$EXECUTION_ROLES_DIR/registry.yml" \
  "$EXECUTION_ROLES_DIR/governance" \
  "$EXECUTION_ROLES_DIR/runtime" >/dev/null 2>&1; then
  fail "legacy agency paths remain inside execution-roles subtree"
else
  pass "execution-roles subtree does not reference legacy runtime path families"
fi

if rg -n '\bagent\b|\bassistant\b|\bteam\b' \
  "$EXECUTION_ROLES_DIR/runtime/orchestrator/ROLE.md" \
  "$EXECUTION_ROLES_DIR/runtime/specialists" \
  "$EXECUTION_ROLES_DIR/runtime/verifiers" \
  "$EXECUTION_ROLES_DIR/runtime/composition-profiles" >/dev/null 2>&1; then
  fail "legacy role nouns remain in canonical execution-role contracts"
else
  pass "canonical execution-role contracts use only final role nouns"
fi

echo "Validation summary: errors=$errors"
[[ $errors -eq 0 ]]

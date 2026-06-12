#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd -- "$SCRIPT_DIR/../../../../../.." && pwd)"
SKILL_MANIFEST="$ROOT_DIR/.octon/framework/capabilities/runtime/skills/manifest.yml"
SKILL_REGISTRY="$ROOT_DIR/.octon/framework/capabilities/runtime/skills/registry.yml"
COMMAND_MANIFEST="$ROOT_DIR/.octon/framework/capabilities/runtime/commands/manifest.yml"
SKILL_ROOT="$ROOT_DIR/.octon/framework/capabilities/runtime/skills/audit"
COMMAND_ROOT="$ROOT_DIR/.octon/framework/capabilities/runtime/commands"
errors=0

pass() { printf '[OK] %s\n' "$1"; }
fail() { printf '[ERROR] %s\n' "$1" >&2; errors=$((errors + 1)); }

for id in \
  pre-integration-architecture-review \
  post-integration-architecture-review \
  current-state-mechanism-architecture-review \
  architecture-readiness-audit; do
  [[ -f "$SKILL_ROOT/$id/SKILL.md" ]] && pass "skill exists: $id" || fail "skill exists: $id"
  yq -e ".skills[]? | select(.id == \"$id\" and .path == \"audit/$id/\")" "$SKILL_MANIFEST" >/dev/null 2>&1 && pass "skill manifest registers $id" || fail "skill manifest registers $id"
  yq -e ".skills.\"$id\"" "$SKILL_REGISTRY" >/dev/null 2>&1 && pass "skill registry registers $id" || fail "skill registry registers $id"
  if [[ "$id" != "architecture-readiness-audit" ]]; then
    [[ -f "$COMMAND_ROOT/$id.md" ]] && pass "command exists: $id" || fail "command exists: $id"
    yq -e ".commands[]? | select(.id == \"$id\" and .path == \"$id.md\")" "$COMMAND_MANIFEST" >/dev/null 2>&1 && pass "command manifest registers $id" || fail "command manifest registers $id"
    rg -Fq "/.octon/framework/orchestration/runtime/workflows/audit/$id/" "$SKILL_ROOT/$id/SKILL.md" && pass "skill points to workflow: $id" || fail "skill points to workflow: $id"
    rg -Fq "The workflow contract is the execution authority" "$SKILL_ROOT/$id/SKILL.md" && pass "skill keeps workflow authority boundary: $id" || fail "skill keeps workflow authority boundary: $id"
  fi
done

printf 'Validation summary: errors=%s\n' "$errors"
[[ "$errors" -eq 0 ]]

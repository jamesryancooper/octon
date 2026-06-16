#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd -- "$SCRIPT_DIR/../../../../../.." && pwd)"

if [[ "${1:-}" == "--root" ]]; then
  ROOT_DIR="$(cd -- "$2" && pwd)"
  shift 2
fi

SKILL_MANIFEST="$ROOT_DIR/.octon/framework/capabilities/runtime/skills/manifest.yml"
SKILL_REGISTRY="$ROOT_DIR/.octon/framework/capabilities/runtime/skills/registry.yml"
COMMAND_MANIFEST="$ROOT_DIR/.octon/framework/capabilities/runtime/commands/manifest.yml"
SKILL_ROOT="$ROOT_DIR/.octon/framework/capabilities/runtime/skills/audit"
COMMAND_ROOT="$ROOT_DIR/.octon/framework/capabilities/runtime/commands"
NAMING="$ROOT_DIR/.octon/framework/cognition/practices/methodology/architectural-review/naming.yml"
errors=0

pass() { printf '[OK] %s\n' "$1"; }
fail() { printf '[ERROR] %s\n' "$1" >&2; errors=$((errors + 1)); }

require_skill() {
  local id="$1"
  [[ -f "$SKILL_ROOT/$id/SKILL.md" ]] && pass "skill exists: $id" || fail "skill exists: $id"
  yq -e ".skills[]? | select(.id == \"$id\" and .path == \"audit/$id/\")" "$SKILL_MANIFEST" >/dev/null 2>&1 && pass "skill manifest registers $id" || fail "skill manifest registers $id"
  yq -e ".skills.\"$id\"" "$SKILL_REGISTRY" >/dev/null 2>&1 && pass "skill registry registers $id" || fail "skill registry registers $id"
}

require_command() {
  local id="$1"
  [[ -f "$COMMAND_ROOT/$id.md" ]] && pass "command exists: $id" || fail "command exists: $id"
  yq -e ".commands[]? | select(.id == \"$id\" and .path == \"$id.md\")" "$COMMAND_MANIFEST" >/dev/null 2>&1 && pass "command manifest registers $id" || fail "command manifest registers $id"
}

require_alias() {
  local canonical="$1" alias="$2"
  yq -e ".canonical_modes[]? | select(.slug == \"$canonical\") | .invocation_aliases[]? | select(.alias == \"$alias\" and .status == \"active\")" "$NAMING" >/dev/null 2>&1 \
    && pass "canonical mode alias mapped: $canonical -> $alias" \
    || fail "canonical mode alias mapped: $canonical -> $alias"
}

for id in \
  pre-integration-architecture-review \
  post-integration-architecture-review \
  current-state-mechanism-architecture-review \
  architecture-readiness-audit; do
  require_skill "$id"
  require_command "$id"
  if [[ "$id" != "architecture-readiness-audit" ]]; then
    rg -Fq "/.octon/framework/orchestration/runtime/workflows/audit/$id/" "$SKILL_ROOT/$id/SKILL.md" && pass "skill points to workflow: $id" || fail "skill points to workflow: $id"
    rg -Fq "The workflow contract is the execution authority" "$SKILL_ROOT/$id/SKILL.md" && pass "skill keeps workflow authority boundary: $id" || fail "skill keeps workflow authority boundary: $id"
  fi
done

require_skill "audit-domain-architecture"
require_command "audit-domain-architecture"
require_alias "domain-architecture-audit" "audit-domain-architecture"
rg -Fq "canonical Architectural Review Mechanism mode \`domain-architecture-audit\`" "$COMMAND_ROOT/audit-domain-architecture.md" \
  && pass "domain command documents canonical alias" \
  || fail "domain command documents canonical alias"

require_skill "audit-surface-architecture"
require_command "audit-surface-architecture"
require_alias "surface-architecture-audit" "audit-surface-architecture"
rg -Fq "canonical Architectural Review Mechanism mode \`surface-architecture-audit\`" "$COMMAND_ROOT/audit-surface-architecture.md" \
  && pass "surface command documents canonical alias" \
  || fail "surface command documents canonical alias"

rg -Fq "does not restore the retired readiness-audit alias" "$COMMAND_ROOT/architecture-readiness-audit.md" \
  && pass "readiness command documents retired alias boundary" \
  || fail "readiness command documents retired alias boundary"

printf 'Validation summary: errors=%s\n' "$errors"
[[ "$errors" -eq 0 ]]

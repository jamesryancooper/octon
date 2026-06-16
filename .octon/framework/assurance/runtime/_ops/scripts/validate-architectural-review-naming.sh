#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd -- "$SCRIPT_DIR/../../../../../.." && pwd)"

if [[ "${1:-}" == "--root" ]]; then
  ROOT_DIR="$(cd -- "$2" && pwd)"
  shift 2
fi

NAMING="$ROOT_DIR/.octon/framework/cognition/practices/methodology/architectural-review/naming.yml"
errors=0

pass() { printf '[OK] %s\n' "$1"; }
fail() { printf '[ERROR] %s\n' "$1" >&2; errors=$((errors + 1)); }

[[ -f "$NAMING" ]] && pass "architectural review naming model exists" || fail "architectural review naming model exists"
if [[ -f "$NAMING" ]] && yq -e '.' "$NAMING" >/dev/null 2>&1; then
  pass "architectural review naming model parses"
else
  fail "architectural review naming model parses"
fi

for slug in \
  pre-integration-architecture-review \
  post-integration-architecture-review \
  current-state-mechanism-architecture-review \
  architecture-readiness-audit \
  domain-architecture-audit \
  surface-architecture-audit \
  architecture-revision-packet \
  lifecycle-postmortem-evaluator; do
  yq -e ".canonical_modes[]? | select(.slug == \"$slug\")" "$NAMING" >/dev/null 2>&1 && pass "canonical slug declared: $slug" || fail "canonical slug declared: $slug"
done

require_active_alias() {
  local canonical="$1" alias="$2"
  yq -e ".canonical_modes[]? | select(.slug == \"$canonical\") | .invocation_aliases[]? | select(.alias == \"$alias\" and .status == \"active\")" "$NAMING" >/dev/null 2>&1 \
    && pass "active invocation alias declared: $canonical -> $alias" \
    || fail "active invocation alias declared: $canonical -> $alias"
}

require_command_facade() {
  local canonical="$1" command="$2"
  yq -e ".canonical_modes[]? | select(.slug == \"$canonical\") | .command_facades[]? | select(. == \"$command\")" "$NAMING" >/dev/null 2>&1 \
    && pass "command facade declared: $canonical -> $command" \
    || fail "command facade declared: $canonical -> $command"
}

require_command_facade "architecture-readiness-audit" "architecture-readiness-audit"
require_active_alias "domain-architecture-audit" "audit-domain-architecture"
require_command_facade "domain-architecture-audit" "audit-domain-architecture"
require_active_alias "surface-architecture-audit" "audit-surface-architecture"
require_command_facade "surface-architecture-audit" "audit-surface-architecture"

yq -e '.legacy_aliases[]? | select(.alias == "audit-architecture-readiness" and .canonical == "architecture-readiness-audit" and .status == "retired" and .permanent_compatibility == false)' "$NAMING" >/dev/null 2>&1 \
  && pass "legacy audit-architecture-readiness alias remains retired" \
  || fail "legacy audit-architecture-readiness alias remains retired"

[[ -d "$ROOT_DIR/.octon/framework/orchestration/runtime/workflows/audit/architecture-readiness-audit" ]] && pass "canonical architecture-readiness-audit workflow directory exists" || fail "canonical architecture-readiness-audit workflow directory exists"
[[ ! -e "$ROOT_DIR/.octon/framework/orchestration/runtime/workflows/audit/audit-architecture-readiness" ]] && pass "legacy audit-architecture-readiness workflow directory absent" || fail "legacy audit-architecture-readiness workflow directory absent"
[[ -d "$ROOT_DIR/.octon/framework/capabilities/runtime/skills/audit/architecture-readiness-audit" ]] && pass "canonical architecture-readiness-audit skill directory exists" || fail "canonical architecture-readiness-audit skill directory exists"
[[ ! -e "$ROOT_DIR/.octon/framework/capabilities/runtime/skills/audit/audit-architecture-readiness" ]] && pass "legacy audit-architecture-readiness skill directory absent" || fail "legacy audit-architecture-readiness skill directory absent"

search_roots=()
for root in \
  "$ROOT_DIR/.octon/framework/orchestration/runtime/workflows" \
  "$ROOT_DIR/.octon/framework/capabilities/runtime/skills" \
  "$ROOT_DIR/.octon/framework/capabilities/runtime/commands" \
  "$ROOT_DIR/.octon/inputs/additive/extensions/octon-concept-integration"; do
  [[ -e "$root" ]] && search_roots+=("$root")
done

if [[ "${#search_roots[@]}" -gt 0 ]] && rg -n 'audit-architecture-readiness' \
  "${search_roots[@]}" \
  -g '!generated/**' >/tmp/architectural-review-legacy-alias.txt 2>/dev/null; then
  cat /tmp/architectural-review-legacy-alias.txt >&2
  fail "legacy audit-architecture-readiness alias absent from runtime and extension invocation surfaces"
else
  pass "legacy audit-architecture-readiness alias absent from runtime and extension invocation surfaces"
fi

printf 'Validation summary: errors=%s\n' "$errors"
[[ "$errors" -eq 0 ]]

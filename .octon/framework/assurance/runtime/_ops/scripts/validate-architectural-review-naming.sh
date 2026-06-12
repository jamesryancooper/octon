#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd -- "$SCRIPT_DIR/../../../../../.." && pwd)"
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

[[ -d "$ROOT_DIR/.octon/framework/orchestration/runtime/workflows/audit/architecture-readiness-audit" ]] && pass "canonical architecture-readiness-audit workflow directory exists" || fail "canonical architecture-readiness-audit workflow directory exists"
[[ ! -e "$ROOT_DIR/.octon/framework/orchestration/runtime/workflows/audit/audit-architecture-readiness" ]] && pass "legacy audit-architecture-readiness workflow directory absent" || fail "legacy audit-architecture-readiness workflow directory absent"
[[ -d "$ROOT_DIR/.octon/framework/capabilities/runtime/skills/audit/architecture-readiness-audit" ]] && pass "canonical architecture-readiness-audit skill directory exists" || fail "canonical architecture-readiness-audit skill directory exists"
[[ ! -e "$ROOT_DIR/.octon/framework/capabilities/runtime/skills/audit/audit-architecture-readiness" ]] && pass "legacy audit-architecture-readiness skill directory absent" || fail "legacy audit-architecture-readiness skill directory absent"

if rg -n 'audit-architecture-readiness' \
  "$ROOT_DIR/.octon/framework/orchestration/runtime/workflows" \
  "$ROOT_DIR/.octon/framework/capabilities/runtime/skills" \
  "$ROOT_DIR/.octon/framework/capabilities/runtime/commands" \
  "$ROOT_DIR/.octon/inputs/additive/extensions/octon-concept-integration" \
  -g '!generated/**' >/tmp/architectural-review-legacy-alias.txt 2>/dev/null; then
  cat /tmp/architectural-review-legacy-alias.txt >&2
  fail "legacy audit-architecture-readiness alias absent from runtime and extension invocation surfaces"
else
  pass "legacy audit-architecture-readiness alias absent from runtime and extension invocation surfaces"
fi

printf 'Validation summary: errors=%s\n' "$errors"
[[ "$errors" -eq 0 ]]

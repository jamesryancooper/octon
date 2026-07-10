#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd -- "$SCRIPT_DIR/../../../../../.." && pwd)"

# Fixture override for the v2 method-layer negative control. --methods-fixture
# points at a flat directory holding a naming.yml (+ lens-bank.yml) and runs
# ONLY the method-layer checks (schema_version, methods.default, the six
# canonical slugs, and the lens-bank binding / NC-A) without the live-tree
# legacy assertions, so NC-A fails closed for exactly one reason. --root keeps
# its repo-root meaning for the full run.
METHODS_ONLY=0
NAMING=""
LENS_BANK=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --root)
      ROOT_DIR="$(cd -- "$2" && pwd)"
      shift 2
      ;;
    --methods-fixture)
      METHODS_ONLY=1
      fixture_dir="$(cd -- "$2" && pwd)"
      NAMING="$fixture_dir/naming.yml"
      LENS_BANK="$fixture_dir/lens-bank.yml"
      shift 2
      ;;
    *)
      printf '[ERROR] unknown argument: %s\n' "$1" >&2
      exit 2
      ;;
  esac
done

[[ -n "$NAMING" ]] || NAMING="$ROOT_DIR/.octon/framework/cognition/practices/methodology/architectural-review/naming.yml"
[[ -n "$LENS_BANK" ]] || LENS_BANK="$ROOT_DIR/.octon/framework/cognition/practices/methodology/architectural-review/lens-bank.yml"
errors=0

pass() { printf '[OK] %s\n' "$1"; }
fail() { printf '[ERROR] %s\n' "$1" >&2; errors=$((errors + 1)); }

[[ -f "$NAMING" ]] && pass "architectural review naming model exists" || fail "architectural review naming model exists"
if [[ -f "$NAMING" ]] && yq -e '.' "$NAMING" >/dev/null 2>&1; then
  pass "architectural review naming model parses"
else
  fail "architectural review naming model parses"
fi

if [[ "$METHODS_ONLY" -eq 0 ]]; then
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
fi

# --- Method layer (naming v2) --------------------------------------------------
# Runs in both the full and --methods-fixture modes. The six canonical method
# slugs are fixed by architecture-review-method-taxonomy-and-routing and MUST
# equal lens-bank.yml suite_methods (dependency binding to the phase-0 lens
# bank).
EXPECTED_METHODS=(
  balanced-architecture-review-method
  greenfield-reference-architecture-review-method
  tradeoff-review-method
  failure-mode-review-method
  evolution-fitness-review-method
  boundary-authority-review-method
)

[[ "$(yq -r '.schema_version // ""' "$NAMING")" == "architectural-review-naming-v2" ]] \
  && pass "naming schema_version is architectural-review-naming-v2" \
  || fail "naming schema_version is architectural-review-naming-v2"

[[ "$(yq -r '.methods.default // ""' "$NAMING")" == "balanced-architecture-review-method" ]] \
  && pass "methods.default is balanced-architecture-review-method" \
  || fail "methods.default is balanced-architecture-review-method"

mapfile -t CATALOG_SLUGS < <(yq -r '.methods.catalog[]?.slug' "$NAMING" 2>/dev/null || true)
declare -A CATALOG_HAS=()
for s in "${CATALOG_SLUGS[@]}"; do
  [[ -z "$s" || "$s" == "null" ]] && continue
  CATALOG_HAS["$s"]=1
done
for m in "${EXPECTED_METHODS[@]}"; do
  [[ -n "${CATALOG_HAS[$m]:-}" ]] \
    && pass "methods.catalog declares canonical method: $m" \
    || fail "methods.catalog declares canonical method: $m"
done

# NC-A: every declared method slug must appear in lens-bank.yml suite_methods
# (a method declared without a lens-bank profile fails closed).
if [[ -f "$LENS_BANK" ]] && yq -e '.' "$LENS_BANK" >/dev/null 2>&1; then
  pass "lens bank available for method binding: $LENS_BANK"
  mapfile -t SUITE_SLUGS < <(yq -r '.suite_methods[]?.slug' "$LENS_BANK" 2>/dev/null || true)
  declare -A SUITE_HAS=()
  for s in "${SUITE_SLUGS[@]}"; do
    [[ -z "$s" || "$s" == "null" ]] && continue
    SUITE_HAS["$s"]=1
  done
  for s in "${CATALOG_SLUGS[@]}"; do
    [[ -z "$s" || "$s" == "null" ]] && continue
    [[ -n "${SUITE_HAS[$s]:-}" ]] \
      && pass "method slug binds to lens-bank suite_methods: $s" \
      || fail "method slug has no lens-bank suite_methods profile: $s"
  done
else
  fail "lens bank available for method binding: $LENS_BANK"
fi

printf 'Validation summary: errors=%s\n' "$errors"
[[ "$errors" -eq 0 ]]

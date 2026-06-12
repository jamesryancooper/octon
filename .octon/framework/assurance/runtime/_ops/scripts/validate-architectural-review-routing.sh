#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd -- "$SCRIPT_DIR/../../../../../.." && pwd)"
ROUTING="$ROOT_DIR/.octon/framework/cognition/practices/methodology/architectural-review/review-routing.yml"
errors=0

pass() { printf '[OK] %s\n' "$1"; }
fail() { printf '[ERROR] %s\n' "$1" >&2; errors=$((errors + 1)); }

[[ -f "$ROUTING" ]] && pass "architectural review routing file exists" || fail "architectural review routing file exists"
yq -e '.' "$ROUTING" >/dev/null 2>&1 && pass "architectural review routing parses" || fail "architectural review routing parses"
[[ "$(yq -r '.default_route // ""' "$ROUTING")" == "pre-integration-architecture-review" ]] && pass "default route is pre-integration review" || fail "default route is pre-integration review"

for route in \
  pre-integration-architecture-review \
  architecture-revision-packet \
  post-integration-architecture-review \
  current-state-mechanism-architecture-review \
  architecture-readiness-audit \
  domain-architecture-audit \
  surface-architecture-audit \
  lifecycle-postmortem-evaluator \
  constitutional-challenge; do
  yq -e ".routes[]? | select(.route_id == \"$route\")" "$ROUTING" >/dev/null 2>&1 && pass "route declared: $route" || fail "route declared: $route"
done

yq -e '.routes[]? | select(.route_id == "pre-integration-architecture-review" and .lifecycle_authority == "required-gate-for-architecture-proposals")' "$ROUTING" >/dev/null 2>&1 && pass "pre-integration review is required proposal gate" || fail "pre-integration review is required proposal gate"
yq -e '.routes[]? | select(.route_id == "post-integration-architecture-review" and .lifecycle_authority == "evidence-only" and .closeout_authority == "none")' "$ROUTING" >/dev/null 2>&1 && pass "post-integration review is evidence-only" || fail "post-integration review is evidence-only"
yq -e '.routes[]? | select(.route_id == "lifecycle-postmortem-evaluator" and .lifecycle_authority == "evidence-only" and .closeout_authority == "none")' "$ROUTING" >/dev/null 2>&1 && pass "lifecycle postmortem cannot authorize closeout" || fail "lifecycle postmortem cannot authorize closeout"

printf 'Validation summary: errors=%s\n' "$errors"
[[ "$errors" -eq 0 ]]

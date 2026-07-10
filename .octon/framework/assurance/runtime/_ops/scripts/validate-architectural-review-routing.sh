#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd -- "$SCRIPT_DIR/../../../../../.." && pwd)"

# Fixture override for the v2 method-selection negative controls.
# --methods-fixture points at a flat directory holding review-routing.yml, the
# naming.yml catalog it binds to, and an optional method-routing-samples.yml,
# and runs ONLY the method-selection checks (schema_version, default_method,
# NC-B unknown_method, condition presence, NC-C missing_method_record) without
# the live-tree route assertions, so each NC fails closed for exactly one
# reason. --root runs the full model under an alternate repo root.
METHODS_ONLY=0
ROUTING=""
NAMING=""
SAMPLES=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --root)
      ROOT_DIR="$(cd -- "$2" && pwd)"
      shift 2
      ;;
    --methods-fixture)
      METHODS_ONLY=1
      fixture_dir="$(cd -- "$2" && pwd)"
      ROUTING="$fixture_dir/review-routing.yml"
      NAMING="$fixture_dir/naming.yml"
      SAMPLES="$fixture_dir/method-routing-samples.yml"
      shift 2
      ;;
    *)
      printf '[ERROR] unknown argument: %s\n' "$1" >&2
      exit 2
      ;;
  esac
done

AR_DIR="$ROOT_DIR/.octon/framework/cognition/practices/methodology/architectural-review"
[[ -n "$ROUTING" ]] || ROUTING="$AR_DIR/review-routing.yml"
[[ -n "$NAMING" ]] || NAMING="$AR_DIR/naming.yml"
[[ -n "$SAMPLES" ]] || SAMPLES="$AR_DIR/method-routing-samples.yml"
errors=0

pass() { printf '[OK] %s\n' "$1"; }
fail() { printf '[ERROR] %s\n' "$1" >&2; errors=$((errors + 1)); }

[[ -f "$ROUTING" ]] && pass "architectural review routing file exists" || fail "architectural review routing file exists"
yq -e '.' "$ROUTING" >/dev/null 2>&1 && pass "architectural review routing parses" || fail "architectural review routing parses"

if [[ "$METHODS_ONLY" -eq 0 ]]; then
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
fi

# --- Method-selection layer (routing v2) ---------------------------------------
# Runs in both the full and --methods-fixture modes. Method selection grants no
# lifecycle authority; these checks enforce that the selection layer is
# internally consistent and fails closed on an unknown method or a routing
# decision that omits its method record.

[[ "$(yq -r '.schema_version // ""' "$ROUTING")" == "architectural-review-routing-v2" ]] \
  && pass "routing schema_version is architectural-review-routing-v2" \
  || fail "routing schema_version is architectural-review-routing-v2"

[[ "$(yq -r '.method_selection.default_method // ""' "$ROUTING")" == "balanced-architecture-review-method" ]] \
  && pass "method_selection.default_method is balanced-architecture-review-method" \
  || fail "method_selection.default_method is balanced-architecture-review-method"

# Both new fail-closed conditions must be declared (NC-C depends on
# missing_method_record being present).
for cond in unknown_method missing_method_record; do
  yq -e ".fail_closed_conditions[]? | select(. == \"$cond\")" "$ROUTING" >/dev/null 2>&1 \
    && pass "fail_closed_conditions declares: $cond" \
    || fail "fail_closed_conditions declares: $cond"
done

# NC-B: every method referenced by method_selection must be a declared naming
# catalog slug. constitutional_conflict_routes_to points at a route, not a
# method, and is excluded.
declare -A CATALOG_HAS=()
if [[ -f "$NAMING" ]] && yq -e '.' "$NAMING" >/dev/null 2>&1; then
  pass "naming catalog available for method binding: $NAMING"
  while read -r s; do
    [[ -z "$s" || "$s" == "null" ]] && continue
    CATALOG_HAS["$s"]=1
  done < <(yq -r '.methods.catalog[]?.slug' "$NAMING" 2>/dev/null || true)
else
  fail "naming catalog available for method binding: $NAMING"
fi

mapfile -t REFERENCED_METHODS < <(
  {
    yq -r '.method_selection.default_method // empty' "$ROUTING" 2>/dev/null || true
    yq -r '.method_selection.allowed_methods_by_route[]?[]?' "$ROUTING" 2>/dev/null || true
    yq -r '.method_selection.escalation_map | keys | .[]?' "$ROUTING" 2>/dev/null || true
    yq -r '.method_selection.escalation_map[]?[]?.to // empty' "$ROUTING" 2>/dev/null || true
  } | sort -u
)
for m in "${REFERENCED_METHODS[@]}"; do
  [[ -z "$m" || "$m" == "null" ]] && continue
  [[ -n "${CATALOG_HAS[$m]:-}" ]] \
    && pass "method_selection references declared method: $m" \
    || fail "method_selection references unknown method (not in naming catalog): $m"
done

# NC-C: any routing-decision sample that selects a method but omits its method
# record fails closed. In the live model no samples file exists, so this is
# vacuously satisfied while the condition-presence check above still guards it.
if [[ -f "$SAMPLES" ]]; then
  if yq -e '.' "$SAMPLES" >/dev/null 2>&1; then
    pass "method-routing samples parse: $SAMPLES"
    missing_records=0
    while IFS=$'\t' read -r selected recorded; do
      [[ -z "$selected" || "$selected" == "null" ]] && continue
      if [[ -z "$recorded" || "$recorded" == "null" ]]; then
        fail "routing decision selects '$selected' but omits its method record"
        missing_records=$((missing_records + 1))
      fi
    done < <(yq -r '.routing_decisions[]? | [(.selected_method // ""), (.method_record.method // "")] | @tsv' "$SAMPLES" 2>/dev/null || true)
    [[ "$missing_records" -eq 0 ]] && pass "all method-bearing routing decisions record their method"
  else
    fail "method-routing samples parse: $SAMPLES"
  fi
fi

printf 'Validation summary: errors=%s\n' "$errors"
[[ "$errors" -eq 0 ]]

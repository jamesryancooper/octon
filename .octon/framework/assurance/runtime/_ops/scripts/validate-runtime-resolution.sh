#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
ROOT_DIR="${OCTON_ROOT_DIR:-$(cd -- "$OCTON_DIR/.." && pwd)}"
ROOT_MANIFEST="$OCTON_DIR/octon.yml"
SELECTOR="$OCTON_DIR/instance/governance/runtime-resolution.yml"
SPEC="$OCTON_DIR/framework/engine/runtime/spec/runtime-resolution-v1.md"
SCHEMA="$OCTON_DIR/framework/engine/runtime/spec/runtime-resolution-v1.schema.json"
ROUTE_SCHEMA="$OCTON_DIR/framework/engine/runtime/spec/runtime-effective-route-bundle-v1.schema.json"

errors=0
fail(){ echo "[ERROR] $1"; errors=$((errors+1)); }
pass(){ echo "[OK] $1"; }

resolve_repo_path() {
  local raw="$1"
  case "$raw" in
    /.octon/*) printf '%s/%s\n' "$ROOT_DIR" "${raw#/}" ;;
    .octon/*) printf '%s/%s\n' "$ROOT_DIR" "$raw" ;;
    *) printf '%s\n' "$raw" ;;
  esac
}

echo "== Runtime Resolution Validation =="

[[ -f "$SPEC" ]] && pass "runtime-resolution spec present" || fail "missing runtime-resolution spec"
[[ -f "$SCHEMA" ]] && pass "runtime-resolution schema present" || fail "missing runtime-resolution schema"
[[ -f "$ROUTE_SCHEMA" ]] && pass "runtime route-bundle schema present" || fail "missing runtime route-bundle schema"
[[ -f "$SELECTOR" ]] && pass "runtime-resolution selector present" || fail "missing runtime-resolution selector"

[[ "$(yq -r '.resolution.runtime_resolution_ref // ""' "$ROOT_MANIFEST")" == ".octon/instance/governance/runtime-resolution.yml" ]] \
  && pass "root manifest delegates runtime-resolution selector" \
  || fail "root manifest must delegate runtime-resolution selector"

[[ "$(yq -r '.schema_version // ""' "$SELECTOR")" == "octon-runtime-resolution-v1" ]] \
  && pass "selector schema version current" \
  || fail "selector schema version invalid"

for query in \
  '.runtime_effective_route_bundle_ref' \
  '.runtime_effective_route_bundle_lock_ref' \
  '.pack_routes_effective_ref' \
  '.pack_routes_lock_ref' \
  '.support_target_matrix_ref' \
  '.extensions_catalog_ref' \
  '.extensions_generation_lock_ref'
do
  ref="$(yq -r "$query // \"\"" "$SELECTOR")"
  [[ -n "$ref" ]] && pass "selector declares $query" || fail "selector missing $query"
  [[ -e "$(resolve_repo_path "$ref")" ]] && pass "resolved $query exists" || fail "resolved $query missing: $ref"
done

echo "Validation summary: errors=$errors"
[[ $errors -eq 0 ]]

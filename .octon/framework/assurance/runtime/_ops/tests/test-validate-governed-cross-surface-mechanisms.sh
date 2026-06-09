#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "$SCRIPT_DIR/../../../../../.." && pwd)"
VALIDATOR="$REPO_ROOT/.octon/framework/assurance/runtime/_ops/scripts/validate-governed-cross-surface-mechanisms.sh"

pass_count=0
fail_count=0
declare -a CLEANUP_DIRS=()

cleanup() {
  local dir
  for dir in "${CLEANUP_DIRS[@]}"; do
    [[ -n "$dir" ]] && rm -r "$dir"
  done
}
trap cleanup EXIT

pass() { printf 'PASS: %s\n' "$1"; pass_count=$((pass_count + 1)); }
fail() { printf 'FAIL: %s\n' "$1" >&2; fail_count=$((fail_count + 1)); }

new_fixture_root() {
  local root
  root="$(mktemp -d "${TMPDIR:-/tmp}/governed-mechanisms.XXXXXX")"
  CLEANUP_DIRS+=("$root")
  mkdir -p "$root/.octon/framework/cognition/_meta/architecture"
  mkdir -p "$root/.octon/generated/cognition/projections/materialized"
  mkdir -p "$root/.octon/framework/product/features"
  cp -R "$REPO_ROOT/.octon/framework/cognition/_meta/architecture/governed-cross-surface-mechanisms" \
    "$root/.octon/framework/cognition/_meta/architecture/"
  cp -R "$REPO_ROOT/.octon/generated/cognition/projections/materialized/governed-cross-surface-mechanisms" \
    "$root/.octon/generated/cognition/projections/materialized/"
  cat >"$root/.octon/framework/product/features/catalog.yml" <<'YAML'
schema_version: "octon-product-feature-catalog-v1"
catalog_role: "navigation-only"
authority_note: "Navigation only."
features:
  - feature_id: "fixture"
    name: "Fixture"
YAML
  printf '%s\n' "$root"
}

assert_success() {
  local label="$1" root="$2"
  if "$VALIDATOR" --root "$root" >/tmp/governed-mechanisms.out 2>&1; then
    pass "$label"
  else
    cat /tmp/governed-mechanisms.out >&2
    fail "$label"
  fi
}

assert_failure() {
  local label="$1" root="$2"
  if "$VALIDATOR" --root "$root" >/tmp/governed-mechanisms.out 2>&1; then
    cat /tmp/governed-mechanisms.out >&2
    fail "$label"
  else
    pass "$label"
  fi
}

root="$(new_fixture_root)"
assert_success "valid governed mechanism index passes" "$root"

root="$(new_fixture_root)"
perl -0pi -e 's/not runtime authority/runtime authority/' \
  "$root/.octon/framework/cognition/_meta/architecture/governed-cross-surface-mechanisms/README.md"
assert_failure "missing non-authority banner fails" "$root"

root="$(new_fixture_root)"
yq -i '.mechanisms[0].retained_evidence_refs += [".octon/state/control/execution/runs/example.yml"]' \
  "$root/.octon/framework/cognition/_meta/architecture/governed-cross-surface-mechanisms/index.yml"
assert_failure "state control as retained evidence fails" "$root"

root="$(new_fixture_root)"
perl -0pi -e 's/parent evidence satisfying child receipts/parent summary only/' \
  "$root/.octon/generated/cognition/projections/materialized/governed-cross-surface-mechanisms/operator-map.md"
assert_failure "operator map missing forbidden child-receipt consumer fails" "$root"

root="$(new_fixture_root)"
perl -0pi -e 's/parent_evidence_satisfies_child_receipts: false/parent_evidence_satisfies_child_receipts: true/' \
  "$root/.octon/framework/cognition/_meta/architecture/governed-cross-surface-mechanisms/aggregate-closeout-evidence-template.md"
assert_failure "parent evidence satisfying child receipts fails" "$root"

printf 'Test summary: passes=%d failures=%d\n' "$pass_count" "$fail_count"
[[ "$fail_count" -eq 0 ]]

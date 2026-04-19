#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
ROOT_DIR="$(cd -- "$OCTON_DIR/.." && pwd)"

errors=0

fail() {
  echo "[ERROR] $1" >&2
  errors=$((errors + 1))
}

pass() {
  echo "[OK] $1"
}

require_file() {
  local path="$1"
  if [[ -f "$path" ]]; then
    pass "found ${path#$ROOT_DIR/}"
  else
    fail "missing ${path#$ROOT_DIR/}"
  fi
}

forbidden_text() {
  local pattern="$1"
  shift
  if rg -n "$pattern" "$@" >/dev/null 2>&1; then
    fail "forbidden active-path pattern still present: $pattern"
  else
    pass "no active-path matches for $pattern"
  fi
}

echo "== Execution Role Hard Cutover Validation =="

require_file "$OCTON_DIR/framework/execution-roles/README.md"
require_file "$OCTON_DIR/framework/execution-roles/registry.yml"
require_file "$OCTON_DIR/framework/execution-roles/runtime/orchestrator/ROLE.md"
require_file "$OCTON_DIR/framework/execution-roles/runtime/orchestrator/role.yml"
require_file "$OCTON_DIR/framework/execution-roles/runtime/specialists/registry.yml"
require_file "$OCTON_DIR/framework/execution-roles/runtime/verifiers/registry.yml"
require_file "$OCTON_DIR/framework/execution-roles/runtime/composition-profiles/registry.yml"

require_file "$OCTON_DIR/framework/engine/runtime/spec/execution-request-v3.schema.json"
require_file "$OCTON_DIR/framework/engine/runtime/spec/execution-receipt-v3.schema.json"
require_file "$OCTON_DIR/framework/engine/runtime/spec/runtime-event-v1.schema.json"

[[ ! -e "$OCTON_DIR/framework/agency" ]] && pass "legacy framework/agency tree absent" || fail "legacy framework/agency tree still exists"
[[ ! -e "$OCTON_DIR/instance/agency" ]] && pass "legacy instance/agency tree absent" || fail "legacy instance/agency tree still exists"

forbidden_text 'actor_ref' \
  "$OCTON_DIR/README.md" \
  "$OCTON_DIR/octon.yml" \
  "$OCTON_DIR/framework/constitution" \
  "$OCTON_DIR/framework/engine" \
  "$OCTON_DIR/framework/execution-roles" \
  "$OCTON_DIR/framework/overlay-points" \
  "$OCTON_DIR/instance/bootstrap" \
  "$OCTON_DIR/instance/ingress" \
  "$ROOT_DIR/.github"

forbidden_text 'agent-augmented' \
  "$OCTON_DIR/README.md" \
  "$OCTON_DIR/octon.yml" \
  "$OCTON_DIR/framework/constitution" \
  "$OCTON_DIR/framework/engine" \
  "$OCTON_DIR/framework/execution-roles" \
  "$OCTON_DIR/framework/orchestration" \
  "$OCTON_DIR/instance/bootstrap" \
  "$OCTON_DIR/instance/ingress" \
  "$ROOT_DIR/.github"

forbidden_text 'instance-agency-runtime' \
  "$OCTON_DIR/README.md" \
  "$OCTON_DIR/octon.yml" \
  "$OCTON_DIR/framework/manifest.yml" \
  "$OCTON_DIR/framework/overlay-points" \
  "$OCTON_DIR/framework/cognition/_meta/architecture" \
  "$OCTON_DIR/instance" \
  "$ROOT_DIR/.github"

support_mode="$(yq -r '.support_claim_mode' "$OCTON_DIR/instance/governance/support-targets.yml" 2>/dev/null || true)"
[[ "$support_mode" == "bounded-admitted-finite" ]] && pass "support claim mode aligned" || fail "support claim mode is not bounded-admitted-finite"

live_packs="$(yq -r '.live_support_universe.capability_packs[]' "$OCTON_DIR/instance/governance/support-targets.yml" 2>/dev/null || true)"
if grep -qx 'browser' <<<"$live_packs" || grep -qx 'api' <<<"$live_packs"; then
  fail "browser/api capability packs still appear in live support universe"
else
  pass "browser/api capability packs excluded from live support universe"
fi

tuple_count="$(yq -r '.tuple_admissions | length' "$OCTON_DIR/instance/governance/support-targets.yml" 2>/dev/null || true)"
[[ "$tuple_count" == "3" ]] && pass "live tuple admission set narrowed to three active tuples" || fail "unexpected tuple admission count: ${tuple_count:-missing}"

framework_subsystems="$(yq -r '.subsystems[]' "$OCTON_DIR/framework/manifest.yml" 2>/dev/null || true)"
grep -qx 'execution-roles' <<<"$framework_subsystems" && pass "framework manifest publishes execution-roles subsystem" || fail "framework manifest does not publish execution-roles subsystem"

echo "Validation summary: errors=$errors"
[[ $errors -eq 0 ]]

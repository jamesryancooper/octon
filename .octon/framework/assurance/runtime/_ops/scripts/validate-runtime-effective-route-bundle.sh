#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
ROOT_DIR="${OCTON_ROOT_DIR:-$(cd -- "$OCTON_DIR/.." && pwd)}"
SELECTOR="$OCTON_DIR/instance/governance/runtime-resolution.yml"
BUNDLE="$OCTON_DIR/generated/effective/runtime/route-bundle.yml"
LOCK="$OCTON_DIR/generated/effective/runtime/route-bundle.lock.yml"
SUPPORT_TARGETS="$OCTON_DIR/instance/governance/support-targets.yml"

errors=0
fail(){ echo "[ERROR] $1"; errors=$((errors+1)); }
pass(){ echo "[OK] $1"; }

hash_file() {
  if command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "$1" | awk '{print $1}'
  else
    sha256sum "$1" | awk '{print $1}'
  fi
}

resolve_repo_path() {
  local raw="$1"
  case "$raw" in
    /.octon/*) printf '%s/%s\n' "$ROOT_DIR" "${raw#/}" ;;
    .octon/*) printf '%s/%s\n' "$ROOT_DIR" "$raw" ;;
    *) printf '%s\n' "$raw" ;;
  esac
}

echo "== Runtime Effective Route Bundle Validation =="

[[ -f "$BUNDLE" ]] && pass "runtime route bundle present" || fail "missing runtime route bundle"
[[ -f "$LOCK" ]] && pass "runtime route bundle lock present" || fail "missing runtime route bundle lock"
[[ "$(yq -r '.schema_version // ""' "$BUNDLE")" == "octon-runtime-effective-route-bundle-v1" ]] && pass "runtime route bundle schema current" || fail "runtime route bundle schema invalid"
[[ "$(yq -r '.schema_version // ""' "$LOCK")" == "octon-runtime-effective-route-bundle-lock-v1" ]] && pass "runtime route bundle lock schema current" || fail "runtime route bundle lock schema invalid"
[[ "$(yq -r '.generation_id // ""' "$BUNDLE")" == "$(yq -r '.generation_id // ""' "$LOCK")" ]] && pass "route bundle generation ids aligned" || fail "route bundle generation id mismatch"

expected_bundle_ref="$(yq -r '.runtime_effective_route_bundle_ref // ""' "$SELECTOR")"
expected_lock_ref="$(yq -r '.runtime_effective_route_bundle_lock_ref // ""' "$SELECTOR")"
[[ "$expected_bundle_ref" == ".octon/generated/effective/runtime/route-bundle.yml" ]] && pass "selector bundle ref current" || fail "selector bundle ref drift"
[[ "$expected_lock_ref" == ".octon/generated/effective/runtime/route-bundle.lock.yml" ]] && pass "selector lock ref current" || fail "selector lock ref drift"

bundle_sha="$(hash_file "$BUNDLE")"
[[ "$(yq -r '.route_bundle_sha256 // ""' "$LOCK")" == "$bundle_sha" ]] && pass "route bundle digest current" || fail "route bundle digest drift"

selector_sha="$(hash_file "$SELECTOR")"
[[ "$(yq -r '.runtime_resolution_sha256 // ""' "$LOCK")" == "$selector_sha" ]] && pass "selector digest current" || fail "selector digest drift"

receipt_rel="$(yq -r '.publication_receipt_path // ""' "$LOCK")"
receipt_abs="$(resolve_repo_path "$receipt_rel")"
[[ -f "$receipt_abs" ]] && pass "publication receipt present" || fail "publication receipt missing"
[[ "$(yq -r '.generation_id // ""' "$receipt_abs" 2>/dev/null)" == "$(yq -r '.generation_id // ""' "$BUNDLE")" ]] && pass "publication receipt generation id matches" || fail "publication receipt generation id mismatch"
[[ "$(yq -r '.publication_receipt_sha256 // ""' "$LOCK")" == "$(hash_file "$receipt_abs")" ]] && pass "publication receipt digest current" || fail "publication receipt digest drift"
[[ "$(yq -r '.result // ""' "$receipt_abs" 2>/dev/null)" == "$(yq -r '.publication_status // ""' "$BUNDLE")" ]] && pass "publication receipt status matches" || fail "publication receipt status mismatch"

bundle_tuple_count="$(yq -r '.routes | length' "$BUNDLE")"
support_tuple_count="$(yq -r '.tuple_admissions | length' "$SUPPORT_TARGETS")"
[[ "$bundle_tuple_count" == "$support_tuple_count" ]] && pass "bundle covers every declared support tuple" || fail "bundle tuple coverage mismatch"

for query in \
  '.support_target_matrix_sha256:.support_target_matrix_ref:support target matrix' \
  '.pack_routes_effective_sha256:.pack_routes_effective_ref:pack routes effective' \
  '.pack_routes_lock_sha256:.pack_routes_lock_ref:pack routes lock' \
  '.extensions_catalog_sha256:.extensions_catalog_ref:extensions catalog' \
  '.extensions_generation_lock_sha256:.extensions_generation_lock_ref:extensions generation lock'
do
  digest_query="${query%%:*}"
  rest="${query#*:}"
  ref_query="${rest%%:*}"
  label="${rest##*:}"
  ref="$(yq -r "$ref_query // \"\"" "$SELECTOR")"
  expected="$(yq -r "$digest_query // \"\"" "$LOCK")"
  actual="$(hash_file "$(resolve_repo_path "$ref")")"
  [[ "$expected" == "$actual" ]] && pass "$label digest current" || fail "$label digest drift"
done

route_claim_errors="$(yq -r '.routes[]? | select(.claim_effect == "" or .route == "") | .tuple_id' "$BUNDLE" | awk 'NF')"
[[ -z "$route_claim_errors" ]] && pass "bundle routes declare claim effect and route" || fail "bundle routes missing claim effect or route: $route_claim_errors"

[[ "$(yq -r '.extensions.status // ""' "$BUNDLE")" == "published" ]] && pass "bundle reports published extension state" || fail "bundle extension state must be published"
[[ "$(yq -r '.extensions.quarantine_count // 0' "$BUNDLE")" == "0" ]] && pass "bundle reports zero quarantined extensions" || fail "bundle must fail closed on quarantined extensions"

echo "Validation summary: errors=$errors"
[[ $errors -eq 0 ]]

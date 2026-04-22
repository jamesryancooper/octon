#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
ROOT_DIR="${OCTON_ROOT_DIR:-$(cd -- "$OCTON_DIR/.." && pwd)}"
source "$SCRIPT_DIR/validator-result-common.sh"
SELECTOR="$OCTON_DIR/instance/governance/runtime-resolution.yml"
BUNDLE="$OCTON_DIR/generated/effective/runtime/route-bundle.yml"
LOCK="$OCTON_DIR/generated/effective/runtime/route-bundle.lock.yml"
SUPPORT_TARGETS="$OCTON_DIR/instance/governance/support-targets.yml"
HANDLE_CONTRACT_PATH="$(pick_existing_file \
  "$OCTON_DIR/framework/engine/runtime/spec/runtime-effective-artifact-handle-v2.md" \
  "$OCTON_DIR/framework/engine/runtime/spec/runtime-effective-artifact-handle-v1.md")"

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

check_lock_schema() {
  case "$(yq -r '.schema_version // ""' "$LOCK")" in
    octon-runtime-effective-route-bundle-lock-v2|octon-runtime-effective-route-bundle-lock-v3)
      pass "runtime route bundle lock schema current"
      ;;
    *)
      fail "runtime route bundle lock schema invalid"
      ;;
  esac
}

publication_receipt_ref() {
  yq -r '.publication_receipt_path // .publication_receipt_ref // ""' "$LOCK"
}

reset_validator_result_metadata
validator_result_add_evidence \
  ".octon/generated/effective/runtime/route-bundle.yml" \
  ".octon/generated/effective/runtime/route-bundle.lock.yml" \
  ".octon/instance/governance/runtime-resolution.yml"
validator_result_add_runtime_test \
  ".octon/framework/assurance/runtime/_ops/tests/test-stale-digest-bound-route-bundle-denial.sh"
validator_result_add_negative_control \
  "root-manifest-digest-drift-denies" \
  "publication-receipt-digest-drift-denies" \
  "runtime-route-bundle-lock-missing-denies"
validator_result_add_schema_version \
  "octon-runtime-effective-route-bundle-v1" \
  "octon-runtime-effective-route-bundle-lock-v2" \
  "octon-runtime-effective-route-bundle-lock-v3"
[[ -n "${HANDLE_CONTRACT_PATH:-}" ]] && validator_result_add_contract "${HANDLE_CONTRACT_PATH#$OCTON_DIR/}"

echo "== Runtime Effective Route Bundle Validation =="

[[ -f "$BUNDLE" ]] && pass "runtime route bundle present" || fail "missing runtime route bundle"
[[ -f "$LOCK" ]] && pass "runtime route bundle lock present" || fail "missing runtime route bundle lock"
[[ "$(yq -r '.schema_version // ""' "$BUNDLE")" == "octon-runtime-effective-route-bundle-v1" ]] && pass "runtime route bundle schema current" || fail "runtime route bundle schema invalid"
check_lock_schema
[[ "$(yq -r '.generation_id // ""' "$BUNDLE")" == "$(yq -r '.generation_id // ""' "$LOCK")" ]] && pass "route bundle generation ids aligned" || fail "route bundle generation id mismatch"
[[ -n "${HANDLE_CONTRACT_PATH:-}" ]] && pass "runtime-effective handle contract present" || fail "missing runtime-effective handle contract"

expected_bundle_ref="$(yq -r '.runtime_effective_route_bundle_ref // ""' "$SELECTOR")"
expected_lock_ref="$(yq -r '.runtime_effective_route_bundle_lock_ref // ""' "$SELECTOR")"
[[ "$expected_bundle_ref" == ".octon/generated/effective/runtime/route-bundle.yml" ]] && pass "selector bundle ref current" || fail "selector bundle ref drift"
[[ "$expected_lock_ref" == ".octon/generated/effective/runtime/route-bundle.lock.yml" ]] && pass "selector lock ref current" || fail "selector lock ref drift"

bundle_sha="$(hash_file "$BUNDLE")"
[[ "$(yq -r '.route_bundle_sha256 // ""' "$LOCK")" == "$bundle_sha" ]] && pass "route bundle digest current" || fail "route bundle digest drift"

selector_sha="$(hash_file "$SELECTOR")"
[[ "$(yq -r '.source_digests.runtime_resolution_sha256 // ""' "$LOCK")" == "$selector_sha" ]] && pass "selector digest current" || fail "selector digest drift"

root_sha="$(hash_file "$OCTON_DIR/octon.yml")"
[[ "$(yq -r '.source_digests.root_manifest_sha256 // ""' "$LOCK")" == "$root_sha" ]] && pass "root manifest digest current" || fail "root manifest digest drift"

freshness_mode="$(yq -r '.freshness.mode // ""' "$LOCK")"
case "$freshness_mode" in
  digest_bound|ttl_bound|receipt_bound)
    pass "runtime route bundle freshness mode current"
    ;;
  *)
    fail "runtime route bundle freshness mode invalid"
    ;;
esac
yq -e '.freshness.invalidation_conditions | length > 0' "$LOCK" >/dev/null 2>&1 \
  && pass "runtime route bundle invalidation conditions declared" \
  || fail "runtime route bundle invalidation conditions missing"
[[ "$(yq -r '.non_authority_classification // ""' "$LOCK")" == "derived-runtime-handle" ]] \
  && pass "runtime route bundle non-authority classification valid" \
  || fail "runtime route bundle non-authority classification invalid"
yq -e '.allowed_consumers[] | select(. == "runtime_resolver")' "$LOCK" >/dev/null 2>&1 \
  && pass "runtime route bundle allows runtime_resolver" \
  || fail "runtime route bundle must allow runtime_resolver"
yq -e '.forbidden_consumers[] | select(. == "direct_runtime_raw_path_read")' "$LOCK" >/dev/null 2>&1 \
  && pass "runtime route bundle forbids raw runtime reads" \
  || fail "runtime route bundle must forbid raw runtime reads"

receipt_rel="$(publication_receipt_ref)"
receipt_abs="$(resolve_repo_path "$receipt_rel")"
[[ -f "$receipt_abs" ]] && pass "publication receipt present" || fail "publication receipt missing"
[[ "$(yq -r '.generation_id // ""' "$receipt_abs" 2>/dev/null)" == "$(yq -r '.generation_id // ""' "$BUNDLE")" ]] && pass "publication receipt generation id matches" || fail "publication receipt generation id mismatch"
[[ "$(yq -r '.publication_receipt_sha256 // ""' "$LOCK")" == "$(hash_file "$receipt_abs")" ]] && pass "publication receipt digest current" || fail "publication receipt digest drift"
[[ "$(yq -r '.result // ""' "$receipt_abs" 2>/dev/null)" == "$(yq -r '.publication_status // ""' "$BUNDLE")" ]] && pass "publication receipt status matches" || fail "publication receipt status mismatch"

bundle_tuple_count="$(yq -r '.routes | length' "$BUNDLE")"
support_tuple_count="$(yq -r '.tuple_admissions | length' "$SUPPORT_TARGETS")"
[[ "$bundle_tuple_count" == "$support_tuple_count" ]] && pass "bundle covers every declared support tuple" || fail "bundle tuple coverage mismatch"

for query in \
  '.source_digests.support_target_matrix_sha256:.support_target_matrix_ref:support target matrix' \
  '.source_digests.pack_routes_effective_sha256:.pack_routes_effective_ref:pack routes effective' \
  '.source_digests.pack_routes_lock_sha256:.pack_routes_lock_ref:pack routes lock' \
  '.source_digests.extensions_catalog_sha256:.extensions_catalog_ref:extensions catalog' \
  '.source_digests.extensions_generation_lock_sha256:.extensions_generation_lock_ref:extensions generation lock'
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
if [[ $errors -eq 0 ]]; then
  emit_validator_result "validate-runtime-effective-route-bundle.sh" "runtime_effective_handles" "runtime" "runtime" "pass"
else
  emit_validator_result "validate-runtime-effective-route-bundle.sh" "runtime_effective_handles" "runtime" "existence" "fail"
fi
[[ $errors -eq 0 ]]

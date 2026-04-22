#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
source "$SCRIPT_DIR/validator-result-common.sh"

ROUTE_LOCK="$OCTON_DIR/generated/effective/runtime/route-bundle.lock.yml"
PACK_LOCK="$OCTON_DIR/generated/effective/capabilities/pack-routes.lock.yml"
CONTRACT_PATH="$(pick_existing_file \
  "$OCTON_DIR/framework/engine/runtime/spec/runtime-effective-artifact-handle-v2.md" \
  "$OCTON_DIR/framework/engine/runtime/spec/runtime-effective-artifact-handle-v1.md")"

errors=0
fail() { echo "[ERROR] $1"; errors=$((errors + 1)); }
pass() { echo "[OK] $1"; }

check_mode() {
  local file="$1" label="$2"
  case "$(yq -r '.freshness.mode // ""' "$file")" in
    digest_bound|ttl_bound|receipt_bound) pass "$label freshness mode valid" ;;
    *) fail "$label freshness mode invalid" ;;
  esac
  yq -e '.freshness.invalidation_conditions | length > 0' "$file" >/dev/null 2>&1 \
    && pass "$label invalidation conditions declared" \
    || fail "$label must declare invalidation conditions"
}

check_common_handle_fields() {
  local file="$1" label="$2"
  yq -e '.allowed_consumers[] | select(. == "runtime_resolver")' "$file" >/dev/null 2>&1 \
    && pass "$label allows runtime_resolver" \
    || fail "$label must allow runtime_resolver"
  yq -e '.forbidden_consumers[] | select(. == "direct_runtime_raw_path_read")' "$file" >/dev/null 2>&1 \
    && pass "$label forbids raw runtime reads" \
    || fail "$label must forbid raw runtime reads"
  [[ "$(yq -r '.non_authority_classification // ""' "$file")" == "derived-runtime-handle" ]] \
    && pass "$label non-authority classification valid" \
    || fail "$label non-authority classification invalid"
}

check_route_lock_schema() {
  local file="$1"
  case "$(yq -r '.schema_version // ""' "$file")" in
    octon-runtime-effective-route-bundle-lock-v2|octon-runtime-effective-route-bundle-lock-v3)
      pass "runtime route lock schema valid"
      ;;
    *)
      fail "runtime route lock schema invalid"
      ;;
  esac
}

check_pack_lock_schema() {
  local file="$1"
  case "$(yq -r '.schema_version // ""' "$file")" in
    octon-runtime-pack-routes-lock-v1|octon-runtime-pack-routes-lock-v2)
      pass "pack routes lock schema valid"
      ;;
    *)
      fail "pack routes lock schema invalid"
      ;;
  esac
}

check_dependency_handles() {
  local file="$1" label="$2"
  local schema_version
  schema_version="$(yq -r '.schema_version // ""' "$file")"
  if [[ "$schema_version" != "octon-runtime-effective-route-bundle-lock-v3" ]]; then
    validator_result_add_limitation "$label uses a pre-recursive route-lock schema without dependency_handles"
    return 0
  fi

  yq -e '.dependency_handles | length > 0' "$file" >/dev/null 2>&1 \
    && pass "$label dependency handles declared" \
    || fail "$label must declare dependency handles"

  while IFS=$'\t' read -r artifact_kind output_ref; do
    [[ -n "$artifact_kind" ]] \
      && pass "$label dependency handle declares artifact kind" \
      || fail "$label dependency handle missing artifact kind"
    [[ -n "$output_ref" ]] \
      && pass "$label dependency handle declares output ref" \
      || fail "$label dependency handle missing output ref"
  done < <(yq -r '.dependency_handles[]? | [(.artifact_kind // ""), (.output_ref // .ref // "")] | @tsv' "$file")
}

reset_validator_result_metadata
validator_result_add_evidence \
  ".octon/generated/effective/runtime/route-bundle.lock.yml" \
  ".octon/generated/effective/capabilities/pack-routes.lock.yml"
validator_result_add_runtime_test \
  ".octon/framework/assurance/runtime/_ops/tests/test-runtime-effective-handle-negative-controls.sh"
validator_result_add_negative_control \
  "missing-allowed-consumer-denies" \
  "invalid-non-authority-classification-denies" \
  "invalid-freshness-mode-denies" \
  "missing-invalidation-conditions-denies"
validator_result_add_schema_version \
  "octon-runtime-effective-route-bundle-lock-v2" \
  "octon-runtime-effective-route-bundle-lock-v3" \
  "octon-runtime-pack-routes-lock-v1" \
  "octon-runtime-pack-routes-lock-v2"
[[ -n "${CONTRACT_PATH:-}" ]] && validator_result_add_contract "${CONTRACT_PATH#$OCTON_DIR/}"

echo "== Runtime Effective Artifact Handles Validation =="

[[ -f "$ROUTE_LOCK" ]] && pass "runtime route lock present" || fail "missing runtime route lock"
[[ -f "$PACK_LOCK" ]] && pass "pack routes lock present" || fail "missing pack routes lock"
[[ -n "${CONTRACT_PATH:-}" ]] && pass "runtime-effective handle contract present" || fail "missing runtime-effective handle contract"

if [[ -f "$ROUTE_LOCK" ]]; then
  check_route_lock_schema "$ROUTE_LOCK"
  check_mode "$ROUTE_LOCK" "runtime route lock"
  check_common_handle_fields "$ROUTE_LOCK" "runtime route lock"
  yq -e '.source_digests.root_manifest_sha256' "$ROUTE_LOCK" >/dev/null 2>&1 \
    && pass "runtime route lock records root manifest digest" \
    || fail "runtime route lock missing root manifest digest"
  yq -e '.source_digests.extensions_catalog_sha256' "$ROUTE_LOCK" >/dev/null 2>&1 \
    && pass "runtime route lock records extensions catalog digest" \
    || fail "runtime route lock missing extensions catalog digest"
  yq -e '.source_digests.support_target_matrix_sha256' "$ROUTE_LOCK" >/dev/null 2>&1 \
    && pass "runtime route lock records support target matrix digest" \
    || fail "runtime route lock missing support target matrix digest"
  check_dependency_handles "$ROUTE_LOCK" "runtime route lock"
fi

if [[ -f "$PACK_LOCK" ]]; then
  check_pack_lock_schema "$PACK_LOCK"
  check_mode "$PACK_LOCK" "pack routes lock"
  check_common_handle_fields "$PACK_LOCK" "pack routes lock"
  yq -e '.root_manifest_sha256' "$PACK_LOCK" >/dev/null 2>&1 \
    && pass "pack routes lock records root manifest digest" \
    || fail "pack routes lock missing root manifest digest"
fi

echo "Validation summary: errors=$errors"
if [[ $errors -eq 0 ]]; then
  emit_validator_result "validate-runtime-effective-artifact-handles.sh" "runtime_effective_handles" "runtime" "runtime" "pass"
else
  emit_validator_result "validate-runtime-effective-artifact-handles.sh" "runtime_effective_handles" "runtime" "existence" "fail"
fi
[[ $errors -eq 0 ]]

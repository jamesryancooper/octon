#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
ROOT_DIR="${OCTON_ROOT_DIR:-$(cd -- "$OCTON_DIR/.." && pwd)}"

errors=0
fail() { echo "[ERROR] $1"; errors=$((errors + 1)); }
pass() { echo "[OK] $1"; }

require_file() {
  local path="$1"
  [[ -f "$path" ]] && pass "present: ${path#$ROOT_DIR/}" || fail "missing file: ${path#$ROOT_DIR/}"
}

has_text() {
  local text="$1" file="$2"
  if command -v rg >/dev/null 2>&1; then
    rg -Fq -- "$text" "$file"
  else
    grep -Fq -- "$text" "$file"
  fi
}

TOKEN_V1="$OCTON_DIR/framework/engine/runtime/spec/authorized-effect-token-v1.md"
TOKEN_V2="$OCTON_DIR/framework/engine/runtime/spec/authorized-effect-token-v2.schema.json"
TOKEN_CONSUMPTION="$OCTON_DIR/framework/engine/runtime/spec/authorized-effect-token-consumption-v1.schema.json"
INVENTORY="$OCTON_DIR/framework/engine/runtime/spec/material-side-effect-inventory.yml"
INVENTORY_SCHEMA="$OCTON_DIR/framework/engine/runtime/spec/material-side-effect-inventory-v1.schema.json"
COVERAGE_MAP="$OCTON_DIR/framework/engine/runtime/spec/authorization-boundary-coverage.yml"
EVENT_SCHEMA="$OCTON_DIR/framework/engine/runtime/spec/runtime-event-v1.schema.json"
RECEIPT_SCHEMA="$OCTON_DIR/framework/engine/runtime/spec/execution-receipt-v3.schema.json"
TOKEN_FIXTURES="$OCTON_DIR/framework/assurance/runtime/_ops/fixtures/authorized-effect-token-enforcement/fixture-set.yml"
AUTHORITY_ENGINE_TESTS="$OCTON_DIR/framework/engine/runtime/crates/authority_engine/src/implementation/tests.rs"

echo "== Authorized Effect Token Enforcement Validation =="

command -v yq >/dev/null 2>&1 || {
  echo "[ERROR] yq is required"
  exit 1
}

require_file "$TOKEN_V1"
require_file "$TOKEN_V2"
require_file "$TOKEN_CONSUMPTION"
require_file "$INVENTORY"
require_file "$INVENTORY_SCHEMA"
require_file "$COVERAGE_MAP"
require_file "$EVENT_SCHEMA"
require_file "$RECEIPT_SCHEMA"
require_file "$TOKEN_FIXTURES"
require_file "$AUTHORITY_ENGINE_TESTS"

has_text "VerifiedEffect<T>" "$TOKEN_V1" \
  && pass "token contract requires VerifiedEffect<T>" \
  || fail "token contract must require VerifiedEffect<T>"

has_text "\"authorized_effects\"" "$RECEIPT_SCHEMA" \
  && pass "execution receipt schema exposes authorized_effects" \
  || fail "execution receipt schema must expose authorized_effects"

for event_name in \
  effect_token.requested \
  effect_token.minted \
  effect_token.denied \
  effect_token.consumption_requested \
  effect_token.consumed \
  effect_token.rejected \
  effect_token.expired \
  effect_token.revoked
do
  has_text "$event_name" "$EVENT_SCHEMA" \
    && pass "runtime-event-v1 declares $event_name" \
    || fail "runtime-event-v1 must declare $event_name"
done

while IFS='|' read -r case_id expected_reason; do
  [[ -n "$case_id" ]] || continue
  actual_reason="$(yq -r ".cases[] | select(.case_id == \"$case_id\") | (.denial_reason // \"null\")" "$TOKEN_FIXTURES" | head -1)"
  backing_test="$(yq -r ".cases[] | select(.case_id == \"$case_id\") | (.backing_rust_test // \"\")" "$TOKEN_FIXTURES" | head -1)"
  if [[ "$actual_reason" == "$expected_reason" ]]; then
    pass "fixture case $case_id maps to $expected_reason"
  else
    fail "fixture case $case_id must map to $expected_reason"
  fi
  if [[ -n "$backing_test" ]] && has_text "fn $backing_test" "$AUTHORITY_ENGINE_TESTS"; then
    pass "fixture case $case_id has backing Rust test $backing_test"
  else
    fail "fixture case $case_id missing backing Rust test"
  fi
done <<'CASES'
valid_token_consumes|null
missing_token|missing_token
decision_not_allow|decision_not_allow
wrong_effect_class|wrong_effect_class
wrong_run|wrong_run
wrong_route|wrong_route
stale_token|stale_token
wrong_support_tuple|wrong_support_tuple
support_envelope_blocked|wrong_support_tuple
unsupported_tuple|unsupported_tuple
excluded_tuple|excluded_tuple
wrong_capability_pack|wrong_capability_pack
wrong_scope|wrong_scope
expired_token|expired_token
revoked_token|revoked_token
missing_approval|missing_approval
missing_exception|missing_exception
rollback_not_ready|rollback_not_ready
budget_exceeded|budget_exceeded
egress_denied|egress_denied
already_consumed|already_consumed
CASES

while IFS=$'\t' read -r class_id token_type owner risk material; do
  [[ -n "$class_id" ]] || continue
  [[ -n "$token_type" ]] && pass "$class_id token type present" || fail "$class_id missing token type"
  [[ -n "$owner" ]] && pass "$class_id owner present" || fail "$class_id missing owner"
  [[ -n "$risk" ]] && pass "$class_id risk tier present" || fail "$class_id missing risk tier"
  [[ "$material" == "true" || "$material" == "false" ]] \
    && pass "$class_id material flag present" \
    || fail "$class_id missing material flag"
done < <(yq -r '.classes[] | [.id, .token_type, .owner, .risk_tier, (.material|tostring)] | @tsv' "$INVENTORY")

while IFS=$'\t' read -r path_id class_id owner_ref consumer_api_ref negative_ref token_required coverage_state; do
  [[ -n "$path_id" ]] || continue
  yq -e ".classes[] | select(.id == \"$class_id\")" "$INVENTORY" >/dev/null 2>&1 \
    && pass "$path_id class binding present" \
    || fail "$path_id class binding missing"
  [[ -n "$owner_ref" ]] && pass "$path_id owner ref present" || fail "$path_id missing owner ref"
  [[ -n "$consumer_api_ref" ]] && pass "$path_id consumer api ref present" || fail "$path_id missing consumer api ref"
  [[ -n "$negative_ref" ]] && pass "$path_id negative bypass ref present" || fail "$path_id missing negative bypass ref"
  [[ "$token_required" == "true" || "$token_required" == "false" ]] \
    && pass "$path_id token_required present" \
    || fail "$path_id missing token_required"
  [[ -n "$coverage_state" ]] && pass "$path_id coverage_state present" || fail "$path_id missing coverage_state"

  if [[ "$coverage_state" == "live" ]]; then
    if yq -e ".paths[] | select(.path_id == \"$path_id\")" "$COVERAGE_MAP" >/dev/null 2>&1; then
      pass "$path_id coverage map entry present"
    else
      fail "$path_id missing from authorization-boundary-coverage.yml"
      continue
    fi

    if [[ "$token_required" == "true" ]]; then
      yq -e ".paths[] | select(.path_id == \"$path_id\" and (.authorized_effect_token_type // \"\") != \"\")" "$COVERAGE_MAP" >/dev/null 2>&1 \
        && pass "$path_id token mediation present" \
        || fail "$path_id missing authorized_effect_token_type"
    fi
  else
    pass "$path_id is explicitly non-live: $coverage_state"
  fi
done < <(yq -r '.paths[] | [.path_id, .class_id, .owner_ref, .consumer_api_ref, .negative_bypass_test_ref, (.token_required|tostring), .coverage_state] | @tsv' "$INVENTORY")

echo "Validation summary: errors=$errors"
[[ $errors -eq 0 ]]

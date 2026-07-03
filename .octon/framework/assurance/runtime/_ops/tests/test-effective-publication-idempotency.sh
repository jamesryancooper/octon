#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../../../../../.." && pwd)"
TEST_NAME="$(basename "$0")"

ROUTE_PUBLISHER="$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/generate-runtime-effective-route-bundle.sh"
PACK_PUBLISHER="$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/generate-pack-routes.sh"
CAPABILITY_PUBLISHER="$ROOT_DIR/.octon/framework/capabilities/_ops/scripts/publish-capability-routing.sh"

pass_count=0
fail_count=0

pass() {
  echo "PASS: $1"
  pass_count=$((pass_count + 1))
}

fail() {
  echo "FAIL: $1" >&2
  fail_count=$((fail_count + 1))
}

assert_file_contains() {
  local label="$1" file="$2" pattern="$3"
  if rg -q "$pattern" "$file"; then
    pass "$label"
  else
    fail "$label"
  fi
}

assert_file_lacks() {
  local label="$1" file="$2" pattern="$3"
  if rg -q "$pattern" "$file"; then
    fail "$label"
  else
    pass "$label"
  fi
}

case_publishers_use_common_write_suppression() {
  local publisher
  for publisher in "$ROUTE_PUBLISHER" "$PACK_PUBLISHER" "$CAPABILITY_PUBLISHER"; do
    assert_file_contains "$(basename "$publisher") sources common idempotency helper" "$publisher" 'generator-idempotency-common\.sh'
    assert_file_contains "$(basename "$publisher") writes through common helper" "$publisher" 'octon_churn_write_file_if_changed'
  done
}

case_timestamped_publishers_reuse_noop_receipt_identity() {
  local publisher
  for publisher in "$ROUTE_PUBLISHER" "$PACK_PUBLISHER"; do
    assert_file_contains "$(basename "$publisher") normalizes volatile publication fields" "$publisher" 'normalize_effective_publication_payload'
    assert_file_contains "$(basename "$publisher") reuses publication values for no-op payloads" "$publisher" 'maybe_reuse_publication_values'
    assert_file_contains "$(basename "$publisher") preserves existing receipt path" "$publisher" 'publication_receipt_path'
    assert_file_lacks "$(basename "$publisher") no direct output copy remains" "$publisher" 'cp "\$tmp_out" "\$OUT_FILE"'
    assert_file_lacks "$(basename "$publisher") no direct lock copy remains" "$publisher" 'cp "\$tmp_lock" "\$LOCK_FILE"'
  done
}

main() {
  case_publishers_use_common_write_suppression
  case_timestamped_publishers_reuse_noop_receipt_identity

  echo
  echo "$TEST_NAME: passed=$pass_count failed=$fail_count"
  [[ "$fail_count" -eq 0 ]]
}

main "$@"

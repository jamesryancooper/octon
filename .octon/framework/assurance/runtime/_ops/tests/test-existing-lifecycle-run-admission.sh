#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../../../../../.." && pwd)"
VALIDATOR="$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-existing-lifecycle-run-admission.sh"
CARGO_MANIFEST="$ROOT_DIR/.octon/framework/engine/runtime/crates/Cargo.toml"

pass_count=0
fail_count=0
pass() { echo "PASS: $1"; pass_count=$((pass_count + 1)); }
fail() { echo "FAIL: $1" >&2; fail_count=$((fail_count + 1)); }

if bash "$VALIDATOR"; then
  pass "static admission contract validates"
else
  fail "static admission contract validates"
fi

if cargo test --quiet --manifest-path "$CARGO_MANIFEST" -p octon_kernel lifecycle_run_admission::tests; then
  pass "kernel admission positive and negative matrix passes"
else
  fail "kernel admission positive and negative matrix passes"
fi

# The compatibility flag is deliberately set while exercising the new route's
# tests. It must not become provenance or bypass any admission predicate.
if OCTON_WORKFLOW_RUN_COMPAT=1 cargo test --quiet --manifest-path "$CARGO_MANIFEST" -p octon_kernel lifecycle_run_admission::tests; then
  pass "compatibility environment does not authorize lifecycle binding"
else
  fail "compatibility environment does not authorize lifecycle binding"
fi

echo "Test summary: pass=$pass_count fail=$fail_count"
[[ $fail_count -eq 0 ]]

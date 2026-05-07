#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "$SCRIPT_DIR/../../../../../.." && pwd)"
CARGO_MANIFEST="$REPO_ROOT/.octon/framework/engine/runtime/crates/Cargo.toml"
LIFECYCLE_RS="$REPO_ROOT/.octon/framework/engine/runtime/crates/kernel/src/lifecycle.rs"

pass_count=0
fail_count=0

pass() { printf 'PASS: %s\n' "$1"; pass_count=$((pass_count + 1)); }
fail() { printf 'FAIL: %s\n' "$1" >&2; fail_count=$((fail_count + 1)); }

main() {
  if cargo test --manifest-path "$CARGO_MANIFEST" -p octon_lifecycle_executor; then
    pass "lifecycle executor adapter crate tests pass"
  else
    fail "lifecycle executor adapter crate tests pass"
  fi

  if ! rg -n 'Command::new\("(codex|claude)"|find_binary\("(codex|claude)"' "$LIFECYCLE_RS" >/dev/null; then
    pass "lifecycle.rs has no direct Codex or Claude process execution"
  else
    fail "lifecycle.rs has no direct Codex or Claude process execution"
  fi

  printf '\nPassed: %s\nFailed: %s\n' "$pass_count" "$fail_count"
  [[ "$fail_count" -eq 0 ]]
}

main "$@"

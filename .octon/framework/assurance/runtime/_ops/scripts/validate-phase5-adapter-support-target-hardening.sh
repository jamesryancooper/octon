#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"

errors=0
fail() { echo "[ERROR] $1"; errors=$((errors + 1)); }
pass() { echo "[OK] $1"; }
run_test() { "$@" >/dev/null 2>&1 && pass "$1" || fail "$1"; }

main() {
  echo "== Global Adapter And Pack Certification Validation =="

  bash "$SCRIPT_DIR/validate-execution-role-adapter-hardening.sh"

  cargo test --manifest-path "$OCTON_DIR/framework/engine/runtime/crates/Cargo.toml" -p octon_kernel authorization::tests::admitted_api_pack_allows_declared_execution -- --exact >/dev/null 2>&1 && pass "kernel admits declared api pack" || fail "kernel admits declared api pack"
  cargo test --manifest-path "$OCTON_DIR/framework/engine/runtime/crates/Cargo.toml" -p octon_kernel authorization::tests::admitted_browser_pack_allows_declared_execution -- --exact >/dev/null 2>&1 && pass "kernel admits declared browser pack" || fail "kernel admits declared browser pack"
  cargo test --manifest-path "$OCTON_DIR/framework/engine/runtime/crates/Cargo.toml" -p octon_kernel authorization::tests::undeclared_host_adapter_denies_execution -- --exact >/dev/null 2>&1 && pass "kernel denies undeclared host adapter" || fail "kernel denies undeclared host adapter"
  cargo test --manifest-path "$OCTON_DIR/framework/engine/runtime/crates/Cargo.toml" -p octon_kernel authorization::tests::invalid_model_adapter_manifest_denies_execution -- --exact >/dev/null 2>&1 && pass "kernel denies invalid model adapter manifest" || fail "kernel denies invalid model adapter manifest"

  echo "Validation summary: errors=$errors"
  [[ $errors -eq 0 ]]
}

main "$@"

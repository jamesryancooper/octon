#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
ROOT_DIR="${OCTON_ROOT_DIR:-$(cd -- "$OCTON_DIR/.." && pwd)}"
ROOT_MANIFEST="$OCTON_DIR/octon.yml"

errors=0

fail() {
  echo "[ERROR] $1"
  errors=$((errors + 1))
}

pass() {
  echo "[OK] $1"
}

run_validator() {
  local label="$1"
  local script="$2"
  if OCTON_DIR_OVERRIDE="$OCTON_DIR" OCTON_ROOT_DIR="$ROOT_DIR" bash "$script" >/dev/null; then
    pass "$label"
  else
    fail "$label"
  fi
}

main() {
  echo "== Runtime Effective State Validation =="

  if [[ ! -f "$ROOT_MANIFEST" ]]; then
    fail "missing root manifest: ${ROOT_MANIFEST#$ROOT_DIR/}"
    echo "Validation summary: errors=$errors"
    exit 1
  fi

  if [[ "$(yq -r '.policies.raw_input_dependency // ""' "$ROOT_MANIFEST")" == "fail-closed" ]]; then
    pass "root manifest raw_input_dependency policy is fail-closed"
  else
    fail "root manifest raw_input_dependency policy must be fail-closed"
  fi

  if [[ "$(yq -r '.policies.generated_staleness // ""' "$ROOT_MANIFEST")" == "fail-closed" ]]; then
    pass "root manifest generated_staleness policy is fail-closed"
  else
    fail "root manifest generated_staleness policy must be fail-closed"
  fi

  run_validator \
    "harness version and root manifest schema state are current" \
    "$SCRIPT_DIR/validate-harness-version-contract.sh"
  run_validator \
    "root manifest class-root and profile bindings are current" \
    "$SCRIPT_DIR/validate-root-manifest-profiles.sh"
  run_validator \
    "framework and instance companion manifests are current" \
    "$SCRIPT_DIR/validate-companion-manifests.sh"
  run_validator \
    "raw-input dependency ban holds for runtime and governance surfaces" \
    "$SCRIPT_DIR/validate-raw-input-dependency-ban.sh"
  run_validator \
    "locality publication state is current and coherent" \
    "$SCRIPT_DIR/validate-locality-publication-state.sh"
  run_validator \
    "extension publication state is current and coherent" \
    "$SCRIPT_DIR/validate-extension-publication-state.sh"
  run_validator \
    "capability publication state is current and coherent" \
    "$SCRIPT_DIR/validate-capability-publication-state.sh"
  run_validator \
    "execution governance contracts and protected CI posture are current" \
    "$SCRIPT_DIR/validate-execution-governance.sh"

  echo "Validation summary: errors=$errors"
  if [[ $errors -gt 0 ]]; then
    exit 1
  fi
}

main "$@"

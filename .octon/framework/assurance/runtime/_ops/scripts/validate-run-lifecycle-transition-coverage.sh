#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
ROOT_DIR="${OCTON_ROOT_DIR:-$(cd -- "$OCTON_DIR/.." && pwd)}"
MAIN_RS="$OCTON_DIR/framework/engine/runtime/crates/kernel/src/main.rs"
COMMANDS_RS="$OCTON_DIR/framework/engine/runtime/crates/kernel/src/commands/mod.rs"
LIFECYCLE_SPEC="$OCTON_DIR/framework/engine/runtime/spec/run-lifecycle-v1.md"

errors=0

fail() {
  echo "[ERROR] $1"
  errors=$((errors + 1))
}

pass() {
  echo "[OK] $1"
}

main() {
  echo "== Run Lifecycle Transition Coverage Validation =="

  [[ -f "$LIFECYCLE_SPEC" ]] && pass "run lifecycle spec present" || fail "missing run lifecycle spec"
  [[ -f "$MAIN_RS" ]] && pass "kernel CLI present" || fail "missing kernel CLI"

  if grep -Fq 'Start {' "$MAIN_RS"; then pass "kernel CLI exposes run start"; else fail "kernel CLI must expose run start"; fi
  if grep -Fq 'Inspect {' "$MAIN_RS"; then pass "kernel CLI exposes run inspect"; else fail "kernel CLI must expose run inspect"; fi
  if grep -Fq 'Checkpoint {' "$MAIN_RS"; then pass "kernel CLI exposes run checkpoint"; else fail "kernel CLI must expose run checkpoint"; fi
  if grep -Fq 'Disclose {' "$MAIN_RS"; then pass "kernel CLI exposes run disclose"; else fail "kernel CLI must expose run disclose"; fi
  if grep -Fq 'Close {' "$MAIN_RS"; then pass "kernel CLI exposes run close"; else fail "kernel CLI must expose run close"; fi
  if grep -Fq 'Replay {' "$MAIN_RS"; then pass "kernel CLI exposes run replay"; else fail "kernel CLI must expose run replay"; fi

  bash "$SCRIPT_DIR/validate-runtime-lifecycle-normalization.sh" >/dev/null \
    && pass "runtime lifecycle normalization passes" \
    || fail "runtime lifecycle normalization failed"
  bash "$SCRIPT_DIR/validate-evidence-completeness.sh" >/dev/null \
    && pass "evidence completeness passes" \
    || fail "evidence completeness failed"

  echo "Validation summary: errors=$errors"
  [[ $errors -eq 0 ]]
}

main "$@"

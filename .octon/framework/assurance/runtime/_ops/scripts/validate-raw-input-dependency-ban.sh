#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
ROOT_DIR="$(cd -- "$OCTON_DIR/.." && pwd)"

errors=0

fail() {
  echo "[ERROR] $1"
  errors=$((errors + 1))
}

pass() {
  echo "[OK] $1"
}

main() {
  echo "== Raw Input Dependency Validation =="

  local targets=(
    "$OCTON_DIR/framework/engine/governance"
    "$OCTON_DIR/framework/engine/runtime/policy"
    "$OCTON_DIR/framework/assurance/governance"
    "$OCTON_DIR/framework/capabilities/governance"
    "$OCTON_DIR/framework/cognition/governance"
  )

  local matches
  local existing_targets=()
  local target
  for target in "${targets[@]}"; do
    [[ -e "$target" ]] && existing_targets+=("$target")
  done

  matches="$(
    rg -n \
      -g '*.md' -g '*.yml' -g '*.yaml' -g '*.json' -g '*.sh' \
      '(\.octon/inputs/(additive|exploratory)/|inputs/(additive|exploratory)/)' \
      "${existing_targets[@]}" || true
  )"

  if [[ -z "$matches" ]]; then
    pass "no raw inputs/** runtime or governance dependencies detected"
  else
    while IFS= read -r line; do
      [[ -z "$line" ]] && continue
      fail "raw input dependency detected: ${line#$ROOT_DIR/}"
    done <<< "$matches"
  fi

  echo "Validation summary: errors=$errors"
  if [[ $errors -gt 0 ]]; then
    exit 1
  fi
}

main "$@"

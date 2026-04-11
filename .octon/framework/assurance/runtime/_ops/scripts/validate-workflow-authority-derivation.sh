#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
ROOT_DIR="$(cd -- "$DEFAULT_OCTON_DIR/.." && pwd)"

errors=0

fail() {
  echo "[ERROR] $1" >&2
  errors=$((errors + 1))
}

pass() {
  echo "[OK] $1"
}

echo "== Workflow Authority Derivation Validation =="

has_authority_refs() {
  local file="$1"
  local pattern='\.octon/state/control/execution|\.octon/state/evidence/control/execution'
  if command -v rg >/dev/null 2>&1; then
    rg -n "$pattern" "$file" >/dev/null 2>&1
  else
    grep -En "$pattern" "$file" >/dev/null 2>&1
  fi
}

for rel in \
  .github/workflows/pr-autonomy-policy.yml \
  .github/workflows/ai-review-gate.yml \
  .github/workflows/closure-certification.yml \
  .github/workflows/uec-cutover-validate.yml \
  .github/workflows/uec-cutover-certify.yml \
  .github/workflows/unified-execution-constitution-closure.yml; do
  file="$ROOT_DIR/$rel"
  [[ -f "$file" ]] || continue
  if has_authority_refs "$file"; then
    pass "$rel references canonical authority artifacts"
  else
    fail "$rel does not visibly derive authority from canonical artifacts"
  fi
done

echo "Validation summary: errors=$errors"
[[ $errors -eq 0 ]]

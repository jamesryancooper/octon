#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

validators=(
  "validate-architecture-conformance.sh"
  "validate-runtime-resolution.sh"
  "validate-runtime-effective-route-bundle.sh"
  "validate-material-side-effect-inventory.sh"
  "validate-authorization-boundary-coverage.sh"
  "validate-run-lifecycle-transition-coverage.sh"
  "validate-support-target-path-normalization.sh"
  "validate-support-target-proofing.sh"
  "validate-support-pack-admission-alignment.sh"
  "validate-publication-freshness-gates.sh"
  "validate-extension-active-state-compactness.sh"
  "validate-operator-read-models.sh"
  "validate-compatibility-retirement-readiness.sh"
  "validate-operator-boot-surface.sh"
  "validate-proof-plane-completeness.sh"
)

errors=0
passes=0

run_validator() {
  local validator="$1"
  if bash "$SCRIPT_DIR/$validator" >/dev/null; then
    echo "- PASS \`$validator\`"
    passes=$((passes + 1))
  else
    echo "- FAIL \`$validator\`"
    errors=$((errors + 1))
  fi
}

echo "## Architecture Health"
for validator in "${validators[@]}"; do
  run_validator "$validator"
done
echo
echo "Summary: pass=$passes fail=$errors"
[[ $errors -eq 0 ]]

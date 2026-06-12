#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd -- "$SCRIPT_DIR/../../../../../.." && pwd)"
FIXTURE_DIR="$ROOT_DIR/.octon/framework/assurance/runtime/_ops/fixtures/architectural-review"
RECEIPT_VALIDATOR="$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-receipts.sh"

bash "$RECEIPT_VALIDATOR" \
  --receipt "$FIXTURE_DIR/valid-pre-integration-receipt.yml" \
  --mode pre-integration-architecture-review \
  --require-pass

if bash "$RECEIPT_VALIDATOR" \
  --receipt "$FIXTURE_DIR/invalid-placeholder-receipt.yml" \
  --mode pre-integration-architecture-review \
  --require-pass >/tmp/architectural-review-invalid-placeholder.out 2>&1; then
  cat /tmp/architectural-review-invalid-placeholder.out >&2
  echo "[ERROR] invalid placeholder receipt passed" >&2
  exit 1
fi

bash "$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-naming.sh"
bash "$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-routing.sh"
bash "$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-workflows.sh"
bash "$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-lifecycle-gates.sh"
bash "$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-extension-split.sh"
bash "$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-skills-commands.sh"

echo "[OK] architectural review validator fixtures passed"

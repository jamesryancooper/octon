#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../../../../../.." && pwd)"
VALIDATOR="$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-change-closeout-lifecycle-alignment.sh"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf -- "$TMP_DIR"' EXIT

bash "$VALIDATOR"

jq -n '{selected_route:"branch-no-pr",target_lifecycle_outcome:"preserved",lifecycle_outcome:"preserved",cleanup_status:"not_applicable",rollback_handle:"refs/heads/candidate"}' >"$TMP_DIR/valid.json"
bash "$VALIDATOR" --receipt "$TMP_DIR/valid.json"

jq '.selected_route="direct-main"' "$TMP_DIR/valid.json" >"$TMP_DIR/direct-main.json"
if bash "$VALIDATOR" --receipt "$TMP_DIR/direct-main.json" >/dev/null 2>&1; then
  echo "FAIL: direct-main receipt passed" >&2
  exit 1
fi

jq '.target_lifecycle_outcome="cleaned" | .lifecycle_outcome="cleaned" | .cleanup_status="completed"' "$TMP_DIR/valid.json" >"$TMP_DIR/cleaned.json"
if bash "$VALIDATOR" --receipt "$TMP_DIR/cleaned.json" >/dev/null 2>&1; then
  echo "FAIL: cleaned receipt passed" >&2
  exit 1
fi

echo "PASS: lifecycle validator rejects direct-main and cleaned claims"

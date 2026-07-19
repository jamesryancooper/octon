#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../../../../../.." && pwd)"
VALIDATOR="$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-closeout-worktree-wrapper.sh"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf -- "$TMP_DIR"' EXIT

bash "$VALIDATOR"

cat >"$TMP_DIR/valid.yml" <<'YAML'
schema_version: closeout-worktree-report-v1
target_lifecycle_outcome: preserved
worktree_terminal_state: disposition_complete_with_retained_residue
publication_denial_reason: RP00_CONTAINMENT_PUBLICATION_DISABLED
cleanup_denial_reason: RP00_CONTAINMENT_CLEANUP_DISABLED
YAML
bash "$VALIDATOR" --report "$TMP_DIR/valid.yml"

sed 's/target_lifecycle_outcome: preserved/target_lifecycle_outcome: cleaned/' "$TMP_DIR/valid.yml" >"$TMP_DIR/invalid.yml"
if bash "$VALIDATOR" --report "$TMP_DIR/invalid.yml" >/dev/null 2>&1; then
  echo "FAIL: cleaned wrapper report passed" >&2
  exit 1
fi

echo "PASS: worktree wrapper rejects effectful terminal outcomes"

#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"

OBJECTIVE="$OCTON_DIR/framework/constitution/contracts/objective/README.md"
DISCLOSURE="$OCTON_DIR/framework/constitution/contracts/disclosure/README.md"

errors=0
fail() { echo "[ERROR] $1"; errors=$((errors + 1)); }
pass() { echo "[OK] $1"; }

echo "== Contract Family Version Coherence Validation =="
/usr/bin/grep -Fq 'run-contract-v3.schema.json' "$OBJECTIVE" && pass "objective family names run-contract-v3 as canonical-active" || fail "objective family does not name run-contract-v3 as canonical-active"
/usr/bin/grep -Fq 'stage-attempt-v2.schema.json' "$OBJECTIVE" && pass "objective family names stage-attempt-v2 as canonical-active" || fail "objective family does not name stage-attempt-v2 as canonical-active"
/usr/bin/grep -Fq 'run-card-v2.schema.json' "$DISCLOSURE" && pass "disclosure family names run-card-v2 as canonical-active" || fail "disclosure family does not name run-card-v2 as canonical-active"
/usr/bin/grep -Fq 'harness-card-v2.schema.json' "$DISCLOSURE" && pass "disclosure family names harness-card-v2 as canonical-active" || fail "disclosure family does not name harness-card-v2 as canonical-active"

echo "Validation summary: errors=$errors"
[[ $errors -eq 0 ]]

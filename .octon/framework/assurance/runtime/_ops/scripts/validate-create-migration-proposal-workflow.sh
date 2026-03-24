#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ASSURANCE_DIR="$(cd -- "$SCRIPT_DIR/../../.." && pwd)"
OCTON_DIR="$(cd -- "$ASSURANCE_DIR/.." && pwd)"
WORKFLOW_DIR="$OCTON_DIR/orchestration/runtime/workflows/meta/create-migration-proposal"
WORKFLOW_MANIFEST="$OCTON_DIR/orchestration/runtime/workflows/manifest.yml"
WORKFLOW_REGISTRY="$OCTON_DIR/orchestration/runtime/workflows/registry.yml"
errors=0
fail(){ echo "[ERROR] $1"; errors=$((errors+1)); }
pass(){ echo "[OK] $1"; }
grep -Fq 'name: "create-migration-proposal"' "$WORKFLOW_DIR/workflow.yml" && pass "workflow id matches" || fail "workflow id matches"
grep -Fq 'generate-proposal-registry.sh' "$WORKFLOW_DIR/stages/03-scaffold-package.md" && pass "migration scaffold stage regenerates proposal registry" || fail "migration scaffold stage regenerates proposal registry"
grep -Fq 'validate-proposal-standard.sh' "$WORKFLOW_DIR/stages/04-validate-package.md" && pass "baseline proposal validator referenced" || fail "baseline proposal validator referenced"
grep -Fq 'validate-migration-proposal.sh' "$WORKFLOW_DIR/workflow.yml" && pass "migration validator referenced" || fail "migration validator referenced"
yq -e '.workflows[] | select(.id == "create-migration-proposal" and .path == "meta/create-migration-proposal/")' "$WORKFLOW_MANIFEST" >/dev/null 2>&1 && pass "manifest registration exists" || fail "manifest registration exists"
grep -Fq 'create-migration-proposal:' "$WORKFLOW_REGISTRY" && pass "registry entry exists" || fail "registry entry exists"
echo "Validation summary: errors=$errors"
[[ $errors -eq 0 ]]

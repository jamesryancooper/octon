#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ASSURANCE_DIR="$(cd -- "$SCRIPT_DIR/../../.." && pwd)"
OCTON_DIR="$(cd -- "$ASSURANCE_DIR/.." && pwd)"
WORKFLOW_DIR="$OCTON_DIR/orchestration/runtime/workflows/audit/audit-architecture-proposal"
WORKFLOW_MANIFEST="$OCTON_DIR/orchestration/runtime/workflows/manifest.yml"
WORKFLOW_REGISTRY="$OCTON_DIR/orchestration/runtime/workflows/registry.yml"
errors=0
fail(){ echo "[ERROR] $1"; errors=$((errors+1)); }
pass(){ echo "[OK] $1"; }
yq -e '.name == "audit-architecture-proposal"' "$WORKFLOW_DIR/workflow.yml" >/dev/null 2>&1 && pass "workflow id matches" || fail "workflow id matches"
grep -Fq 'validate-architecture-proposal.sh' "$WORKFLOW_DIR/workflow.yml" && pass "architecture validator referenced" || fail "architecture validator referenced"
grep -Fq 'implementation-simulation' "$WORKFLOW_DIR/workflow.yml" && pass "implementation simulation stage is active" || fail "implementation simulation stage is active"
grep -Fq 'specification-closure' "$WORKFLOW_DIR/workflow.yml" && pass "specification closure stage is active" || fail "specification closure stage is active"
grep -Fq 'implementation-grade-completeness-review.md' "$WORKFLOW_DIR/stages/08-specification-closure.md" && pass "completeness review receipt is produced" || fail "completeness review receipt is produced"
grep -Fq 'external-tool-integrity.yml' "$WORKFLOW_DIR/stages/01-configure.md" && pass "external-tool integrity policy is loaded" || fail "external-tool integrity policy is loaded"
grep -Fq 'External tools remain unmodified' "$WORKFLOW_DIR/stages/07-implementation-simulation.md" && pass "implementation simulation preserves external tools unmodified" || fail "implementation simulation preserves external tools unmodified"
grep -Fq 'modifying or reengineering an external tool' "$WORKFLOW_DIR/stages/08-specification-closure.md" && pass "specification closure rejects external-tool modification" || fail "specification closure rejects external-tool modification"
grep -Fq 'supported external interfaces' "$WORKFLOW_DIR/stages/12-verify.md" && pass "verification checks supported-interface use" || fail "verification checks supported-interface use"
yq -e '.workflows[] | select(.id == "audit-architecture-proposal" and .path == "audit/audit-architecture-proposal/")' "$WORKFLOW_MANIFEST" >/dev/null 2>&1 && pass "manifest registration exists" || fail "manifest registration exists"
grep -Fq 'audit-architecture-proposal:' "$WORKFLOW_REGISTRY" && pass "registry entry exists" || fail "registry entry exists"
echo "Validation summary: errors=$errors"
[[ $errors -eq 0 ]]

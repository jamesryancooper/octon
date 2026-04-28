#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
ROOT_DIR="${OCTON_ROOT_DIR:-$(cd -- "$OCTON_DIR/.." && pwd)}"
ARCH_WORKFLOW="$ROOT_DIR/.github/workflows/architecture-conformance.yml"
PHASE6_PLAN="$OCTON_DIR/instance/cognition/context/shared/migrations/2026-03-29-unified-execution-constitution-phase6-simplification-deletion/plan.md"
AGENCY_README="$OCTON_DIR/framework/execution-roles/README.md"
AGENCY_SPEC="$OCTON_DIR/framework/execution-roles/_meta/architecture/specification.md"
INGRESS="$OCTON_DIR/instance/ingress/AGENTS.md"
CONTRACT_REGISTRY="$OCTON_DIR/framework/constitution/contracts/registry.yml"
AI_GATE="$ROOT_DIR/.github/workflows/ai-review-gate.yml"
PR_AUTO_MERGE="$ROOT_DIR/.github/workflows/pr-auto-merge.yml"
PR_TRIAGE="$ROOT_DIR/.github/workflows/pr-triage.yml"
PR_CLEAN_STATE="$ROOT_DIR/.github/workflows/pr-clean-state-enforcer.yml"
PR_STALE_CLOSE="$ROOT_DIR/.github/workflows/pr-stale-close.yml"
GIT_PR_SHIP="$OCTON_DIR/framework/execution-roles/_ops/scripts/git/git-pr-ship.sh"
AI_GATE_AGGREGATE="$OCTON_DIR/framework/execution-roles/_ops/scripts/ai-gate/aggregate-decision.sh"
LABEL_SYNC="$OCTON_DIR/framework/execution-roles/_ops/scripts/github/sync-github-labels.sh"
EXECUTION_ROLE_VALIDATE_WORKFLOW="$ROOT_DIR/.github/workflows/execution-role-validate.yml"

errors=0

fail() {
  echo "[ERROR] $1"
  errors=$((errors + 1))
}

pass() {
  echo "[OK] $1"
}

require_file() {
  local path="$1"
  if [[ -f "$path" ]]; then
    pass "found ${path#$ROOT_DIR/}"
  else
    fail "missing ${path#$ROOT_DIR/}"
  fi
}

require_text() {
  local needle="$1"
  local file="$2"
  local label="$3"
  if command -v rg >/dev/null 2>&1; then
    if rg -Fq -- "$needle" "$file"; then
      pass "$label"
    else
      fail "$label"
    fi
  elif grep -Fq -- "$needle" "$file"; then
    pass "$label"
  else
    fail "$label"
  fi
}

forbid_text() {
  local needle="$1"
  local file="$2"
  local label="$3"
  if command -v rg >/dev/null 2>&1; then
    if rg -Fq -- "$needle" "$file"; then
      fail "$label"
    else
      pass "$label"
    fi
  elif grep -Fq -- "$needle" "$file"; then
    fail "$label"
  else
    pass "$label"
  fi
}

run_test() {
  local label="$1"
  shift
  if "$@" >/dev/null 2>&1; then
    pass "$label"
  else
    fail "$label"
  fi
}

main() {
  echo "== Unified Execution Constitution Phase 6 Validation =="

  require_file "$PHASE6_PLAN"
  require_file "$ARCH_WORKFLOW"
  require_file "$AGENCY_README"
  require_file "$AGENCY_SPEC"
  require_file "$INGRESS"
  require_file "$CONTRACT_REGISTRY"
  require_file "$AI_GATE"
  require_file "$PR_AUTO_MERGE"
  require_file "$PR_TRIAGE"
  require_file "$PR_CLEAN_STATE"
  require_file "$PR_STALE_CLOSE"
  require_file "$GIT_PR_SHIP"
  require_file "$AI_GATE_AGGREGATE"
  require_file "$LABEL_SYNC"

  require_text 'The execution-role kernel path is fixed:' "$AGENCY_README" "execution-role README publishes orchestrator-first kernel path"
  require_text 'Execution roles never authorize themselves.' "$AGENCY_SPEC" "execution-role specification documents engine-owned authorization boundary"
  forbid_text 'framework/execution-roles/governance/CONSTITUTION.md' "$INGRESS" "instance ingress excludes retired governance CONSTITUTION.md from kernel path"
  require_text '.octon/framework/execution-roles/runtime/orchestrator/ROLE.md' "$INGRESS" "instance ingress points at orchestrator contract"
  require_text 'historical-shim' "$CONTRACT_REGISTRY" "contract registry demotes duplicate constitutional shims"

  forbid_text 'SOUL.md' "$OCTON_DIR/framework/execution-roles/runtime/orchestrator/ROLE.md" "orchestrator contract no longer depends on SOUL.md"
  forbid_text 'SOUL.md' "$OCTON_DIR/framework/execution-roles/runtime/verifiers/independent-verifier/VERIFIER.md" "verifier contract no longer depends on SOUL.md"

  if [[ -f "$OCTON_DIR/framework/execution-roles/runtime/orchestrator/SOUL.md" || -f "$OCTON_DIR/framework/execution-roles/runtime/verifiers/independent-verifier/SOUL.md" ]]; then
    fail "active or scaffolded SOUL.md overlays remain in the kernel path"
  else
    pass "active and scaffolded SOUL.md overlays are retired"
  fi

  forbid_text 'labeled' "$AI_GATE" "AI review gate no longer triggers on label churn"
  forbid_text 'unlabeled' "$AI_GATE" "AI review gate no longer triggers on label churn"
  forbid_text 'projection-label' "$AI_GATE" "AI review gate no longer projects label authority"
  forbid_text 'ai-gate:' "$AI_GATE" "AI review gate no longer syncs ai-gate labels"
  forbid_text 'labeled' "$PR_AUTO_MERGE" "PR auto-merge no longer triggers on label churn"
  forbid_text 'unlabeled' "$PR_AUTO_MERGE" "PR auto-merge no longer triggers on label churn"
  forbid_text 'projection-label' "$PR_AUTO_MERGE" "PR auto-merge no longer projects autonomy labels"
  forbid_text 'autonomy:auto-merge' "$GIT_PR_SHIP" "git-pr-ship no longer adds autonomy lane labels"
  forbid_text 'autonomy:no-automerge' "$GIT_PR_SHIP" "git-pr-ship no longer removes autonomy lane labels"
  forbid_text 'ai-gate:required' "$LABEL_SYNC" "label sync no longer publishes ai-gate labels"
  forbid_text 'autonomy:auto-merge' "$LABEL_SYNC" "label sync no longer publishes autonomy lane labels"
  forbid_text '--labels-json' "$AI_GATE_AGGREGATE" "AI gate aggregation no longer depends on PR labels"
  forbid_text 'autonomy lane disabled' "$PR_CLEAN_STATE" "clean-state enforcer no longer uses autonomy:no-automerge as a reason"
  forbid_text 'autonomy:no-automerge' "$PR_STALE_CLOSE" "stale-close no longer exempts autonomy:no-automerge"

  require_text 'validate-phase6-simplification-deletion.sh' "$ARCH_WORKFLOW" "architecture conformance workflow enforces Phase 6 validator"
  require_text '.octon/framework/scaffolding/**' "$ARCH_WORKFLOW" "architecture conformance workflow triggers on scaffolding changes"

  run_test \
    "execution-role validator passes with orchestrator-first path" \
    bash "$OCTON_DIR/framework/execution-roles/_ops/scripts/validate/validate-execution-roles.sh"
  run_test \
    "execution-role label catalog validator passes after lane-label deletion" \
    bash "$OCTON_DIR/framework/execution-roles/_ops/scripts/validate/validate-autonomy-labels.sh"
  run_test \
    "bootstrap ingress validator passes" \
    bash "$OCTON_DIR/framework/assurance/runtime/_ops/scripts/validate-bootstrap-ingress.sh"
  run_test \
    "execution governance validator script parses after label-lane removal" \
    bash -n "$OCTON_DIR/framework/assurance/runtime/_ops/scripts/validate-execution-governance.sh"
  run_test \
    "harness structure validator passes" \
    bash "$OCTON_DIR/framework/assurance/runtime/_ops/scripts/validate-harness-structure.sh"
  run_test \
    "AI review gate workflow remains valid YAML" \
    yq -e '.' "$AI_GATE"
  run_test \
    "PR auto-merge workflow remains valid YAML" \
    yq -e '.' "$PR_AUTO_MERGE"
  run_test \
    "PR triage workflow remains valid YAML" \
    yq -e '.' "$PR_TRIAGE"
  run_test \
    "execution-role validate workflow remains valid YAML" \
    yq -e '.' "$EXECUTION_ROLE_VALIDATE_WORKFLOW"
  run_test \
    "architecture conformance workflow remains valid YAML" \
    yq -e '.' "$ARCH_WORKFLOW"
  run_test \
    "AI gate aggregator script parses" \
    bash -n "$AI_GATE_AGGREGATE"
  run_test \
    "git-pr-ship script parses" \
    bash -n "$GIT_PR_SHIP"
  run_test \
    "label sync script parses" \
    bash -n "$LABEL_SYNC"
  run_test \
    "label validator script parses" \
    bash -n "$OCTON_DIR/framework/execution-roles/_ops/scripts/validate/validate-autonomy-labels.sh"
  run_test \
    "Phase 6 validator script parses" \
    bash -n "$OCTON_DIR/framework/assurance/runtime/_ops/scripts/validate-phase6-simplification-deletion.sh"
  run_test \
    "git diff check is clean" \
    git diff --check

  echo "Validation summary: errors=$errors"
  [[ $errors -eq 0 ]]
}

main "$@"

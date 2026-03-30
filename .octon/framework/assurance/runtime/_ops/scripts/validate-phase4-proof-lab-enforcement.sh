#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
ROOT_DIR="${OCTON_ROOT_DIR:-$(cd -- "$OCTON_DIR/.." && pwd)}"

ASSURANCE_FAMILY="$OCTON_DIR/framework/constitution/contracts/assurance/family.yml"
AI_REVIEW_GATE="$ROOT_DIR/.github/workflows/ai-review-gate.yml"
ARCH_WORKFLOW="$ROOT_DIR/.github/workflows/architecture-conformance.yml"
EVALUATOR_REGISTRY="$OCTON_DIR/framework/assurance/evaluators/adapters/registry.yml"
RUN3_BEHAVIORAL="$OCTON_DIR/state/evidence/runs/run-wave3-runtime-bridge-20260327/assurance/behavioral.yml"
RUN3_RECOVERY="$OCTON_DIR/state/evidence/runs/run-wave3-runtime-bridge-20260327/assurance/recovery.yml"
RUN3_FUNCTIONAL="$OCTON_DIR/state/evidence/runs/run-wave3-runtime-bridge-20260327/assurance/functional.yml"
RUN3_FUNCTIONAL_EXEC="$OCTON_DIR/state/evidence/runs/run-wave3-runtime-bridge-20260327/assurance/functional-suite-execution.yml"
RUN3_BEHAVIORAL_EXEC="$OCTON_DIR/state/evidence/runs/run-wave3-runtime-bridge-20260327/assurance/behavioral-suite-execution.yml"
RUN3_RECOVERY_EXEC="$OCTON_DIR/state/evidence/runs/run-wave3-runtime-bridge-20260327/assurance/recovery-suite-execution.yml"
RUN4_MAINTAINABILITY="$OCTON_DIR/state/evidence/runs/run-wave4-benchmark-evaluator-20260327/assurance/maintainability.yml"
RUN4_MAINTAINABILITY_EXEC="$OCTON_DIR/state/evidence/runs/run-wave4-benchmark-evaluator-20260327/assurance/maintainability-suite-execution.yml"
RUN4_EVALUATOR="$OCTON_DIR/state/evidence/runs/run-wave4-benchmark-evaluator-20260327/assurance/evaluator.yml"

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

require_dir() {
  local path="$1"
  if [[ -d "$path" ]]; then
    pass "found ${path#$ROOT_DIR/}"
  else
    fail "missing ${path#$ROOT_DIR/}"
  fi
}

require_yq() {
  local expr="$1"
  local file="$2"
  local label="$3"
  if yq -e "$expr" "$file" >/dev/null 2>&1; then
    pass "$label"
  else
    fail "$label"
  fi
}

require_text() {
  local needle="$1"
  local file="$2"
  local label="$3"
  if command -v rg >/dev/null 2>&1; then
    if rg -Fq "$needle" "$file"; then
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

main() {
  echo "== Phase 4 Proof And Lab Enforcement Validation =="

  require_file "$ASSURANCE_FAMILY"
  require_file "$AI_REVIEW_GATE"
  require_file "$ARCH_WORKFLOW"
  require_file "$EVALUATOR_REGISTRY"
  require_file "$RUN3_FUNCTIONAL_EXEC"
  require_file "$RUN3_BEHAVIORAL_EXEC"
  require_file "$RUN3_RECOVERY_EXEC"
  require_file "$RUN4_MAINTAINABILITY_EXEC"
  require_file "$RUN4_EVALUATOR"

  require_dir "$OCTON_DIR/framework/assurance/functional/suites"
  require_dir "$OCTON_DIR/framework/assurance/behavioral/suites"
  require_dir "$OCTON_DIR/framework/assurance/maintainability/suites"
  require_dir "$OCTON_DIR/framework/assurance/recovery/suites"
  require_file "$OCTON_DIR/framework/assurance/functional/suites/registry.yml"
  require_file "$OCTON_DIR/framework/assurance/behavioral/suites/registry.yml"
  require_file "$OCTON_DIR/framework/assurance/maintainability/suites/registry.yml"
  require_file "$OCTON_DIR/framework/assurance/recovery/suites/registry.yml"

  require_dir "$OCTON_DIR/framework/lab/scenarios"
  require_dir "$OCTON_DIR/framework/lab/replay"
  require_dir "$OCTON_DIR/framework/lab/shadow"
  require_dir "$OCTON_DIR/framework/lab/faults"
  require_file "$OCTON_DIR/framework/lab/scenarios/registry.yml"
  require_file "$OCTON_DIR/framework/lab/replay/registry.yml"
  require_file "$OCTON_DIR/framework/lab/shadow/registry.yml"
  require_file "$OCTON_DIR/framework/lab/faults/registry.yml"
  require_file "$OCTON_DIR/framework/lab/runtime/contracts/lab-scenario-v1.schema.json"
  require_file "$OCTON_DIR/framework/lab/runtime/contracts/replay-bundle-v1.schema.json"
  require_file "$OCTON_DIR/framework/lab/runtime/contracts/shadow-run-manifest-v1.schema.json"
  require_file "$OCTON_DIR/framework/lab/runtime/contracts/fault-injection-plan-v1.schema.json"
  require_file "$OCTON_DIR/framework/lab/runtime/contracts/probe-contract-v1.schema.json"

  require_dir "$OCTON_DIR/state/evidence/lab/replays"
  require_dir "$OCTON_DIR/state/evidence/lab/shadow-runs"
  require_dir "$OCTON_DIR/state/evidence/lab/faults"
  require_file "$OCTON_DIR/state/evidence/lab/scenarios/scn-runtime-proof-supported-20260329/scenario-proof.yml"
  require_file "$OCTON_DIR/state/evidence/lab/replays/rpl-runtime-proof-supported-20260329/replay-bundle.yml"
  require_file "$OCTON_DIR/state/evidence/lab/shadow-runs/shd-runtime-proof-supported-20260329/shadow-run.yml"
  require_file "$OCTON_DIR/state/evidence/lab/faults/flt-runtime-proof-supported-20260329/fault-report.yml"

  require_yq '.proof_planes.structural.blocking_status == "active"' "$ASSURANCE_FAMILY" "structural proof remains blocking"
  require_yq '.proof_planes.governance.blocking_status == "active"' "$ASSURANCE_FAMILY" "governance proof remains blocking"
  require_yq '.proof_planes.functional.suites_root == ".octon/framework/assurance/functional/suites"' "$ASSURANCE_FAMILY" "functional suites declared"
  require_yq '.proof_planes.behavioral.suites_root == ".octon/framework/assurance/behavioral/suites"' "$ASSURANCE_FAMILY" "behavioral suites declared"
  require_yq '.proof_planes.maintainability.suites_root == ".octon/framework/assurance/maintainability/suites"' "$ASSURANCE_FAMILY" "maintainability suites declared"
  require_yq '.proof_planes.recovery.suites_root == ".octon/framework/assurance/recovery/suites"' "$ASSURANCE_FAMILY" "recovery suites declared"
  require_yq '.proof_planes.evaluators.adapter_registry_ref == ".octon/framework/assurance/evaluators/adapters/registry.yml"' "$ASSURANCE_FAMILY" "evaluator adapters declared"
  require_yq '.runner_ref == ".octon/framework/assurance/runtime/_ops/scripts/run-phase4-proof-suite.sh"' "$OCTON_DIR/framework/assurance/functional/suites/run-lifecycle-integrity.yml" "functional suite declares executable runner"
  require_yq '.runner_ref == ".octon/framework/assurance/runtime/_ops/scripts/run-phase4-proof-suite.sh"' "$OCTON_DIR/framework/assurance/behavioral/suites/replay-shadow-substance.yml" "behavioral suite declares executable runner"
  require_yq '.runner_ref == ".octon/framework/assurance/runtime/_ops/scripts/run-phase4-proof-suite.sh"' "$OCTON_DIR/framework/assurance/recovery/suites/checkpoint-fault-recovery.yml" "recovery suite declares executable runner"

  require_text "run-evaluator-adapter.sh" "$AI_REVIEW_GATE" "AI review gate uses generic evaluator adapter runner"
  require_text ".octon/framework/assurance/evaluators/adapters/" "$AI_REVIEW_GATE" "AI review gate routes through evaluator adapter manifests"
  require_text "validate-phase4-proof-lab-enforcement.sh" "$ARCH_WORKFLOW" "architecture conformance workflow enforces Phase 4 proof/lab validator"
  require_text ".octon/state/evidence/runs/**" "$ARCH_WORKFLOW" "architecture conformance workflow triggers on retained run proof changes"

  require_yq '.evidence_refs[] | select(. == ".octon/framework/assurance/functional/suites/run-lifecycle-integrity.yml")' "$RUN3_FUNCTIONAL" "Wave 3 functional proof cites functional suite"
  require_yq '.evidence_refs[] | select(. == ".octon/state/evidence/runs/run-wave3-runtime-bridge-20260327/assurance/functional-suite-execution.yml")' "$RUN3_FUNCTIONAL" "Wave 3 functional proof cites executed functional suite"
  require_yq '.evidence_refs[] | select(. == ".octon/framework/assurance/behavioral/suites/replay-shadow-substance.yml")' "$RUN3_BEHAVIORAL" "Wave 3 behavioral proof cites behavioral suite"
  require_yq '.evidence_refs[] | select(. == ".octon/state/evidence/runs/run-wave3-runtime-bridge-20260327/assurance/behavioral-suite-execution.yml")' "$RUN3_BEHAVIORAL" "Wave 3 behavioral proof cites executed behavioral suite"
  require_yq '.evidence_refs[] | select(. == ".octon/state/evidence/lab/scenarios/scn-runtime-proof-supported-20260329/scenario-proof.yml")' "$RUN3_BEHAVIORAL" "Wave 3 behavioral proof cites scenario evidence"
  require_yq '.evidence_refs[] | select(. == ".octon/state/evidence/lab/shadow-runs/shd-runtime-proof-supported-20260329/shadow-run.yml")' "$RUN3_BEHAVIORAL" "Wave 3 behavioral proof cites shadow-run evidence"
  require_yq '.evidence_refs[] | select(. == ".octon/framework/assurance/recovery/suites/checkpoint-fault-recovery.yml")' "$RUN3_RECOVERY" "Wave 3 recovery proof cites recovery suite"
  require_yq '.evidence_refs[] | select(. == ".octon/state/evidence/runs/run-wave3-runtime-bridge-20260327/assurance/recovery-suite-execution.yml")' "$RUN3_RECOVERY" "Wave 3 recovery proof cites executed recovery suite"
  require_yq '.evidence_refs[] | select(. == ".octon/state/evidence/lab/faults/flt-runtime-proof-supported-20260329/fault-report.yml")' "$RUN3_RECOVERY" "Wave 3 recovery proof cites fault evidence"
  require_yq '.evidence_refs[] | select(. == ".octon/framework/assurance/maintainability/suites/runtime-ssot-alignment.yml")' "$RUN4_MAINTAINABILITY" "Wave 4 maintainability proof cites maintainability suite"
  require_yq '.evidence_refs[] | select(. == ".octon/state/evidence/runs/run-wave4-benchmark-evaluator-20260327/assurance/maintainability-suite-execution.yml")' "$RUN4_MAINTAINABILITY" "Wave 4 maintainability proof cites executed maintainability suite"
  require_yq '.evidence_refs[] | select(. == ".octon/framework/assurance/evaluators/adapters/openai-review.yml")' "$RUN4_EVALUATOR" "Wave 4 evaluator review cites OpenAI adapter"
  require_yq '.evidence_refs[] | select(. == ".octon/framework/assurance/evaluators/adapters/anthropic-review.yml")' "$RUN4_EVALUATOR" "Wave 4 evaluator review cites Anthropic adapter"

  echo "Validation summary: errors=$errors"
  [[ $errors -eq 0 ]]
}

main "$@"

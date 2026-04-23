#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
ROOT_DIR="${OCTON_ROOT_DIR:-$(cd -- "$OCTON_DIR/.." && pwd)}"

SUPPORT_TARGETS="$OCTON_DIR/instance/governance/support-targets.yml"
LIVE_CONSEQUENTIAL="$OCTON_DIR/instance/governance/support-target-admissions/live/repo-shell-repo-consequential-en.yml"
STAGE_ONLY_GITHUB="$OCTON_DIR/instance/governance/support-target-admissions/stage-only/github-repo-consequential-en.yml"
LIVE_PROOF="$OCTON_DIR/state/evidence/validation/support-targets/repo-shell-repo-consequential-en.yml"
STAGE_ONLY_PROOF="$OCTON_DIR/state/evidence/validation/support-targets/github-repo-consequential-en.yml"

errors=0

fail() {
  echo "[ERROR] $1"
  errors=$((errors + 1))
}

pass() {
  echo "[OK] $1"
}

require_yq_expr() {
  local expr="$1"
  local file="$2"
  local label="$3"
  if yq -e "$expr" "$file" >/dev/null 2>&1; then
    pass "$label"
  else
    fail "$label"
  fi
}

echo "== Support-Target Admission Validation =="

command -v yq >/dev/null 2>&1 || {
  echo "[ERROR] yq is required" >&2
  exit 1
}

require_yq_expr '.tiers.workload[] | select(.id == "repo-consequential" and (.description | test("Run Journal conformance")))' "$SUPPORT_TARGETS" "repo-consequential tier description cites Run Journal conformance"
require_yq_expr '.notes[] | select(test("deterministic state-reconstruction proof"))' "$SUPPORT_TARGETS" "support target notes retain consequential Run Journal proof requirement"

require_yq_expr '.required_runtime_evidence[] | select(. == "valid-run-journal-conformance")' "$LIVE_CONSEQUENTIAL" "live consequential admission requires valid Run Journal conformance"
require_yq_expr '.required_runtime_evidence[] | select(. == "deterministic-state-reconstruction")' "$LIVE_CONSEQUENTIAL" "live consequential admission requires deterministic reconstruction"
require_yq_expr '.required_runtime_evidence[] | select(. == "journal-closeout-snapshot-match")' "$LIVE_CONSEQUENTIAL" "live consequential admission requires closeout snapshot match"
require_yq_expr '.required_runtime_validators[] | select(. == ".octon/framework/assurance/runtime/_ops/scripts/validate-run-journal-contracts.sh")' "$LIVE_CONSEQUENTIAL" "live consequential admission cites the Run Journal validator"

require_yq_expr '.live_promotion_prerequisites[] | select(. == "valid-run-journal-conformance")' "$STAGE_ONLY_GITHUB" "stage-only GitHub consequential admission requires Run Journal proof before live promotion"
require_yq_expr '.live_promotion_validators[] | select(. == ".octon/framework/assurance/runtime/_ops/scripts/validate-run-journal-contracts.sh")' "$STAGE_ONLY_GITHUB" "stage-only GitHub consequential admission cites the Run Journal validator"

if [[ -f "$LIVE_PROOF" ]]; then
  require_yq_expr '.run_journal_validation_refs[] | select(. == ".octon/state/evidence/validation/run-journal-runtime-hardening/support-target-admission/repo-shell-repo-consequential-en.yml")' "$LIVE_PROOF" "live consequential proof bundle links Run Journal admission proof"
else
  fail "missing live consequential proof bundle"
fi

if [[ -f "$STAGE_ONLY_PROOF" ]]; then
  require_yq_expr '.run_journal_validation_refs[] | select(. == ".octon/state/evidence/validation/run-journal-runtime-hardening/support-target-admission/github-repo-consequential-en.yml")' "$STAGE_ONLY_PROOF" "stage-only GitHub proof bundle links Run Journal admission proof"
else
  fail "missing stage-only GitHub proof bundle"
fi

echo "Validation summary: errors=$errors"
[[ "$errors" -eq 0 ]]

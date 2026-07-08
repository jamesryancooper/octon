#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../../../../../.." && pwd)"
VALIDATOR="$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-governance-efficiency-report.sh"
TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/governance-efficiency-validator-test.XXXXXX")"
trap 'rm -rf "$TMP_DIR"' EXIT

fixture="$TMP_DIR/report.yml"
cat >"$fixture" <<'YAML'
schema_version: "octon-governance-efficiency-report-v1"
artifact_role: "governance-efficiency-report"
report_id: "governance-efficiency-report@test"
generated_at: "2026-07-08T16:40:53Z"
non_authority_classification: "advisory-only"
producer:
  id: "test"
  entrypoint_ref: ".octon/framework/assurance/runtime/_ops/scripts/evaluate-governance-efficiency.sh"
  owner: "assurance/runtime"
consumer:
  allowed_consumers:
    - "operator-analysis"
  forbidden_consumers:
    - "review-authorization"
    - "validation-gate"
    - "closeout"
    - "cleanup"
    - "archive"
    - "terminal-proof"
    - "policy-mutation"
    - "lifecycle-transition"
    - "child-receipt-substitution"
target:
  path: ".octon/inputs/exploratory/proposals/architecture/example"
  target_kind: "proposal-packet"
authority_boundaries:
  authorizes_review: false
  authorizes_validation: false
  authorizes_closeout: false
  authorizes_cleanup: false
  authorizes_archive: false
  authorizes_terminal_proof: false
  authorizes_policy_mutation: false
  authorizes_lifecycle_transition: false
  replaces_child_receipts: false
evidence_inputs:
  - ref: ".octon/inputs/exploratory/proposals/architecture/example/support/proposal-review.md"
    observed: true
    evidence_class: "proposal-review"
findings:
  - finding_id: "GE-001"
    category: "automation"
    risk_covered: "Review remains child-owned."
    latency_cost: "manual repeated check"
    evidence_refs:
      - ".octon/inputs/exploratory/proposals/architecture/example/support/proposal-review.md"
    confidence: "medium"
    recommendation: "Draft a future proposal for automation."
    recommendation_authority: "advisory-only"
    requires_follow_up_proposal: true
uncertainty:
  missing_evidence_count: 0
  partial_evidence_count: 0
  notes:
    - "Fixture has complete evidence for this narrow check."
validation:
  validators_run:
    - ".octon/framework/assurance/runtime/_ops/scripts/validate-governance-efficiency-report.sh"
  negative_controls:
    - "review-authorization"
    - "validation-gate"
    - "closeout"
    - "cleanup"
    - "archive"
    - "terminal-proof"
    - "policy-mutation"
    - "lifecycle-transition"
    - "child-receipt-substitution"
YAML

bash "$VALIDATOR" --schema-only >/dev/null
bash "$VALIDATOR" --report "$fixture" >/dev/null

review_claim="$TMP_DIR/review-claim.yml"
cp "$fixture" "$review_claim"
yq -i '.authority_boundaries.authorizes_review = true' "$review_claim"
if bash "$VALIDATOR" --report "$review_claim" >/dev/null 2>&1; then
  echo "[ERROR] review authorization claim should fail"
  exit 1
fi

missing_forbidden="$TMP_DIR/missing-forbidden.yml"
cp "$fixture" "$missing_forbidden"
yq -i 'del(.consumer.forbidden_consumers[] | select(. == "archive"))' "$missing_forbidden"
if bash "$VALIDATOR" --report "$missing_forbidden" >/dev/null 2>&1; then
  echo "[ERROR] missing forbidden archive consumer should fail"
  exit 1
fi

confident_missing="$TMP_DIR/confident-missing.yml"
cp "$fixture" "$confident_missing"
yq -i '.uncertainty.missing_evidence_count = 1 | .findings[0].confidence = "high"' "$confident_missing"
if bash "$VALIDATOR" --report "$confident_missing" >/dev/null 2>&1; then
  echo "[ERROR] high confidence with missing evidence should fail"
  exit 1
fi

no_follow_up="$TMP_DIR/no-follow-up.yml"
cp "$fixture" "$no_follow_up"
yq -i '.findings[0].requires_follow_up_proposal = false' "$no_follow_up"
if bash "$VALIDATOR" --report "$no_follow_up" >/dev/null 2>&1; then
  echo "[ERROR] recommendation without follow-up proposal should fail"
  exit 1
fi

echo "test-validate-governance-efficiency-report: pass"

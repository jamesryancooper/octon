#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
VALIDATOR="$SCRIPT_DIR/../scripts/validate-self-evolution-runtime-v5.sh"
ROOT_DIR="${OCTON_ROOT_DIR:-$(cd -- "$SCRIPT_DIR/../../../../../.." && pwd)}"

"$VALIDATOR" --root "$ROOT_DIR" "$@"

tmp="$(mktemp -d)"
trap 'rm -r -f "$tmp"' EXIT
cp -R "$ROOT_DIR/.octon" "$tmp/.octon"
proposal_id="octon-self-evolution-proposal-to-promotion-runtime-v5"

expect_fail() {
  local label="$1"
  if "$VALIDATOR" --root "$tmp" >"$tmp/$label.out" 2>&1; then
    echo "[ERROR] validator accepted negative control: $label" >&2
    cat "$tmp/$label.out" >&2
    exit 1
  fi
  echo "[OK] negative control failed closed: $label"
}

candidate="$tmp/.octon/state/control/evolution/candidates/evolution-candidate-v5-validation.yml"
simulation="$tmp/.octon/state/control/evolution/simulations/evolution-simulation-v5-validation.yml"
lab="$tmp/.octon/state/control/evolution/lab-gates/evolution-lab-gate-v5-validation.yml"
amendment="$tmp/.octon/state/control/evolution/amendment-requests/evolution-amendment-v5-validation.yml"
promotion="$tmp/.octon/state/control/evolution/promotions/evolution-promotion-v5-validation.yml"
approval_grant="$tmp/.octon/state/control/execution/approvals/grants/grant-evolution-promotion-v5-validation.yml"
recert="$tmp/.octon/state/control/evolution/recertifications/evolution-recertification-v5-validation.yml"
recert_receipt="$tmp/.octon/state/evidence/evolution/recertifications/evolution-recertification-v5-validation/receipt.yml"
promotion_receipt="$tmp/.octon/state/evidence/evolution/promotions/evolution-promotion-v5-validation/receipt.yml"
rollback="$tmp/.octon/state/control/evolution/rollbacks/evolution-rollback-v5-validation.yml"
proposal="$tmp/.octon/inputs/exploratory/proposals/architecture/$proposal_id/proposal.yml"
if [[ ! -f "$proposal" ]]; then
  proposal="$tmp/.octon/inputs/exploratory/proposals/.archive/architecture/$proposal_id/proposal.yml"
fi
generated="$tmp/.octon/generated/cognition/projections/materialized/evolution/ledger.yml"
framework_doc="$tmp/.octon/framework/orchestration/practices/evolution-lifecycle-standards.md"

cp "$candidate" "$tmp/candidate.bak"
yq -i 'del(.source_evidence_refs)' "$candidate"
expect_fail "candidate-without-evidence"
cp "$tmp/candidate.bak" "$candidate"

cp "$candidate" "$tmp/candidate-authorizes.bak"
yq -i '.candidate_authorizes_change = true' "$candidate"
expect_fail "candidate-self-authorizes"
cp "$tmp/candidate-authorizes.bak" "$candidate"

cp "$candidate" "$tmp/candidate-disposition.bak"
yq -i '.current_disposition = "auto_promote"' "$candidate"
expect_fail "candidate-invalid-schema-disposition"
cp "$tmp/candidate-disposition.bak" "$candidate"

cp "$simulation" "$tmp/simulation.bak"
yq -i '.simulation_success_approves_change = true' "$simulation"
expect_fail "simulation-success-approval"
cp "$tmp/simulation.bak" "$simulation"

cp "$lab" "$tmp/lab.bak"
yq -i '.lab_success_approves_change = true' "$lab"
expect_fail "lab-success-approval"
cp "$tmp/lab.bak" "$lab"

cp "$lab" "$tmp/lab-stage-only.bak"
yq -i '.result = "stage_only"' "$lab"
expect_fail "lab-not-passed"
cp "$tmp/lab-stage-only.bak" "$lab"

cp "$amendment" "$tmp/amendment.bak"
yq -i '.approval_refs = []' "$amendment"
expect_fail "missing-amendment-approval"
cp "$tmp/amendment.bak" "$amendment"

cp "$candidate" "$tmp/candidate-amendment-link.bak"
yq -i 'del(.constitutional_amendment_request_ref)' "$candidate"
expect_fail "missing-amendment-link"
cp "$tmp/candidate-amendment-link.bak" "$candidate"

cp "$approval_grant" "$tmp/approval-grant.bak"
yq -i '.state = "expired"' "$approval_grant"
expect_fail "inactive-approval-grant"
cp "$tmp/approval-grant.bak" "$approval_grant"

cp "$promotion" "$tmp/promotion-support.bak"
yq -i 'del(.support_no_widening)' "$promotion"
expect_fail "missing-support-no-widening"
cp "$tmp/promotion-support.bak" "$promotion"

cp "$promotion_receipt" "$tmp/promotion-receipt.bak"
yq -i '.receipt_authorizes_future_change = true' "$promotion_receipt"
expect_fail "promotion-receipt-authority"
cp "$tmp/promotion-receipt.bak" "$promotion_receipt"

cp "$promotion_receipt" "$tmp/promotion-receipt-targets.bak"
yq -i 'del(.target_refs[0])' "$promotion_receipt"
expect_fail "promotion-receipt-target-gap"
cp "$tmp/promotion-receipt-targets.bak" "$promotion_receipt"

cp "$recert" "$tmp/recert.bak"
yq -i '.connector_admissions = "pending"' "$recert"
expect_fail "incomplete-recertification-dimensions"
cp "$tmp/recert.bak" "$recert"

cp "$recert_receipt" "$tmp/recert-receipt.bak"
yq -i 'del(.dimension_evidence_refs.validator_health)' "$recert_receipt"
expect_fail "missing-recertification-dimension-evidence"
cp "$tmp/recert-receipt.bak" "$recert_receipt"

cp "$rollback" "$tmp/rollback.bak"
yq -i 'del(.rollback_plan)' "$rollback"
expect_fail "rollback-posture-missing-plan"
cp "$tmp/rollback.bak" "$rollback"

cp "$proposal" "$tmp/proposal.bak"
yq -i '.status = "in-review" | del(.archive)' "$proposal"
expect_fail "proposal-status-mismatch"
cp "$tmp/proposal.bak" "$proposal"

cp "$proposal" "$tmp/proposal-generated-effective.bak"
cp "$promotion" "$tmp/promotion-generated-effective.bak"
yq -i '.promotion_targets += [".octon/generated/effective/runtime/route-bundle.yml"]' "$proposal"
yq -i '.declared_promotion_targets += [".octon/generated/effective/runtime/route-bundle.yml"]' "$promotion"
expect_fail "generated-effective-target"
cp "$tmp/proposal-generated-effective.bak" "$proposal"
cp "$tmp/promotion-generated-effective.bak" "$promotion"

cp "$generated" "$tmp/generated.bak"
yq -i '.authority = "authoritative"' "$generated"
expect_fail "generated-authority"
cp "$tmp/generated.bak" "$generated"

cp "$framework_doc" "$tmp/framework-doc.bak"
printf '\nForbidden proposal path: %s%s\n' ".octon/inputs/exploratory/proposals/architecture/" "$proposal_id" >>"$framework_doc"
expect_fail "durable-proposal-path-dependency"
cp "$tmp/framework-doc.bak" "$framework_doc"

echo "[OK] Self-Evolution Runtime v5 negative controls passed."

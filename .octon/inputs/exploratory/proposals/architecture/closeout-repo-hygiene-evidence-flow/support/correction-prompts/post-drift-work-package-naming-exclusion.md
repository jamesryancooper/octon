# Correction Prompt: Post-Drift Work Package Naming Exclusion

finding_id: "post-drift-work-package-naming-exclusion"
created_at: "2026-05-29T23:29:09Z"
finding_source: "validate-proposal-post-implementation-drift.sh"
finding_status: "corrected"
correction_scope: "packet-local drift/churn receipt only"

## Failed Finding

The final verification sweep failed
`validate-proposal-post-implementation-drift.sh` for
`closeout-repo-hygiene-evidence-flow` because the broad
`.octon/framework/assurance/runtime/_ops/scripts/` promotion target contains
Work Package naming text in validator self-scan logic.

## Required Correction

Refresh only `support/post-implementation-drift-churn-review.md` to record an
explicit Work Package naming drift exclusion for validator logic. Do not
rewrite child promotion targets, implementation receipts, review
authorization, or durable implementation artifacts.

## Acceptance Criteria

- The packet keeps `verdict: pass` and `unresolved_items_count: 0`.
- The exclusion names Work Package naming drift and explains why it is
  validator self-scan text rather than packet-owned policy naming.
- `validate-proposal-post-implementation-drift.sh --package
  .octon/inputs/exploratory/proposals/architecture/closeout-repo-hygiene-evidence-flow`
  passes after correction.

# Evidence Plan

## Required Receipts

- `support/proposal-creation.md`
- `support/implementation-grade-completeness-review.md`
- `support/proposal-review.md`
- `support/executable-implementation-prompt.md`
- `support/implementation-run.md`
- `support/implementation-conformance-review.md`
- `support/post-implementation-drift-churn-review.md`
- `support/proposal-closeout.md`

## Runtime Evidence

Each major phase should retain Lifecycle Runner output under
`.octon/state/evidence/runs/workflows/**` and checkpoint state under
`.octon/state/control/execution/runs/**`.

## Validation Evidence

Validation evidence should include structural proposal validation, review gate,
implementation readiness, product feature catalog validation, roadmap
validation, product validator tests, terminology sweeps, generated projection
checks when applicable, conformance, and drift/churn validation.

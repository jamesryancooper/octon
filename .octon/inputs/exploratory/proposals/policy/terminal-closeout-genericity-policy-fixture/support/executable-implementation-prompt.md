# Executable Implementation Prompt

Implement only the validation fixture behavior for:

`.octon/inputs/exploratory/proposals/policy/terminal-closeout-genericity-policy-fixture`

Promotion targets:

- `.octon/framework/execution-roles/practices/standards/ai-assisted-development-discipline.md`
- `.octon/framework/execution-roles/practices/standards/validation-evidence-quality.md`

Run validators including `validate-policy-proposal.sh`, `validate-proposal-implementation-readiness.sh`, `validate-proposal-implementation-conformance.sh`, and `validate-proposal-post-implementation-drift.sh`.

Retain evidence under `.octon/state/evidence/**` and write `support/implementation-conformance-review.md` and `support/post-implementation-drift-churn-review.md`.

Rollback is deletion of this fixture packet and regeneration of proposal projections through owning generators.

Refuse closeout or archive if validators fail, if terminal evidence is stale, if generated outputs are edited directly, or if route evidence does not remain owned by the terminal closeout workflow.


# Executable Implementation Prompt

Implement the accepted child packet `run-program-clean-delivery-test-hermeticity`.

## Authorized Scope

- `.octon/framework/assurance/runtime/_ops/tests/test-classify-proposal-worktree-hygiene.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/generate-run-health-read-model.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-run-health-read-model.sh`
- `.octon/framework/assurance/runtime/_ops/fixtures/run-health-read-model/`
- `.octon/framework/assurance/runtime/_ops/tests/test-run-health-read-model.sh`
- `.octon/framework/assurance/runtime/_ops/tests/`

## Required Work

1. Make `test-classify-proposal-worktree-hygiene.sh` pass without modifying tracked generated run-health projection files.
2. Make `test-run-health-read-model.sh` write generator and validator outputs only under temporary or fixture-owned roots.
3. Preserve meaningful coverage for `generate-run-health-read-model.sh` and `validate-run-health-read-model.sh`.
4. Add or retain negative controls proving tracked generated projection writes are rejected, isolated, or reported instead of hidden.
5. Retain `support/implementation-run.md`, `support/implementation-conformance-review.md`, `support/post-implementation-drift-churn-review.md`, `support/validation.md`, and focused validation evidence before promotion or closeout.

## Validation Commands

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-test-hermeticity --skip-registry-check
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-test-hermeticity
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-test-hermeticity
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-test-hermeticity --require-implementation-authorization
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-receipts.sh --receipt .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-test-hermeticity/support/pre-integration-architecture-review.yml --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-test-hermeticity --mode pre-integration-architecture-review --require-pass
bash .octon/framework/assurance/runtime/_ops/tests/test-classify-proposal-worktree-hygiene.sh
bash .octon/framework/assurance/runtime/_ops/tests/test-run-health-read-model.sh
git status --short -- .octon/generated/cognition/projections/materialized/runs
```

## Closeout Refusal Criteria

Refuse closeout and block archive if either focused test writes tracked generated run-health projections, if generator coverage is replaced by a no-op fixture, if dirty generated output is deleted or reset to hide test residue, if post-test generated projection status is omitted, or if validation evidence is stale after durable edits.

## Rollback

Rollback is limited to reverting this child packet's hermetic test, generator, validator, and fixture edits, then superseding the child support receipts through a correction route. Retained validation logs remain evidence only.

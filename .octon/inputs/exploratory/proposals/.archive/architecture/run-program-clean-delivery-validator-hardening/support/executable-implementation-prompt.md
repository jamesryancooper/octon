# Executable Implementation Prompt

Implement the accepted child packet `run-program-clean-delivery-validator-hardening`.

## Authorized Scope

- `.octon/framework/assurance/runtime/_ops/scripts/validate-run-program-clean-delivery.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-evidence-disclosure-tiers.sh`
- `.octon/framework/assurance/runtime/_ops/tests/test-run-program-clean-delivery-validator.sh`
- `.octon/framework/assurance/runtime/_ops/tests/`

## Required Work

1. Harden the clean-delivery validator chain so terminal `cleaned` claims require the evidence-disclosure validator.
2. Preserve existing delivery receipt, delivery evidence index, blocker, final sync, and worktree hygiene checks.
3. Add negative controls for missing delivery receipt, missing evidence index, open blockers, remote/local mismatch, dirty worktree proof, stale terminal proof, parent summary substitution, aggregate evidence substitution, generated-output substitution, child-authority replacement, and stale disclosure validation.
4. Retain implementation-run, implementation-conformance, post-implementation drift/churn, validation, and rollback evidence before promotion.
5. Require `support/implementation-conformance-review.md` and `support/post-implementation-drift-churn-review.md` before any promotion or closeout claim.

## Validation Commands

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-validator-hardening --skip-registry-check
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-validator-hardening
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-validator-hardening
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-validator-hardening --require-implementation-authorization
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-receipts.sh --receipt .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-validator-hardening/support/pre-integration-architecture-review.yml --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-validator-hardening --mode pre-integration-architecture-review --require-pass
bash .octon/framework/assurance/runtime/_ops/scripts/validate-evidence-disclosure-tiers.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-run-program-clean-delivery.sh
bash .octon/framework/assurance/runtime/_ops/tests/test-run-program-clean-delivery-validator.sh
```

## Closeout Refusal Criteria

Refuse closeout and block archive if disclosure validation is absent from the clean-delivery chain, if any false-terminal fixture passes unexpectedly, if parent summaries replace child-owned receipts, if generated outputs are treated as authority, or if validation evidence is stale after durable edits.

## Rollback

Rollback is limited to reverting the clean-delivery validator and fixture changes and superseding this packet's support receipts through a correction route. Retained validation logs remain evidence only.

# Executable Implementation Prompt

Implement the accepted `lifecycle-interaction-receipt-model` proposal. Stay
within the approved promotion targets and preserve the non-authorizing,
target-owned authority model.

## Approved Targets

- `.octon/framework/product/contracts/lifecycle-interaction-request-v1.schema.json`
- `.octon/framework/product/contracts/lifecycle-interaction-return-v1.schema.json`
- `.octon/framework/product/features/governed-lifecycle-orchestration.md`
- `.octon/framework/product/features/catalog.yml`
- `.octon/framework/cognition/_meta/architecture/inputs/additive/extensions/schemas/extension-lifecycle-contract.schema.json`
- `.octon/framework/cognition/_meta/architecture/inputs/additive/extensions/schemas/lifecycle-run-event.schema.json`
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/context/lifecycle.contract.yml`
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/skills/octon-proposal-lifecycle-closeout-packet/SKILL.md`
- `.octon/framework/capabilities/runtime/skills/remediation/closeout-change/SKILL.md`
- `.octon/framework/capabilities/runtime/skills/remediation/closeout-worktree/SKILL.md`
- `.octon/framework/capabilities/runtime/skills/remediation/repo-hygiene-cleanup/SKILL.md`
- `.octon/framework/engine/runtime/spec/lifecycle-route-execution-request-v1.schema.json`
- `.octon/framework/engine/runtime/crates/kernel/src/lifecycle.rs`
- `.octon/framework/engine/runtime/crates/lifecycle_executor/src/request.rs`
- `.octon/framework/engine/runtime/crates/lifecycle_executor/src/authorization.rs`
- `.octon/framework/engine/runtime/crates/lifecycle_executor/src/adapter.rs`
- `.octon/framework/engine/runtime/crates/lifecycle_executor/src/observer.rs`
- `.octon/framework/engine/runtime/crates/lifecycle_executor/tests/adapter.rs`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-lifecycle-interaction-receipts.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-lifecycle-contracts.sh`
- `.octon/framework/assurance/runtime/_ops/tests/test-lifecycle-interaction-receipts.sh`
- `.octon/framework/assurance/runtime/_ops/tests/test-lifecycle-runner.sh`
- `.octon/framework/assurance/runtime/_ops/tests/test-lifecycle-executor-adapter.sh`
- `.octon/generated/effective/extensions/published/octon-proposal-lifecycle/bundled-first-party/context/lifecycle.contract.yml`
- `.octon/generated/effective/extensions/published/octon-proposal-lifecycle/bundled-first-party/skills/octon-proposal-lifecycle-closeout-packet/SKILL.md`

## Required Implementation

1. Add request and return schemas for lifecycle interaction receipts.
2. Add optional lifecycle contract metadata for emitted and accepted
   interaction profiles and validate unsafe metadata.
3. Update proposal-packet lifecycle metadata and closeout skill guidance so
   blocked closeout can emit `follow_on_work_required` request receipts.
4. Update Change Closeout, Worktree Closeout, and Repo Hygiene skills so
   request receipts are consumed as context only.
5. Update runner checkpoint/event/request context so validated interaction
   refs are visible without causing automatic dispatch or authority transfer.
6. Update executor route request and authorization proof so interaction refs
   are non-authorizing context and cannot satisfy missing target gates.
7. Add validators and tests for valid receipts and negative controls:
   dangling evidence refs, stale evidence refs, scope widening, forbidden
   authority transfer, missing return evidence, request-as-gate-authority,
   runner discovery without self-dispatch, executor non-reinterpretation,
   generated projection refresh, and unchanged proposal statuses.
8. Refresh generated effective extension projections only through the extension
   publication generator.

## Boundaries

Refuse to implement lifecycle bus behavior, shared phase-loop state, new
proposal statuses, source-owned target authority, generated-source authority,
or automatic execution from an interaction request. Refuse closeout or archive
claims unless conformance, drift, scope, authority, evidence, rollback,
delegation, hosted-control, and hygiene gates pass.

## Validation Commands

Run these commands and retain the important output in implementation evidence:

- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/lifecycle-interaction-receipt-model`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/lifecycle-interaction-receipt-model --require-implementation-authorization`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/lifecycle-interaction-receipt-model`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-lifecycle-interaction-receipts.sh --self-test`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-lifecycle-contracts.sh --contract .octon/inputs/additive/extensions/octon-proposal-lifecycle/context/lifecycle.contract.yml`
- `bash .octon/framework/assurance/runtime/_ops/tests/test-lifecycle-interaction-receipts.sh`
- `bash .octon/framework/assurance/runtime/_ops/tests/test-lifecycle-runner.sh`
- `bash .octon/framework/assurance/runtime/_ops/tests/test-lifecycle-executor-adapter.sh`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/architecture/lifecycle-interaction-receipt-model`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/architecture/lifecycle-interaction-receipt-model`

## Evidence And Receipts

Write `support/implementation-run.md` after implementation execution. Write
`support/implementation-conformance-review.md` and
`support/post-implementation-drift-churn-review.md` after validation. The
receipts must cite validators, unresolved counts, exclusions, generated
projection publication evidence, rollback posture, and closeout refusal
criteria.

## Rollback

Rollback by reverting the declared targets, retaining any durable evidence,
republishing generated effective extension projections from authored inputs,
and rerunning the validator set. Do not delete evidence, force-reset refs,
rewrite hosted state, or treat generated files as source authority.

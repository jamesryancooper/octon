# Executable Implementation Prompt

proposal_id: proposal-program-runner-evidence-run-control
generated_at: 2026-05-30T21:46:51Z
generator: octon-proposal-lifecycle-generate-packet-implementation-prompt
source_review_gate: passed
implementation_grade_readiness: passed

## Role

Implement only the `evidence tiers, checkpoints, replay, cancellation, resume, and locks` child packet. Preserve Octon's
existing route ownership, workflow ownership, validator ownership, publication
ownership, registry ownership, cleanup ownership, closeout ownership, archive
ownership, disclosure-tier ownership, and run lifecycle ownership.

## Promotion Targets

- `.octon/framework/engine/runtime/crates/kernel/src/lifecycle_program.rs`
- `.octon/framework/engine/runtime/spec/`
- `.octon/framework/constitution/contracts/retention/`
- `.octon/framework/constitution/obligations/evidence.yml`
- `.octon/framework/assurance/runtime/_ops/scripts/`

## Required Workstreams

1. Re-read this packet's `proposal.yml`, `architecture/implementation-plan.md`,
   `architecture/acceptance-criteria.md`, `architecture/target-architecture.md`,
   `validation-plan.md`, and `resources/source-lineage.md`.
2. Reconfirm the current implementation and reuse existing contracts, routes,
   validators, workflow routes, scripts, prompts, and runtime machinery before
   adding or changing behavior.
3. Apply the smallest implementation that satisfies this child packet's
   acceptance criteria inside its declared promotion targets and write scopes.
4. Add or update focused tests and negative controls for the child-owned slice.
5. Refresh generated state only through canonical publication or registry
   scripts when authored-source changes require it; never hand-edit generated
   effective state.
6. Record implementation evidence in `support/implementation-run.md` only after
   durable implementation occurs.

## Validation Commands

Run the relevant subset for the actual touched surfaces and record results:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-runner-evidence-run-control
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-runner-evidence-run-control
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-runner-evidence-run-control --require-implementation-authorization
```

Add route, Rust, shell, publication, registry, or workflow tests selected by the
child packet's `validation-plan.md`.

## Post-Implementation Receipts

After implementation, produce and pass:

- `support/implementation-conformance-review.md`
- `support/post-implementation-drift-churn-review.md`

Then run:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-runner-evidence-run-control
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-runner-evidence-run-control
```

## Evidence And Rollback

Retain concise validation and implementation evidence under the appropriate
proposal support files or run evidence roots. Keep raw local logs local-only
when retained. Include rollback evidence for every edited authored source and
for every generated artifact refreshed through canonical scripts.

## Refusal Criteria

Refuse or block closeout/archive claims if either
`support/implementation-conformance-review.md` or
`support/post-implementation-drift-churn-review.md` is absent, stale, failing,
or incomplete. Refuse implementation if the work would move route, validator,
promotion, closeout, cleanup, archive, publication, registry, disclosure-tier,
or run-lifecycle ownership into the generic runner.

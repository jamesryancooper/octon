# Executable Implementation Prompt

implementation_prompt_id: delegated-governance-cutover-closeout-implementation-prompt-2026-05-18
proposal_path: .octon/inputs/exploratory/proposals/architecture/delegated-governance-cutover-closeout
route_id: run-packet-implementation
status: operational-aid
generated_at: 2026-05-18T16:18:02Z

This prompt is an operational implementation aid for the accepted proposal
packet. It does not approve execution, widen scope, create authority, replace
run contracts, replace proposal manifests, or substitute for retained evidence.
Generated outputs and read models remain derived-only through cutover.

## Prompt Generation Gate Receipt

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/delegated-governance-cutover-closeout --require-implementation-authorization
```

Observed result at prompt-generation time: `errors=0 warnings=0`.

## Profile Selection Receipt

- `release_state`: `pre-1.0`
- `change_profile`: `atomic`
- atomic posture: perform final compatibility retirement and closeout checks
  only after predecessor child receipts are terminal and fresh
- transitional exception: not authorized

## Mandatory Preflight

Verify all required predecessor children are terminal with fresh implementation
run, conformance, drift/churn, validation, and promotion evidence. Then run:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/delegated-governance-cutover-closeout
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/delegated-governance-cutover-closeout
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/delegated-governance-cutover-closeout --require-implementation-authorization
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/delegated-governance-cutover-closeout
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-child-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/octon-wide-delegated-governance-migration
```

Refuse implementation if any predecessor child is not terminal, not fresh, or
missing retained receipts.

## In Scope

Durable edits may touch only:

- `.octon/framework/constitution/contracts/authority/`
- `.octon/framework/constitution/contracts/runtime/`
- `.octon/framework/engine/runtime/spec/`
- `.octon/framework/assurance/runtime/_ops/scripts/`
- `.octon/framework/assurance/runtime/_ops/tests/`
- `.octon/framework/product/features/lifecycle-autopilot.md`

Expected durable work:

1. Verify predecessor child outcomes and receipt freshness.
2. Run aggregate delegated-governance validators and record evidence.
3. Retire remaining compatibility/default approval language in migrated
   surfaces, including approval-default, operator-override, and generic
   approval-required posture where predecessor packets authorized migration.
4. Confirm generated/read-model outputs remain non-authority after cutover.
5. Produce aggregate closeout evidence for the parent program that summarizes
   child outcomes without replacing child-owned receipts.

## Out Of Scope

Do not implement missing predecessor work in this child. Do not close or archive
the parent program until aggregate evidence passes. Do not mutate connector
permissions, runtime behavior, or generated projections outside the declared
targets. Do not change `proposal.yml#status`.

## Required Evidence And Receipts

Retain evidence under:

```text
.octon/state/evidence/validation/proposals/delegated-governance-cutover-closeout/<timestamp>/
```

Retain:

- predecessor receipt freshness matrix;
- aggregate delegated-governance validator outputs;
- compatibility/default-approval retirement receipt;
- generated/read-model non-authority receipt;
- parent closeout evidence summary that cites, but does not replace,
  child-owned receipts;
- rollback posture for cutover edits.

Update:

- `support/implementation-run.md`
- `support/implementation-conformance-review.md`
- `support/post-implementation-drift-churn-review.md`
- `support/validation.md`

## Validation

Run:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/delegated-governance-cutover-closeout
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/delegated-governance-cutover-closeout
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/delegated-governance-cutover-closeout
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-structure.sh --package .octon/inputs/exploratory/proposals/architecture/octon-wide-delegated-governance-migration
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-child-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/octon-wide-delegated-governance-migration
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/architecture/delegated-governance-cutover-closeout
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/architecture/delegated-governance-cutover-closeout
```

Also run every aggregate delegated-governance validator introduced by
predecessor packets.

## Rollback And Closeout Refusal

Rollback is revert of cutover edits and restoration of the last validated
pre-cutover durable state. Refuse closeout or archive if any predecessor child
lacks terminal fresh receipts, if compatibility/default approval language
remains in migrated surfaces, if generated/read-model outputs can grant
authority, if aggregate validators fail, or if
`support/implementation-conformance-review.md` and
`support/post-implementation-drift-churn-review.md` do not pass.

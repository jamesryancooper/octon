# Executable Implementation Prompt

implementation_prompt_id: mission-runtime-proof-first-posture-implementation-prompt-2026-05-18
proposal_path: .octon/inputs/exploratory/proposals/architecture/mission-runtime-proof-first-posture
route_id: run-packet-implementation
status: operational-aid
generated_at: 2026-05-18T16:18:02Z

This prompt is an operational implementation aid for the accepted proposal
packet. It does not approve execution, widen scope, create authority, replace
run contracts, replace proposal manifests, or substitute for retained evidence.
Generated/read-model states can report proof state but must not authorize
dispatch.

## Prompt Generation Gate Receipt

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/mission-runtime-proof-first-posture --require-implementation-authorization
```

Observed result at prompt-generation time: `errors=0 warnings=0`.

## Profile Selection Receipt

- `release_state`: `pre-1.0`
- `change_profile`: `atomic`
- atomic posture: replace mission/runtime approval-default posture with retained
  proof-first dispatch semantics for migrated surfaces
- transitional exception: not authorized

## Mandatory Preflight

Confirm the shared contract model is available and fresh enough to bind proof
semantics. Then run:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/mission-runtime-proof-first-posture
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/mission-runtime-proof-first-posture
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/mission-runtime-proof-first-posture --require-implementation-authorization
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/mission-runtime-proof-first-posture
```

Refuse implementation if shared proof semantics are missing, stale, or
contradictory.

## In Scope

Durable edits may touch only:

- `.octon/framework/engine/runtime/crates/kernel/`
- `.octon/framework/engine/runtime/spec/`
- `.octon/framework/constitution/contracts/runtime/`

Expected durable work:

1. Inventory mission/runtime `approval_required`, unattended, autonomous,
   operator override, unsafe resume, and proof-state surfaces.
2. Replace generic approval posture where applicable with proof-first state and
   typed fail-closed outcomes such as `authorization-proof-failed` and
   `human-boundary-blocked`.
3. Require retained authorization or delegation proof before delegated dispatch
   in migrated runtime paths.
4. Ensure `unattended` means proof-gated execution only, not operator override.
5. Add negative controls for missing proof, unsupported mode, generated-output
   authority misuse, stale evidence, contradictory evidence, scope mismatch,
   and unsafe resume.

## Out Of Scope

Do not implement connector-specific external effect handling, authority-engine
grant schema migration, workflow classification, or run-health read-model
publication in this child. Do not edit generated projections or proposal
status. Do not treat proposal-local files as runtime authority.

## Required Evidence And Receipts

Retain evidence under:

```text
.octon/state/evidence/validation/proposals/mission-runtime-proof-first-posture/<timestamp>/
```

Retain:

- mission/runtime reconnaissance receipt;
- retained-proof-before-dispatch validation receipt;
- unsupported-mode and unsafe-resume negative-control outputs;
- fail-closed vocabulary receipt;
- rollback posture for runtime/spec/contract changes.

Update:

- `support/implementation-run.md`
- `support/implementation-conformance-review.md`
- `support/post-implementation-drift-churn-review.md`
- `support/validation.md`

## Validation

Run:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/mission-runtime-proof-first-posture
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/mission-runtime-proof-first-posture
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/mission-runtime-proof-first-posture
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/architecture/mission-runtime-proof-first-posture
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/architecture/mission-runtime-proof-first-posture
```

Also run focused kernel runtime tests and any mission/runtime validators touched
by the implementation.

## Rollback And Closeout Refusal

Rollback is revert of kernel, runtime spec, and runtime contract changes from
this packet. Refuse closeout or archive if unattended dispatch can proceed
without retained proof, if operator override semantics remain as authority, if
unsafe resume is not a typed human boundary, if validation evidence is missing,
or if `support/implementation-conformance-review.md` and
`support/post-implementation-drift-churn-review.md` do not pass.

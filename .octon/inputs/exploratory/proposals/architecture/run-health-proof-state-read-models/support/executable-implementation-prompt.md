# Executable Implementation Prompt

implementation_prompt_id: run-health-proof-state-read-models-implementation-prompt-2026-05-18
proposal_path: .octon/inputs/exploratory/proposals/architecture/run-health-proof-state-read-models
route_id: run-packet-implementation
status: operational-aid
generated_at: 2026-05-18T16:18:02Z

This prompt is an operational implementation aid for the accepted proposal
packet. It does not approve execution, widen scope, create authority, replace
run contracts, replace proposal manifests, or substitute for retained evidence.
Generated read models remain observational and cannot control dispatch.

## Prompt Generation Gate Receipt

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/run-health-proof-state-read-models --require-implementation-authorization
```

Observed result at prompt-generation time: `errors=0 warnings=0`.

## Profile Selection Receipt

- `release_state`: `pre-1.0`
- `change_profile`: `atomic`
- atomic posture: migrate run-health/read-model vocabulary to proof-state and
  typed human-boundary reporting without making projections authoritative
- transitional exception: not authorized

## Mandatory Preflight

Confirm the shared contract model is available and that generated outputs are
handled only through publication/freshness mechanisms. Then run:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/run-health-proof-state-read-models
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/run-health-proof-state-read-models
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/run-health-proof-state-read-models --require-implementation-authorization
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/run-health-proof-state-read-models
```

Refuse implementation if any read-model change would become control truth.

## In Scope

Durable edits may touch only:

- `.octon/framework/engine/runtime/spec/`
- `.octon/framework/assurance/runtime/_ops/scripts/`
- `.octon/generated/cognition/projections/materialized/`

Expected durable work:

1. Inventory run-health and read-model status vocabulary, including
   `approval-required`, proof-failed, blocked, review-required, revoked,
   denied, unknown, stale, contradictory, and scope-mismatch states.
2. Replace or narrow generic `approval-required` reporting where applicable
   into proof-first and typed human-boundary states.
3. Preserve generated projection non-authority and source traceability.
4. Add or strengthen validators proving read models cannot grant authority or
   become dispatch control.
5. Refresh generated projections only through the appropriate generator or
   publication path and retain freshness evidence.

## Out Of Scope

Do not change authority-engine grant semantics, mission runtime dispatch,
connector authorization, or workflow classification. Do not hand-edit generated
outputs unless the repository's existing generator path explicitly requires it
and records publication/freshness evidence. Do not change `proposal.yml#status`.

## Required Evidence And Receipts

Retain evidence under:

```text
.octon/state/evidence/validation/proposals/run-health-proof-state-read-models/<timestamp>/
```

Retain:

- run-health/read-model vocabulary inventory receipt;
- projection non-authority validation receipt;
- proof-state vocabulary check outputs;
- generated-output freshness receipt when projections are refreshed;
- rollback posture for spec, validator, and generated projection changes.

Update:

- `support/implementation-run.md`
- `support/implementation-conformance-review.md`
- `support/post-implementation-drift-churn-review.md`
- `support/validation.md`

## Validation

Run:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/run-health-proof-state-read-models
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/run-health-proof-state-read-models
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/run-health-proof-state-read-models
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/architecture/run-health-proof-state-read-models
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/architecture/run-health-proof-state-read-models
```

Also run read-model validators touched by the implementation.

## Rollback And Closeout Refusal

Rollback is revert of spec, validator, and generated projection changes plus
retirement of any publication evidence created solely for a failed attempt.
Refuse closeout or archive if read models can grant authority, if stale or
contradictory evidence does not fail closed in status vocabulary, if generated
freshness evidence is missing, or if `support/implementation-conformance-review.md`
and `support/post-implementation-drift-churn-review.md` do not pass.

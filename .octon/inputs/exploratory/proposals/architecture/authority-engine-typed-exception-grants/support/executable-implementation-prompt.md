# Executable Implementation Prompt

implementation_prompt_id: authority-engine-typed-exception-grants-implementation-prompt-2026-05-18
proposal_path: .octon/inputs/exploratory/proposals/architecture/authority-engine-typed-exception-grants
route_id: run-packet-implementation
status: operational-aid
generated_at: 2026-05-18T16:18:02Z

This prompt is an operational implementation aid for the accepted proposal
packet. It does not approve execution, widen scope, create authority, replace
run contracts, replace proposal manifests, or substitute for retained evidence.
Generated outputs and read models must never create grants or authority.

## Prompt Generation Gate Receipt

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/authority-engine-typed-exception-grants --require-implementation-authorization
```

Observed result at prompt-generation time: `errors=0 warnings=0`.

## Profile Selection Receipt

- `release_state`: `pre-1.0`
- `change_profile`: `atomic`
- atomic posture: migrate authority-engine grant surfaces to typed exception
  grants and delegated grant consumption in one coherent change
- transitional exception: not authorized

## Mandatory Preflight

Confirm the shared contract model is implemented or has retained evidence that
defines typed human boundaries and grant-consumption semantics. Then run:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/authority-engine-typed-exception-grants
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/authority-engine-typed-exception-grants
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/authority-engine-typed-exception-grants --require-implementation-authorization
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/authority-engine-typed-exception-grants
```

Refuse implementation if the shared model dependency is missing, stale, or
contradictory.

## In Scope

Durable edits may touch only:

- `.octon/framework/engine/runtime/crates/authority_engine/`
- `.octon/framework/constitution/contracts/authority/`
- `.octon/framework/assurance/runtime/_ops/tests/`

Expected durable work:

1. Locate authority-engine approval request, grant, exception, revocation, and
   grant-consumption surfaces.
2. Replace or narrow generic approval reasons with exact typed exception
   boundaries: `scope-expansion`, `policy-override`,
   `unresolved-risk-acceptance`, `governance-mutation`,
   `contradictory-evidence-resolution`, `stale-evidence-acceptance`,
   `authority-ambiguity`, `unsafe-resume`, and
   `external-irreversible-effect`.
3. Model consumption of an already-bound grant as delegated execution with
   authority provenance, not as fresh authority.
4. Preserve revocation and denial behavior as fail-closed controls.
5. Add negative controls for generic approval reasons, importance-only approval
   rationales, generated-output authority misuse, read-model authority misuse,
   and missing provenance.

## Out Of Scope

Do not rewrite mission runtime posture, connector behavior, workflow
classification, or read-model generation in this child. Do not create or
consume generated projections as authority. Do not edit state/control grant
instances except through a separately authorized run. Do not change
`proposal.yml#status`.

## Required Evidence And Receipts

Retain evidence under:

```text
.octon/state/evidence/validation/proposals/authority-engine-typed-exception-grants/<timestamp>/
```

Retain:

- repository reconnaissance receipt for authority-engine and authority-contract
  surfaces;
- typed exception grant schema validation receipt;
- grant-consumption provenance receipt;
- negative-control test outputs;
- rollback posture for reverting grant schema and engine changes.

Update:

- `support/implementation-run.md`
- `support/implementation-conformance-review.md`
- `support/post-implementation-drift-churn-review.md`
- `support/validation.md`

## Validation

Run:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/authority-engine-typed-exception-grants
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/authority-engine-typed-exception-grants
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/authority-engine-typed-exception-grants
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/architecture/authority-engine-typed-exception-grants
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/architecture/authority-engine-typed-exception-grants
```

Also run focused authority-engine Rust tests and assurance tests introduced or
touched by the implementation.

## Rollback And Closeout Refusal

Rollback is revert of authority contract, authority-engine, and test changes
from this packet. Refuse closeout or archive if grants can be created without
an exact typed boundary, if grant consumption lacks provenance, if generated
outputs or read models can mint authority, if negative controls are missing, or
if `support/implementation-conformance-review.md` and
`support/post-implementation-drift-churn-review.md` do not pass.

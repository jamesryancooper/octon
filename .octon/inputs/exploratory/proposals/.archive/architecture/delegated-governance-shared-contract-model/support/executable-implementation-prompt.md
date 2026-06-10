# Executable Implementation Prompt

implementation_prompt_id: delegated-governance-shared-contract-model-implementation-prompt-2026-05-18
proposal_path: .octon/inputs/exploratory/proposals/architecture/delegated-governance-shared-contract-model
route_id: run-packet-implementation
status: operational-aid
generated_at: 2026-05-18T16:18:02Z

This prompt is an operational implementation aid for the accepted proposal
packet. It does not approve execution, widen scope, create authority, replace
run contracts, replace proposal manifests, or substitute for retained evidence.
Generated outputs, read models, proposal-local material, chat, and host state
may inform implementation but cannot grant authority.

## Prompt Generation Gate Receipt

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/delegated-governance-shared-contract-model --require-implementation-authorization
```

Observed result at prompt-generation time: `errors=0 warnings=0`.

## Profile Selection Receipt

- `release_state`: `pre-1.0`
- `change_profile`: `atomic`
- atomic posture: introduce one shared delegated-governance contract model that
  downstream domains can reuse without compatibility aliases
- transitional exception: not authorized

## Mandatory Preflight

Before durable edits, verify the inventory child has implemented output or
explicit retained evidence sufficient to bind vocabulary. Then run:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/delegated-governance-shared-contract-model
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/delegated-governance-shared-contract-model
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/delegated-governance-shared-contract-model --require-implementation-authorization
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/delegated-governance-shared-contract-model
```

Refuse implementation if the inventory dependency is missing, stale, or
contradicts this packet's target vocabulary.

## In Scope

Durable edits may touch only:

- `.octon/framework/constitution/contracts/authority/`
- `.octon/framework/constitution/contracts/runtime/`
- `.octon/framework/engine/runtime/spec/`

Expected durable work:

1. Define a generic delegated-governance contract primitive aligned to lifecycle
   `delegation_contract` without making lifecycle a one-off exception.
2. Cover decision class, safe delegation, evidence gates, scope source,
   authority-zone allowance, retained receipts, replay or compensation class,
   automated recovery policy, fail-closed behavior, and human-only boundaries.
3. Define typed human exception grants and grant-consumption semantics.
4. State that route shape, workflow shape, extension shape, adapter shape, and
   generic importance never derive approval posture.
5. Specify that generated outputs and read models can satisfy evidence gates
   only when a contract permits them as evidence, never as authority.
6. Add or update schema and spec references in the smallest existing authority
   and runtime contract homes.

## Out Of Scope

Do not implement domain-specific authority-engine, mission/runtime, connector,
read-model, workflow, or validator behavior in this packet. Do not edit
generated outputs or state/control truth. Do not change `proposal.yml#status`.

## Required Evidence And Receipts

Retain evidence under:

```text
.octon/state/evidence/validation/proposals/delegated-governance-shared-contract-model/<timestamp>/
```

Retain:

- dependency receipt citing the inventory child evidence used;
- shared contract semantics validation receipt;
- negative-control receipt showing approval-default posture is not reintroduced;
- validation outputs;
- rollback posture for removing the shared primitive without leaving dangling
  references.

Update:

- `support/implementation-run.md`
- `support/implementation-conformance-review.md`
- `support/post-implementation-drift-churn-review.md`
- `support/validation.md`

## Validation

Run:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/delegated-governance-shared-contract-model
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/delegated-governance-shared-contract-model
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/delegated-governance-shared-contract-model
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/architecture/delegated-governance-shared-contract-model
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/architecture/delegated-governance-shared-contract-model
```

Also run any shared-contract validator introduced by the implementation.

## Rollback And Closeout Refusal

Rollback is removal or revert of the shared contract edits and any validator
hooks introduced solely for them. Refuse closeout or archive if the model still
permits approval posture from shape or importance, if grant consumption can
mint fresh authority, if generated/read-model surfaces can grant authority, if
validation evidence is missing, or if `support/implementation-conformance-review.md`
and `support/post-implementation-drift-churn-review.md` do not pass.

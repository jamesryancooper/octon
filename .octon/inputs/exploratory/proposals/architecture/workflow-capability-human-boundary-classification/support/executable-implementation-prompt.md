# Executable Implementation Prompt

implementation_prompt_id: workflow-capability-human-boundary-classification-implementation-prompt-2026-05-18
proposal_path: .octon/inputs/exploratory/proposals/architecture/workflow-capability-human-boundary-classification
route_id: run-packet-implementation
status: operational-aid
generated_at: 2026-05-18T16:18:02Z

This prompt is an operational implementation aid for the accepted proposal
packet. It does not approve execution, widen scope, create authority, replace
run contracts, replace proposal manifests, or substitute for retained evidence.
Generated capability indexes are derived context only.

## Prompt Generation Gate Receipt

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/workflow-capability-human-boundary-classification --require-implementation-authorization
```

Observed result at prompt-generation time: `errors=0 warnings=0`.

## Profile Selection Receipt

- `release_state`: `pre-1.0`
- `change_profile`: `atomic`
- atomic posture: normalize workflow/capability human-boundary classification
  to proof-first delegated execution and exact typed human boundaries
- transitional exception: not authorized

## Mandatory Preflight

Confirm the shared contract model is available and that workflow/capability
classification changes remain inside declared targets. Then run:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/workflow-capability-human-boundary-classification
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/workflow-capability-human-boundary-classification
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/workflow-capability-human-boundary-classification --require-implementation-authorization
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/workflow-capability-human-boundary-classification
```

Refuse implementation if a route, workflow, extension, or capability shape is
being used as approval posture.

## In Scope

Durable edits may touch only:

- `.octon/framework/orchestration/governance/`
- `.octon/framework/capabilities/governance/policy/`
- `.octon/framework/engine/runtime/spec/`

Expected durable work:

1. Inventory workflow and capability labels such as `human-only`,
   `role-mediated`, `execution-role-ready`, autonomous, workflow-backed,
   extension-backed, and capability-classification surfaces.
2. Map each label to proof-first delegated execution, already-bound grant
   consumption, exact typed human boundary, deny-only, or projection-only.
3. Remove or narrow route-shape, workflow-shape, extension-shape, and
   importance-based approval defaults where applicable.
4. Define how role-mediated paths consume already-bound grants as delegated
   execution without granting new authority.
5. Add negative controls for workflow-vs-extension approval defaults and
   generated-index authority misuse.

## Out Of Scope

Do not implement authority-engine grant internals, connector effect handling,
run-health generation, or mission dispatch in this child. Do not edit generated
capability indexes as authority. Do not change `proposal.yml#status`.

## Required Evidence And Receipts

Retain evidence under:

```text
.octon/state/evidence/validation/proposals/workflow-capability-human-boundary-classification/<timestamp>/
```

Retain:

- workflow/capability classification inventory receipt;
- classification mapping receipt;
- workflow-vs-extension negative-control outputs;
- generated-index non-authority receipt;
- rollback posture for governance/policy/spec changes.

Update:

- `support/implementation-run.md`
- `support/implementation-conformance-review.md`
- `support/post-implementation-drift-churn-review.md`
- `support/validation.md`

## Validation

Run:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/workflow-capability-human-boundary-classification
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/workflow-capability-human-boundary-classification
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/workflow-capability-human-boundary-classification
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/architecture/workflow-capability-human-boundary-classification
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/architecture/workflow-capability-human-boundary-classification
```

Also run workflow/capability policy validators touched by the implementation.

## Rollback And Closeout Refusal

Rollback is revert of orchestration governance, capability policy, and runtime
spec changes from this packet. Refuse closeout or archive if human-only labels
do not name precise typed boundaries, if role-mediated grant consumption mints
fresh authority, if route shape controls approval posture, or if
`support/implementation-conformance-review.md` and
`support/post-implementation-drift-churn-review.md` do not pass.

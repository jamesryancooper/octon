# Executable Implementation Prompt

implementation_prompt_id: connector-external-effect-delegation-boundaries-implementation-prompt-2026-05-18
proposal_path: .octon/inputs/exploratory/proposals/architecture/connector-external-effect-delegation-boundaries
route_id: run-packet-implementation
status: operational-aid
generated_at: 2026-05-18T16:18:02Z

This prompt is an operational implementation aid for the accepted proposal
packet. It does not approve execution, widen scope, create authority, replace
run contracts, replace proposal manifests, or substitute for retained evidence.
Generated connector summaries and read models cannot grant connector authority.

## Prompt Generation Gate Receipt

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/connector-external-effect-delegation-boundaries --require-implementation-authorization
```

Observed result at prompt-generation time: `errors=0 warnings=0`.

## Profile Selection Receipt

- `release_state`: `pre-1.0`
- `change_profile`: `atomic`
- atomic posture: define connector and external-effect delegation boundaries
  with no compatibility fallback to generic approval posture
- transitional exception: not authorized

## Mandatory Preflight

Confirm the shared contract model is available and that external-effect changes
stay within this packet's declared targets. Then run:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/connector-external-effect-delegation-boundaries
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/connector-external-effect-delegation-boundaries
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/connector-external-effect-delegation-boundaries --require-implementation-authorization
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/connector-external-effect-delegation-boundaries
```

Refuse implementation if connector authority ownership or external-effect
classification is ambiguous.

## In Scope

Durable edits may touch only:

- `.octon/instance/governance/connectors/`
- `.octon/framework/constitution/contracts/adapters/`
- `.octon/framework/engine/runtime/spec/`
- `.octon/framework/assurance/runtime/_ops/tests/`

Expected durable work:

1. Inventory connector and external-effect authorization paths, including
   credential classes, connector admissions, operation receipts, egress policy,
   authorized effect token expectations, rollback, and compensation.
2. Classify effects by reversibility, compensation support, egress posture,
   token requirements, scope containment, and receipt requirements.
3. Require token, scope, egress, replay or compensation, and retained receipt
   proof before machine-delegated connector or external-effect execution.
4. Keep external irreversible effects human-required unless rollback or
   compensation and token proof are explicit and machine-checkable.
5. Add negative controls for irreversible effects without proof, permission
   widening, generated-output authority misuse, stale evidence, and scope
   mismatch.

## Out Of Scope

Do not admit new connectors, change live credential values, perform external
effects, mutate state/control operations, or edit runtime code outside the
declared spec target. Do not publish generated connector projections as
authority. Do not change `proposal.yml#status`.

## Required Evidence And Receipts

Retain evidence under:

```text
.octon/state/evidence/validation/proposals/connector-external-effect-delegation-boundaries/<timestamp>/
```

Retain:

- connector/external-effect inventory receipt;
- token and egress proof validation receipt;
- external irreversible effect negative-control outputs;
- generated-summary non-authority receipt;
- rollback and compensation posture receipt.

Update:

- `support/implementation-run.md`
- `support/implementation-conformance-review.md`
- `support/post-implementation-drift-churn-review.md`
- `support/validation.md`

## Validation

Run:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/connector-external-effect-delegation-boundaries
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/connector-external-effect-delegation-boundaries
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/connector-external-effect-delegation-boundaries
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/architecture/connector-external-effect-delegation-boundaries
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/architecture/connector-external-effect-delegation-boundaries
```

Also run focused connector/adapters tests introduced or touched by the
implementation.

## Rollback And Closeout Refusal

Rollback is revert of connector governance, adapter contract, runtime spec, and
test changes from this packet. Refuse closeout or archive if connector effects
can dispatch without token/scope/egress/replay/receipt proof, if external
irreversible effects are machine-delegable without explicit proof, if generated
connector summaries grant authority, or if `support/implementation-conformance-review.md`
and `support/post-implementation-drift-churn-review.md` do not pass.

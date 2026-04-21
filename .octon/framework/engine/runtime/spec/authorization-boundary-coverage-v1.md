# Authorization Boundary Coverage v1

This contract proves that every material side-effect path is routed through the
engine-owned authorization boundary before the effect occurs.

## Canonical Boundary

All material paths remain subordinate to
`/.octon/framework/engine/runtime/spec/execution-authorization-v1.md` and the
engine entrypoint:

```rust
authorize_execution(request: ExecutionRequest) -> GrantBundle
```

Coverage is complete only when the path inventory, negative controls, retained
authority evidence, and runtime receipts all point at the same boundary.

## Material Path Families

Each family below is claim-critical and must be inventoried explicitly:

- capability or service invocation that can mutate repo state, control state,
  retained evidence, or release disclosure
- workflow-stage execution and executor launch
- repo mutation, publication, or release-lineage activation
- control mutations under `/.octon/state/control/**`
- runtime-facing publication under `/.octon/generated/effective/**`
- protected CI, host-projected control actions, and workflow-triggered
  consequential operations
- outbound HTTP, model-backed execution, and runtime-service writes
- support-target-affecting or disclosure-affecting promotion/activation flows

## Coverage Requirements

Every inventoried path must bind:

- a stable `path_id`
- the owning code module, script, or workflow entrypoint
- the side-effect class and affected root
- the `authorize_execution` binding point
- the required support-target tuple or equivalent normalized support posture
- required capability-pack, approval, and rollback posture
- a negative-path test or denial fixture
- retained `decision-artifact` and `grant-bundle` evidence refs

Consequential paths must also bind the canonical run roots before the side
effect:

- `run-contract.yml`
- `run-manifest.yml`
- `runtime-state.yml`
- `rollback-posture.yml`
- `/.octon/state/evidence/runs/<run-id>/**`

Release activation and authoritative promotion additionally require a retained
promotion receipt. Generated read models, labels, comments, checks, and other
projections may display status, but they may never replace or bypass the
boundary.

## Minimum Proof

The coverage claim is valid only when retained evidence includes:

- a complete inventory of material path families
- negative controls showing direct or bypass attempts fail closed
- fixture runs for `allow`, `stage_only`, `escalate`, and `deny`
- retained receipts whose authority refs resolve to the same boundary used by
  the inventory

## Failure Rule

If any material path lacks an explicit boundary mapping, retained authority
evidence, or negative bypass proof, the path is unsupported and must fail
closed.

## Related Contracts

- `execution-authorization-v1.md`
- `execution-request-v3.schema.json`
- `execution-receipt-v3.schema.json`
- `runtime-event-v1.schema.json`
- `/.octon/framework/constitution/contracts/authority/decision-artifact-v2.schema.json`
- `/.octon/framework/constitution/contracts/authority/grant-bundle-v2.schema.json`
- `/.octon/framework/constitution/contracts/authority/promotion-receipt-v1.schema.json`
- `/.octon/framework/engine/runtime/spec/promotion-activation-v1.md`

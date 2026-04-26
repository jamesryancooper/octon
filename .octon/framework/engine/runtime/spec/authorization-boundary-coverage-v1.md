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

For token-enforced material paths, coverage is complete only when the same
inventory also binds:

- the issued `AuthorizedEffect<T>` class,
- the consumer API that verifies it,
- the canonical token-record ref,
- the consumption receipt ref,
- route id, runtime-effective generation/freshness refs, support tuple, and
  capability-pack scope checked by the verifier,
- approval, exception, rollback, budget, and egress refs when those constraints
  participate in the grant,
- the required token lifecycle journal coverage, and
- negative bypass proof for missing, forged, stale, wrong-kind, wrong-scope,
  wrong-run, wrong-route, wrong-support, wrong-capability-pack, revoked,
  expired, missing-approval, missing-exception, rollback-not-ready,
  budget-exceeded, egress-denied, and already-consumed tokens.

## Material Path Families

Each family below is claim-critical and must be inventoried explicitly:

- capability or service invocation that can mutate repo state, control state,
  retained evidence, or release disclosure
- service build and other shell-backed service lifecycle mutations
- workflow-stage execution and executor launch
- repo mutation, publication, or release-lineage activation
- control mutations under `/.octon/state/control/**`
- runtime-facing publication under `/.octon/generated/effective/**`
- extension activation through runtime-owned wrappers
- capability-pack activation through runtime-owned wrappers
- protected CI merge through a token-enforced runtime boundary
- protected CI, host-projected control actions, and workflow-triggered
  consequential operations
- outbound HTTP, model-backed execution, and runtime-service writes
- support-target-affecting or disclosure-affecting promotion/activation flows

## Coverage Requirements

Every inventoried path must bind:

- a stable `path_id`
- the owning code module, script, or workflow entrypoint
- the side-effect class and affected root
- the required `AuthorizedEffect<T>` token type
- the consumer API ref that verifies the token
- the `authorize_execution` binding point
- the required support-target tuple or equivalent normalized support posture
- required capability-pack, approval, and rollback posture
- a negative-path test or denial fixture
- retained `decision-artifact` and `grant-bundle` evidence refs
- retained token-record and consumption-receipt evidence refs

Consequential paths must also bind the canonical run roots before the side
effect:

- `run-contract.yml`
- `run-manifest.yml`
- `events.ndjson`
- `events.manifest.yml`
- `runtime-state.yml`
- `rollback-posture.yml`
- `/.octon/state/evidence/runs/<run-id>/**`

For any material side-effecting path, the boundary proof must show journal
coverage for:

- the authority request or denial/grant outcome,
- the effect-token request/mint or deny outcome,
- the effect-token consumption requested/consumed or rejection outcome,
- the capability authorization/invocation pair or equivalent committed effect,
- any checkpoint or rollback/recovery transition the effect depends on, and
- the retained receipt or evidence snapshot that closes the path.

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
- retained token records and token consumption receipts for material paths
- deterministic denial reasons on rejection receipts, using the
  `authorized-effect-token-consumption-v1` denial reason vocabulary

## Failure Rule

If any material path lacks an explicit boundary mapping, retained authority
evidence, retained token proof, or negative bypass proof, the path is
unsupported and must fail closed.

## Related Contracts

- `execution-authorization-v1.md`
- `authorized-effect-token-v1.md`
- `authorized-effect-token-v2.schema.json`
- `authorized-effect-token-consumption-v1.schema.json`
- `execution-request-v3.schema.json`
- `execution-receipt-v3.schema.json`
- `runtime-event-v1.schema.json`
- `/.octon/framework/constitution/contracts/authority/decision-artifact-v2.schema.json`
- `/.octon/framework/constitution/contracts/authority/grant-bundle-v2.schema.json`
- `/.octon/framework/constitution/contracts/authority/promotion-receipt-v1.schema.json`
- `/.octon/framework/engine/runtime/spec/promotion-activation-v1.md`

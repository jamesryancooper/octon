# Promotion Activation v1

This contract defines how non-authoritative, authored, control, and disclosure
surfaces may change live meaning without creating quiet authority.

## Terms

- `promotion`: move or normalize content into authored authority or mutable
  control roots
- `activation`: make an already retained disclosure or release selector the
  current live claim
- `publication`: refresh a generated/effective or operator-facing projection
  from canonical sources without minting authority

## Promotion Classes

### Authoritative Promotion

Source surfaces under `/.octon/inputs/**` or `/.octon/generated/**` may only
land in `/.octon/framework/**` or `/.octon/instance/**` through a retained
promotion receipt that records:

- source refs and digests
- target refs and digests
- authority basis
- governing policy refs
- semantic effect

### Control Materialization

Changes that create or mutate `/.octon/state/control/**` or retained control
evidence under `/.octon/state/evidence/control/execution/**` require both the
normal authority path and a promotion receipt when the mutation is sourced from
non-authoritative or generated material.

### Derived Publication

Publication into `/.octon/generated/effective/**` or generated operator read
models is allowed only from canonical authored, control, or retained evidence
sources. Publication may refresh operator visibility, but the result remains
derived non-authority even after publication.

### Release Activation

Activating or superseding the live claim requires:

- the active `harness-card-v2` disclosure family
- support-universe coverage for the selected release
- proof-plane coverage for the selected release
- release-lineage update that marks exactly one active release
- a retained promotion receipt describing the activation or supersession

## Prohibited Flows

- `inputs/**` or `generated/**` directly becoming runtime or policy inputs
- `inputs/**` or `generated/**` directly minting live control state without a
  retained receipt
- generated summaries, mission views, operator digests, or effective
  projections being consumed as authority
- release activation without closure truth conditions and release-lineage
  selection

## Failure Rule

Any promotion or activation missing a retained receipt, canonical authority
basis, or explicit semantic class is invalid and must fail closed.

## Related Contracts

- `/.octon/framework/constitution/contracts/authority/promotion-receipt-v1.schema.json`
- `/.octon/framework/engine/runtime/spec/evidence-store-v1.md`
- `/.octon/framework/engine/runtime/spec/operator-read-models-v1.md`
- `/.octon/framework/constitution/contracts/disclosure/family.yml`

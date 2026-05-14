# Authority Boundary Notes

_Status: In-review proposal packet artifact_


## Boundary principles

- `framework/**` and `instance/**` hold authored authority.
- `state/control/**` holds mutable operational truth.
- `state/evidence/**` holds retained factual proof and receipts.
- `state/continuity/**` holds resumption context, not authority.
- `generated/**` is rebuildable projection.
- `inputs/**` is raw/additive/proposal input and never direct runtime/policy dependency.

## Entry-artifact implication

README and AGENTS files may orient readers and agents, but runtime behavior remains owned by canonical contracts and registries.

## Proposal implication

This packet must not be referenced by promoted durable targets as source of truth after implementation.

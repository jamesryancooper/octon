# Target Architecture

## Scope

Precompute advisory repo authority graph and promotion-target/write-scope index to avoid repeated repo re-learning.

## Target End State

The durable implementation introduces or refactors the following surfaces:

- `repo-authority-graph.yml`
- `promotion-target-index.yml`
- `write-scope-index.yml`

## Required Behavior

- Generate advisory path authority class map: framework, instance, state/control, state/evidence, generated/read-model, inputs/proposal.
- Map promotion targets and child write scopes to validators, owners, rollback surfaces, and dependent routes.
- Fail closed if stale graph is used as if it were authority.
- Use graph slices in proposal child context packs.

## Authority Status

All artifacts produced by this child are retained evidence, generated/read-model projections, or policy/spec/code under durable Octon targets. None of the child proposal files become runtime authority.

## Runtime Integration

- Deterministic producers must run before LLM reasoning where possible.
- Source digests and model-visible hashes must be retained.
- Compact artifacts must point to raw evidence or durable authority refs.
- Fail closed when stale, missing, unverifiable, or authority-conflicting.
- Preserve engine-owned authorization and support-proof evidence.

## Token Saving Mechanism

This child reduces model-visible tokens by replacing repeated full-text context with structured, digest-bound, stage-scoped artifacts while retaining raw evidence and replay refs.

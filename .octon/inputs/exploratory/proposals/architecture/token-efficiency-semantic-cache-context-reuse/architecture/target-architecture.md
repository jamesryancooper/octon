# Target Architecture

## Scope

Add source-hash invalidated semantic cache, context-pack layer reuse, generated graph/index reuse, parent-to-child handoff reuse, and lifecycle-level budgets at scale.

## Target End State

The durable implementation introduces or refactors the following surfaces:

- `proposal-semantic-cache.yml`
- `context-pack-layer-cache.yml`
- `cache-invalidation-events.yml`

## Required Behavior

- Add semantic summaries keyed by source digest, policy digest, route purpose, and trust class.
- Reuse context-pack layers for stable governance, prompt capsules, generated freshness handles, and child handoff capsules.
- Invalidate on source digest drift, policy digest drift, request binding mismatch, expired freshness, missing retained evidence, trust downgrade, explicit governance invalidation.
- Add lifecycle-level token budgets and CI token regression tests for repeated proposal runs.

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

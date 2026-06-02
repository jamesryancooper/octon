# Target Architecture

## Scope

Replace full prompt asset expansion by default with digest-bound prompt-pack handles, route capsules, compiled governance capsules, and controlled expansion rules.

## Target End State

The durable implementation introduces or refactors the following surfaces:

- `prompt-pack-capsule.yml`
- `route-instruction-capsule.yml`
- `compiled-governance-capsule.yml`
- `prompt-expansion-policy.yml`

## Required Behavior

- Modify prompt_bundle.rs to support prompt-pack handle mode and retained full prompt packet refs.
- Compile stable prompt/reference/shared-reference assets into capsules with source digests and visible short rules.
- Expand full prompt text only under explicit prompt-expansion-policy-v1 triggers.
- Retain full prompt packet for replay and audit.

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

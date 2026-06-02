# Target Architecture

## Scope

Create proposal/program spines, artifact indexes with token estimates, stage-role classification, and spine/slice/annex defaults.

## Target End State

The durable implementation introduces or refactors the following surfaces:

- `proposal-artifact-index.yml`
- `proposal-program-spine.yml`
- `child-handoff-capsule.yml`

## Required Behavior

- Generate per-proposal artifact indexes with path, role, digest, bytes, estimated tokens, inclusion mode, stage relevance, and read-raw-only-if hints.
- Generate proposal/program spines with status, child registry digest, authority boundary, gate states, receipt digests, blockers, and evidence refs.
- Classify proposal packet documents as spine, current-stage slice, evidence annex, or optional reference.
- Create child-handoff capsules from parent spine plus child-specific scope.

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

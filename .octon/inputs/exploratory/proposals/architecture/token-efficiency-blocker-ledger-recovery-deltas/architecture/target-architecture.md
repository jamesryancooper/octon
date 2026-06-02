# Target Architecture

## Scope

Replace repeated blocker history replay with stable blocker IDs, fingerprints, latest transitions, and bounded recovery deltas.

## Target End State

The durable implementation introduces or refactors the following surfaces:

- `blocker-ledger.yml`
- `recovery-delta-summary.yml`
- `aggregate-terminal-blockers.yml`

## Required Behavior

- Emit blocker-ledger.yml with blocker_id, child_id, blocker class, latest transition, prior/current fingerprint, recovery budget, and evidence refs.
- Make recovery prompts read latest delta and failing slices instead of stale receipt/archive history.
- Preserve child-owned authority: parent ledger summarizes but never satisfies child receipts.
- Add progress fingerprinting to prevent repeated recovery loops.

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

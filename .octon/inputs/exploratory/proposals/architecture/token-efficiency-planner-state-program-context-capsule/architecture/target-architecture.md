# Target Architecture

## Scope

Split full audit program plans from compact planner state and parent/child program context capsules.

## Target End State

The durable implementation introduces or refactors the following surfaces:

- `planner-state.yml`
- `program-context-capsule.yml`
- `compact-completion-capsule.yml`

## Required Behavior

- Retain full program-plan.yml for audit but route planners to planner-state.yml by default.
- Emit program-context-capsule.yml with child status table, dependency vector, runnable batch, current blockers, route decision, key digests, and evidence refs.
- Emit compact completion capsule for no-dispatch terminal parent runs.
- Bind program context capsule to event head and child registry digest.

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

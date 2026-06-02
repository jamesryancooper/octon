# Target Architecture

## Scope

Move evidence to machine-readable receipts, concise closeout projections, compact publication summaries, and on-demand expanded reports.

## Target End State

The durable implementation introduces or refactors the following surfaces:

- `closeout-projection.yml`
- `publication-summary.yml`
- `structured-receipt.yml`
- `expanded-report-request.yml`

## Required Behavior

- Define structured receipt templates with verdict, blockers, unresolved questions, evidence refs, source digests, validation counts, changed files, rollback refs, gate state, and exclusions.
- Make closeout-change and closeout-worktree consume concise closeout projections by default.
- Publish compact final summaries that reference retained evidence instead of duplicating it.
- Add expanded report generator that reconstructs narrative from retained evidence on demand.

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

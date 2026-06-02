# Target Architecture

## Scope

Add per-run evidence indexes, raw-log summaries, failing-slice manifests, and evidence readers that prefer compact refs over raw logs.

## Target End State

The durable implementation introduces or refactors the following surfaces:

- `evidence-index.yml`
- `raw-log-summary.yml`
- `failing-slice-manifest.yml`

## Required Behavior

- Emit evidence-index.yml with artifact role, digest, byte size, estimated tokens, model-visible relevance, and read-raw-only-if hints.
- Index stdout/stderr into deterministic raw-log-summary.yml records that identify prompt echoes, command output, diffs, and failing slices.
- Retain raw logs unchanged as evidence; consume compact summaries by default.
- Add evidence index reader paths for planner/recovery/closeout flows.

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

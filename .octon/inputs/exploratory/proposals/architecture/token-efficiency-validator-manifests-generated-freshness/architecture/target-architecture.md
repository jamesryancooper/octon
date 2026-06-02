# Target Architecture

## Scope

Add validator result manifests, failing slices, publication freshness manifests, generated/read-model digest handles, and compact run-health manifests.

## Target End State

The durable implementation introduces or refactors the following surfaces:

- `validator-result-manifest.yml`
- `publication-freshness-manifest.yml`
- `run-health-compact-manifest.yml`

## Required Behavior

- Emit pass/fail counts, failing slice refs, contract refs, negative controls, stdout/stderr refs, and evidence digests.
- Represent generated effective tree and run-health as compact freshness handles instead of broad path listings.
- Fail closed when generated freshness handles are stale or cannot be verified.
- Prefer manifests in planner/closeout/recovery context.

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

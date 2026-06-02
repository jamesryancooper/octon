# Target Architecture

## Scope

Apply Context Pack Builder inclusion modes to lifecycle, skill, bootstrap, generated, evidence, raw-log, and proposal context.

## Target End State

The durable implementation introduces or refactors the following surfaces:

- `context-pack-policy.yml`
- `source-manifest.json`
- `omissions.json`
- `model-visible-context.sha256`

## Required Behavior

- Add proposal-program context policy with stage-specific inclusion modes.
- Make lifecycle executor construct route context through Context Pack Builder before material authorization.
- Record omission reasons and escalation conditions for every omitted source.
- Ensure lifecycle/skill/bootstrap context uses digest-only or handle-only for stable governance and generated state by default.

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

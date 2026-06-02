# Target Architecture

## Scope

Add lifecycle-level token-budget ledgers, provider-usage capture, repeated-source accounting, and CI token regression measurement.

## Target End State

The durable implementation introduces or refactors the following surfaces:

- `token-budget-ledger.json`
- `token-regression-baseline.yml`
- `model-usage-summary.yml`

## Required Behavior

- Emit token-budget-ledger.json for parent, child, stage, source, and model levels.
- Capture prompt/context/completion/tool-output split when provider usage is available.
- Record repeated-source percentage, prompt boilerplate percentage, generated-state rereads, raw-log rereads, and high-reasoning call count.
- Add CI fixtures that compare before/after token ledger snapshots and fail on avoidable regressions.

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

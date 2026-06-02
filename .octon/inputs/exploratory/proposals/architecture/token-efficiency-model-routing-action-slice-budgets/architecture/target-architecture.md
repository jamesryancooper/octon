# Target Architecture

## Scope

Add deterministic-first routing, token ceilings, route decision receipts, escalation triggers, fallback behavior, and short action-slice loops.

## Target End State

The durable implementation introduces or refactors the following surfaces:

- `route-decision-receipt.yml`
- `model-routing-receipt.yml`
- `action-slice-ledger.yml`

## Required Behavior

- Define deterministic/small/medium/high/high-on-escalation routing matrix.
- Emit route-decision receipts and model-routing receipts for each lifecycle slice.
- Bound parent loops into load_program_spine, evaluate_dependency_vector, select_runnable_children, dispatch_child_or_no_dispatch, summarize_terminal_blockers, validate_completion, emit_closeout_capsule.
- Convert publication freshness, generated freshness, blocker aggregation zero-state, dependency vector, manifest completeness, registry projection, raw-log indexing, closeout schema validation, and worktree cleanliness to deterministic preflights.

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

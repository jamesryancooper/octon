# Churn Filesystem Snapshot Retention

## Target Surfaces

- `.octon/generated/effective/capabilities/filesystem-snapshots/**`
- `.octon/framework/capabilities/runtime/services/interfaces/filesystem-snapshot/**`

## Producer Owner

Capability filesystem snapshot service owner.

## Producer Entrypoint Inventory

Before implementation, enumerate the filesystem snapshot service entrypoints,
snapshot manifest schema, validators, generated snapshot root, and any
capability or evidence consumers that reference snapshots. The inventory must
classify each snapshot as generated/effective output, retained evidence, or
rebuildable local output before retention behavior is changed.

## Current Problem

The latest audit did not show filesystem snapshot churn, but snapshots are a
known generated/effective capability surface that can grow without explicit
stable identity or retention proof.

## Intended Efficiency Improvement

Add stable snapshot identity, no-op detection, retention budgets, and
producer-owned GC with reference-integrity checks.

## Guardrails

- Referenced evidence is never pruned.
- Snapshot schema validation remains intact.
- Generated/effective capability outputs are not generic cleanup candidates.
- Snapshot retention cannot remove a snapshot referenced by retained evidence, receipts, or active capability outputs.

## Validation Gates

- Snapshot schema and service tests.
- No-op snapshot identity tests.
- Retention and reference-integrity tests.
- Negative controls for referenced snapshot deletion and stale snapshot identity reuse.

## Measurable Success Criteria

- No-op snapshot production creates zero tracked diffs.
- Snapshot count and byte size stay within declared retention budgets.
- Producer-owned GC proves every removed generated snapshot is unreferenced or rebuildable.

## Common Metrics

Implementation must report the applicable parent metrics: changed file count,
generated no-op rewrite rate, dirty-worktree residue count, process runtime,
token budget impact, validation coverage retained, and evidence retrieval
integrity for snapshot references.

## External Dependencies

No existing external packet owns this child. It depends on
`proposal-churn-effective-publication-idempotency` through the parent program
sequence because filesystem snapshots live under generated/effective
capability output.

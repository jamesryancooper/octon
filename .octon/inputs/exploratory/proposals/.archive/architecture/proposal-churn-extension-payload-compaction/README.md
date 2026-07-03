# Churn Extension Payload Compaction

## Target Surfaces

- `.octon/generated/effective/extensions/**`
- `.octon/generated/effective/extensions/published/**`
- Extension publication and compatibility receipts

## Producer Owner

Extension state publisher.

## Producer Entrypoint Inventory

Before implementation, enumerate extension publication entrypoints, validators,
published payload consumers, copied payload roots, publication receipt writers,
and compatibility receipt writers. The inventory must state which files are
semantic active state, copied payloads, locks, receipts, or retained
validation evidence.

## Current Problem

Extension publication copies payload trees into generated/effective published
surfaces. The audit found 22 tracked modified extension generated files and a
separate timestamped receipt fanout pattern.

## Intended Efficiency Improvement

Use manifest or digest-addressed payload reuse, skip unchanged payload copies,
and limit publication writes to changed extensions.

## Guardrails

- Extension source files are not cleanup candidates.
- Published generated payloads remain non-authoritative.
- Publication and compatibility receipts remain retained and linked.
- Runtime-facing freshness validation remains mandatory.
- Support claims cannot rely on copied payloads without current publication, compatibility, and freshness proof.
- Digest-addressed reuse cannot mask changed required inputs or dependency closure drift.

## Validation Gates

- Extension publication state validation.
- Extension active-state compactness validation.
- No-op extension publish diff check.
- Digest reuse and changed-extension-only fixtures.
- Negative controls for stale publication receipts, stale compatibility receipts, and missing copied payload retrieval.

## Measurable Success Criteria

- No-op extension publication produces zero generated payload diffs.
- Changed extension publication touches only changed extension outputs and required receipts.
- Receipt and compatibility linkage remains complete.

## Common Metrics

Implementation must report the applicable parent metrics: changed file count,
generated no-op rewrite rate, receipt fanout count, dirty-worktree residue
count, process runtime, token budget impact, validation coverage retained, and
freshness/lock/receipt validation retained.

## External Dependencies

No existing external packet owns this child. It depends on
`proposal-churn-effective-publication-idempotency` through the parent program
sequence so runtime-facing publication invariants are stable first.

# Churn Proposal Artifact Compaction

## Target Surfaces

- `.octon/generated/proposals/**`
- Proposal registry, artifact indexes, program spines, and generated maps

## Producer Owner

Proposal registry and proposal artifact generators.

## Producer Entrypoint Inventory

Before implementation, enumerate proposal registry generation, proposal
artifact index generation, spine validation, registry freshness checks, and
all consumers of `.octon/generated/proposals/**`. The inventory must identify
which proposal input/archive changes invalidate which generated outputs.

## Current Problem

The audit found 13 changed generated proposal files: added artifact/spine files
plus a modified generated registry. As proposal/archive history grows, broad
regeneration creates increasing review and token cost.

## Intended Efficiency Improvement

Make generation archive-aware, changed-packet-only, and index-first so
unrelated proposal artifacts are not rewritten.

## Guardrails

- Proposal packets and archives are not cleanup candidates.
- Generated proposal views remain non-authoritative.
- Proposal manifests, reviews, receipts, and retained evidence remain the owned surfaces for lifecycle truth.
- Generated proposal outputs cannot satisfy child-owned proposal reviews, receipts, closeout, archive, or terminal proof.

## Validation Gates

- Proposal standard validation.
- Proposal registry check.
- Proposal artifact index/spine validation.
- No-op and changed-packet-only generator tests.
- Negative controls proving generated proposal outputs cannot replace child-owned lifecycle evidence.

## Measurable Success Criteria

- No-op proposal artifact generation creates zero tracked generated proposal diffs.
- Changing one proposal packet does not rewrite unrelated artifact indexes or spines.
- Archive-aware behavior preserves retained proposal lineage.

## Common Metrics

Implementation must report the applicable parent metrics: changed file count,
generated no-op rewrite rate, dirty-worktree residue count, process runtime,
token budget impact, validation coverage retained, and generated proposal
freshness retained.

## External Dependencies

No existing external packet owns this child. It consumes
`proposal-churn-common-generator-idempotency-metrics` through the parent
program sequence.

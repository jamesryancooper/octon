# Churn Retained Run Evidence Efficiency

## Target Surfaces

- `.octon/state/evidence/runs/**`
- `.octon/state/control/execution/**`
- `.octon/state/continuity/**`
- Retained run evidence indexes and cleanup helpers

## Producer Owner

Run lifecycle, closeout, evidence-store, continuity, and owning cleanup route
owners.

## Producer Entrypoint Inventory

Before implementation, enumerate run lifecycle writers, closeout writers,
evidence-store writers, continuity writers, retained evidence index
generators, validators, cleanup helpers, and every consumer that resolves run
evidence/control/continuity references.

## Current Problem

Operational evidence and control trees can grow heavily, but the latest audit
showed only narrow landed retained run evidence churn. These surfaces are not
generated cleanup candidates because they include retained evidence, control
truth, and continuity.

## Intended Efficiency Improvement

Optional adjacent work can improve retrieval indexes, retention classification,
and cleanup dry-run quality for exact stale/unreferenced files, with
reference-integrity proof.

## Optional Non-Blocking Status

This child is adjacent operational-efficiency work. It must remain deferrable
and non-blocking for core generated/projection churn reduction unless a later
accepted parent amendment explicitly widens the required scope.

## Guardrails

- Retained evidence is not deleted by generic cleanup.
- Control truth is not mutated by evidence compaction.
- Generated indexes cannot replace retained evidence.
- External cleanup and loop-breaker packets are dependencies, not duplicated.
- Support, closeout, disclosure, and continuity claims must still resolve to retained evidence or control truth, not generated indexes.

## Validation Gates

- Retained run evidence index validation.
- Cleanup dry-run with exact stale/unreferenced classification.
- Reference-integrity checks.
- Negative controls for generated index substitution.
- Negative controls for deleting referenced evidence, mutating control truth, or closing work from an index-only summary.

## Measurable Success Criteria

- Evidence retrieval gets faster or cheaper without losing referenced proof.
- Cleanup identifies only exact stale/unreferenced candidates under owning authority.
- Control and continuity guarantees remain intact.

## Common Metrics

Implementation must report the applicable parent metrics: changed file count,
dirty-worktree residue count, process runtime, token budget impact, validation
coverage retained, evidence retrieval integrity, and any cleanup candidate
count separated from actual deletion authority.

## External Dependencies

- `run-program-clean-delivery-cleanup-disposition`: consumed for cleanup
  authority and residue classification boundaries.
- `proposal-program-loop-breaker`: consumed for avoiding repeated lifecycle
  recovery churn when blocker evidence is unchanged.
- `closeout-worktree-autonomous-partition-evidence`: consumed for non-mutating
  partition evidence and cleanup-authority boundaries.

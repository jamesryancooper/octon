# Churn Receipt Fanout Compaction

## Target Surfaces

- `.octon/state/evidence/validation/**`
- Publication, compatibility, prompt-alignment, and validator receipts

## Producer Owner

Validators and publication receipt writers.

## Producer Entrypoint Inventory

Before implementation, enumerate each receipt writer in scope, the receipt
root it writes, the command or publication route that creates it, the retained
full-log location if any, the validator that consumes it, and the evidence
obligation it satisfies.

## Current Problem

The audit found roughly 41 extension prompt-alignment receipts, 4 publication
receipts, and 1 compatibility receipt. This is retained evidence, but repeated
timestamped equivalent receipts create file, review, and token overhead.

## Intended Efficiency Improvement

Use compact indexes, latest pointers, content-addressed full logs, and dedupe
for equivalent receipts while preserving full proof retrieval and digest
integrity.

## Receipt Equivalence Rule

Two receipts may be deduped or compacted as equivalent only when command or
publisher identity, semantic input digests, effective source digests,
validator or publisher version, environment-relevant options, result, output
digest, retained proof digest, and evidence obligation are all identical.
Timestamp equality is not required; timestamp difference alone is not enough
to force a new full receipt when all equivalence fields match.

## Guardrails

- Retained evidence is not generic cleanup.
- Compact summaries cannot replace required full proof.
- Publication receipt obligations remain intact.
- Missing retrieval or digest mismatch fails validation.
- Support, publication, closeout, and freshness claims must still resolve to retained full proof.
- Equivalent receipt compaction cannot collapse different failures, different validator versions, or different source digests.

## Validation Gates

- Receipt schema validation.
- Retrieval checks from compact index to full proof.
- Digest integrity checks.
- Negative controls for missing full logs and stale pointers.
- Negative controls for non-equivalent receipts that differ only in failure mode, validator version, source digest, or evidence obligation.

## Measurable Success Criteria

- Repeated equivalent validation creates bounded receipt changes.
- Full proof remains retrievable by digest/reference.
- Publication and validation gates still require retained evidence where mandated.

## Common Metrics

Implementation must report the applicable parent metrics: receipt fanout count,
dirty-worktree residue count, process runtime, token budget impact, validation
coverage retained, freshness/lock/receipt validation retained, and evidence
retrieval integrity.

## External Dependencies

- `run-program-clean-delivery-cleanup-disposition`: consumed for cleanup
  authority and residue classification boundaries. This child must not
  duplicate cleanup disposition or use receipt compaction as deletion
  authority.

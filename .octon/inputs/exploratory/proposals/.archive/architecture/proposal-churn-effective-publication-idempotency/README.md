# Churn Effective Publication Idempotency

## Target Surfaces

- `.octon/generated/effective/runtime/**`
- `.octon/generated/effective/capabilities/**`
- `.octon/generated/effective/extensions/**`
- `.octon/generated/effective/governance/**`
- `.octon/generated/effective/locality/**`
- Related locks and publication receipts

## Producer Owner

Effective route, pack route, capability routing, governance/locality, and
extension publication owners.

## Producer Entrypoint Inventory

Before implementation, enumerate every effective-output producer and validator
in scope, including runtime route bundle generation/publication, pack-route
generation, capability routing publication, extension state publication, and
any governance or locality effective publishers. The inventory must state which
paths each producer writes, which locks and receipts it owns, and which
runtime resolver or handle validator consumes the output.

## Current Problem

Runtime-facing effective outputs can be rewritten even when semantic inputs do
not change. Because these surfaces require locks and receipts, careless
compaction can weaken freshness or create false confidence.

## Intended Efficiency Improvement

Make publishers digest-aware and write only on semantic change, while retaining
locks, receipt linkage, traceability, allowed consumer class, and resolver
validation.

## Guardrails

- Runtime-facing generated/effective outputs remain non-authoritative.
- Raw path reads remain denied.
- Freshness, lock, receipt, and resolver negative controls remain required.
- No publication receipt is skipped when semantic publication changes.
- Support claims cannot cite generated/effective output without the required proof, receipt, and freshness linkage.
- Idempotency cannot reuse stale locks, stale receipts, or stale source digests.

## Validation Gates

- Generated/effective freshness validation.
- Runtime-effective handle validation.
- Raw generated/effective read denial tests.
- No-op publish diff checks.
- Support-claim and resolver negative controls for stale, missing, or digest-drifted generated/effective outputs.

## Measurable Success Criteria

- No-op effective publication creates zero tracked generated/effective diffs.
- Changed output count scales with changed semantic inputs.
- Freshness and lock failures still fail closed.
- Receipt linkage remains complete.

## Common Metrics

Implementation must report the applicable parent metrics: changed file count,
generated no-op rewrite rate, receipt fanout count, dirty-worktree residue
count, process runtime, token budget impact, validation coverage retained, and
freshness/lock/receipt validation retained.

## External Dependencies

No existing external packet owns this child. It consumes
`proposal-churn-common-generator-idempotency-metrics` through the parent
program sequence.

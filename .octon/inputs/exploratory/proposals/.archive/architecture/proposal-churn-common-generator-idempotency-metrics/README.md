# Churn Common Generator Idempotency Metrics

## Target Surfaces

- Shared generator and publisher helpers under `.octon/framework/assurance/runtime/_ops/scripts/`
- Shared tests under `.octon/framework/assurance/runtime/_ops/tests/`
- Any future churn metric contract under `.octon/framework/product/contracts/`

## Producer Owner

Shared assurance and publication tooling owners.

## Producer Entrypoint Inventory

Before implementation, enumerate every producer that will consume the common
contract and classify each as generated output, runtime-facing
generated/effective output, retained evidence, host projection, retained
control/continuity, or local scratch.

## Current Problem

Different producers can rewrite files for incidental reasons such as timestamp
changes, unstable ordering, copy churn, or unconditional writes. Without common
metrics, each child would prove efficiency differently.

## Intended Efficiency Improvement

Define stable write-if-changed behavior and shared churn metrics so no-op
producer runs can prove zero tracked diffs and measurable runtime/token impact.

## Guardrails

- Metrics cannot replace freshness, lock, receipt, resolver, validation, or closeout gates.
- Metrics cannot turn generated outputs into authority.
- Metrics must distinguish tracked generated churn, retained evidence growth, host projections, and ignored scratch.

## Validation Gates

- Proposal and architecture validators.
- Fixture tests for no-op write detection.
- Metric report validation with changed file count, no-op rewrite rate, receipt fanout, dirty residue, `.tmp` size, runtime, token impact, validation coverage retained, freshness coverage retained, and evidence retrieval integrity.

## Measurable Success Criteria

- Every core child can report the required metrics.
- No-op producer checks are standardized.
- Common metric output does not satisfy any authority or freshness gate.

## Common Metrics

This child defines the shared metric vocabulary consumed by all churn children:
changed file count, generated no-op rewrite rate, receipt fanout count,
dirty-worktree residue count, `.tmp` byte/file count, process runtime, token
budget impact, validation coverage retained, freshness/lock/receipt validation
retained, and evidence retrieval integrity.

## External Dependencies

None beyond the parent program sequence. Existing cleanup, hermeticity,
loop-breaker, and closeout-partition packets are consumed by the specific
children that need them.

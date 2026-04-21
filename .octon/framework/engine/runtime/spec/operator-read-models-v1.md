# Operator Read Models v1

This contract defines the generated operator-facing views that summarize
mission, run, grant, support, evidence, and closeout state without minting
authority.

## Current Live Read Models

The live repository already publishes these generated read-model families:

- mission summaries:
  `/.octon/generated/cognition/summaries/missions/**`
- operator digests:
  `/.octon/generated/cognition/summaries/operators/**`
- mission views:
  `/.octon/generated/cognition/projections/materialized/missions/**`

Additional run, grant, support, evidence, or closeout views may be added, but
they must follow this contract.

## Required Metadata

Every operator read model must retain:

- explicit generated-only classification
- `generated_at`
- source traceability such as `generated_from`, `source_refs`, or both
- freshness metadata when the underlying source is time-bounded
- canonical refs for any authority, support, disclosure, or evidence claims

Every rendered fact must trace either directly to a canonical authored/control/
evidence source or to another generated field that itself resolves to a
canonical source.

## Non-Authority Rules

- Operator read models may summarize status, support posture, closure state,
  and freshness.
- Operator read models may never be the sole input to runtime policy,
  authority routing, or claim validation.
- Generated summaries, mission views, and operator digests may mirror current
  state but must not outstate `support-targets.yml`, release-lineage, RunCard
  v2, or HarnessCard v2.
- If freshness or traceability cannot be established, the read model must be
  marked stale or withheld rather than silently published.

## Support And Closure Views

Any operator view that summarizes support or closure must cite the current live
sources:

- `/.octon/instance/governance/support-targets.yml`
- `/.octon/instance/governance/disclosure/release-lineage.yml`
- `/.octon/state/evidence/disclosure/runs/<run-id>/run-card.yml`
- `/.octon/state/evidence/disclosure/releases/<release-id>/harness-card.yml`

## Failure Rule

A generated view lacking canonical source refs, freshness metadata, or
non-authority labeling is incomplete and must not be treated as current
operator truth.

## Related Contracts

- `/.octon/framework/engine/runtime/spec/run-lifecycle-v1.md`
- `/.octon/framework/engine/runtime/spec/promotion-activation-v1.md`
- `/.octon/framework/constitution/contracts/disclosure/run-card-v2.schema.json`
- `/.octon/framework/constitution/contracts/disclosure/harness-card-v2.schema.json`

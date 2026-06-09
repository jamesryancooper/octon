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
- run health views:
  `/.octon/generated/cognition/projections/materialized/runs/<run-id>/health.yml`

Additional run, grant, support, evidence, or closeout views may be added, but
they must follow this contract.

## Required Metadata

Every operator read model must retain:

- explicit generated-only classification
- `generated_at`
- source traceability such as `generated_from`, `source_refs`, or both
- freshness metadata when the underlying source is time-bounded
- the canonical run-journal refs and latest event hash when the view summarizes
  run lifecycle or closeout state
- canonical refs for any authority, support, disclosure, or evidence claims

Every rendered fact must trace either directly to a canonical authored/control/
evidence source or to another generated field that itself resolves to a
canonical source.

## Lifecycle Refresh Rule

When an operator read model summarizes run lifecycle state, its source refs must
include the canonical journal refs and latest event hash used by a
journal-derived reconstruction report. A read model may also cite retained
evidence, RunCard, or disclosure refs for proof and operator context, but it
must not cite itself or another generated view as the lifecycle source.

If reconstruction reports drift, missing side artifacts, or journal/runtime
state mismatch, generated lifecycle summaries must be marked stale or withheld
until the control journal is repaired or an explicit recovery posture closes
the mismatch.

## Run Health Views

Run health views are generated-only per-run operator read models governed by
`/.octon/framework/engine/runtime/spec/run-health-read-model-v1.schema.json`.
They summarize lifecycle, support, authorization, evidence, rollback,
intervention, disclosure, and closure posture for one run without authorizing
continuation or widening support.

Run health statuses are:

- `healthy`
- `blocked`
- `stale`
- `unsupported`
- `revoked`
- `authority-ambiguity`
- `review-required`
- `evidence-incomplete`
- `rollback-required`
- `intervention-required`
- `disclosure-incomplete`
- `closure-ready`

Run health views must also expose proof-first authorization vocabulary in
`authorization.proof_state`:

- `proof-valid`
- `proof-missing`
- `proof-failed`
- `proof-stale`
- `proof-contradictory`
- `proof-scope-mismatch`
- `proof-unknown`

When the proof state crosses a human boundary, the view must report the typed
boundary in `authorization.human_boundary_state`:

- `none`
- `approval-required`
- `review-required`
- `exception-required`
- `revocation-active`
- `denied`
- `unknown`

Legacy or generic approval-required conditions must be represented as
`proof-missing` plus `approval-required`, not as a control-authorizing state.
Contradictory, stale, missing, failed, and scope-mismatched proof must remain
operator-visible and fail closed through the health status and diagnostics.

Every run health view must include canonical refs, source digests, freshness
metadata, explicit non-authority classification, forbidden consumer
classification, and diagnostics for uncertainty or input disagreement.

## Compact Manifest Preference

When a generator emits both broad read-model files and a compact manifest,
operator, validator, planner, closeout, and recovery consumers should read the
compact manifest first and follow its digest-bound refs only when deeper
inspection is needed.

The run-health compact manifest is
`/.octon/generated/cognition/projections/materialized/runs/run-health-compact-manifest.yml`.
It must retain:

- `schema_version: run-health-compact-manifest-v1`
- producer and validator refs
- allowed and forbidden consumer posture
- explicit generated-read-model non-authority classification
- source refs and SHA-256 source digests for the index and per-run health files
- status counts, failing-slice refs, and compact run-status entries
- retained generation receipt linkage
- fail-closed behavior for missing sources, digest mismatch, stale freshness,
  and authority-boundary violations

The compact manifest is a token-efficiency handle and diagnostic entry point.
It is not authority, runtime policy, support proof, retained run evidence, or
state reconstruction input.

## Non-Authority Rules

- Operator read models may summarize status, support posture, closure state,
  and freshness.
- Operator read models may never be the sole input to runtime policy,
  authority routing, or claim validation.
- Operator read models may never be consumed as authorization, policy,
  support-target, or state-reconstruction input.
- Operator read models may never satisfy retained evidence, support-proof,
  closeout, archive, release, or implementation evidence gates.
- journal and retained evidence roots remain the only valid sources for those
  paths.
- Generated summaries, mission views, and operator digests may mirror current
  state but must not outstate `support-targets.yml`, release-lineage, RunCard
  v2, or HarnessCard v2.
- If freshness or traceability cannot be established, the read model must be
  marked stale or withheld rather than silently published.

## Evidence Gate Boundary

Operator read models may cite RunCards, HarnessCards, publishable evidence
receipts, generated/effective handles, and retained evidence refs as source
traceability. The gate still resolves against the cited canonical authority,
control, retained evidence, disclosure, or publication receipt, not against the
generated read model itself.

Negative examples:

- A run health view under `/.octon/generated/**` is not an
  `evidence_classification_ref`, retained evidence receipt, or closeout proof.
- A generated/effective route bundle or generated report is not proof that a
  release claim is publishable unless the disclosure also cites the
  corresponding retained publication or publishable evidence receipt.
- A stale operator digest must not be used to prove support admission,
  implementation conformance, archive readiness, or release status.

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

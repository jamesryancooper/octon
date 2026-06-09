# Executable Implementation Prompt: Mechanism Detail Pages And Operator Map

proposal_path: `.octon/inputs/exploratory/proposals/architecture/mechanism-detail-pages-and-operator-map`
next_route: `run-packet-implementation`

## Implementation Scope

This is a selected-run implementation prompt for a formerly optional child. Implement because the operator intentionally selected detail pages and operator maps for the parent program run, after the required predecessor children are stable.

Live repo state at prompt generation:

- `.octon/framework/cognition/_meta/architecture/governed-cross-surface-mechanisms/` is expected to exist after foundation implementation.
- `.octon/generated/cognition/projections/materialized/` exists.

Promotion targets:

- `.octon/framework/cognition/_meta/architecture/governed-cross-surface-mechanisms/`
- `.octon/generated/cognition/projections/materialized/`

## Workstreams

1. Select a small set of highest-risk mechanisms for selected-run detail pages.
2. Add per-mechanism detail pages only when they add material clarity beyond the index entry template.
3. Define generated operator map source references, freshness metadata, and explicit non-authority notices.
4. Ensure operator read models are navigation only, visibility only, and non-authority.
5. Ensure generated maps are forbidden as runtime, policy, support, authority, or closure input.
6. Add or update validation for operator read-model traceability, freshness metadata, non-authority notice, and forbidden consumer classification.
7. Prove selected-run scope with child-owned receipts and keep generated maps barred from runtime, policy, support, closeout, cleanup, retained-evidence, or authority use.

## Authority Boundaries

- Do not implement this formerly optional work outside the accepted selected-run scope.
- Do not make generated operator maps runtime, policy, support, closeout, cleanup, retained-evidence, or authority inputs.
- Do not mutate runtime truth, state/control truth, retained evidence, generated-effective handles, or child packet receipts.
- Do not replace authored mechanism index docs with generated projections.

## Validation

Run these checks at minimum:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/mechanism-detail-pages-and-operator-map --skip-registry-check --skip-promotion-target-checks
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/mechanism-detail-pages-and-operator-map
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/mechanism-detail-pages-and-operator-map --require-implementation-authorization
bash .octon/framework/assurance/runtime/_ops/scripts/validate-operator-read-models.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-generated-non-authority.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/architecture/mechanism-detail-pages-and-operator-map
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/architecture/mechanism-detail-pages-and-operator-map
```

Run any generated projection publication or freshness validators required by the implementation.

## Evidence And Receipts

After selected implementation, produce:

- `support/implementation-conformance-review.md`
- `support/post-implementation-drift-churn-review.md`

The conformance receipt must prove selected-run scope, source traceability, freshness metadata, explicit non-authority notices, and forbidden consumer classification.

The drift/churn receipt must prove no generated map is consumed as runtime, policy, support, authority, or closure input, and that parent aggregate evidence did not satisfy this child-owned implementation or validation evidence.

## Rollback Posture

Rollback is manual: remove optional detail pages and generated operator maps if source traceability, freshness metadata, or non-authority classification is missing or stale.

## Terminal Criteria

Selected implementation is complete only when selected work is narrow, validation passes, and both required receipts pass. Refuse closeout/archive claims until `support/implementation-conformance-review.md` and `support/post-implementation-drift-churn-review.md` exist, pass their validators, and confirm generated maps remain visibility-only.

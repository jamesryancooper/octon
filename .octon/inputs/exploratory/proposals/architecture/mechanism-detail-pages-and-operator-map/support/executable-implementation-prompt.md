# Executable Implementation Prompt: Mechanism Detail Pages And Operator Map

proposal_path: `.octon/inputs/exploratory/proposals/architecture/mechanism-detail-pages-and-operator-map`
next_route: `run-packet-implementation` only if the optional child is intentionally selected

## Implementation Scope

This is an optional/deferred implementation prompt. Implement only if the operator intentionally selects optional detail pages and operator maps after the required program children are stable.

Live repo state at prompt generation:

- `.octon/framework/cognition/_meta/architecture/governed-cross-surface-mechanisms/` is expected to exist after foundation implementation.
- `.octon/generated/cognition/projections/materialized/` exists.

Promotion targets:

- `.octon/framework/cognition/_meta/architecture/governed-cross-surface-mechanisms/`
- `.octon/generated/cognition/projections/materialized/`

## Workstreams

1. Select a small set of highest-risk mechanisms for optional detail pages.
2. Add per-mechanism detail pages only when they add material clarity beyond the index entry template.
3. Define generated operator map source references, freshness metadata, and explicit non-authority notices.
4. Ensure operator read models are navigation only, visibility only, and non-authority.
5. Ensure generated maps are forbidden as runtime, policy, support, authority, or closure input.
6. Add or update validation for operator read-model traceability, freshness metadata, non-authority notice, and forbidden consumer classification.
7. Keep this optional child from blocking mandatory program closeout unless a later accepted parent mutation marks it required.

## Authority Boundaries

- Do not implement this optional work unless intentionally selected.
- Do not make generated operator maps runtime, policy, support, closeout, cleanup, retained-evidence, or authority inputs.
- Do not mutate runtime truth, state/control truth, retained evidence, generated-effective handles, or child packet receipts.
- Do not replace authored mechanism index docs with generated projections.

## Validation

Run these checks at minimum if optional implementation proceeds:

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

After optional implementation, produce:

- `support/implementation-conformance-review.md`
- `support/post-implementation-drift-churn-review.md`

The conformance receipt must prove optional selection, source traceability, freshness metadata, explicit non-authority notices, and forbidden consumer classification.

The drift/churn receipt must prove no generated map is consumed as runtime, policy, support, authority, or closure input, and that optional status did not become a mandatory closeout blocker.

## Rollback Posture

Rollback is manual: remove optional detail pages and generated operator maps if source traceability, freshness metadata, or non-authority classification is missing or stale.

## Terminal Criteria

Optional implementation is complete only when selected work is narrow, validation passes, and both required receipts pass. Refuse closeout/archive claims until `support/implementation-conformance-review.md` and `support/post-implementation-drift-churn-review.md` exist, pass their validators, and confirm optional generated maps remain visibility-only.

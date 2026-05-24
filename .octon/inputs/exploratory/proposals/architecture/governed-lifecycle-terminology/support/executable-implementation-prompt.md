# Executable Implementation Prompt

## Objective

Implement the accepted `governed-lifecycle-terminology` proposal packet. Retire
`Lifecycle Autopilot` where it names the current product capability and replace
it with governed lifecycle terminology while preserving the existing
runner/executor/phase-loop authority boundaries.

## Required Terminology

- Product capability: `Governed Lifecycle Orchestration`
- Runtime orchestration component: `Lifecycle Runner`
- Route execution component: `Lifecycle Executor Adapter`
- Contract primitive: `Lifecycle Phase-Loop Model`
- Behavioral/state-machine concept: `Governed Lifecycle Control Loop`

`Governed Lifecycle Control Loop` may appear only in explanatory prose. Do not
introduce it as a component name, schema name, route name, file name, lifecycle
id, or lifecycle contract primitive.

Define governed execution explicitly: self-operating execution is allowed only
through approved Lifecycle Runner and Lifecycle Executor Adapter mechanisms; it
must never become self-authorizing.

## Promotion Targets

The implementation may modify only these declared targets unless the packet is
revised and re-reviewed:

- `.octon/framework/product/features/catalog.yml`
- `.octon/framework/product/features/lifecycle-autopilot.md`
- `.octon/framework/product/features/governed-lifecycle-orchestration.md`
- `.octon/framework/product/roadmap/lifecycle-autopilot.md`
- `.octon/framework/product/roadmap/governed-lifecycle-orchestration.md`
- `.octon/framework/engine/runtime/spec/lifecycle-program-controller-invariants.md`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-product-feature-catalog.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-product-roadmap.sh`
- `.octon/framework/assurance/runtime/_ops/tests/test-validate-product-feature-catalog.sh`
- `.octon/framework/assurance/runtime/_ops/tests/test-validate-product-roadmap.sh`
- `.octon/framework/assurance/runtime/contracts/alignment-profiles.yml`
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/context/patterns/proposal-program.md`
- `.octon/generated/effective/extensions/published/octon-proposal-lifecycle/bundled-first-party/context/patterns/proposal-program.md`

## Workstreams

1. Rename the current product feature note from
   `.octon/framework/product/features/lifecycle-autopilot.md` to
   `.octon/framework/product/features/governed-lifecycle-orchestration.md`.
2. Rename the current roadmap note from
   `.octon/framework/product/roadmap/lifecycle-autopilot.md` to
   `.octon/framework/product/roadmap/governed-lifecycle-orchestration.md`.
3. Update `.octon/framework/product/features/catalog.yml` so the current
   product feature id and name use governed lifecycle terminology. Do not use
   bare `orchestration` as a shorthand for the product capability.
4. Update product feature and roadmap validators plus their tests so the
   renamed files and feature id are enforced.
5. Update `.octon/framework/assurance/runtime/contracts/alignment-profiles.yml`
   references to the renamed product and roadmap notes.
6. Update active runtime/spec/extension prose that describes the current
   product capability as `Lifecycle Autopilot`. Preserve archived, historical,
   compatibility, unrelated Kaizen/Autopilot, and retained evidence references.
7. Refresh generated effective extension projection only from the authored
   proposal lifecycle extension input if that source file changed.
8. Regenerate `.octon/generated/proposals/registry.yml` from proposal
   manifests as a derived publication output. It is not a promotion target and
   must not be treated as source authority.
9. Write `support/implementation-run.md`,
   `support/implementation-conformance-review.md`,
   `support/post-implementation-drift-churn-review.md`, and
   `support/validation.md`.

## Validation Commands

Run at minimum:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/governed-lifecycle-terminology --skip-registry-check
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/governed-lifecycle-terminology
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/governed-lifecycle-terminology --require-implementation-authorization
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/governed-lifecycle-terminology
bash .octon/framework/assurance/runtime/_ops/scripts/validate-product-feature-catalog.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-product-roadmap.sh
bash .octon/framework/assurance/runtime/_ops/tests/test-validate-product-feature-catalog.sh
bash .octon/framework/assurance/runtime/_ops/tests/test-validate-product-roadmap.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/architecture/governed-lifecycle-terminology
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/architecture/governed-lifecycle-terminology
```

Also run terminology sweeps:

```sh
rg -n "Lifecycle Autopilot|lifecycle-autopilot" .octon/framework/product .octon/framework/engine/runtime/spec .octon/inputs/additive/extensions/octon-proposal-lifecycle
rg -n "Governed Lifecycle Control Loop" .octon/framework .octon/inputs/additive/extensions/octon-proposal-lifecycle
```

Retained matches must be explained as legacy, historical, compatibility, or
prose-only behavior references.

## Evidence And Receipts

Implementation must write:

- `support/implementation-run.md`
- `support/implementation-conformance-review.md`
- `support/post-implementation-drift-churn-review.md`
- `support/validation.md`

The conformance receipt must record `verdict: pass` and
`unresolved_items_count: 0`. The drift/churn receipt must record
`verdict: pass` and `unresolved_items_count: 0`.

## Rollback

Rollback by reverting the durable terminology implementation commit. Restore
the prior product feature file, roadmap file, product catalog id/name, validator
expectations, tests, and generated projections together. Do not partially
restore the old terminology.

## Closeout Refusal Criteria

Refuse closeout and archive if either
`support/implementation-conformance-review.md` or
`support/post-implementation-drift-churn-review.md` is missing, failing,
unresolved, or blocked; if product validators fail; if the review gate is stale;
if generated projections are treated as source authority; or if the
implementation exceeds declared promotion targets without packet revision and
fresh review.

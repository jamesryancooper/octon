# Implementation Plan

## Workstream 1: Workflow Contract

Add `.octon/framework/orchestration/runtime/workflows/meta/verify-governed-mechanism-integration/`
with a workflow contract and stages that:

1. bind `proposal_path`, `mechanism_id`, and `mechanism_profile_ref`;
2. validate the mechanism integration profile;
3. collect implementation conformance, drift/churn, generated publication, and
   current-state architecture review refs;
4. run deterministic profile and receipt validators;
5. write `support/governed-mechanism-integration-evaluation.yml`;
6. retain run evidence under
   `.octon/state/evidence/runs/workflows/<run-id>/governed-mechanism-integration/<mechanism-id>/`.

Register the workflow in workflow registry and manifest surfaces. Keep side
effects limited to proposal-local support writes, retained workflow evidence,
and deterministic validation output.

## Workstream 2: Profile And Receipt Schemas

Add:

- `.octon/framework/product/contracts/governed-mechanism-integration-profile-v1.schema.json`
- `.octon/framework/product/contracts/governed-mechanism-integration-receipt-v1.schema.json`

The profile schema must require all declared surface classes or an explicit
`not_applicable` rationale. The receipt schema must require verdict,
unresolved-item count, blockers, profile ref, architecture review ref,
conformance ref, drift ref, publication refs, validator refs, evidence refs,
authority boundary verdict, surface coverage, non-authority classification,
mode-specific coverage, and implemented packet digest binding.

Schema fixtures should cover passing profiles, omitted required classes,
missing rationales, stale digest binding, denied non-authority classification,
and missing validator refs.

## Workstream 3: Validators And Tests

Add:

- `validate-governed-mechanism-integration-profile.sh`
- `validate-governed-mechanism-integration-receipt.sh`
- `test-validate-governed-mechanism-integration.sh`

Extend existing validators where needed:

- `validate-governed-cross-surface-mechanisms.sh` to recognize durable profile
  guidance and required mechanism integration verification coverage.
- `validate-product-feature-catalog.sh` to keep the feature catalog
  navigation-only while requiring any new feature note to classify authority
  refs correctly.
- `validate-proposal-implementation-conformance.sh` to treat a required
  mechanism integration receipt as a predecessor for implemented closeout when
  a proposal declares mechanism impact.
- `validate-proposal-post-implementation-drift.sh` to reject stale aliases,
  stale proposal backrefs, stale digests, placeholder-marker receipts, and
  omitted validators for governed mechanism proposals.
- `validate-proposal-lifecycle-terminal-freshness.sh` to require scoped
  post-landing freshness proof for merged or cleaned terminal outcomes.

## Workstream 4: Proposal Lifecycle Hooks

Update the proposal lifecycle extension so proposal review requires a proposed
mechanism integration profile when the packet declares a new or materially
changed governed mechanism.

Update implementation, verification, closeout, and archive prompt routes so
they refuse implemented closeout or archive readiness until
`support/governed-mechanism-integration-evaluation.yml` validates and passes
for mechanism proposals.

The hook must be conditional: packets without governed mechanism impact should
record `not_applicable` rather than running the full gate.

## Workstream 5: Generated Publication And Terminal Freshness

Require the workflow to cite publication receipts from canonical scripts such
as:

- `.octon/framework/capabilities/_ops/scripts/publish-capability-routing.sh`
- `.octon/framework/capabilities/_ops/scripts/publish-host-projections.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/generate-proposal-registry.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/publish-runtime-route-bundle.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/publish-pack-routes.sh`

After merge or terminal cleaned outcome, require scoped terminal freshness proof
on main for generated projections, proposal registry, child spines, and
mechanism docs touched by the mechanism proposal.

## Workstream 6: Documentation And Navigation

Update governed mechanism index guidance to describe integration profiles,
verification receipts, evidence roots, and authority boundaries.

Add a product feature note and catalog entry for governed mechanism integration
verification. The feature catalog must remain navigation-only and point to
durable workflow, schema, validator, evidence, generated, and documentation
surfaces without becoming authority.

## Workstream 7: Rollback And Closeout

Rollback removes the workflow, schemas, validators, tests, lifecycle hook
updates, product feature entry, and mechanism-index guidance as one atomic
change. Retain emitted workflow or validation evidence under state/evidence.

Closeout may claim implemented or archive-ready only when implementation
conformance, drift/churn, governed mechanism integration receipt validation,
publication freshness, terminal freshness, and proposal validators pass.

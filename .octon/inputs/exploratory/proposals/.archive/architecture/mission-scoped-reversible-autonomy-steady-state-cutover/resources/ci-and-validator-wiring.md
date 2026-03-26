# CI And Validator Wiring

## Goal

Make MSRAOM completeness enforceable and regression-resistant.

## Required Validators

The steady-state cutover requires these validators to exist and be blocking:

1. `validate-architecture-conformance.sh`
2. `alignment-check.sh --profile harness,mission-autonomy`
3. `validate-runtime-effective-state.sh`
4. `validate-mission-runtime-contracts.sh`
5. `validate-mission-source-of-truth.sh`
6. `test-mission-autonomy-scenarios.sh`
7. `validate-generated-mission-views.sh`
8. `validate-control-evidence-coverage.sh`

## Required Workflow Shape

Preferred path: extend `.github/workflows/architecture-conformance.yml`.

Minimum jobs:
- `architecture`
- `mission-runtime-contracts`
- `runtime-effective-state`
- `mission-autonomy-scenarios`
- `mission-generated-views-and-evidence`

If runtime duration requires a split, create
`.github/workflows/mission-autonomy-conformance.yml` and make it required in
branch protection.

## Required Fail Conditions

CI must fail on any of these:
- release/version parity mismatch
- missing control file in an active mission
- missing generated route for an active mission
- null route ref in mode state
- stale route for material work
- empty intent register for material autonomy
- missing action-slice reference for material autonomy
- generic route recovery fallback for material autonomy
- unnormalized breaker vocabulary
- missing mission summaries
- missing operator digests for routed recipients
- missing mission-view
- missing control receipts for required mutation classes
- scenario suite mismatch
- doc/runtime or manifest/runtime root mismatch

## Required Fixture Set

Add or update committed fixtures so CI proves:
- routine housekeeping
- campaign/refactor
- dependency/security patching
- release-sensitive behavior
- infra drift
- migration/backfill
- external sync
- observe-only monitoring
- incident containment
- destructive work
- absent human
- late feedback
- conflicting human input
- reversible / compensable / irreversible routing

## Required Branch Protection

The branch-protection rule for `main` must require the MSRAOM conformance
checks. A validator named in the contract registry but not actually enforced in
branch protection is not enough.

## Final Rule

MSRAOM is not “done” if its completeness can regress without CI going red.

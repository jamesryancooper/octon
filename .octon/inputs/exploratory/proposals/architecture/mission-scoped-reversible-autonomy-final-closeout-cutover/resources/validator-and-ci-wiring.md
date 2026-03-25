# Validator And CI Wiring

## Final CI shape

The architecture-conformance workflow must block on all MSRAOM invariants.

## Required blocking jobs

### Architecture and version
- `architecture`
- `mission-runtime-contracts`

### Lifecycle and routing
- `mission-lifecycle-cutover`
- `runtime-effective-state`
- `mission-route-normalization`

### Scenario conformance
- `mission-autonomy-scenarios`

### Generated outputs and evidence
- `mission-generated-views-and-evidence`

## Required scripts

- `validate-version-parity.sh`
- `validate-architecture-conformance.sh`
- `alignment-check.sh`
- `validate-mission-lifecycle-cutover.sh`
- `validate-mission-runtime-contracts.sh`
- `validate-mission-source-of-truth.sh`
- `validate-mission-intent-invariants.sh`
- `validate-route-normalization.sh`
- `validate-runtime-effective-state.sh`
- `validate-mission-generated-summaries.sh`
- `validate-mission-view-generation.sh`
- `validate-mission-control-evidence.sh`
- `test-mission-autonomy-scenarios.sh`
- `test-mission-lifecycle-activation.sh`
- `test-autonomy-burn-reducer.sh`

## Why this matters

The final audit no longer identified a missing conceptual architecture.
It identified proof gaps.
So the closeout must be CI-enforced, not merely documented.

## Merge rule

Any PR touching MSRAOM-governed surfaces must pass the full closeout suite.
No allowlist may skip the lifecycle, route, scenario, evidence, or generated-view jobs.

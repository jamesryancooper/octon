# Validator and Fixture Inventory

## Existing validator families to reuse or extend

- `validate-architecture-conformance.sh`
- `validate-architecture-contract-registry.sh`
- `validate-runtime-effective-state.sh`
- `validate-route-normalization.sh`
- `validate-evidence-completeness.sh`
- `validate-generated-non-authority.sh`
- `validate-input-non-authority.sh`
- `validate-material-side-effect-inventory.sh`
- `validate-authorization-boundary-coverage.sh`
- `validate-authorized-effect-token-enforcement.sh`
- `validate-cross-artifact-capability-pack-consistency.sh`
- `validate-cross-artifact-route-consistency.sh`
- `validate-cross-artifact-support-tuple-consistency.sh`

## New validators proposed

- `generate-support-envelope-reconciliation.sh`
- `validate-support-envelope-reconciliation.sh`
- `generate-run-health-read-model.sh`
- `validate-run-health-read-model.sh`

## Existing tests to reuse or extend

- `test-authorization-boundary-coverage.sh`
- `test-authorization-boundary-negative-controls.sh`
- `test-authorized-effect-token-consumption.sh`
- `test-authorized-effect-token-negative-bypass.sh`
- `test-material-side-effect-coverage-fixtures.sh`
- `test-material-side-effect-token-bypass-denials.sh`
- `test-pack-route-widening-denial.sh`
- `test-support-pack-no-widening.sh`
- `test-support-tuple-proof-sufficiency.sh`
- `test-validate-run-lifecycle-transition-coverage.sh`

## New fixture families proposed

```text
.octon/framework/assurance/runtime/_ops/fixtures/support-envelope-reconciliation/
.octon/framework/assurance/runtime/_ops/fixtures/run-health-read-model/
.octon/framework/assurance/runtime/_ops/fixtures/authorized-effect-token-enforcement/
```

## Fixture quality rule

Every negative fixture must name the exact expected denial reason. A test that
merely fails is not enough; it must fail because the intended gate caught the
intended violation.

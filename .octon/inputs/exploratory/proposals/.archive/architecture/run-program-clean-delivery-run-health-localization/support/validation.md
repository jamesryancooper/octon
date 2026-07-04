# Validation

validated_at: 2026-07-03T20:06:30Z
verdict: pass

## Commands Run

- `bash .octon/framework/assurance/runtime/_ops/tests/test-run-health-read-model.sh`: pass, `passed=17 failed=0`.
- `bash .octon/framework/assurance/runtime/_ops/tests/test-run-program-clean-delivery-validator.sh`: pass, `pass=34 fail=0`.
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-run-health-read-model.sh`: pass, `errors=0`.
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-evidence-disclosure-tiers.sh`: pass, `errors=0 warnings=0`.
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-run-program-clean-delivery.sh`: pass, `errors=0`.
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-run-health-localization --skip-registry-check`: pass, `errors=0 warnings=1`.
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-run-health-localization`: pass, `errors=0 warnings=0`.
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-run-health-localization`: pass, `errors=0 warnings=0`.
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-run-health-localization --require-implementation-authorization`: pass.
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-receipts.sh --receipt .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-run-health-localization/support/pre-integration-architecture-review.yml --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-run-health-localization --mode pre-integration-architecture-review --require-pass`: pass, `errors=0`.
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-run-health-localization`: pass, `errors=0 warnings=0`.
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-run-health-localization`: pass, `errors=0 warnings=0`.

## Generated Run-Health Status Proof

- command: `git status --porcelain -- .octon/generated/cognition/projections/materialized/runs`
- before_line_count: 1010
- before_sha256: `sha256:c8b9902fb6b22981c1ed6b0b69335af9b520b63be6937d669aace3ef09a436b3`
- after_line_count: 1010
- after_sha256: `sha256:c8b9902fb6b22981c1ed6b0b69335af9b520b63be6937d669aace3ef09a436b3`
- byte_for_byte_equal: yes

## Negative Controls

- Missing explicit publish owner fails closed.
- Mutated explicit publish digest fails closed.
- Non-authority mutation of generated run-health output fails closed.
- Source digest mutation fails closed.
- Invalid generated run-health published path fails closed.
- Compact manifest digest and source digest mutations fail closed.
- Unpromoted generated run-health projection claim in clean-delivery receipt fails closed.

## Validator Gap

`bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-run-health-localization` fails because `.octon/generated/proposals/registry.yml` is stale relative to proposal manifests. This route did not refresh that registry because the executable prompt excludes generated proposal registries from the accepted promotion targets.

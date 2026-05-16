# Effect Token Enforcement Coverage Validation

verdict: blocked
validated_at: 2026-05-16T08:17:24Z
run_id: lifecycle-proposal-program-1778904192406-8da93d7a-effect-token-enforcement-coverage
proposal_path: .octon/inputs/exploratory/proposals/architecture/effect-token-enforcement-coverage

## Profile Selection Receipt

release_state: pre-1.0
change_profile: atomic
transitional_exception_note: not authorized

## Command Results

- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/effect-token-enforcement-coverage` - pass, errors=0 warnings=0.
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/effect-token-enforcement-coverage --require-implementation-authorization` - pass, errors=0 warnings=0.
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/effect-token-enforcement-coverage` - pass for the target packet with one artifact-catalog warning; the broader registry projection check also completed with errors=0 warnings=1.
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/effect-token-enforcement-coverage` - pass, errors=0.
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-material-side-effect-inventory.sh` - pass, errors=0.
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-authorization-boundary-coverage.sh` - pass, errors=0.
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-authorized-effect-token-enforcement.sh` - pass, errors=0.
- `bash .octon/framework/assurance/runtime/_ops/tests/test-material-side-effect-token-bypass-denials.sh` - pass, 3 passed and 0 failed.
- `bash .octon/framework/assurance/runtime/_ops/tests/test-authorized-effect-token-negative-bypass.sh` - pass.
- `bash .octon/framework/assurance/runtime/_ops/tests/test-authorized-effect-token-consumption.sh` - pass.
- `bash .octon/framework/assurance/runtime/_ops/tests/test-material-side-effect-coverage-fixtures.sh` - pass.
- `cargo test --manifest-path .octon/framework/engine/runtime/crates/Cargo.toml -p octon_authorized_effects` - pass.
- `cargo test --manifest-path .octon/framework/engine/runtime/crates/Cargo.toml -p octon_authority_engine --lib` - pass, 70 tests passed.
- `cargo test --manifest-path .octon/framework/engine/runtime/crates/Cargo.toml -p octon_kernel --bin octon` - pass, 200 tests passed.
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-support-envelope-reconciliation.sh` - fail, errors=1; the generated support-envelope reconciliation is stale.
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-run-health-read-model.sh` - fail, errors=195; generated run-health read models have digest drift for support reconciliation, runtime route bundle, and pack routes.
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-conformance.sh` - fail, errors=2; support-envelope reconciliation and run-health read-model validation failed.
- `bash .octon/framework/assurance/runtime/_ops/scripts/cleanup-local-run-artifacts.sh --summary-only` - pass, dry-run only, cleanup_candidates=1081, protected_referenced=48, manual_review=186.
- `rg -n "effect-token-enforcement-coverage|\\.octon/inputs/exploratory/proposals/architecture/effect-token-enforcement-coverage" .octon/framework/engine/runtime/spec .octon/framework/engine/runtime/crates .octon/framework/assurance/runtime/_ops/scripts .octon/framework/assurance/runtime/_ops/tests` - no matches, exit code 1.

## Boundary Finding

Focused effect-token enforcement evidence passes in the approved target
families. The remaining blockers are generated/support projection freshness
issues outside this packet's declared promotion targets:

- `.octon/generated/**` support-envelope reconciliation freshness;
- `.octon/generated/cognition/projections/materialized/runs/**` health read
  model digests for support reconciliation, runtime route bundle, and pack
  routes.

This route did not repair those generated surfaces because the packet excludes
generated/effective publication and generated read-model refresh from durable
promotion scope.

## Closeout Finding

The route remains blocked for promotion readiness. `proposal.yml#status` must
remain `accepted` until an authorized generated/projection freshness route
repairs the blocker and the post-implementation gates pass.

# Effect Token Enforcement Coverage Validation Evidence

verdict: blocked
validated_at: 2026-05-16T08:01:37Z
run_id: lifecycle-proposal-program-1778904192406-8da93d7a-effect-token-enforcement-coverage
proposal_path: .octon/inputs/exploratory/proposals/architecture/effect-token-enforcement-coverage

## Profile Selection Receipt

- release_state: pre-1.0
- change_profile: atomic
- transitional_exception_note: not authorized

## Current Command Results

- `validate-proposal-standard.sh --package .../effect-token-enforcement-coverage` - pass, errors=0 warnings=1. The warning is the existing artifact-catalog coverage warning for visible implementation-route support files.
- `validate-architecture-proposal.sh --package .../effect-token-enforcement-coverage` - pass, errors=0 warnings=0.
- `validate-proposal-implementation-readiness.sh --package .../effect-token-enforcement-coverage` - pass, errors=0 warnings=0.
- `validate-proposal-review-gate.sh --package .../effect-token-enforcement-coverage --require-implementation-authorization` - pass, errors=0 warnings=0.
- `validate-material-side-effect-inventory.sh` - pass, errors=0.
- `validate-authorization-boundary-coverage.sh` - pass, errors=0.
- `validate-authorized-effect-token-enforcement.sh` - pass, errors=0.
- `test-material-side-effect-token-bypass-denials.sh` - pass, 3 passed and 0 failed.
- `test-authorized-effect-token-negative-bypass.sh` - pass.
- `test-authorized-effect-token-consumption.sh` - pass.
- `test-material-side-effect-coverage-fixtures.sh` - pass.
- `cargo test --manifest-path .octon/framework/engine/runtime/crates/Cargo.toml -p octon_authorized_effects` - pass, 0 tests.
- `cargo test --manifest-path .octon/framework/engine/runtime/crates/Cargo.toml -p octon_authority_engine --lib` - pass, 70 passed and 0 failed.
- `cargo test --manifest-path .octon/framework/engine/runtime/crates/Cargo.toml -p octon_kernel --bin octon` - pass, 200 passed and 0 failed.
- `validate-support-envelope-reconciliation.sh` - fail, errors=1, because the published generated support-envelope reconciliation is stale.
- `validate-run-health-read-model.sh` - fail, errors=195, because generated run-health read models carry support reconciliation, runtime route bundle, and pack-route digest drift.
- `validate-architecture-conformance.sh` - fail, errors=2, because it composes the failing support-envelope reconciliation and run-health read-model gates.
- `cleanup-local-run-artifacts.sh --summary-only` - pass as dry-run: cleanup_candidates=1002, protected_referenced=50, manual_review=183.
- Exact `rg` scan for proposal id and proposal path under declared durable target families - no matches.

## Blocked Gate

Focused effect-token implementation evidence is current and passing. Promotion
readiness remains blocked by generated projection freshness failures outside
this packet's declared promotion targets. This route did not repair
`.octon/generated/**`, mutate `.octon/state/control/**`, change support-target
authority, or promote `proposal.yml#status`.

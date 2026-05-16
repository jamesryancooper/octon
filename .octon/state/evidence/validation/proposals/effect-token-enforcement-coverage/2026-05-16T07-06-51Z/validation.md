# Effect Token Enforcement Coverage Validation

run_id: lifecycle-proposal-program-1778904192406-8da93d7a-effect-token-enforcement-coverage
validated_at: 2026-05-16T07:15:58Z
verdict: blocked

## Profile Selection Receipt

release_state: pre-1.0
change_profile: atomic
transitional_exception_note: not authorized

## Worktree Baseline

The run started from an already dirty worktree with sibling lifecycle outputs,
generated/effective projection diffs, state/control and evidence artifacts,
packet-local receipt edits, and one approved target-family test edit already
present at `.octon/framework/assurance/runtime/_ops/tests/test-material-side-effect-token-bypass-denials.sh`.
Those existing changes were preserved. No new durable edit was made under the
approved promotion target families during this run.

## Command Results

- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/effect-token-enforcement-coverage` - exit 0; `errors=0 warnings=1`.
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/effect-token-enforcement-coverage` - exit 0; `errors=0`.
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/effect-token-enforcement-coverage` - exit 0; `errors=0 warnings=0`.
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/effect-token-enforcement-coverage --require-implementation-authorization` - exit 0; review accepted, no open blockers, implementation authorized.
- `(cd .octon/inputs/exploratory/proposals/architecture/effect-token-enforcement-coverage && shasum -a 256 -c SHA256SUMS.txt)` - exit 0 before receipt refresh.
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-material-side-effect-inventory.sh` - exit 0; `errors=0`.
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-authorization-boundary-coverage.sh` - exit 0; `errors=0`.
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-authorized-effect-token-enforcement.sh` - exit 0; `errors=0`.
- `bash .octon/framework/assurance/runtime/_ops/tests/test-material-side-effect-token-bypass-denials.sh` - exit 0; 3 passed, 0 failed.
- `bash .octon/framework/assurance/runtime/_ops/tests/test-authorized-effect-token-negative-bypass.sh` - exit 0; required negative effect-token rejection cases passed.
- `bash .octon/framework/assurance/runtime/_ops/tests/test-authorized-effect-token-consumption.sh` - exit 0; issued-token consumption receipt test passed.
- `bash .octon/framework/assurance/runtime/_ops/tests/test-material-side-effect-coverage-fixtures.sh` - exit 0; bypass fixture, publication wrapper delegation, forged runtime env denial, design-package execution artifact, and workflow execution artifact checks passed.
- `cargo test --manifest-path .octon/framework/engine/runtime/crates/Cargo.toml -p octon_authorized_effects` - exit 0; crate test harness and doctests passed.
- `cargo test --manifest-path .octon/framework/engine/runtime/crates/Cargo.toml -p octon_authority_engine --lib` - exit 0; 70 passed, 0 failed.
- `cargo test --manifest-path .octon/framework/engine/runtime/crates/Cargo.toml -p octon_kernel --bin octon` - exit 0; 200 passed, 0 failed.
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-support-envelope-reconciliation.sh` - exit 1; `errors=1`, published support-envelope reconciliation is stale.
- `set -o pipefail; bash .octon/framework/assurance/runtime/_ops/scripts/validate-run-health-read-model.sh 2>&1 | tail -40` - exit 1; full validator reports `errors=195` from generated run-health digest drift for support reconciliation, runtime route bundle, and pack routes.
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-conformance.sh` - exit 1; `errors=2`, because support-envelope reconciliation and run-health read-model validation failed.

## Generated Publication Wrapper Evidence

`test-material-side-effect-coverage-fixtures.sh` exercised runtime publication
wrappers and retained new run evidence under:

- `.octon/state/evidence/runs/publish-1778915319346-90337/`
- `.octon/state/evidence/runs/publish-1778915325231-92050/`
- `.octon/state/evidence/runs/publish-1778915331805-94091/`

The wrapper also left generated/effective and state/control diffs outside this
packet's approved durable promotion targets. They are not claimed as durable
implementation output for this route.

## Backreference Check

Exact searches for `effect-token-enforcement-coverage` and the proposal path
under the declared durable target roots returned no active proposal-path
dependencies.

## Blocker

`BLOCKER-EFFECT-TOKEN-001`: Promotion readiness remains blocked by stale
support-envelope reconciliation and generated run-health read-model digest
drift outside the packet's promotion targets. Correcting those projections
requires a separate authorized publication or projection-refresh route.


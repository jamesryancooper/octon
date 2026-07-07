# Validation

validation_id: proposal-program-ownership-baseline-and-leases-validation-20260707T133500Z
validated_at: 2026-07-07T13:35:00Z
verdict: pass
errors: 0
warnings: 2

## Commands

- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-ownership-baseline-and-leases --require-implementation-authorization`
  - result: pass
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-ownership-baseline-and-leases --skip-registry-check`
  - result: pass
  - notes: one artifact-catalog coverage warning for the generated executable prompt; the catalog was left unchanged to preserve the accepted review digest boundary.
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-ownership-baseline-and-leases`
  - result: pass
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-ownership-baseline-and-leases`
  - result: pass
- `cargo test --manifest-path .octon/framework/engine/runtime/crates/Cargo.toml -p octon_kernel program_worktree_baseline_blocks_fresh_dirty_unleased_git_run`
  - result: pass
- `cargo test --manifest-path .octon/framework/engine/runtime/crates/Cargo.toml -p octon_kernel program_worktree_baseline_records_run_owned_leased_and_foreign_paths`
  - result: pass
- `cargo test --manifest-path .octon/framework/engine/runtime/crates/Cargo.toml -p octon_kernel route_write_lease`
  - result: pass
- `bash .octon/framework/assurance/runtime/_ops/tests/test-classify-proposal-worktree-hygiene.sh`
  - result: pass
  - notes: 48 passing classifier fixture cases, 0 failures.
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-child-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-execution-resilience-and-supersession`
  - result: pass
  - notes: one warning for the archived loop-breaker packet lacking registry evidence index refs.
- `bash .octon/framework/assurance/runtime/_ops/tests/test-validate-lifecycle-contracts.sh`
  - result: pass
  - notes: 207 passing contract/schema cases, 0 failures.
- `bash .octon/framework/assurance/runtime/_ops/tests/test-validate-proposal-program-delivery.sh`
  - result: pass
  - notes: 58 passing delivery validator cases, 0 failures.

## Diagnostic Commands

- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-readiness-projection.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-execution-resilience-and-supersession`
  - result: expected-blocked
  - notes: reports parent status does not support readiness projection while the parent program remains `status: in-review`; child checks for this ownership packet pass.

## Coverage

- Dirty-start baseline without a lease blocks before route dispatch.
- Explicit dirty-start lease records owned, leased, and foreign path buckets.
- Parent route write leases exclude child-owned packet surfaces.
- Child route write leases bind child target/write scopes and exclude parent
  and sibling surfaces.
- Unsafe lease paths fail closed.
- Classifier fixtures cover owned, in-scope, archived-child, current-run,
  retained-evidence, generated, protected, foreign, manual, and unbound path
  classifications.
- Parent summaries and generated outputs remain non-authoritative.

## Exclusions

- No new durable code patch.
- No generated output hand edit.
- No archive, cleanup, branch cleanup, parent closeout, or child closeout for
  another packet.

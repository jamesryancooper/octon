# Validation Log

## Passing

- `cargo test -p octon_authority_engine`
- `cargo test -p octon_kernel pipeline:: -- --nocapture`
- `cargo run ... octon workflow list`
- `bash .octon/framework/assurance/runtime/_ops/scripts/generate-proposal-registry.sh --write`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-support-target-live-claims.sh`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-phase4-proof-lab-enforcement.sh`
- `bash .octon/framework/assurance/governance/_ops/scripts/assert-unified-execution-closure.sh`

## Retained validator logs

- `support-target-live-claims.log`
- `phase4-proof-lab.log`
- `final-closeout.log`

## Live-path runtime evidence

- `uec-validate-proposal-20260331-b` emitted canonical run roots and a
  canonical RunCard under `state/evidence/disclosure/runs/**`.
- The run failed proposal validation, so it proves runtime/disclosure emission
  but not successful routine execution.
- `uec-validate-proposal-20260331-success-3` emitted a successful canonical run
  with all seven proof-plane refs populated.
- `uec-audit-architecture-20260331-2` emitted a second successful canonical run
  with full proof-plane disclosure under the same bounded support envelope.

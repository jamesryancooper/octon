# Runtime Enforcement Hardening Plan

## Objective

Make the execution authorization boundary impossible to bypass for material side effects.

## Required runtime invariants

1. Every material side-effect path appears in `material-side-effect-inventory.yml`.
2. Every inventory path appears in `authorization-boundary-coverage.yml`.
3. Every coverage entry names:
   - entrypoint
   - side-effect class
   - request builder
   - `authorize_execution` reference
   - grant artifact
   - receipt artifact
   - denial reason code
   - negative controls
   - tests
4. Runtime grant emission requires a fresh runtime-effective route bundle.
5. Runtime request builders must bind run contract, support tuple, pack routes, rollback plan, risk/materiality,
   execution role, executor profile, and evidence roots.

## Negative controls

Add tests proving denial/stage/escalation for:

- generated/cognition as authority
- generated/proposals as lifecycle authority
- raw input direct runtime dependency
- host UI/comment/check as authority
- stale generated/effective route bundle
- missing publication receipt
- missing run contract
- stage-only support tuple claimed as live
- unadmitted pack requested
- selected but unpublished extension requested
- quarantined extension requested
- missing rollback plan for rollback-required profile
- unsupported network/model egress

## Implementation locations

- `framework/engine/runtime/crates/authority_engine/src/implementation/execution.rs`
- `framework/engine/runtime/crates/core/src/config.rs`
- `framework/engine/runtime/crates/runtime_resolver/src/lib.rs`
- `framework/engine/runtime/spec/authorization-boundary-coverage.yml`
- `framework/assurance/runtime/_ops/tests/test-authorization-boundary-negative-controls.sh`

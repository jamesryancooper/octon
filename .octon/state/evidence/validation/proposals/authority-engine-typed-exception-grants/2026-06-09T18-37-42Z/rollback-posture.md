# Rollback Posture

verdict: pass
recorded_at: 2026-06-09T18:37:42Z
proposal_id: authority-engine-typed-exception-grants

## Rollback Scope

Rollback is file-level revert of this route's durable edits:

- `.octon/framework/constitution/contracts/authority/approval-request-v1.schema.json`
- `.octon/framework/constitution/contracts/authority/approval-grant-v1.schema.json`
- `.octon/framework/constitution/contracts/authority/grant-bundle-v2.schema.json`
- `.octon/framework/engine/runtime/crates/authority_engine/src/implementation.rs`
- `.octon/framework/engine/runtime/crates/authority_engine/src/implementation/api.rs`
- `.octon/framework/engine/runtime/crates/authority_engine/src/implementation/authority.rs`
- `.octon/framework/engine/runtime/crates/authority_engine/src/implementation/execution.rs`
- `.octon/framework/engine/runtime/crates/authority_engine/src/implementation/effects.rs`
- `.octon/framework/engine/runtime/crates/authority_engine/src/implementation/tests.rs`
- `.octon/framework/assurance/runtime/_ops/tests/test-authority-engine-typed-exception-grants.sh`
- this packet's implementation support receipts;
- retained evidence under this timestamped validation root.

## Out Of Scope For Rollback

Pre-existing delegated-governance inventory/shared-contract work in the dirty worktree is outside this child route's rollback scope.

## Recovery Posture

If reverted, authority-engine behavior returns to the prior generic approval-grant consumption model. No generated projection or state/control grant instance was edited by this route.

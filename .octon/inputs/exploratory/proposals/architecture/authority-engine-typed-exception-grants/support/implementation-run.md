# Implementation Run Receipt

verdict: pass
run_id: lifecycle-proposal-program-1781029326147-1a061c9f-authority-engine-typed-exception-grants
implemented_at: 2026-06-09T18:37:42Z
promotion_evidence_count: 10
proposal_id: authority-engine-typed-exception-grants
route_id: run-packet-implementation
proposal_status_after_route: accepted

## Profile Selection Receipt

- release_state: pre-1.0
- change_profile: atomic
- rationale: The packet requests one clean-break migration of authority-engine grant consumption to exact typed exception boundaries.
- transitional exception: none

## Implementation Summary

Implemented typed exception grant enforcement in the authority engine:

- approval requests and grants now carry typed boundary and provenance fields;
- active approval grants require exact typed boundaries before route allow;
- active grant consumption is recorded as delegated execution with authority provenance;
- generated-output and read-model authority sources deny the route;
- importance-only approval rationale stages the route;
- effect-token approval verification rejects missing boundary, delegated-consumption mode, or provenance;
- authority grant bundles retain consumption provenance.

## Durable Files Changed By This Route

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

## Evidence Root

`.octon/state/evidence/validation/proposals/authority-engine-typed-exception-grants/2026-06-09T18-37-42Z/`

## Validators And Checks

- `validate-proposal-standard.sh`: pass before implementation, `errors=0 warnings=0`
- `validate-architecture-proposal.sh`: pass
- `validate-proposal-review-gate.sh --require-implementation-authorization`: pass
- `validate-proposal-implementation-readiness.sh`: pass
- `jq empty` on authority schema files: pass
- `bash -n test-authority-engine-typed-exception-grants.sh`: pass
- `cargo fmt -p octon_authority_engine`: pass
- `cargo test -p octon_authority_engine grant`: pass, 7 tests
- `test-authority-engine-typed-exception-grants.sh`: pass
- `cargo test -p octon_authority_engine`: pass, 75 tests

## Exclusions

- No generated output edit.
- No state/control grant instance edit.
- No proposal status promotion.
- No connector, mission, workflow, or read-model behavior change.
- No dependency change.

## Rollback

Rollback is file-level revert of the durable files listed above, this packet's implementation support receipts, and the timestamped validation evidence root.

## Next Route

Proceed to the separate promote-proposal lifecycle route only after post-implementation validators pass.

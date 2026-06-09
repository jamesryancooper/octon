# Repository Reconnaissance Receipt

verdict: pass
recorded_at: 2026-06-09T18:37:42Z
proposal_id: authority-engine-typed-exception-grants

## Searches Run

- `find .octon/framework/engine/runtime/crates/authority_engine .octon/framework/constitution/contracts/authority .octon/framework/assurance/runtime/_ops/tests -maxdepth 3 -type f`
- `rg -n "approval|grant|exception|revocation|provenance|delegat|authority|generated|read[-_ ]model|importance|generic" ...`
- `rg -n "struct GrantBundle|struct ExecutionRequest|ApprovalGrantArtifact|reason_codes|approval_required|approval_request_ref|approval_grant_refs|exception_lease_refs|authority_grant_bundle_ref" ...`
- `rg -n "materialize-authority-approval|record-authority-exception|approval-grant|authority_zone|operation_class|typed" ...`

## Existing Surfaces Found

- Authority engine route and grant materialization: `.octon/framework/engine/runtime/crates/authority_engine/src/implementation/{api,authority,execution,effects}.rs`
- Existing effect-token approval, exception, revocation, rollback, and support verification in `effects.rs`
- Authority schemas: `approval-request-v1.schema.json`, `approval-grant-v1.schema.json`, `grant-bundle-v2.schema.json`
- Shared delegated-governance schema already present from the predecessor child: `delegated-governance-contract-v1.schema.json`
- Existing authority-engine tests in `src/implementation/tests.rs`
- Existing assurance tests under `.octon/framework/assurance/runtime/_ops/tests/`

## Reused Surfaces

- Reused the existing approval grant loader and revocation loader.
- Reused authority grant bundle emission rather than adding a separate provenance artifact type.
- Reused effect-token verification as the grant-consumption enforcement point.
- Reused the shared delegated-governance vocabulary and exact typed boundary values.

## Rejected New Surfaces

- No new runtime crate, validator framework, generated projection, state/control grant instance, or materialization script was added.
- The existing shell materialization helper was left unchanged because it is outside this packet's declared promotion targets.

## New Surfaces Added

- One focused assurance test: `.octon/framework/assurance/runtime/_ops/tests/test-authority-engine-typed-exception-grants.sh`

The new assurance test is a narrow schema/negative-control check. Runtime behavior is covered by authority-engine Rust tests.

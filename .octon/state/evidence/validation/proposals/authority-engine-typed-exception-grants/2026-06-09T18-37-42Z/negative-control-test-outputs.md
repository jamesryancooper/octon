# Negative Control Test Outputs

verdict: pass
recorded_at: 2026-06-09T18:37:42Z
proposal_id: authority-engine-typed-exception-grants

## Rust Negative Controls

`cargo test -p octon_authority_engine grant`

Result: pass, 7 tests.

Covered tests:

- `typed_approval_grant_authorizes_delegated_consumption`
- `generic_active_approval_grant_is_rejected`
- `generated_output_cannot_create_authority_grant`
- `read_model_cannot_create_authority_grant`
- `effect_consumption_rejects_missing_grant_provenance`
- existing grant/effect denial coverage selected by the `grant` filter

`cargo test -p octon_authority_engine`

Result: pass, 75 tests.

## Assurance Negative Controls

`bash .octon/framework/assurance/runtime/_ops/tests/test-authority-engine-typed-exception-grants.sh`

Result: pass.

Checked:

- approval-grant typed boundary enum;
- approval-grant delegated consumption enum;
- approval-request generated-output and read-model authority-source denial;
- grant-bundle `mints_fresh_authority: false`;
- shared delegated-governance generic-importance denial;
- shared generated/read-model non-authority declarations.

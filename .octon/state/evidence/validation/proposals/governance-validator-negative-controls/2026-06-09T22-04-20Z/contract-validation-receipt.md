# Contract Validation Receipt

proposal_id: governance-validator-negative-controls
run_id: 2026-06-09T22-04-20Z
verdict: pass

## Authority Contract Checks

- `jq empty .octon/framework/constitution/contracts/authority/delegated-governance-contract-v1.schema.json` passed.
- `test-authority-engine-typed-exception-grants.sh` passed against the updated shared schema.
- `validate-authority-zone-policy.sh` passed.

The schema now requires explicit delegated-governance negative-control
requirements and fail-closed routes for missing, stale, contradictory, and
scope-mismatched evidence, unsupported modes, unsafe resume, policy override,
governance mutation, generated authority attempts, and irreversible external
effects.

# Validation Plan

## Proposal Validators

- `validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/autonomous-proposal-program-recovery-envelope --skip-registry-check`
- `validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/autonomous-proposal-program-recovery-envelope`
- `validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/autonomous-proposal-program-recovery-envelope`

## Future Implementation Validators

- `cargo test -p kernel lifecycle_program::tests::autonomous_recovery_envelope_stops_at_material_side_effects`
- `octon lifecycle plan --lifecycle proposal-program --target <fixture-program>`
- `validate-proposal-program-structure.sh --package <fixture-program>`

## Negative Controls

- Verify the change fails closed when required evidence is missing or stale.
- Verify parent summaries cannot replace child-owned receipts.
- Verify generated outputs remain non-authoritative.

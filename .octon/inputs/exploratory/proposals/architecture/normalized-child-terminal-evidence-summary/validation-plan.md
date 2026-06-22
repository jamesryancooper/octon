# Validation Plan

## Proposal Validators

- `validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/normalized-child-terminal-evidence-summary --skip-registry-check`
- `validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/normalized-child-terminal-evidence-summary`
- `validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/normalized-child-terminal-evidence-summary`

## Future Implementation Validators

- `cargo test -p kernel lifecycle_program::tests::archived_implemented_child_terminal_evidence_replaces_legacy_run_receipt_repair`
- `cargo test -p kernel lifecycle_program::tests::active_implemented_child_still_requires_strict_implementation_run_fields`
- `validate-proposal-program-child-readiness.sh --package <fixture-program>`
- `validate-proposal-program-readiness-projection.sh --package <fixture-program>`

## Negative Controls

- Verify the change fails closed when required evidence is missing or stale.
- Verify parent summaries cannot replace child-owned receipts.
- Verify generated outputs remain non-authoritative.

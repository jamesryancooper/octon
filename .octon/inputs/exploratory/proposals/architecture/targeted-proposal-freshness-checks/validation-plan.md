# Validation Plan

## Proposal Validators

- `validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/targeted-proposal-freshness-checks --skip-registry-check`
- `validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/targeted-proposal-freshness-checks`
- `validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/targeted-proposal-freshness-checks`

## Future Implementation Validators

- `test-targeted-proposal-freshness.sh`
- `validate-proposal-lifecycle-terminal-freshness.sh --proposal <fixture> --targeted`
- `generate-proposal-registry.sh --check`

## Negative Controls

- Verify the change fails closed when required evidence is missing or stale.
- Verify parent summaries cannot replace child-owned receipts.
- Verify generated outputs remain non-authoritative.

# Validation Plan

## Proposal Validators

- `validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-supersession-rescue-path --skip-registry-check`
- `validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-supersession-rescue-path`
- `validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-supersession-rescue-path`

## Future Implementation Validators

- `cargo test -p kernel lifecycle_program::tests::polluted_run_freeze_preserves_child_receipt_refs`
- `validate-proposal-program-delivery-profile.sh --profile <profile>`
- `validate-proposal-program-delivery-receipt.sh --receipt <receipt>`
- `validate-proposal-program-delivery-workflow.sh`

## Negative Controls

- Frozen polluted-run evidence cannot authorize mutation.
- Missing child-owned receipt refs block carry-forward.
- Stale child-owned receipt digests block carry-forward.
- Foreign/manual residue is preserved and not silently adopted.
- Parent summaries cannot satisfy child-owned receipts.

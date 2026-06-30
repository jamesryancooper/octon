# Validation Plan

## Proposal Creation Validators

- `validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-to-clean-delivery --skip-registry-check`
- `validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-to-clean-delivery`
- `validate-proposal-program-structure.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-to-clean-delivery`

## Child Validators

Run for each child packet:

- `validate-proposal-standard.sh --package <child> --skip-registry-check`
- `validate-architecture-proposal.sh --package <child>`

## Future Implementation Validators

- `validate-proposal-program-delivery-workflow.sh`
- `validate-proposal-program-delivery-receipt.sh --receipt <receipt>`
- `validate-change-closeout-state-machine.sh --receipt <change-receipt>`
- `validate-hosted-no-pr-landing.sh --receipt <change-receipt>`
- `validate-change-closeout-lifecycle-alignment.sh --receipt <change-receipt> --verify-live-refs`
- `validate-evidence-disclosure-tiers.sh --change-receipt <change-receipt>`
- `validate-terminal-closeout-local-evidence.sh --manifest <manifest>`
- `classify-change-closeout-residue.sh --root <repo>`
- `cleanup-local-run-artifacts.sh --summary-only --root <repo>`

## Negative Controls

- Parent summaries cannot satisfy child receipts.
- Local/private evidence cannot satisfy hosted/shared closeout claims.
- Generated outputs cannot authorize delivery or runtime execution.
- PR routing cannot be inferred from caution or high impact without a concrete
  PR predicate.
- Branch cleanup cannot occur without containment, no-open-PR, rollback, and
  cleanup authorization evidence.

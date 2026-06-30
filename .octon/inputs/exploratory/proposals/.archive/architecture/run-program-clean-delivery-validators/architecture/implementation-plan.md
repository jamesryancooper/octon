# Implementation Plan

1. Compose existing static validators for proposal-program delivery profile,
   delivery receipt shape, delivery evidence index, Change closeout state
   machine, closeout lifecycle alignment, hosted no-PR landing, and evidence
   disclosure tiers.
2. Add one aggregate validator:
   `.octon/framework/assurance/runtime/_ops/scripts/validate-run-program-clean-delivery.sh`.
3. In receipt mode, require the owning
   `validate-proposal-program-delivery-receipt.sh --receipt <receipt>` gate
   before checking clean terminal fields.
4. Fail closed unless the receipt records `actual_outcome: cleaned`, passing
   fresh terminal proof, clean worktree hygiene, final sync equality, no open
   blockers, and no aggregate substitution for target-owned receipts.
5. Add one shell regression test:
   `.octon/framework/assurance/runtime/_ops/tests/test-run-program-clean-delivery-validator.sh`.
6. Cover the success fixture plus negative controls for non-cleaned outcome,
   stale terminal proof, and aggregate evidence substitution.

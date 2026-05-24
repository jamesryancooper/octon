# Rollback Plan

Rollback must preserve target-owned authority and generated-source boundaries.

1. Revert the two new product contract schemas if no retained interaction
   receipt depends on them.
2. Revert lifecycle contract metadata and republish extension generated
   projections through `publish-extension-state.sh`.
3. Revert runner and executor request fields only after no checkpoint,
   event-log, or execution-request evidence references interaction refs.
4. Revert skill prose only after any emitted request receipts are either
   retained as historical evidence or superseded by explicit return/blocker
   receipts.
5. Re-run lifecycle contract, interaction receipt, runner, executor, proposal
   conformance, and drift validators.

Rollback must not delete durable evidence, force-delete branches, rewrite
hosted state, or treat generated projections as source authority.

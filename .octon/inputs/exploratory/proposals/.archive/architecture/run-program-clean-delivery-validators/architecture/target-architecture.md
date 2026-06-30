# Target Architecture

Add a terminal clean-delivery aggregate validator that composes existing
validators and proves:

- the clean-delivery validator chain is present and statically healthy;
- proposal-program delivery receipts validate through the owning receipt
  validator before any aggregate conclusion is made;
- `actual_outcome` is exactly `cleaned`;
- terminal current-state proof is passing and fresh after the last mutation;
- worktree hygiene is passing and reports `dirty_worktree: false`;
- final sync proves local main, origin main, and landed ref equality;
- target-owned evidence policy forbids aggregate receipts replacing
  child-owned receipts;
- no open blockers remain in the delivery receipt.

The implementation is the read-only shell validator
`.octon/framework/assurance/runtime/_ops/scripts/validate-run-program-clean-delivery.sh`.
It records exact missing evidence as validator failures and delegates
correction to the owning lifecycle, closeout, archive, generated publication,
or cleanup route that owns the missing receipt.

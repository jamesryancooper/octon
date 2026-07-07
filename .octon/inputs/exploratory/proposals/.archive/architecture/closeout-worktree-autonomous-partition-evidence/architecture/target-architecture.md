# Target Architecture

`closeout-worktree` can emit an evidence-only partition report for proposal-program handoffs.

## Target Behavior

- Consume lifecycle interaction request context as advisory, non-authorizing input.
- Re-inventory and re-classify the current worktree before returning a partition report.
- Partition paths into deliverable, publishable closeout evidence, local-private retained, foreign/manual, protected, unsafe, or ambiguous classes.
- Return a `closeout-worktree-report-v1` and optional `lifecycle-interaction-return-v1` when ownership is provable.
- Preserve and exclude foreign/manual residue from the named lifecycle blocker only when the report proves non-mutating disposition.

## Safety Properties

- Reports do not authorize deletion, reset, staging, commit, push, publication, archive, branch cleanup, child closeout, or terminal delivery claims.
- Reports do not replace Change receipts.
- Reports do not replace child-owned proposal receipts.
- Ambiguous ownership remains nonterminal with candidate-keyed blockers.

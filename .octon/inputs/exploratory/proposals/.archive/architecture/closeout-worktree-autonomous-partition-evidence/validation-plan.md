# Validation Plan

## Proposal Validators

- `validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/closeout-worktree-autonomous-partition-evidence --skip-registry-check`
- `validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/closeout-worktree-autonomous-partition-evidence`
- `validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/closeout-worktree-autonomous-partition-evidence`

## Future Implementation Validators

- `validate-closeout-worktree-wrapper.sh`
- `validate-closeout-worktree-wrapper.sh --report <partition-report>`
- `test-closeout-worktree-wrapper.sh`
- `classify-proposal-worktree-hygiene.sh --target <fixture-program> --lifecycle proposal-program`

## Negative Controls

- Partition reports cannot authorize deletion.
- Partition reports cannot authorize staging, commit, push, archive, publication, branch cleanup, or terminal delivery claims.
- Partition reports cannot replace Change receipts.
- Partition reports cannot replace child-owned proposal receipts.
- Ambiguous ownership stays nonterminal.

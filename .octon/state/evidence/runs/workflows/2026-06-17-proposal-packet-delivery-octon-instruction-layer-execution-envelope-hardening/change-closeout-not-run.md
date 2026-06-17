# Change Closeout Not Run

- route: `branch-no-pr`
- target_outcome: `cleaned`
- status: `blocked`
- blocker: the packet delivery wrapper was invoked after the proposal had
  already been archived on the local branch.

The wrapper cannot truthfully claim hosted no-PR landing, final sync, or branch
cleanup. Those effects must be owned by `closeout-change` or
`closeout-worktree` with landing authorization, mutation proof, rollback
evidence, source-branch containment, and cleanup authorization.

No PR fallback is allowed by the bound delivery profile.

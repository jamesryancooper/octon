# Acceptance Criteria

- The runner emits handoff evidence when child-batch residue needs Change or
  worktree disposition.
- The handoff is non-authorizing and cannot mutate Git, cleanup, publication,
  promotion, or archive state.
- Terminal phases can require returned evidence without treating it as child
  receipts.

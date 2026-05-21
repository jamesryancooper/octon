---
title: Closeout Worktree Safety
---

# Safety

- Preserve unrelated and user-owned work.
- Fail closed when candidate ownership, route, target outcome, cleanup
  authority, validation scope, or rollback posture is ambiguous.
- Do not stage files directly from the wrapper.
- Do not commit, push, land, merge, open PRs, delete branches, restore, reset,
  or overwrite directly from the wrapper.
- Do not use detection-only residue classification as cleanup authority.
- Do not group unrelated residue into one Change receipt.
- Do not continue after `closeout-change` reports a blocker that changes the
  safety or ownership posture of remaining candidates.
- Do not claim full worktree closeout unless every observed item is either
  closed through singular Change evidence or explicitly retained, deferred,
  blocked, escalated, or foreign.
- Do not treat generated outputs, raw inputs, host projections, GitHub state,
  chat, model memory, or tool availability as closeout authority.

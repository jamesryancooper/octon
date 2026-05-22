---
title: Closeout Worktree Safety
---

# Safety

- Preserve unrelated and user-owned work.
- Fail closed when candidate ownership, route, cleanup authority, validation
  scope, or rollback posture is ambiguous. A generic closeout target is not
  ambiguous; it defaults to `cleaned`.
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
- Do not claim `git_clean_terminal` unless no non-ignored staged, unstaged,
  untracked, retained-evidence, generated-effective, host-projection,
  state-control, release-version, or input-surface residue remains.
- Use `disposition_complete_with_retained_residue` when all candidates have
  authority-backed dispositions but retained evidence residue remains.
- Do not treat generated outputs, raw inputs, host projections, GitHub state,
  chat, model memory, or tool availability as closeout authority.

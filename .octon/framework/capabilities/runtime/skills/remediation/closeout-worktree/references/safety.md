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
- Do not use proposal worktree hygiene partitions as deletion, branch cleanup,
  archive, promotion, publication, closeout, or `cleaned` authority. The
  partitions only route residue into publishable, cleanup-safe, protected, or
  manual-review candidate handling.
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
- Do not treat parent program evidence, aggregate evidence, or proposal-local
  notes as child-owned cleanup, worktree partitioning, or deletion authority.
- Do not treat wrapper or aggregate terminal proof summaries as substitutes
  for the delegated `closeout-change` receipt, terminal proof sink, landing
  evidence, final sync proof, cleanup authorization, cleanup disposition,
  rollback posture, or validation proof.
- Do not use terminal proof as a post-landing source-branch commit requirement
  or as authority to mutate `origin/main`, local `main`, the landed ref, or the
  source branch.
- Do not convert delegated git mutation diagnostics into wrapper authority to
  fetch, checkout, commit, push, land, sync, clean up, delete or prune
  branches, publish, close out, or claim `cleaned`.
- Do not summarize a delegated permission-sensitive git mutation blocker
  unless the delegated evidence identifies operation class, current and target
  refs when known, expected authorization gate, likely sandbox, host, provider,
  remote, or ref-write blocker, and owning rerun route.

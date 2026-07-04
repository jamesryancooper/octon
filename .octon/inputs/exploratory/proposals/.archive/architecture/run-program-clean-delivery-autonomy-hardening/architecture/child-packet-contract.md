# Child Packet Contract

Each child packet is a sibling packet under
`.octon/inputs/exploratory/proposals/architecture/`. No child packet is nested
inside the parent program directory.

## Required Child Duties

- Declare its own proposal metadata, target architecture, implementation plan,
  acceptance criteria, source lineage, source-of-truth map, artifact catalog,
  and validation plan.
- Preserve child-owned review, implementation, validation, closeout, archive,
  and rollback evidence.
- Define exact promotion targets and negative controls for the postmortem
  finding it owns.
- Treat proposal-local content as non-authoritative until accepted and
  implemented through a governed route.
- Avoid claiming parent delivery, Git cleanup, archive authorization, generated
  freshness, or terminal worktree cleanliness.

## Parent Duties

The parent may sequence children, track readiness, summarize child outcomes,
and verify aggregate acceptance after child-owned evidence exists. The parent
must not use its summaries as substitute child authority.

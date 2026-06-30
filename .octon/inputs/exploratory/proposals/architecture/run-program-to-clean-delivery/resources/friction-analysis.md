# Friction Analysis

## Observed Friction

- Manual route invocations were required across review/revise loops, child
  packet sequencing, implementation orchestration, verification/correction,
  closeout, archive, hygiene, delivery, terminal evidence, and final clean
  state validation.
- Stale route-owned receipts and digest-bound architecture receipts required
  manual refresh at stable packet boundaries.
- Child authority was preserved, but the handoff between parent program,
  child packets, closeout, archive, worktree hygiene, and Change delivery was
  too manual.
- Worktree hygiene and foreign or ambiguous residue handling required operator
  routing even when exact scope and safe handoff were known.
- Branch-no-pr delivery could land and clean refs, but terminal receipt
  validation exposed weak integration between publishable closeout evidence and
  local/private terminal evidence.
- Generated proposal metadata refreshes were treated as manual closeout chores
  instead of route-owned refreshes.

## Root Causes

- The existing proposal-program lifecycle runner can plan and execute bounded
  route steps, but it stops before delivery, hosted mutation, branch cleanup,
  and cleaned claims.
- `/proposal-program-delivery` models the correct downstream workflow, but it
  is not easy to invoke as the default continuation from a program lifecycle
  run.
- Route-owned stale receipt refresh, generated metadata refresh, and worktree
  hygiene handoff are present as separate mechanisms but lack one explicit
  end-to-end state projection.
- Terminal local evidence is correctly non-authority, but branch-no-pr cleaned
  receipts must retain publishable landing and cleanup refs before the local
  terminal sink is synthesized.

## Design Seed

Prefer a wrapper over existing route-owned steps with targeted runner,
delivery, receipt, validator, and operator-surface hardening. Do not create a
second authority plane for proposal, closeout, archive, cleanup, branch, or
terminal proof decisions.

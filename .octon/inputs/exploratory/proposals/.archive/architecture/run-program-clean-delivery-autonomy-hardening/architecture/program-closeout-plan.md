# Program Closeout Plan

The parent program can close only after all required child packets have reached
terminal child-owned closeout.

## Required Parent Closeout Evidence

- Child packet terminal outcomes and archive readiness by path and digest.
- Parent completeness review proving every PM-001 through PM-007 finding is
  owned by at least one child packet.
- Aggregate validation proof for compact blocker remediation, no-dispatch
  deduplication, autonomous hygiene continuation, stale branch retirement,
  run-health localization, authorized hosted landing, and final retained-state
  reporting.
- Parent closeout receipt that does not claim archive authorization unless the
  route-owned parent closeout gate grants it.
- Change closeout evidence for any durable implementation branch, including
  final sync, branch cleanup, retained evidence, and terminal worktree status.

## Stop Conditions

Stop before parent archive or delivery if any child authority is missing, any
required receipt is stale, any generated read model is treated as authority,
any destructive cleanup lacks route-owned authorization, or any final report
overclaims retained branch, retained worktree, or retained evidence state.

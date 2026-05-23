# Cutover Checklist

## Preconditions

- Packet has fresh accepted review receipt.
- Implementation-grade completeness gate passes.
- Implementation prompt is generated through the governed lifecycle.
- Worktree scope contains only the approved implementation change.
- Required validators are identified before edits begin.

## Clean-Break Cutover

1. Update source-authored schema and contract surfaces together.
2. Update runner checkpoint, resume, event-log, and loop-bound behavior.
3. Update proposal lifecycle extension docs, commands, skills, prompts, and
   validation scenarios.
4. Update tests and validators in the same change set.
5. Run contract, runner, executor, acceptance, and proposal lifecycle tests.
6. Refresh generated effective projections from source-authored inputs.
7. Validate generated projection freshness and source digest linkage.
8. Retain publication and run evidence outside `inputs/**`.
9. Re-run lifecycle discovery through generated effective handles.
10. Record implementation conformance and post-implementation drift/churn
    receipts.

## Cutover Refusals

Do not cut over if:

- any phase-loop schema or contract reference is unresolved;
- any route can skip fresh accepted review before implementation;
- generated projections are stale or hand-edited;
- checkpoint and event-log replay disagree;
- durable route execution lacks delegation proof or required approval evidence;
- proposal-local receipts are referenced as runtime authority;
- new proposal statuses appear without accepted contract-level proof;
- old and new phase-loop semantics coexist as active live behavior after
  cutover.

# Target Architecture

The workflow child adds `lifecycle-postmortem` as a meta workflow with stages
similar to:

1. Bind target run id and verify the lifecycle run is terminal, closed, failed,
   revoked, rolled back, or otherwise post-run inspectable.
2. Reconstruct factual lifecycle state from run journal, runtime state,
   RunCard, closeout refs, checkpoints, lifecycle events, program events, and
   retained evidence.
3. Invoke the lifecycle-postmortem evaluator template with an evidence map and
   explicit known limits.
4. Write retained evidence under
   `.octon/state/evidence/runs/<run-id>/assurance/lifecycle-postmortem/`.
5. Emit optional review-finding records for durable traceability.
6. Report the final evaluator judgment without mutating lifecycle authority.

## Workflow Contract Requirements

The workflow contract must declare:

- `entry_mode: human` or another explicit operator-invoked mode;
- read scope over run control and retained evidence;
- write scope limited to retained evidence;
- no state mutation, publication, branch mutation, or cleanup authority;
- fail-closed done gates for missing evidence, unresolved references, invalid
  final judgment, and attempted authority transfer.

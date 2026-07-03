# Implementation Plan

1. Review Change closeout skill behavior, default work unit policy, state machine, receipt schema, and landing validators.
2. Define receipt states for branch published, PR merged, origin main synced, local main synced, and branch cleanup completed or preserved.
3. Update validators to require receipt-state alignment for the terminal actions actually performed.
4. Add fixtures for already published, newly pushed, PR-merged, no-PR landed, synced-main, and branch-cleaned states.
5. Wire clean-delivery closeout checks to require the Change closeout receipt instead of host narrative.

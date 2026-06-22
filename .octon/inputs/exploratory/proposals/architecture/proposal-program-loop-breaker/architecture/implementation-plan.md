# Implementation Plan

1. Add a blocker fingerprint model to the proposal-program planner state.
2. Record route id, blocker class, child id when present, path set, source refs, source digests, and disposition in route-decision evidence.
3. Compare the selected route against prior route decisions before recovery dispatch.
4. Mark unchanged cleanup routes terminal for the current blocker and route to blocked or stage-only posture when no higher-priority recovery remains.
5. Add publication-drift priority before cleanup when generated freshness evidence is stale.
6. Add token and attempt budget checks to the recovery planner.
7. Add fixtures for unchanged blocker, changed blocker, publication drift, cleanup terminality, and budget exhaustion.

This child must not add ownership leases, supersession, or closeout-worktree partition behavior.

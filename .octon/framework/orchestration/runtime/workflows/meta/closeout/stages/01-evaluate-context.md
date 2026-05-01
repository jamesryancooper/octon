# Evaluate Context

1. Load the canonical Git/worktree autonomy contract.
2. Determine whether the current state is:
   - main worktree needing a feature branch
   - branch worktree with no PR
   - draft PR in the autonomous lane
   - draft PR in the manual lane
   - already-ready PR with only queued or running required checks requiring
     status-only reporting
   - blocked implementation that should continue without closeout mutation
3. Treat red required checks, failing jobs, failing scripts, unresolved review
   conversations, unresolved author action items, and failed final hygiene as
   blockers, not as waiting states.
4. Record the resolved closeout context and every blocking condition.

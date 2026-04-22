# Evaluate Context

1. Load the canonical Git/worktree autonomy contract.
2. Determine whether the current state is:
   - main worktree needing a feature branch
   - branch worktree with no PR
   - draft PR in the autonomous lane
   - draft PR in the manual lane
   - already-ready PR requiring status-only reporting
   - blocked implementation that should continue without closeout mutation
3. Record the resolved closeout context and any blocking conditions.

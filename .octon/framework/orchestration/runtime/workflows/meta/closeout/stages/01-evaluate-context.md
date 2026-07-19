# Evaluate Context

1. Load the default-work-unit policy, state machine, and Git/worktree contract.
2. Inventory Change, branch, refs, worktrees, and dirty state read-only.
3. Preserve exact include/exclude boundaries and unrelated work.
4. Select `branch-pr` only for an independent PR predicate; otherwise choose
   `branch-no-pr` for preservation or `stage-only-escalate` for a blocker.
5. Resolve a generic closeout target to `preserved`.
6. Record `RP00_CONTAINMENT_PUBLICATION_DISABLED` for a direct-main,
   landing, or publication request.
7. Record `RP00_CONTAINMENT_CLEANUP_DISABLED` for cleanup, deletion, pruning,
   worktree removal, or closeout-driven sync.

Do not perform any requested effect while evaluating it.

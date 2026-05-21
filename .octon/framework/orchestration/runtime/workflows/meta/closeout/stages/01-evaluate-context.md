# Evaluate Context

1. Load the canonical default work unit policy, Change Closeout State Machine,
   and Git/worktree route contract.
2. Resolve or create the Change identity before selecting branch or PR actions.
3. Select the route, target lifecycle outcome, and actual lifecycle outcome
   separately. Determine whether the current state is:
   - direct-main eligible Change
   - branch-only Change with no PR requirement and outcome `preserved`,
     `branch-local-complete`, `published-branch`, `landed`, or `cleaned`
   - PR-backed Change with outcome `preserved`, `published`, `ready`, `landed`,
     or `cleaned`
   - already-ready PR-backed Change with only queued or running required checks
   - stage-only or escalated Change with missing decision, validation,
     rollback, authorization, review, or ownership evidence
   - blocked implementation that should continue without closeout mutation
4. Apply the decision ladder in order: route, target lifecycle outcome, actual
   lifecycle outcome, then closeout report posture. Do not infer completion from
   a route, branch push, draft/open PR, ready PR, or branch-local commit.
   Keep the state machine as phase and evidence authority, not route authority.
5. When the operator asks to close out a Change or worktree without naming a
   narrower target outcome, resolve `target_lifecycle_outcome` to `cleaned`
   before mutating hosted refs, deleting branches, or reporting closeout.
   Explicit requests for pushed-branch handoff, branch-local completion, landed
   only, preservation, blocker recording, or escalation remain narrower targets.
6. Treat red required checks, failing jobs, failing scripts, unresolved review
   conversations, unresolved author action items, missing rollback handles,
   missing Change receipts, and failed final hygiene as blockers, not as
   waiting states.
7. For hosted `branch-no-pr` landing, evaluate whether provider rules allow
   route-neutral fast-forward updates and whether a governed landing
   authorization can be emitted for the current source ref and `origin/main`
   pre-ref; a PR-required ruleset is a blocker, not permission to open a PR.
8. If target outcome is `landed` or `cleaned` but evidence only supports
   `published-branch`, record landing evaluation evidence, `not_landed_reason`,
   and `closeout_outcome: continued` or a blocker state.
9. Record the selected Change route, target lifecycle outcome, actual lifecycle
   outcome, and every blocking condition.
10. For any completed or cleaned claim, require `stateful_closeout` receipt
    evidence that identifies inventory, residue classification, phase exits,
    cleanup decisions, final verification, and applicable hosted landing or
    branch cleanup references.

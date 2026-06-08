# Source: Terminal Routing Postmortem Recommendations

This source distills the verified postmortem recommendations for the
proposal-program runner end-to-end execution attempt.

## Source Findings

1. The final hard blocker was duplicate canonical workflow run id during
   `archive-proposal` retry for child
   `proposal-program-runner-executor-delegation-gates`.
2. Workflow retry should allocate attempt-suffixed workflow run ids for new
   dispatch attempts. Resume of an existing workflow run requires explicit
   replay-safe proof.
3. `closeout-change` should be contract-declared as a non-authorizing
   lifecycle interaction checkpoint after mutating child implementation or
   child batches, not as runner-local cleanup or automatic Git mutation.
4. Aggregate child terminal blockers should be parent controller evidence.
   Program route receipts may consume that evidence but must not replace
   child-owned receipts.
5. Promotion evidence must be bound to the selected child identity before
   workflow-owned `promote-proposal` dispatch.
6. Generated-state freshness drift should be classified before workflow
   dispatch where possible and route to canonical publication recovery.
7. Parent review should not churn because volatile run-control or route-created
   evidence changed outside the reviewed parent artifact surface.
8. Archive observation must converge after workflow-owned active-path moves or
   fail closed with retained blocked archive evidence.
9. Tests and fixtures must prove the terminal routing failure pattern cannot
   recur silently.

## Ownership Constraints

- The runner orchestrates; it does not own route behavior.
- Promotion and archive remain workflow-owned.
- Change closeout remains route/workflow-owned.
- Cleanup mutation remains cleanup-route/helper-owned.
- Publication and registry refresh remain script/tool-owned.
- Generated state remains non-authority.
- Parent evidence may summarize child outcomes but never satisfies child
  receipts.

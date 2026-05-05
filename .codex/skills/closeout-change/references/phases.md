---
title: Closeout Change Phases
---

# Phases

1. Load the default work unit policy, Change receipt schema, Git/worktree
   contract, and current repository state.
2. Resolve Change identity from user intent, branch, commit scope, existing
   receipt, or PR context.
3. Evaluate route inputs: user instruction, repo state, touched paths, risk,
   validation floor, collaboration need, protected surfaces, and continuity.
4. Select exactly one route.
5. Resolve the target lifecycle outcome separately from the route. If the
   operator selected `branch-no-pr` but did not specify handoff, hosted
   landing, or cleaned closeout, ask before mutating hosted refs or deleting
   branches.
6. Select the actual lifecycle outcome separately from the route and target.
7. Verify route-required and outcome-required evidence.
8. For `branch-no-pr`, distinguish preservation, branch-local commit, branch
   push, hosted no-PR landing on `main`, and cleanup. Hosted no-PR landing
   requires preflight before mutation and post-push proof that `origin/main`
   equals the recorded `landed_ref`.
9. For `branch-pr`, distinguish published, ready, landed, and cleaned states
   instead of treating draft/open/ready PRs as full closeout.
10. Complete the route-specific output or record stage-only blockers. If the
    target outcome was `landed` or `cleaned` but the actual outcome is lower,
    record `not_landed_reason` or `not_cleaned_reason` and report continued or
    blocked closeout.
11. Write or update the Change receipt and execution log.

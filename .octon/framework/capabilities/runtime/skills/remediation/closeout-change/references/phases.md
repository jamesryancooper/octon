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
5. Select the lifecycle outcome separately from the route.
6. Verify route-required and outcome-required evidence.
7. For `branch-no-pr`, distinguish preservation, branch-local commit, branch
   push, hosted no-PR landing on `main`, and cleanup. Hosted no-PR landing
   requires preflight before mutation and post-push proof that `origin/main`
   equals the recorded `landed_ref`.
8. For `branch-pr`, distinguish published, ready, landed, and cleaned states
   instead of treating draft/open/ready PRs as full closeout.
9. Complete the route-specific output or record stage-only blockers.
10. Write or update the Change receipt and execution log.

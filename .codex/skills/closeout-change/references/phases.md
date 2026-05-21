---
title: Closeout Change Phases
---

# Phases

1. Load the default work unit policy, Change Closeout State Machine, Change
   receipt schema, Git/worktree contract, and current repository state.
2. Capture inventory for branch, HEAD, `main`, `origin/main`, staged,
   unstaged, untracked, ignored, branch, remote, and worktree state.
3. Classify residue for staged, unstaged, untracked, ignored, generated,
   host-projection, retained evidence, release, input-surface, and branch
   items. Detection alone is not deletion authority.
4. Resolve Change identity from user intent, branch, commit scope, existing
   receipt, or PR context.
5. Evaluate route inputs: user instruction, repo state, touched paths, risk,
   validation floor, collaboration need, protected surfaces, and continuity.
6. Select exactly one route.
7. Resolve the target lifecycle outcome separately from the route. If the
   operator only asked to close out the Change and did not explicitly specify a
   narrower target, set `target_lifecycle_outcome: cleaned` before mutating
   hosted refs or deleting branches.
8. Select the actual lifecycle outcome separately from the route and target.
9. Verify route-required and outcome-required evidence.
10. For `branch-no-pr`, distinguish preservation, branch-local commit, branch
   push, hosted no-PR landing on `main`, and cleanup. Hosted no-PR landing
   requires preflight and governed `branch-landing-authorization-v1` evidence
   before mutation and post-push proof that `origin/main` equals the recorded
   `landed_ref`.
11. For `branch-pr`, distinguish published, ready, landed, and cleaned states
   instead of treating draft/open/ready PRs as full closeout.
12. Complete the route-specific output or record stage-only blockers. If the
    target outcome was `landed` or `cleaned` but the actual outcome is lower,
    record `not_landed_reason` or `not_cleaned_reason` plus
    `landing_stop_reason` or `cleanup_stop_reason` and report continued or
    blocked closeout.
13. Write or update the Change receipt and execution log. Completed or cleaned
    claims require `stateful_closeout` evidence.
14. Before reporting branch-based full closeout, verify the source branch
    changes are integrated into `origin/main`, fetch origin, update local
    `main` to that same ref, verify landed-ref containment in both refs, and
    record cleanup completed with `branch-cleanup-authorization-v1` evidence
    when claiming `cleaned`. Deferred cleanup is a lower actual outcome with
    blocker evidence.

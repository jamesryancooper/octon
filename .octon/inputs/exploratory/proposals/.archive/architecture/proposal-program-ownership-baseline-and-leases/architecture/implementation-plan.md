# Implementation Plan

1. Add baseline capture to proposal-program run setup.
2. Define route write lease fields in planner state and lifecycle contract.
3. Teach route selection to require a lease before mutating paths.
4. Extend proposal worktree hygiene classification to emit owned, leased, foreign/manual, protected, generated, and ambiguous path classes.
5. Add isolated worktree gate checks to readiness projection where current worktree state is polluted.
6. Add validator and fixture coverage for valid lease, missing lease, stale lease, foreign path, protected evidence, and generated-only path cases.

This child must not implement polluted-run supersession or closeout-worktree partition reports.

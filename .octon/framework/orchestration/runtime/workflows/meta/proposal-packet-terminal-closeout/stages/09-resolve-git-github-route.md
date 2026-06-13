---
title: Resolve Git And GitHub Route
description: Validate Git/GitHub route evidence or delegate mutation to existing closeout routes.
---

# Step 9: Resolve Git And GitHub Route

## Consumed Evidence

- Worktree hygiene evidence.
- Default work unit and Change closeout route evidence.
- Hosted exact-SHA check evidence when applicable.

## Produced Evidence

- Git/GitHub route refs.
- Exact-SHA check refs.
- Landing and branch cleanup authorization refs when applicable.
- State ledger entry `resolve-git-github-route`.

## Actions

1. If no Git mutation is required, record route evidence as not applicable.
2. If Git mutation is required, delegate to `closeout-change` or
   `closeout-worktree`.
3. For branch-no-PR hosted landing, require provider preflight, exact source
   SHA checks, governed landing authorization, branch cleanup authorization,
   fetch, sync, and local/main/origin equality proof from the owning route.
4. Block with exact check, SHA, workflow, evidence ref, and next route when
   hosted checks are missing or fail.

## Side Effect Class

Read-only validation plus retained evidence write. Git/GitHub mutation is
delegated and never performed here.

## Re-Entry Condition

Re-enter when Change closeout, Git/GitHub, hosted check, branch landing, branch
cleanup, or sync evidence changes.

## Stop Condition

Stop with `blocked` and next route `closeout-change` or `closeout-worktree`
when route evidence is missing or failed.

## Receipt Fields

- `git_github_route.route_ref`
- `git_github_route.branch_no_pr`
- `git_github_route.mutation_delegated`
- `git_github_route.exact_sha_checks_ref`
- `git_github_route.landing_authorization_ref`
- `git_github_route.branch_cleanup_required`
- `git_github_route.branch_cleanup_authorization_ref`
- `state_ledger[].state_id: resolve-git-github-route`

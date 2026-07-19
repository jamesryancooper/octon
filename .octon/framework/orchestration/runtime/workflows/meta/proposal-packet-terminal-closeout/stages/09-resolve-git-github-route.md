---
title: Enforce Git And GitHub Containment
description: Prove exact-work preservation and deny publication effects.
---

# Step 9: Enforce Git And GitHub Containment

## Consumed Evidence

- Worktree hygiene and exact-candidate preservation evidence.
- The containment-bound terminal profile.
- Current target outcome and route request.

## Produced Evidence

- A read-only preservation record.
- Stable containment reason `RP00_CONTAINMENT_PUBLICATION_DISABLED` when an
  effectful or omitted/default route is requested.
- State ledger entry `resolve-git-github-route` with `mutation_delegated: false`.

## Actions

1. Admit only `archive-ready` or `blocked` with `none-closeout-only` or
   `stage-only-escalate`.
2. Reject direct-main, hosted branch-no-PR, landing, sync, cleanup, branch
   deletion, and any omitted/default effectful request before dispatch.
3. Do not delegate to `closeout-change`, `closeout-worktree`, a hosted provider,
   or a cleanup route.
4. Prove exact candidate refs, branches, worktrees, rollback handles, and
   unrelated work remain preserved.
5. Name RP-06/RP-08 as the later owning route without authorizing or invoking
   it.

## Side Effect Class

Read-only validation plus retained evidence write. No Git/GitHub, provider,
publication, cleanup, or branch mutation is delegated or performed.

## Stop Condition

Stop with `blocked`, `RP00_CONTAINMENT_PUBLICATION_DISABLED`, and the later
owning route when any effectful or omitted/default request is observed.

## Receipt Fields

- `git_github_route.route_ref: not-applicable`
- `git_github_route.branch_no_pr: false`
- `git_github_route.mutation_delegated: false`
- `git_github_route.exact_sha_checks_ref`
- `git_github_route.landing_authorization_ref: not-applicable`
- `git_github_route.branch_cleanup_required: false`
- `git_github_route.branch_cleanup_authorization_ref: not-applicable`
- `state_ledger[].state_id: resolve-git-github-route`

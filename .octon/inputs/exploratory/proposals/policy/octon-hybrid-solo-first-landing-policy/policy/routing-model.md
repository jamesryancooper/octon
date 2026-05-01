# Hybrid Landing Routing Model

## Route Selection

Route selection answers which execution and review channel the Change needs.
Lifecycle outcome answers how far closeout progressed.

Selection precedence remains fail-closed:

1. Existing PR context or explicit PR request selects `branch-pr`.
2. Hosted review, external signoff, unresolved review discussion, release
   automation, collaborative ownership, or high-impact governance handling
   selects `branch-pr`.
3. Isolated branch work with no PR predicate selects `branch-no-pr`.
4. Clean current `main` and low-risk scope may select `direct-main`.
5. Missing route, validation, permission, or provider feasibility selects
   `stage-only-escalate`.

## Branch-No-PR Hosted Landing

Hosted `branch-no-pr` landing requires:

- current clean branch worktree;
- pushed source branch;
- source SHA descends from current `origin/main`;
- exact source SHA has required route-neutral checks;
- provider ruleset allows no-PR fast-forward update;
- valid Change receipt with hosted landing evidence;
- rollback handle;
- fast-forward-only push to `main`;
- post-push verification that `origin/main` equals `landed_ref`;
- cleanup evidence or deferred cleanup record.

## Provider Rule Outcomes

If the live provider ruleset requires PRs, hosted no-PR landing is unavailable.
Octon must report the blocker and select a non-hosted branch outcome,
`stage-only-escalate`, or explicit `branch-pr`.

If the provider ruleset is route-neutral, Octon may land without a PR only
after exact-SHA validation and receipt checks pass.

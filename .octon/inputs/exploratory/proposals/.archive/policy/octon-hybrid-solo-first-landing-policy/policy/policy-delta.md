# Policy Delta

## Durable Authority

The durable policy authority is the default work unit contract:

- `.octon/framework/product/contracts/default-work-unit.yml`
- `.octon/framework/product/contracts/default-work-unit.md`
- `.octon/framework/product/contracts/change-receipt-v1.schema.json`

The Git/worktree autonomy contract, closeout skills, workflows, helper scripts,
and validators must subordinate to these product contracts.

## Required Default Work Unit Changes

Update `branch-no-pr` so its hosted `landed` and `cleaned` outcomes require:

- provider ruleset compatibility for route-neutral landing;
- source branch pushed to the remote;
- source ref current with `origin/main`;
- exact source SHA validation evidence;
- fast-forward-only update from prior `origin/main` to the source SHA;
- remote verification that `origin/main` equals the recorded `landed_ref`;
- Change receipt and rollback handle;
- cleanup evidence or explicit deferred-cleanup record.

Clarify that a PR-required provider ruleset makes hosted `branch-no-pr`
landing infeasible. In that case Octon must select `stage-only-escalate`,
`branch-local-complete`, `published-branch`, or explicit `branch-pr` according
to operator intent.

## Required Receipt Changes

Extend the Change receipt contract so hosted no-PR landing can be represented
without PR metadata. Add a hosted landing evidence object containing remote,
target branch, source branch, source ref, target pre-ref, target post-ref,
validated ref, required check refs, provider ruleset ref, and
`fast_forward_only: true`.

Allow `publication_status: hosted-main-updated` for `branch-no-pr` landed or
cleaned outcomes. Continue forbidding PR URLs, PR numbers, and PR durable
history for `branch-no-pr`.

## Required Closeout Changes

`closeout-change` must run provider-rule and exact-SHA landing preflight before
claiming hosted `branch-no-pr` `landed` or `cleaned`. It must never open a PR
unless route selection returns `branch-pr`.

`closeout-pr` remains PR-backed only and must continue to distinguish
`published`, `ready`, `landed`, and `cleaned`.

## Linked GitHub Projection Delta

The target GitHub ruleset replaces universal PR-required `main` with
route-neutral protection: deletion protection, non-fast-forward protection,
required linear history, strict required checks, route-neutral required gates,
and PR-specific checks enforced only inside `branch-pr` route logic.

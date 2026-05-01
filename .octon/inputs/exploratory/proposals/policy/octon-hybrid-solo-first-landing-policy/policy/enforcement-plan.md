# Enforcement Plan

## Policy Enforcement

Update default work unit validators so `branch-no-pr` hosted landing cannot
pass without remote `main` evidence. The validator must compare the recorded
`landed_ref` with the observed `origin/main` ref and fail if they differ.

## Helper Enforcement

Add hosted no-PR landing helpers that fail closed before mutation:

- `git-branch-hosted-preflight.sh`
- `git-required-checks-at-ref.sh`
- `git-branch-land-hosted-no-pr.sh`

The landing helper must not create or update a PR. It must push only by
fast-forwarding the exact validated source SHA to `refs/heads/main`, then fetch
and verify the remote target ref.

## Validator Enforcement

Add or update validators for:

- current PR-required GitHub ruleset produces a clear hosted no-PR preflight
  failure;
- target route-neutral ruleset permits validated fast-forward no-PR landing;
- stale branches cannot land;
- missing or failing checks block landing;
- missing receipt or rollback handle blocks landing;
- PR metadata is forbidden for `branch-no-pr`;
- PR merge evidence is required for `branch-pr` `landed` or `cleaned`;
- local checkpoints and branch-local commits cannot claim hosted landing;
- no route opens a PR unless `branch-pr` is selected.

## CI And GitHub Projection Enforcement

The linked repo-local GitHub projection packet must add route-neutral checks
that run on branch pushes and PRs before changing the live ruleset. Expected
check classes are:

- route-neutral closeout validation;
- branch naming validation;
- route-aware autonomy validation.

PR-specific checks such as `PR Quality Standards` and `AI Review Gate /
decision` become required inside `branch-pr` route logic, not universal
requirements for all `main` updates.

## Rollout Enforcement

The live GitHub ruleset must remain PR-required until Octon internal preflight
and validators pass and a linked operational rollout verifies the repo-local
projection checks. The ruleset switch is blocked until that linked rollout
updates GitHub rules.

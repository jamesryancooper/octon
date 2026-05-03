# Change Route Ruleset Preflight Evidence

## Scope

This evidence packet is read-only pre-migration evidence for the Change
Lifecycle Routing Model. It does not mutate live GitHub settings.

## Current Live State

- Repository: `jamesryancooper/octon`
- Default branch: `main`
- Ruleset id: `12881449`
- Ruleset name: `Main Branch Guardrails (PR + CI + Codex)`
- Live posture: `current-pr-required`
- Strict live validation:
  `.octon/framework/assurance/runtime/_ops/scripts/validate-github-main-ruleset-alignment.sh --strict-live`
- Result: passed; live `main` still contains a `pull_request` rule, so hosted
  `branch-no-pr` remains blocked before migration.

Rollback input:

- `current-live-main-ruleset-12881449.json`
- `current-live-main-rules.json`

## Shadow Route-Neutral Check Evidence

- Workflow run:
  `https://github.com/jamesryancooper/octon/actions/runs/25266636817`
- Workflow ref: `main`
- Source branch: `chore/change-route-shadow-f8fa2c9`
- Source SHA: `f8fa2c958464bf32dff59ce984bce73fd97c2599`
- Result: passed

Observed route-neutral check contexts:

- `branch_naming_validation`
- `route_neutral_closeout_validation`
- `route_aware_autonomy_validation`
- `exact_source_sha_validation`

## Target Fixture

The target route-neutral fixture is:

- `.octon/framework/assurance/runtime/_ops/fixtures/github-main-ruleset/target-route-neutral-branch-rules.json`

The full target ruleset candidate is:

- `target-route-neutral-main-ruleset-12881449.json`

The candidate preserves:

- active enforcement
- default-branch targeting
- deletion protection
- required status checks
- strict required status check policy
- non-fast-forward protection
- linear history
- bypass actor configuration

The candidate removes universal PR-required behavior by removing the
`pull_request` rule and replacing universal PR-oriented checks with the
observed route-neutral check contexts.

Review diff:

- `current-to-target-ruleset-12881449.diff`

## Rollback Procedure

If maintainers accept and apply the target ruleset, rollback is to re-apply the
preserved `current-live-main-ruleset-12881449.json` object for ruleset
`12881449`.

Rollback acceptance checks:

1. `gh api repos/jamesryancooper/octon/rulesets/12881449` matches the preserved
   rollback snapshot for rules and required checks.
2. `.octon/framework/assurance/runtime/_ops/scripts/validate-github-main-ruleset-alignment.sh --strict-live`
   passes with the expected `current-pr-required` posture.

## Maintainer Acceptance Gate

Do not mutate the live GitHub ruleset until a maintainer explicitly accepts:

- current live PR-required evidence
- passing shadow route-neutral run evidence
- target route-neutral fixture
- exact diff from the live ruleset object
- rollback snapshot and rollback procedure
- first hosted `branch-no-pr` landing procedure

## First Hosted No-PR Landing Procedure

After live target route-neutral validation passes, perform one small reversible
hosted `branch-no-pr` landing. The Change receipt must retain:

- provider ruleset ref
- pushed source branch
- exact source SHA validation refs
- `integration_method=fast-forward`
- rollback handle
- cleanup disposition
- `target_post_ref == landed_ref`
- `origin/main == landed_ref`

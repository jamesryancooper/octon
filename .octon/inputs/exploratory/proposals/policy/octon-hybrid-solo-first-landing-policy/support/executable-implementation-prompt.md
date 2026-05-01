# Executable Implementation Prompt

Implement the Octon-internal portion of the Hybrid Solo-First Landing Policy
proposal packet at:

`.octon/inputs/exploratory/proposals/policy/octon-hybrid-solo-first-landing-policy`

## Scope

Edit these promotion targets:

- `.octon/framework/product/contracts/default-work-unit.yml`
- `.octon/framework/product/contracts/default-work-unit.md`
- `.octon/framework/product/contracts/change-receipt-v1.schema.json`
- `.octon/framework/capabilities/runtime/skills/remediation/closeout-change/SKILL.md`
- `.octon/framework/capabilities/runtime/skills/remediation/closeout-change/references/phases.md`
- `.octon/framework/capabilities/runtime/skills/remediation/closeout-change/references/decisions.md`
- `.octon/framework/capabilities/runtime/skills/remediation/closeout-change/references/validation.md`
- `.octon/framework/capabilities/runtime/skills/remediation/closeout-change/references/safety.md`
- `.octon/framework/capabilities/runtime/skills/remediation/closeout-pr/SKILL.md`
- `.octon/framework/orchestration/runtime/workflows/meta/closeout/workflow.yml`
- `.octon/framework/orchestration/runtime/workflows/meta/closeout/README.md`
- `.octon/framework/orchestration/runtime/workflows/meta/closeout/stages/01-evaluate-context.md`
- `.octon/framework/orchestration/runtime/workflows/meta/closeout/stages/02-request-or-report.md`
- `.octon/framework/execution-roles/practices/standards/git-worktree-autonomy-contract.yml`
- `.octon/framework/execution-roles/_ops/scripts/git/git-branch-push.sh`
- `.octon/framework/execution-roles/_ops/scripts/git/git-branch-land.sh`
- `.octon/framework/execution-roles/_ops/scripts/git/git-branch-cleanup.sh`
- `.octon/framework/execution-roles/_ops/scripts/git/git-branch-hosted-preflight.sh`
- `.octon/framework/execution-roles/_ops/scripts/git/git-branch-land-hosted-no-pr.sh`
- `.octon/framework/execution-roles/_ops/scripts/git/git-required-checks-at-ref.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-change-closeout-lifecycle-alignment.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-default-work-unit-alignment.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-git-github-workflow-alignment.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-hosted-no-pr-landing.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-github-main-ruleset-alignment.sh`
- `.octon/framework/assurance/runtime/_ops/tests/test-change-closeout-lifecycle-alignment.sh`
- `.octon/framework/assurance/runtime/_ops/tests/test-default-work-unit-alignment.sh`
- `.octon/framework/assurance/runtime/_ops/tests/test-git-github-workflow-alignment.sh`
- `.octon/framework/assurance/runtime/_ops/tests/test-hosted-no-pr-landing.sh`

## Required Behavior

Implement hosted-capable `branch-no-pr` landing without opening PRs. Hosted
landing must require route-neutral provider rules, pushed source branch, source
SHA current with `origin/main`, exact-SHA validation, valid Change receipt,
rollback handle, fast-forward-only update, post-push remote verification, and
cleanup evidence.

If the live GitHub ruleset still requires PRs, hosted no-PR landing preflight
must fail clearly and return a blocker. Do not silently convert the route to
`branch-pr`; a PR may be opened only after route selection returns `branch-pr`
or the operator explicitly selects PR-backed publication.

## Validation

Run these validators before implementation closeout:

- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-policy-proposal.sh --package .octon/inputs/exploratory/proposals/policy/octon-hybrid-solo-first-landing-policy`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/policy/octon-hybrid-solo-first-landing-policy`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-default-work-unit-alignment.sh`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-change-closeout-lifecycle-alignment.sh`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-git-github-workflow-alignment.sh`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-hosted-no-pr-landing.sh`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-github-main-ruleset-alignment.sh`
- `bash .octon/framework/assurance/runtime/_ops/tests/test-hosted-no-pr-landing.sh`
- `git diff --check`

## Evidence And Receipts

Update `support/implementation-conformance-review.md` after implementation.
Update `support/post-implementation-drift-churn-review.md` after drift/churn
review. Retain validation evidence and rollback notes in the Change receipt.

## Rollback

Rollback is ordinary Git rollback of the implementation commits. Do not change
the live GitHub ruleset in this packet. The linked repo-local projection packet
must own that rollout after route-neutral checks are proven.

## Closeout Refusal Criteria

Refuse closeout if hosted no-PR landing can be falsely claimed from local-only
evidence, if the current PR-required ruleset does not produce a clear preflight
blocker, if PR metadata can appear in `branch-no-pr` receipts, if `branch-pr`
landing lacks PR merge evidence, or if required receipts remain missing.

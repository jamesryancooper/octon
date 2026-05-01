# Implementation Map

## Product Contracts

| Target | Change |
|---|---|
| `.octon/framework/product/contracts/default-work-unit.yml` | Add hosted no-PR landing requirements, provider-rule feasibility, exact-SHA validation, and remote `origin/main` evidence requirements. |
| `.octon/framework/product/contracts/default-work-unit.md` | Explain hybrid solo-first semantics, route-neutral protection, and fail-closed behavior when GitHub requires PRs. |
| `.octon/framework/product/contracts/change-receipt-v1.schema.json` | Add hosted landing evidence fields and `hosted-main-updated` publication status for `branch-no-pr`; preserve PR metadata bans. |

## Closeout Skills And Workflow

| Target | Change |
|---|---|
| `.octon/framework/capabilities/runtime/skills/remediation/closeout-change/SKILL.md` | Require hosted landing preflight before `branch-no-pr` `landed` or `cleaned`; report PR-required rulesets as blockers. |
| `.octon/framework/capabilities/runtime/skills/remediation/closeout-change/references/phases.md` | Add hosted no-PR preflight and post-push verification phase. |
| `.octon/framework/capabilities/runtime/skills/remediation/closeout-change/references/decisions.md` | Add decisions for provider-rule compatibility and route-neutral landing feasibility. |
| `.octon/framework/capabilities/runtime/skills/remediation/closeout-change/references/validation.md` | Require exact source SHA checks and remote target ref equality. |
| `.octon/framework/capabilities/runtime/skills/remediation/closeout-change/references/safety.md` | Add fail-closed protections for stale branches, missing checks, and PR-required rulesets. |
| `.octon/framework/capabilities/runtime/skills/remediation/closeout-pr/SKILL.md` | Preserve PR-only behavior and document that PRs are selected by route predicates, not branch existence. |
| `.octon/framework/orchestration/runtime/workflows/meta/closeout/workflow.yml` | Include hosted no-PR landing state and provider feasibility gate. |
| `.octon/framework/orchestration/runtime/workflows/meta/closeout/README.md` | Refresh generated workflow summary after the closeout done-gate change. |
| `.octon/framework/orchestration/runtime/workflows/meta/closeout/stages/01-evaluate-context.md` | Resolve GitHub ruleset compatibility and branch freshness during route evaluation. |
| `.octon/framework/orchestration/runtime/workflows/meta/closeout/stages/02-request-or-report.md` | Report blocked hosted no-PR landing without opening a PR unless `branch-pr` is selected. |

## Git Helpers

| Target | Change |
|---|---|
| `.octon/framework/execution-roles/practices/standards/git-worktree-autonomy-contract.yml` | Add hosted no-PR helper requirements and exact-SHA landing evidence. |
| `.octon/framework/execution-roles/_ops/scripts/git/git-branch-push.sh` | Emit branch ref evidence usable by no-PR hosted landing. |
| `.octon/framework/execution-roles/_ops/scripts/git/git-branch-land.sh` | Clarify local-only behavior or delegate hosted mode to the hosted landing helper. |
| `.octon/framework/execution-roles/_ops/scripts/git/git-branch-cleanup.sh` | Verify local and remote branch cleanup after hosted no-PR landing. |
| `.octon/framework/execution-roles/_ops/scripts/git/git-branch-hosted-preflight.sh` | New helper for ruleset, freshness, source ref, receipt, rollback, and check feasibility. |
| `.octon/framework/execution-roles/_ops/scripts/git/git-branch-land-hosted-no-pr.sh` | New helper for fast-forward-only hosted landing and post-push remote verification. |
| `.octon/framework/execution-roles/_ops/scripts/git/git-required-checks-at-ref.sh` | New helper for exact-SHA check status collection. |

## Assurance

| Target | Change |
|---|---|
| `.octon/framework/assurance/runtime/_ops/scripts/validate-change-closeout-lifecycle-alignment.sh` | Enforce hosted no-PR receipt semantics and remote target equality. |
| `.octon/framework/assurance/runtime/_ops/scripts/validate-default-work-unit-alignment.sh` | Validate policy vocabulary and provider feasibility requirements. |
| `.octon/framework/assurance/runtime/_ops/scripts/validate-git-github-workflow-alignment.sh` | Validate helper route guards and forbid PR mutation from no-PR helpers. |
| `.octon/framework/assurance/runtime/_ops/scripts/validate-hosted-no-pr-landing.sh` | New receipt and repository-state validator for hosted no-PR landings. |
| `.octon/framework/assurance/runtime/_ops/scripts/validate-github-main-ruleset-alignment.sh` | New validator that distinguishes current PR-required ruleset from target route-neutral ruleset. |
| `.octon/framework/assurance/runtime/_ops/tests/test-change-closeout-lifecycle-alignment.sh` | Add negative fixtures for false hosted landing claims. |
| `.octon/framework/assurance/runtime/_ops/tests/test-default-work-unit-alignment.sh` | Add hybrid route model assertions. |
| `.octon/framework/assurance/runtime/_ops/tests/test-git-github-workflow-alignment.sh` | Add helper route guard and no-PR PR-mutation negative controls. |
| `.octon/framework/assurance/runtime/_ops/tests/test-hosted-no-pr-landing.sh` | New tests for stale, missing check, missing receipt, local-only, PR metadata, and successful fast-forward fixtures. |

## Linked Repo-Local Projection

The linked projection packet must update `.github/**` workflows and the live
GitHub ruleset after this Octon-internal packet passes. It must not be folded
into this packet's promotion target list.

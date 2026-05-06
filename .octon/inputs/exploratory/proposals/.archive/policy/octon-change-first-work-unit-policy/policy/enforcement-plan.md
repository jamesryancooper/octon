# Enforcement Plan

## Validation Updates

Add `.octon/framework/assurance/runtime/_ops/scripts/validate-default-work-unit-alignment.sh`. It should fail authoritative policy, workflow, standard, skill, and ingress surfaces that define PRs, branches, GitHub, or Change Package as the product default work unit. It should also fail active authoritative Work Package terminology after cutover, except in historical archive material or explicit migration notes.

Validate that `.octon/framework/product/contracts/change-receipt-v1.schema.json` exists after promotion and supports all selected routes: direct-main, branch-only, PR-backed, and stage-only/escalated.

Validate that route-neutral `closeout-change` is the default closeout skill entry point and that `closeout-pr` is only invocable as the PR-backed subflow or by explicit PR context.

Update Git and GitHub alignment checks so they distinguish:

- direct-main Change;
- branch-only Change;
- PR-backed Change;
- stage-only or checkpointed Change.

Update closeout validation so PR metadata is optional unless the selected route is PR-backed, while Change intent, outcome, validation evidence, and rollback handle are always required.

Update skill and workflow manifest checks so GitHub publication skills are selected only after Change routing chooses a PR path.

Update documentation drift checks so user-facing and agent-facing instructions use Change-first language at policy boundaries and PR-specific language only inside GitHub implementation surfaces.

Update `validate-git-github-workflow-alignment.sh` so PR-first assertions move under PR-backed route fixtures only.

Update `validate-commit-pr-alignment.sh` so branch and PR checks are route-gated and direct-main commits can satisfy no-PR Change requirements.

Replace `validate-engagement-work-package-compiler.sh` with `validate-engagement-change-package-compiler.sh` so Change Package is the internal execution bundle and legacy Work Package compiler surfaces cannot remain active.

Update CI alignment wiring so `.github/workflows/alignment-check.yml` invokes the default-work-unit validator after promotion.

## Required Test Scenarios

Validation should cover these scenarios:

- low-risk solo Change on clean current `main` routes direct-to-main with local validation, commit receipt, and rollback handle;
- medium-risk or paused Change routes to branch without PR and preserves checkpoint or commit evidence;
- high-risk, protected, collaborative, externally reviewed, or user-requested publication Change routes to branch with PR;
- no-PR Change fails closeout when validation evidence or rollback handle is missing;
- PR-backed Change fails when PR metadata exists but Change intent, validation, or outcome evidence is absent;
- GitHub adapter files may remain PR-specific when they reference the canonical Change routing policy;
- Change Package schema and compiler fixtures pass only when Change Package is represented as the internal execution bundle for a Change;
- legacy Work Package schema, compiler, and active terminology fail after the cutover;
- old PR-first phrases fail in canonical policy, closeout, skill-routing, and ingress surfaces;
- PR-specific GitHub workflows pass when scoped to PR-backed route projection;
- `closeout-change` dispatches route-specific requirements before invoking any branch or PR helper;
- Change receipts validate for direct-main, branch-only, PR-backed, and stage-only/escalated fixtures.

## Acceptance Criteria

Promotion is complete when:

- the canonical policy exists under `.octon/framework/product/contracts/`;
- active Work Package schemas, compilers, policy names, and user-facing authoritative terminology have been renamed to Change Package without aliases or shims;
- registries expose the policy as the authoritative default work unit contract;
- Git and closeout standards reference the policy instead of owning product stance;
- implementation adapters keep PR mechanics but do not define PRs as the work unit;
- skill routing can select direct-main, branch-only, PR-backed, and stage-only Change paths;
- `closeout-change` is the default closeout entry point and produces route-neutral Change receipts;
- validators prove both PR-backed and no-PR Changes satisfy durable history and validation requirements;
- repo-local `.github/**` projections are covered by a linked repo-local proposal before `.github/**` implementation edits are claimed under proposal lifecycle;
- this proposal packet is either archived or superseded by the promoted authority.

# Executable Implementation Prompt

You are a senior Octon implementation engineer responsible for promoting the Change-first default work unit policy into durable Octon authority surfaces.

Implement the proposal packet at:

```text
.octon/inputs/exploratory/proposals/policy/octon-change-first-work-unit-policy/
```

Treat the proposal packet as non-authoritative implementation input. Durable behavior must land only in declared promotion targets, linked repo-local proposal targets, regenerated projections, validators, and retained evidence.

## Mission

Make Octon Change-first end to end:

1. The default work unit is a Change.
2. Pull Requests are optional publishing and review outputs.
3. Change Package is the internal runtime execution bundle for a Change.
4. Direct-to-main is allowed for low-risk solo Changes under explicit safety, validation, and rollback criteria.
5. Branches are isolation tools, not mandatory ceremony.
6. Review, validation, durable history, rollback, and closeout attach to the Change.
7. Routing distinguishes direct-main, branch-only, PR-backed, and stage-only/escalated Changes.
8. Work Package terminology is cut over completely before 1.0; no aliases or shims are part of the target state.

## Required Preflight

Before editing:

1. Read root `AGENTS.md` and `.octon/instance/ingress/AGENTS.md`.
2. Record the required execution profile receipt: `change_profile=atomic` unless a hard gate forces transitional, and `release_state=pre-1.0`.
3. Re-read this packet:
   - `proposal.yml`
   - `policy-proposal.yml`
   - `policy/decision.md`
   - `policy/routing-model.md`
   - `implementation/implementation-map.md`
   - `policy/policy-delta.md`
   - `policy/enforcement-plan.md`
   - `navigation/source-of-truth-map.md`
4. Confirm implementation is authorized from the packet's current lifecycle state. If not authorized, stop after reporting readiness.
5. Inspect live target state. At generation time, these targets are missing and must be created:
   - `.octon/framework/product/contracts/default-work-unit.md`
   - `.octon/framework/product/contracts/default-work-unit.yml`
   - `.octon/framework/product/contracts/change-receipt-v1.schema.json`
   - `.octon/framework/engine/runtime/spec/change-package-v1.schema.json`
   - `.octon/framework/constitution/contracts/runtime/change-package-v1.schema.json`
   - `.octon/framework/engine/runtime/spec/engagement-change-package-compiler-v1.md`
   - `.octon/framework/capabilities/runtime/skills/remediation/closeout-change/**`
   - `.octon/framework/assurance/runtime/_ops/scripts/validate-default-work-unit-alignment.sh`
   - `.octon/framework/assurance/runtime/_ops/tests/test-default-work-unit-alignment.sh`
   - `.octon/framework/assurance/runtime/_ops/scripts/validate-engagement-change-package-compiler.sh`
   - `.octon/framework/assurance/runtime/_ops/tests/test-engagement-change-package-compiler.sh`
6. Confirm `.github/**` is not a promotion target in this octon-internal packet. Create a linked `repo-local` proposal before editing `.github/**` under proposal lifecycle.

## Hard Boundaries

- Do not make proposal-local files runtime dependencies.
- Do not add `.github/**` paths to this packet's `promotion_targets`.
- Do not add Change policy text to root `AGENTS.md` or `CLAUDE.md`; they remain thin ingress adapters.
- Do not remove PR support.
- Do not preserve Work Package as active target-state terminology.
- Do not create compatibility aliases, shims, duplicate schemas, or parallel compiler names for Work Package.
- Do not hand-edit generated registries or projections when a canonical generator exists.
- Do not claim direct-to-main support unless validation, evidence, receipt, and rollback requirements pass without PR metadata.

## Workstream 1: Canonical Product Contracts

Create `.octon/framework/product/contracts/default-work-unit.md`.

It must define:

- Change as the default work unit;
- Pull Request as optional publication/review output;
- branch as isolation mechanism;
- Change Package as the compiled internal execution bundle;
- Work Package as deprecated pre-1.0 terminology with no active target-state alias or shim;
- Run Contract as execution authority for a run;
- direct-main, branch-only, PR-backed, and stage-only/escalated routes;
- durable history, validation, review, rollback, and closeout requirements.

Create `.octon/framework/product/contracts/default-work-unit.yml`.

It must expose machine-readable route semantics:

- route IDs: `direct-main`, `branch-no-pr`, `branch-pr`, `stage-only-escalate`;
- route input predicates;
- route precedence order;
- required evidence by route;
- required validation by route;
- PR-required predicates;
- branch-required predicates;
- direct-main eligibility predicates;
- fail-closed conditions.

Create `.octon/framework/product/contracts/change-receipt-v1.schema.json`.

It must validate route-neutral Change receipts containing:

- Change identity and selected route;
- intent and scope;
- touched paths or diff reference;
- validation evidence references;
- review evidence or waiver references;
- durable history reference;
- rollback handle;
- closeout outcome;
- remaining blockers.

Update registries and precedence:

- `.octon/framework/cognition/_meta/architecture/contract-registry.yml`
- `.octon/framework/constitution/contracts/registry.yml`
- `.octon/framework/constitution/precedence/normative.yml`

The default work unit contract must outrank Git, GitHub, branch, PR, Change Package adapter policy, and any legacy Work Package migration notes when semantics conflict.

## Workstream 2: Change Closeout And Routing

Update Git/worktree and closeout surfaces so route selection happens before branch or PR action:

- `.octon/framework/execution-roles/practices/standards/git-worktree-autonomy-contract.yml`
- `.octon/framework/orchestration/runtime/workflows/meta/closeout/workflow.yml`
- `.octon/framework/orchestration/runtime/workflows/meta/closeout/README.md`
- `.octon/framework/orchestration/runtime/workflows/meta/closeout/stages/01-evaluate-context.md`
- `.octon/framework/orchestration/runtime/workflows/meta/closeout/stages/02-request-or-report.md`
- `.octon/framework/orchestration/runtime/workflows/manifest.yml`
- `.octon/instance/ingress/AGENTS.md`
- `.octon/instance/ingress/manifest.yml`

Required behavior:

- direct-main eligible Changes close out without branch or PR metadata;
- branch-only Changes preserve isolation, continuation, validation, receipt, and rollback evidence without opening a PR;
- PR-backed Changes invoke PR publication/review mechanics only after route selection;
- stage-only/escalated Changes preserve blockers and next route conditions without claiming completion.

## Workstream 3: Skills And Commands

Create route-neutral `closeout-change` under:

```text
.octon/framework/capabilities/runtime/skills/remediation/closeout-change/
```

Required files:

- `SKILL.md`
- `references/phases.md`
- `references/decisions.md`
- `references/checkpoints.md`
- `references/io-contract.md`
- `references/safety.md`
- `references/validation.md`
- `references/dependencies.md`

`closeout-change` must:

- resolve or create Change identity;
- select one route from the default work unit contract;
- produce or update a Change receipt;
- delegate to `closeout-pr` only for PR-backed Changes;
- fail closed when route, validation, rollback, or evidence is ambiguous.

Update skill and command discovery:

- `.octon/framework/capabilities/runtime/skills/manifest.yml`
- `.octon/framework/capabilities/runtime/skills/registry.yml`
- `.octon/framework/capabilities/runtime/commands/alignment-check.md`
- `.octon/framework/capabilities/runtime/commands/manifest.yml`

Retarget PR-specific skills:

- `closeout-pr` remains PR-backed only and must require upstream Change route/receipt context.
- `resolve-pr-comments` remains PR-specific and must require existing PR-backed Change context.
- `provider-github-gates` remains GitHub-specific and must not imply hosted gates are required for no-PR Changes.

## Workstream 4: Git, GitHub, Adapters, And Capability Packs

Update Git helpers and contracts so they are route-specific:

- `git-wt-new.sh` is used only for branch routes.
- `git-pr-open.sh` is used only for `branch-pr`.
- `git-pr-ship.sh` is used only for PR-backed ready/automerge requests.
- `git-pr-cleanup.sh` remains PR-backed cleanup unless given route-neutral cleanup behavior.

Update these surfaces accordingly:

- `.octon/framework/execution-roles/_ops/scripts/git/git-wt-new.sh`
- `.octon/framework/execution-roles/_ops/scripts/git/git-pr-open.sh`
- `.octon/framework/execution-roles/_ops/scripts/git/git-pr-ship.sh`
- `.octon/framework/execution-roles/_ops/scripts/git/git-pr-cleanup.sh`
- `.octon/framework/execution-roles/practices/standards/commit-pr-standards.json`
- `.octon/framework/execution-roles/practices/standards/github-control-plane-contract.json`
- `.octon/framework/execution-roles/practices/standards/ai-gate-policy.json`
- `.octon/framework/execution-roles/practices/standards/ai-gate-findings.schema.json`
- `.octon/framework/capabilities/packs/git/manifest.yml`
- `.octon/framework/capabilities/packs/git/README.md`
- `.octon/instance/governance/capability-packs/git.yml`
- `.octon/instance/capabilities/runtime/packs/admissions/git.yml`
- `.octon/framework/engine/runtime/adapters/host/github-control-plane.yml`
- `.octon/framework/engine/runtime/adapters/host/repo-shell.yml`

GitHub remains a projection host for PR-backed Changes and must not mint default work unit authority.

## Workstream 5: Change Package Cutover

Complete the pre-1.0 Work Package to Change Package cutover.

Create or rename target-state representation language and validators in:

- `.octon/framework/engine/runtime/spec/change-package-v1.schema.json`
- `.octon/framework/constitution/contracts/runtime/change-package-v1.schema.json`
- `.octon/framework/engine/runtime/spec/engagement-change-package-compiler-v1.md`
- `.octon/framework/engine/runtime/spec/evidence-store-v1.md`
- `.octon/framework/engine/runtime/spec/mission-autonomy-runtime-v2.md`
- `.octon/framework/engine/runtime/spec/mission-runner-v1.md`
- `.octon/framework/engine/runtime/spec/mission-continuation-v1.md`
- `.octon/instance/governance/policies/engagement-change-package-compiler.yml`
- `.octon/instance/governance/policies/evidence-profiles.yml`
- `.octon/instance/governance/policies/preflight-evidence-lane.yml`
- `.octon/instance/governance/policies/branch-freshness.yml`
- `.octon/instance/governance/policies/risk-materiality.yml`
- `.octon/instance/governance/policies/mission-closeout.yml`
- `.octon/instance/governance/policies/autonomy-window.yml`
- `.octon/instance/governance/policies/mission-continuation.yml`
- `.octon/instance/governance/engagements/path-families.yml`

Delete or rename active legacy Work Package schema, compiler, policy, validator, path-family, fixture, manifest, and documentation references. Do not retain aliases, shims, compatibility paths, or duplicate schema families.

## Workstream 6: Practice Docs And Operator Surfaces

Update practice docs so they reference the canonical default work unit policy instead of owning product stance:

- `.octon/framework/execution-roles/practices/git-github-autonomy-workflow-v1.md`
- `.octon/framework/execution-roles/practices/pull-request-standards.md`
- `.octon/framework/execution-roles/practices/commits.md`
- `.octon/framework/execution-roles/practices/git-autonomy-playbook.md`
- `.octon/framework/execution-roles/practices/github-autonomy-runbook.md`
- `.octon/framework/execution-roles/practices/README.md`
- `.octon/framework/execution-roles/practices/operating-model.md`
- `.octon/framework/execution-roles/practices/daily-flow.md`
- `.octon/framework/execution-roles/practices/SHIPPING.md`
- `.octon/framework/engine/practices/release-runbook.md`
- `.octon/instance/bootstrap/START.md`
- `.octon/instance/bootstrap/scope.md`
- `.octon/instance/bootstrap/catalog.md`
- `.octon/instance/bootstrap/conventions.md`
- `.octon/framework/assurance/practices/complete.md`
- `.octon/framework/assurance/practices/session-exit.md`
- `.octon/framework/assurance/practices/standards/testing-strategy.md`
- `.octon/framework/assurance/practices/standards/security-and-privacy.md`

PR standards remain valid only for PR-backed Changes.

## Workstream 7: Validators And Fixtures

Create:

- `.octon/framework/assurance/runtime/_ops/scripts/validate-default-work-unit-alignment.sh`
- `.octon/framework/assurance/runtime/_ops/tests/test-default-work-unit-alignment.sh`

Update:

- `.octon/framework/assurance/runtime/_ops/scripts/validate-git-github-workflow-alignment.sh`
- `.octon/framework/assurance/runtime/_ops/tests/test-git-github-workflow-alignment.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-commit-pr-alignment.sh`
- `.octon/framework/assurance/governance/_ops/scripts/evaluate-pr-autonomy-policy.sh`
- `.octon/framework/engine/_ops/scripts/project-github-control-approval.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-execution-governance.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-operator-boot-surface.sh`
- `.octon/framework/assurance/runtime/_ops/tests/test-validate-operator-boot-surface.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-ingress-manifest-parity.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-bootstrap-ingress.sh`
- `.octon/framework/assurance/runtime/_ops/tests/test-validate-bootstrap-ingress.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-architecture-health.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-workflow-authority-derivation.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-projection-shell-boundaries.sh`
- `.octon/framework/assurance/runtime/contracts/alignment-profiles.yml`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-engagement-change-package-compiler.sh`
- `.octon/framework/assurance/runtime/_ops/tests/test-engagement-change-package-compiler.sh`
- `.octon/framework/assurance/evaluators/review-routing.yml`
- `.octon/framework/assurance/evaluators/adapters/openai-review.yml`
- `.octon/framework/assurance/evaluators/adapters/registry.yml`

Required fixture scenarios:

- low-risk direct-main Change passes without PR metadata;
- direct-main Change fails when validation, receipt, or rollback handle is missing;
- branch-only Change passes without PR metadata;
- PR-backed Change passes only with Change identity and PR projection metadata;
- stage-only/escalated Change records blockers and does not claim completion;
- Change Package fixtures pass only when represented as the internal execution bundle for a Change;
- active Work Package terminology fails outside historical archive or explicit migration notes;
- old PR-first default language fails in policy, closeout, skill routing, and ingress surfaces.

## Workstream 8: Repo-Local GitHub Projection Proposal

Create a linked `repo-local` proposal for `.github/**` alignment before editing `.github/**` under proposal lifecycle.

The linked proposal should cover at least:

- `.github/workflows/main-pr-first-guard.yml`
- `.github/workflows/main-push-safety.yml`
- `.github/workflows/commit-and-branch-standards.yml`
- `.github/workflows/pr-quality.yml`
- `.github/PULL_REQUEST_TEMPLATE.md`
- `.github/PULL_REQUEST_TEMPLATE/kaizen.md`
- `.github/PULL_REQUEST_TEMPLATE/orchestration-domain-implementation.md`
- `.github/workflows/pr-autonomy-policy.yml`
- `.github/workflows/pr-auto-merge.yml`
- `.github/workflows/pr-triage.yml`
- `.github/workflows/pr-clean-state-enforcer.yml`
- `.github/workflows/pr-stale-close.yml`
- `.github/workflows/ai-review-gate.yml`
- `.github/workflows/codex-pr-review.yml`
- `.github/workflows/alignment-check.yml`
- `.github/workflows/harness-self-containment.yml`
- mixed push/PR validation workflows listed in `implementation/implementation-map.md`.

After the linked proposal exists and implementation scope authorizes repo-local edits, align `.github/**` so direct-main push validation works without PR metadata and PR workflows remain scoped to PR-backed Changes.

## Validation Commands

Run at minimum:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-default-work-unit-alignment.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-git-github-workflow-alignment.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-commit-pr-alignment.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-engagement-change-package-compiler.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-operator-boot-surface.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-ingress-manifest-parity.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-bootstrap-ingress.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-execution-governance.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-workflow-authority-derivation.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-projection-shell-boundaries.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-health.sh
bash .octon/framework/capabilities/runtime/skills/_ops/scripts/validate-skills.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/policy/octon-change-first-work-unit-policy --skip-registry-check
bash .octon/framework/assurance/runtime/_ops/scripts/validate-policy-proposal.sh --package .octon/inputs/exploratory/proposals/policy/octon-change-first-work-unit-policy
```

Also run the shell tests for any validator you create or modify.

If `.github/**` is implemented through a linked repo-local proposal, run the relevant GitHub workflow validators and alignment checks after those edits.

## Evidence Plan

Retain implementation evidence with:

- selected Change route and rationale;
- changed target list grouped by workstream;
- validation command outputs or summaries;
- fixture scenario results;
- generated proposal registry status if regenerated;
- linked repo-local proposal path for `.github/**`, if created;
- rollback instructions for each workstream;
- unresolved blockers or explicit deferrals.

Do not store evidence only in PR bodies. PR metadata may project evidence for PR-backed Changes, but the Change receipt remains the durable evidence unit.

## Post-Implementation Gate Requirements

Before claiming implementation closeout or archive eligibility:

- write `support/implementation-conformance-review.md` with `verdict: pass`;
- write `support/post-implementation-drift-churn-review.md` with `verdict: pass`;
- run `validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/policy/octon-change-first-work-unit-policy`;
- run `validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/policy/octon-change-first-work-unit-policy`;
- refuse closeout or archive if either receipt is missing, failing, incomplete, or records unresolved blockers.

The executable implementation prompt must cover every declared promotion target. Treat this as the full target checklist:

- `.octon/framework/product/contracts/default-work-unit.md`
- `.octon/framework/product/contracts/default-work-unit.yml`
- `.octon/framework/product/contracts/change-receipt-v1.schema.json`
- `.octon/framework/cognition/_meta/architecture/contract-registry.yml`
- `.octon/framework/constitution/contracts/registry.yml`
- `.octon/framework/constitution/precedence/normative.yml`
- `.octon/instance/ingress/AGENTS.md`
- `.octon/instance/ingress/manifest.yml`
- `.octon/framework/execution-roles/practices/standards/git-worktree-autonomy-contract.yml`
- `.octon/framework/execution-roles/practices/standards/commit-pr-standards.json`
- `.octon/framework/execution-roles/practices/standards/github-control-plane-contract.json`
- `.octon/framework/execution-roles/practices/standards/ai-gate-policy.json`
- `.octon/framework/execution-roles/practices/standards/ai-gate-findings.schema.json`
- `.octon/framework/execution-roles/practices/git-github-autonomy-workflow-v1.md`
- `.octon/framework/execution-roles/practices/pull-request-standards.md`
- `.octon/framework/execution-roles/practices/commits.md`
- `.octon/framework/execution-roles/practices/git-autonomy-playbook.md`
- `.octon/framework/execution-roles/practices/github-autonomy-runbook.md`
- `.octon/framework/execution-roles/practices/README.md`
- `.octon/framework/execution-roles/practices/operating-model.md`
- `.octon/framework/execution-roles/practices/daily-flow.md`
- `.octon/framework/execution-roles/practices/SHIPPING.md`
- `.octon/framework/engine/practices/release-runbook.md`
- `.octon/framework/execution-roles/_ops/scripts/git/git-wt-new.sh`
- `.octon/framework/execution-roles/_ops/scripts/git/git-pr-open.sh`
- `.octon/framework/execution-roles/_ops/scripts/git/git-pr-ship.sh`
- `.octon/framework/execution-roles/_ops/scripts/git/git-pr-cleanup.sh`
- `.octon/framework/orchestration/runtime/workflows/meta/closeout/workflow.yml`
- `.octon/framework/orchestration/runtime/workflows/meta/closeout/README.md`
- `.octon/framework/orchestration/runtime/workflows/meta/closeout/stages/01-evaluate-context.md`
- `.octon/framework/orchestration/runtime/workflows/meta/closeout/stages/02-request-or-report.md`
- `.octon/framework/orchestration/runtime/workflows/manifest.yml`
- `.octon/framework/capabilities/runtime/skills/manifest.yml`
- `.octon/framework/capabilities/runtime/skills/registry.yml`
- `.octon/framework/capabilities/runtime/skills/remediation/closeout-change/SKILL.md`
- `.octon/framework/capabilities/runtime/skills/remediation/closeout-change/references/phases.md`
- `.octon/framework/capabilities/runtime/skills/remediation/closeout-change/references/decisions.md`
- `.octon/framework/capabilities/runtime/skills/remediation/closeout-change/references/checkpoints.md`
- `.octon/framework/capabilities/runtime/skills/remediation/closeout-change/references/io-contract.md`
- `.octon/framework/capabilities/runtime/skills/remediation/closeout-change/references/safety.md`
- `.octon/framework/capabilities/runtime/skills/remediation/closeout-change/references/validation.md`
- `.octon/framework/capabilities/runtime/skills/remediation/closeout-change/references/dependencies.md`
- `.octon/framework/capabilities/runtime/skills/remediation/closeout-pr/SKILL.md`
- `.octon/framework/capabilities/runtime/skills/remediation/closeout-pr/references/phases.md`
- `.octon/framework/capabilities/runtime/skills/remediation/closeout-pr/references/decisions.md`
- `.octon/framework/capabilities/runtime/skills/remediation/closeout-pr/references/checkpoints.md`
- `.octon/framework/capabilities/runtime/skills/remediation/closeout-pr/references/io-contract.md`
- `.octon/framework/capabilities/runtime/skills/remediation/closeout-pr/references/safety.md`
- `.octon/framework/capabilities/runtime/skills/remediation/closeout-pr/references/validation.md`
- `.octon/framework/capabilities/runtime/skills/remediation/resolve-pr-comments/SKILL.md`
- `.octon/framework/capabilities/runtime/skills/platforms/provider-github-gates/SKILL.md`
- `.octon/framework/capabilities/runtime/skills/platforms/provider-github-gates/references/phases.md`
- `.octon/framework/capabilities/runtime/skills/platforms/provider-github-gates/references/decisions.md`
- `.octon/framework/capabilities/runtime/skills/platforms/provider-github-gates/references/safety.md`
- `.octon/framework/capabilities/runtime/skills/platforms/provider-github-gates/references/validation.md`
- `.octon/framework/capabilities/packs/git/manifest.yml`
- `.octon/framework/capabilities/packs/git/README.md`
- `.octon/instance/governance/capability-packs/git.yml`
- `.octon/instance/capabilities/runtime/packs/admissions/git.yml`
- `.octon/framework/engine/runtime/adapters/host/github-control-plane.yml`
- `.octon/framework/engine/runtime/adapters/host/repo-shell.yml`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-default-work-unit-alignment.sh`
- `.octon/framework/assurance/runtime/_ops/tests/test-default-work-unit-alignment.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-git-github-workflow-alignment.sh`
- `.octon/framework/assurance/runtime/_ops/tests/test-git-github-workflow-alignment.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-commit-pr-alignment.sh`
- `.octon/framework/assurance/governance/_ops/scripts/evaluate-pr-autonomy-policy.sh`
- `.octon/framework/engine/_ops/scripts/project-github-control-approval.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-execution-governance.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-operator-boot-surface.sh`
- `.octon/framework/assurance/runtime/_ops/tests/test-validate-operator-boot-surface.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-ingress-manifest-parity.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-bootstrap-ingress.sh`
- `.octon/framework/assurance/runtime/_ops/tests/test-validate-bootstrap-ingress.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-architecture-health.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-workflow-authority-derivation.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-projection-shell-boundaries.sh`
- `.octon/framework/assurance/runtime/contracts/alignment-profiles.yml`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-engagement-change-package-compiler.sh`
- `.octon/framework/assurance/runtime/_ops/tests/test-engagement-change-package-compiler.sh`
- `.octon/framework/assurance/practices/complete.md`
- `.octon/framework/assurance/practices/session-exit.md`
- `.octon/framework/assurance/practices/standards/testing-strategy.md`
- `.octon/framework/assurance/practices/standards/security-and-privacy.md`
- `.octon/framework/assurance/evaluators/review-routing.yml`
- `.octon/framework/assurance/evaluators/adapters/openai-review.yml`
- `.octon/framework/assurance/evaluators/adapters/registry.yml`
- `.octon/framework/constitution/contracts/runtime/change-package-v1.schema.json`
- `.octon/framework/engine/runtime/spec/change-package-v1.schema.json`
- `.octon/framework/engine/runtime/spec/engagement-change-package-compiler-v1.md`
- `.octon/framework/engine/runtime/spec/evidence-store-v1.md`
- `.octon/framework/engine/runtime/spec/mission-autonomy-runtime-v2.md`
- `.octon/framework/engine/runtime/spec/mission-runner-v1.md`
- `.octon/framework/engine/runtime/spec/mission-continuation-v1.md`
- `.octon/instance/governance/policies/engagement-change-package-compiler.yml`
- `.octon/instance/governance/policies/evidence-profiles.yml`
- `.octon/instance/governance/policies/preflight-evidence-lane.yml`
- `.octon/instance/governance/policies/branch-freshness.yml`
- `.octon/instance/governance/policies/risk-materiality.yml`
- `.octon/instance/governance/policies/mission-closeout.yml`
- `.octon/instance/governance/policies/autonomy-window.yml`
- `.octon/instance/governance/policies/mission-continuation.yml`
- `.octon/instance/governance/engagements/path-families.yml`
- `.octon/instance/bootstrap/START.md`
- `.octon/instance/bootstrap/scope.md`
- `.octon/instance/bootstrap/catalog.md`
- `.octon/instance/bootstrap/conventions.md`
- `.octon/framework/capabilities/runtime/commands/alignment-check.md`
- `.octon/framework/capabilities/runtime/commands/manifest.yml`

## Rollback Posture

The preferred rollback is commit-level revert of the atomic implementation branch.

Additional rollback expectations:

- new policy contracts can be removed if promotion is rejected before downstream adoption;
- the Change Package cutover should be atomic; rollback is a commit-level revert rather than a compatibility shim;
- validators must fail closed but should be revertible independently;
- `closeout-change` can be disabled in skill routing while retaining PR-backed `closeout-pr`;
- `.github/**` changes must be rollback-scoped by the linked repo-local proposal.

## Terminal Criteria

The implementation is complete only when:

- canonical default work unit and Change receipt contracts exist;
- registries expose the default work unit policy;
- route-neutral `closeout-change` is the default closeout entry point;
- `closeout-pr` is PR-backed only;
- Git/worktree contracts route direct-main, branch-only, PR-backed, and stage-only/escalated Changes;
- Change Package is documented and validated as the internal execution bundle for a Change;
- direct-main no-PR Changes can validate, commit, receipt, close out, and roll back without PR metadata;
- branch-only Changes can complete or checkpoint without opening a PR;
- PR-backed Changes carry Change identity and evidence;
- validators fail if PRs, branches, GitHub, or Change Package are reintroduced as the product default work unit;
- validators fail active Work Package terminology outside historical archive or explicit migration notes;
- `.github/**` alignment is handled through a linked repo-local proposal before repo-local workflow edits are claimed;
- no canonical target depends on this proposal packet path.

## Delegation Boundary

No delegation is pre-authorized by this prompt. If the operator explicitly authorizes delegation, split only along disjoint write scopes:

- product contracts and registries;
- closeout workflow and skills;
- validators and fixtures;
- Change Package cutover;
- practice docs;
- linked repo-local `.github/**` proposal and implementation.

Each delegated worker must avoid reverting other workers' changes and must report changed paths, validation run, and blockers.

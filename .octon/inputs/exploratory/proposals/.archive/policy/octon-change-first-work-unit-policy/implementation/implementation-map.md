# Implementation Map

## Status

This is the execution-grade alignment inventory for the Change-first default work unit policy.

Priority legend:

- P0: required to make the policy coherent;
- P1: required for safe execution paths;
- P2: required for agent and operator clarity;
- P3: cleanup, historical, or narrow adapter alignment.

Role legend:

- owns policy: defines canonical Change-first semantics;
- references policy: must defer to the canonical policy and avoid restating it;
- implementation-specific: may stay PR, branch, GitHub, or Change Package specific when selected by the policy. Legacy Work Package terminology is not a target-state implementation surface.

## Proposal Boundary

This packet is `octon-internal`, so `proposal.yml` promotion targets are limited to `.octon/**` by the proposal standard.

Repo-local host projections under `.github/**` are still implementation-affecting artifacts and are listed here. They must not be added to this octon-internal proposal manifest. Create a linked `repo-local` proposal before `.github/**` edits are claimed under proposal lifecycle.

Root `AGENTS.md` and `CLAUDE.md` are also repo-local adapters. They should remain byte-parity or symlink adapters to `.octon/instance/ingress/AGENTS.md`; do not add Change policy text to them.

## Canonical Policy And Registry Targets

| Artifact | Current assumption | Required change | Role | Priority and rationale |
|---|---|---|---|---|
| `.octon/framework/product/contracts/default-work-unit.md` | Missing. No product-level default work unit contract exists. | Create the human-readable canonical policy: Change is the default work unit; PRs are optional outputs; branches are isolation tools; Change Package is the compiled internal execution bundle. Work Package is deprecated terminology. | owns policy | P0: without this, downstream files keep inventing local policy. |
| `.octon/framework/product/contracts/default-work-unit.yml` | Missing. No machine-readable route contract exists. | Create route IDs, input predicates, precedence, evidence requirements, gate requirements, and fail-closed conditions from `policy/routing-model.md`. | owns policy | P0: workflows and validators need structured semantics. |
| `.octon/framework/product/contracts/change-receipt-v1.schema.json` | Missing. No route-neutral Change receipt schema exists. | Create a schema for Change identity, selected route, intent, scope, validation evidence, review evidence or waiver, durable history, rollback handle, closeout outcome, and blockers. | owns policy | P0: no-PR Changes need durable evidence without PR metadata. |
| `.octon/framework/cognition/_meta/architecture/contract-registry.yml` | Architecture registry has no default-work-unit contract family. | Register the product contract and route downstream Git, closeout, Change Package, and host projection surfaces to it. | references policy | P0: discoverability and topology depend on this registry. |
| `.octon/framework/constitution/contracts/registry.yml` | Runtime contracts expose Work Package but not Change as the product work unit. | Add the default work unit contract, replace Work Package contract names with Change Package contract names, and register Change Package as the internal execution-bundle contract. | references policy | P0: constitutional contract discovery must not preserve the old vocabulary. |
| `.octon/framework/constitution/precedence/normative.yml` | Normative precedence does not name the default work unit policy. | Add precedence for the default work unit contract above Git, GitHub, branch, PR, Change Package adapter policies, and any legacy Work Package migration notes. | references policy | P0: conflict resolution must favor Change-first semantics. |

## Change Package Runtime Cutover

| Artifact | Current assumption | Required change | Role | Priority and rationale |
|---|---|---|---|---|
| `.octon/framework/engine/runtime/spec/change-package-v1.schema.json` | Missing target-state schema. Current runtime schema is named `work-package-v1`. | Rename the runtime schema to `change-package-v1`, update schema IDs, titles, examples, references, and fixtures, and remove the old active Work Package schema path. | implementation-specific | P0: the internal bundle name must align before 1.0. |
| `.octon/framework/constitution/contracts/runtime/change-package-v1.schema.json` | Missing target-state constitutional schema. Current constitutional schema is named `work-package-v1`. | Rename the constitutional runtime schema to `change-package-v1`, update registry references, and remove the old active Work Package schema path. | implementation-specific | P0: constitutional authority must not preserve the old vocabulary. |
| `.octon/framework/engine/runtime/spec/engagement-change-package-compiler-v1.md` | Current compiler is named `engagement-work-package-compiler-v1`. | Rename the compiler spec to Change Package, update compiler vocabulary, examples, generated artifact names, and consumer references. | implementation-specific | P0: execution preparation should compile a Change Package, not a Work Package. |
| `.octon/instance/governance/policies/engagement-change-package-compiler.yml` | Current governance policy is named `engagement-work-package-compiler.yml`. | Rename the policy and all active references so readiness gates prepare a Change Package for a Change. Do not retain a Work Package alias policy. | references policy | P0: governance admission must use the 1.0 taxonomy. |
| `.octon/framework/assurance/runtime/_ops/scripts/validate-engagement-change-package-compiler.sh` and `.octon/framework/assurance/runtime/_ops/tests/test-engagement-change-package-compiler.sh` | Current validators assert Work Package compiler readiness. | Rename the validator and tests, update fixtures, and add failures for active Work Package compiler terminology or stale paths. | implementation-specific | P0: validation must enforce the complete cutover. |
| Legacy `work-package` schema, compiler, policy, validator, fixture, and manifest references | Active runtime surfaces currently use Work Package names. | Delete or rename active Work Package targets during promotion. Do not leave aliases, shims, duplicate manifests, compatibility paths, or parallel schema names. | implementation-specific | P0: partial migration would preserve the confusion the cutover is meant to remove. |
| `.octon/instance/governance/engagements/path-families.yml` | Path families are named `work-package-*`. | Rename path-family identifiers to `change-package-*` and update consumers in the same implementation pass. | implementation-specific | P1: evidence routing should not reintroduce old terminology. |
| `.octon/instance/governance/policies/evidence-profiles.yml` | Evidence profile selection is phrased as Work Package readiness. | Reword policy-boundary language to Change evidence profile selection represented through Change Package. | references policy | P1: evidence must attach to Change and use the target runtime bundle name. |
| `.octon/instance/governance/policies/preflight-evidence-lane.yml` | Preflight evidence keeps Work Package stage-only. | Clarify stage-only applies to a Change represented by a Change Package or checkpoint. | references policy | P1: no-PR and stage-only semantics need consistent wording. |
| `.octon/instance/governance/policies/autonomy-window.yml` and `.octon/instance/governance/policies/mission-continuation.yml` | Autonomy and continuation require active Work Packages. | Define that requirement as active Change Package state for a Change. | references policy | P1: mission runtime should not retain old work-unit vocabulary. |
| `.octon/framework/engine/runtime/spec/evidence-store-v1.md`, `.octon/framework/engine/runtime/spec/mission-autonomy-runtime-v2.md`, `.octon/framework/engine/runtime/spec/mission-runner-v1.md`, and `.octon/framework/engine/runtime/spec/mission-continuation-v1.md` | Runtime docs consume Work Package state. | Replace active Work Package terminology with Change Package terminology and ensure receipts, closeout, and evidence are described as Change-scoped. | references policy | P1: runtime readers need one coherent 1.0 vocabulary. |
| `.octon/instance/bootstrap/START.md`, `.octon/instance/bootstrap/scope.md`, `.octon/instance/bootstrap/catalog.md`, `.octon/instance/bootstrap/conventions.md` | Bootstrap orientation teaches Engagement / Project Profile / Work Package. | Teach Change as the product work unit and Change Package as the Safe Start internal execution bundle. | references policy | P2: user and agent onboarding should match product stance. |

## Git, Branch, PR, And Closeout Contracts

| Artifact | Current assumption | Required change | Role | Priority and rationale |
|---|---|---|---|---|
| `.octon/framework/execution-roles/practices/standards/git-worktree-autonomy-contract.yml` | Says one branch worktree per task or PR, same branch and PR for task life, and closeout opens a draft PR. | Replace PR-first closeout with Change route selection. Keep worktree and PR mechanics only for branch-only and PR-backed routes. Add direct-main and stage-only contexts. | references policy | P0: this is the named branch/PR closeout authority today. |
| `.octon/framework/execution-roles/practices/git-github-autonomy-workflow-v1.md` | Central overview says main remains PR-first and branch worktree is default execution unit. | Reframe as Git/GitHub projection workflow selected by Change routing. Direct-main and branch-only must be first-class routes. | references policy | P0: current overview directly conflicts with Change-first. |
| `.octon/framework/orchestration/runtime/workflows/meta/closeout/workflow.yml` | Closeout resolves branch and PR context from Git/worktree contract. | Rename closeout intent to Change closeout and route through default work unit policy before resolving Git/PR-specific context. | references policy | P0: closeout is where users ask to finish work. |
| `.octon/framework/orchestration/runtime/workflows/meta/closeout/stages/01-evaluate-context.md` | Context states are main needing branch, branch no PR, draft PR, ready PR, blocked. | Add direct-main eligible, branch-only completion, PR-backed completion, and stage-only escalation states. | references policy | P0: route selection must be operational, not prose-only. |
| `.octon/framework/orchestration/runtime/workflows/meta/closeout/stages/02-request-or-report.md` and closeout `README.md` | Prompts are branch/PR closeout prompts. | Prompt for selected Change route and only mention PR when PR-backed route is chosen. | references policy | P1: prevents PR prompting from remaining the default UX. |
| `.octon/instance/ingress/AGENTS.md` and `.octon/instance/ingress/manifest.yml` | Ingress points to branch/PR closeout workflow and Git worktree contract. | Rename pointer language to Change closeout and include the default work unit policy as the first closeout policy reference. | references policy | P1: ingress should not own policy but must point to the right owner. |
| Root `AGENTS.md` and `CLAUDE.md` adapters | Must remain thin parity adapters. | Do not add policy text; update only if adapter parity requires it after ingress changes. | implementation-specific | P2: prevents root adapters from becoming shadow policy. |

## Execution Role Practice Documents

| Artifact | Current assumption | Required change | Role | Priority and rationale |
|---|---|---|---|---|
| `.octon/framework/execution-roles/practices/pull-request-standards.md` | Defines quality standards as if PRs are the normal review unit. | Scope to PR-backed Changes. Require PR bodies to carry Change receipt fields, validation, risk, and rollback references. | implementation-specific | P1: PR rules remain useful but must not own default work unit policy. |
| `.octon/framework/execution-roles/practices/commits.md` | Commit standards emphasize PR-time branch and commit checks. | Add direct-main and branch-only commit requirements, including receipt and rollback requirements for no-PR Changes. | references policy | P1: no-PR Changes need durable history standards. |
| `.octon/framework/execution-roles/practices/standards/commit-pr-standards.json` | Machine contract is commit and branch naming plus PR validation. | Add route-aware fields or rename scope to commit/change/branch/PR standards. Branch naming applies only when branch route is selected. | references policy | P1: machine checks must not require branches for direct-main. |
| `.octon/framework/execution-roles/practices/github-autonomy-runbook.md` | Runbook assumes PR-first main and PR autonomy lanes. | Reframe as GitHub adapter runbook for PR-backed Changes, release PRs, and hosted gate projections only. | implementation-specific | P1: GitHub can remain rich, but only after routing selects it. |
| `.octon/framework/execution-roles/practices/git-autonomy-playbook.md` | Playbook sequences worktrees and PRs. | Add route selection before worktree creation; keep multi-worktree sequencing for branch-only and PR-backed Changes. | references policy | P1: branch creation must become conditional. |
| `.octon/framework/execution-roles/practices/operating-model.md` and `.octon/framework/execution-roles/practices/daily-flow.md` | User/operator flow centers PR review. | Recast solo-developer daily flow around Changes, with PR review as one queue type. | references policy | P2: product experience should match solo-developer stance. |
| `.octon/framework/execution-roles/practices/SHIPPING.md` | Shipping flow starts from merged PR. | Add direct-main and branch-only shipping paths, while keeping PR-merged path for PR-backed Changes. | references policy | P2: shipping cannot require a PR for every landed Change. |
| `.octon/framework/execution-roles/practices/README.md` and `.octon/framework/execution-roles/practices/start-here.md` | Index points users into PR standards and GitHub workflow as central. | Add default work unit policy to entry points and label PR docs as PR-backed route docs. | references policy | P2: discovery must not steer to PR-first by default. |
| `.octon/framework/engine/practices/release-runbook.md` | Release flow uses release-please PRs. | Keep release PR behavior, but mark it as an explicitly PR-backed release route. | implementation-specific | P3: release automation can remain PR-native. |
| `.octon/framework/scaffolding/practices/prompts/2026-04-06-target-state-closure-provable-closure.prompt.md`, `2026-04-07-octon-two-packet-final-state-execution.prompt.md`, `2026-04-09-octon-bounded-uec-proposal-packet-full-implementation.prompt.md`, `2026-04-11-host-tool-provisioning-and-multi-repo-portability-full-implementation.prompt.md`, `2026-04-11-octon-selected-harness-concepts-integration-packet-execution.prompt.md`, `2026-04-17-git-github-autonomous-workflow-hardening-full-implementation.prompt.md`, and `2026-04-17-git-github-workflow-ssot-drift-hardening.prompt.md` | Historical implementation prompts contain one-branch or PR-first instructions. | Mark as historical prompts or update reusable instructions so new prompt generation routes through Change-first policy. | implementation-specific | P3: avoid old prompts re-seeding PR-first behavior. |

## Git Helpers, Host Adapters, And Capability Packs

| Artifact | Current assumption | Required change | Role | Priority and rationale |
|---|---|---|---|---|
| `.octon/framework/execution-roles/_ops/scripts/git/git-wt-new.sh` | Creates a branch worktree as the normal setup helper. | Keep helper, but require callers to invoke it only after `branch-no-pr` or `branch-pr` route selection. | implementation-specific | P1: branch helpers should not imply branch default. |
| `.octon/framework/execution-roles/_ops/scripts/git/git-pr-open.sh` | Commits, pushes, populates PR template, and always opens draft PR. | Keep as PR-backed route helper. Add preflight guard or documentation requiring selected route `branch-pr`. | implementation-specific | P1: PR creation must become an output decision. |
| `.octon/framework/execution-roles/_ops/scripts/git/git-pr-ship.sh` | Reports or requests ready/automerge for an existing PR. | Keep PR-specific. Require Change receipt linkage before ready/automerge requests. | implementation-specific | P1: PR status must attach to Change evidence. |
| `.octon/framework/execution-roles/_ops/scripts/git/git-pr-cleanup.sh` and Git autonomy hooks | Cleanup assumes PR closure branches. | Keep for PR-backed route; add branch-only cleanup or route-neutral cleanup language if reused outside PRs. | implementation-specific | P2: cleanup should not be the only post-change convergence path. |
| `.octon/framework/capabilities/packs/git/manifest.yml`, `.octon/framework/capabilities/packs/git/README.md`, `.octon/instance/governance/capability-packs/git.yml`, and `.octon/instance/capabilities/runtime/packs/admissions/git.yml` | Git pack covers branch, commit, rollback mutation. | Add route-aware git mutation language: direct-main commit, branch-only commit/checkpoint, PR-backed publication. | references policy | P1: capability admission must support all Change routes. |
| `.octon/framework/engine/runtime/adapters/host/github-control-plane.yml` | Describes canonical PR-autonomy lane projection. | Reframe GitHub as projection host for PR-backed Changes. It may not project default work unit authority. | implementation-specific | P1: GitHub remains non-authoritative. |
| `.octon/framework/engine/runtime/adapters/host/repo-shell.yml` | Local shell adapter mentions branch freshness signals. | Add local no-PR validation and receipt projection expectations for direct-main and branch-only Changes. | implementation-specific | P1: no-PR Changes need a local adapter path. |

## Skills And Commands

| Artifact | Current assumption | Required change | Role | Priority and rationale |
|---|---|---|---|---|
| `.octon/framework/capabilities/runtime/skills/manifest.yml` and `.octon/framework/capabilities/runtime/skills/registry.yml` | Routes include `closeout-pr`, `resolve-pr-comments`, and `provider-github-gates` as PR/GitHub skills. | Add route-neutral `closeout-change` discovery first. Keep `closeout-pr` discoverable only as the PR-backed subflow selected by Change routing. | references policy | P0: skill routing is how agents enact the policy. |
| `.octon/framework/capabilities/runtime/skills/remediation/closeout-change/SKILL.md` and its `references/phases.md`, `references/decisions.md`, `references/checkpoints.md`, `references/io-contract.md`, `references/safety.md`, `references/validation.md`, `references/dependencies.md` | Missing. No skill owns route-neutral Change closeout. | Create the route-neutral closeout skill. It must resolve Change identity, select `direct-main`, `branch-no-pr`, `branch-pr`, or `stage-only-escalate`, produce a Change receipt, and delegate PR-specific work to `closeout-pr`. | references policy | P0: this is the implementation entry point that prevents PR closeout from remaining default. |
| `.octon/framework/capabilities/runtime/skills/remediation/closeout-pr/SKILL.md` and its `references/phases.md`, `references/decisions.md`, `references/checkpoints.md`, `references/io-contract.md`, `references/safety.md`, `references/validation.md` | Skill is the autonomous loop for one branch worktree through PR merge. | Scope it to PR-backed Changes only and require an upstream Change route and receipt reference. | implementation-specific | P0: current closeout skill would keep opening PRs if invoked directly. |
| `.octon/framework/capabilities/runtime/skills/remediation/resolve-pr-comments/SKILL.md` | Skill resolves PR review comments. | Keep PR-specific and require existing PR-backed Change context. | implementation-specific | P2: valid PR adapter, not default route. |
| `.octon/framework/capabilities/runtime/skills/platforms/provider-github-gates/SKILL.md` and its references | Provider gate skill requires PR context. | Keep PR-specific, but make it explicit that local gate evidence satisfies no-PR Changes. | implementation-specific | P1: hosted gates should not be the only gate path. |
| `.octon/framework/capabilities/runtime/commands/alignment-check.md` and `.octon/framework/capabilities/runtime/commands/manifest.yml` | Alignment check advertises commit/PR validator. | Add default-work-unit validator and route-aware Git/GitHub validators to the command surface. | references policy | P1: implementation needs one command to prove alignment. |

## Assurance And Validators

| Artifact | Current assumption | Required change | Role | Priority and rationale |
|---|---|---|---|---|
| `.octon/framework/assurance/runtime/_ops/scripts/validate-default-work-unit-alignment.sh` and `.octon/framework/assurance/runtime/_ops/tests/test-default-work-unit-alignment.sh` | Missing. | Create validator that fails PR-as-default, branch-as-default, Change-Package-as-product-default language, and active Work Package terminology outside historical archive or explicit migration notes. | references policy | P0: prevents regression into PR-first or pre-cutover vocabulary. |
| `.octon/framework/assurance/runtime/_ops/scripts/validate-git-github-workflow-alignment.sh` and `test-git-github-workflow-alignment.sh` | Asserts draft-first PR, same branch/same PR, branch/PR closeout, and PR workflows. | Rework around Change routes. Keep PR assertions only for PR-backed route fixtures. | implementation-specific | P0: existing validator currently enforces the old stance. |
| `.octon/framework/assurance/runtime/_ops/scripts/validate-commit-pr-alignment.sh` | Validates commit, branch, PR template, and PR workflows together. | Split or route-gate checks so direct-main does not require branch/PR artifacts, while PR-backed Changes still require them. | implementation-specific | P1: no-PR Change validation must pass. |
| `.octon/framework/assurance/governance/_ops/scripts/evaluate-pr-autonomy-policy.sh` | Evaluates PR title, body, changed files, branch class, and autonomy lane. | Keep PR-specific, but require PR-backed Change identity and prevent this evaluator from being used as default Change completion proof. | implementation-specific | P1: this is the canonical PR autonomy classifier. |
| `.octon/framework/engine/_ops/scripts/project-github-control-approval.sh` | Projects approvals to GitHub PR target IDs and checks. | Keep GitHub projection behavior, but support or document generic Change approval sources upstream of PR projection. | implementation-specific | P1: approval projection must not mint work-unit authority. |
| `.octon/framework/assurance/runtime/_ops/scripts/validate-execution-governance.sh` | Validates GitHub autonomy workflows and PR-autonomy classifier wiring. | Update to validate Change routing first, then PR-autonomy classifier wiring only for PR-backed projections. | references policy | P1: execution governance should enforce the new routing order. |
| `.octon/framework/assurance/runtime/_ops/scripts/validate-operator-boot-surface.sh`, `.octon/framework/assurance/runtime/_ops/tests/test-validate-operator-boot-surface.sh`, `.octon/framework/assurance/runtime/_ops/scripts/validate-ingress-manifest-parity.sh`, `.octon/framework/assurance/runtime/_ops/scripts/validate-bootstrap-ingress.sh`, `.octon/framework/assurance/runtime/_ops/tests/test-validate-bootstrap-ingress.sh`, and `.octon/framework/assurance/runtime/_ops/scripts/validate-architecture-health.sh` | Boot and architecture-health validators assert branch/PR closeout pointers, ingress parity, and manifest health. | Update to assert Change closeout pointers and default-work-unit policy reference, while preserving adapter parity and forbidding inline closeout policy. | references policy | P1: boot validation otherwise preserves old terminology. |
| `.octon/framework/assurance/runtime/_ops/scripts/validate-workflow-authority-derivation.sh` and `.octon/framework/assurance/runtime/_ops/scripts/validate-projection-shell-boundaries.sh` | Validate PR-autonomy and AI-review workflow authority/projection boundaries. | Keep projection checks, but require canonical Change authority before PR or AI projection claims. | references policy | P2: host projection boundaries must stay subordinate to Change. |
| `.octon/framework/assurance/runtime/contracts/alignment-profiles.yml` | Names commit/PR alignment as an alignment profile. | Add default-work-unit profile and route-aware Git/GitHub profile names. | references policy | P1: `alignment-check` must expose the new gate. |
| `.octon/framework/assurance/runtime/_ops/scripts/validate-engagement-change-package-compiler.sh` | Missing target-state validator. Current validator is Work Package named. | Rename and update the validator so Change Package compiler readiness is checked and active Work Package compiler names fail. | implementation-specific | P1: protects complete taxonomy cutover. |
| `.octon/framework/execution-roles/practices/standards/ai-gate-policy.json` and `.octon/framework/execution-roles/practices/standards/ai-gate-findings.schema.json` | AI gate projections are PR-centered in practice. | Make gate target generic Change identity, with PR as an optional projection target. | references policy | P1: AI/code review gates attach to Change. |
| `.octon/framework/execution-roles/practices/standards/github-control-plane-contract.json` | GitHub control plane is merge-critical for PR autonomy. | Keep PR-backed merge controls, but require canonical Change routing and receipt references before GitHub gates can claim completeness. | implementation-specific | P1: GitHub gate state must not become authority. |
| `.octon/framework/assurance/evaluators/review-routing.yml`, `.octon/framework/assurance/evaluators/adapters/openai-review.yml`, and `.octon/framework/assurance/evaluators/adapters/registry.yml` | Review routing is currently consumed mostly through PR-hosted AI review gates. | Define review targets as Change-scoped, with PR diff as one possible projection input. | references policy | P2: local no-PR review needs an evaluator route. |
| `.octon/framework/assurance/practices/complete.md`, `.octon/framework/assurance/practices/session-exit.md`, `.octon/framework/assurance/practices/standards/testing-strategy.md`, and `.octon/framework/assurance/practices/standards/security-and-privacy.md` | Assurance practice docs refer to commit/PR governance, PR artifacts, PR annotations, or PR security gates. | Reword to Change evidence first; PR artifacts and annotations are required only for PR-backed Changes. | references policy | P2: assurance practice language should not pull users back to PR-first. |

## Repo-Local Host Projections

These artifacts are outside `.octon/**`, so they are not promotion targets in this octon-internal packet.

| Artifact | Current assumption | Required change | Role | Priority and rationale |
|---|---|---|---|---|
| `.github/workflows/main-pr-first-guard.yml` | Enforces PR-first updates to `main` except break-glass. | Replace with route-aware main update guard that allows direct-main Changes only when Change receipt, validation evidence, and rollback handle are present. | implementation-specific | P0: this directly blocks the proposed direct-main route. |
| `.github/workflows/main-push-safety.yml` | Provides push safety on `main`. | Treat as direct-main Change safety projection; require receipt and validation checks instead of PR association. | implementation-specific | P0: direct-main needs hosted safety when pushed. |
| `.github/workflows/commit-and-branch-standards.yml` | Validates PR branch names and PR commits. | Keep branch checks for branch routes; add direct-main commit validation and skip branch checks when no branch route exists. | implementation-specific | P1: route-aware commits are required. |
| `.github/workflows/pr-quality.yml`, `.github/PULL_REQUEST_TEMPLATE.md`, `.github/PULL_REQUEST_TEMPLATE/kaizen.md`, and `.github/PULL_REQUEST_TEMPLATE/orchestration-domain-implementation.md` | PR body quality is mandatory for PRs. | Keep for PR-backed Changes and add required Change receipt, validation, risk, and rollback fields. | implementation-specific | P1: PRs become publication outputs with Change metadata. |
| `.github/workflows/pr-autonomy-policy.yml`, `.github/workflows/pr-auto-merge.yml`, `.github/workflows/pr-triage.yml`, `.github/workflows/pr-clean-state-enforcer.yml`, and `.github/workflows/pr-stale-close.yml` | PR autonomy lane manages PR lifecycle. | Keep as PR-backed route projection only. Do not let these workflows imply all Changes need PRs. | implementation-specific | P1: PR automation remains useful but optional. |
| `.github/workflows/ai-review-gate.yml` and `.github/workflows/codex-pr-review.yml` | AI/code review gates run in PR context. | Keep PR projection and define local/no-PR review evidence path in `.octon/**`; PR workflows should reference Change identity when available. | implementation-specific | P1: gates attach to Change, not PR. |
| `.github/workflows/alignment-check.yml` and `.github/workflows/harness-self-containment.yml` | Alignment checks include commit/PR and PR-first guard surfaces. | Invoke default-work-unit alignment and update watched file lists to route-aware surfaces. | implementation-specific | P1: CI must enforce the new contract. |
| `.github/workflows/deny-by-default-gates.yml`, `.github/workflows/repo-hygiene.yml`, `.github/workflows/architecture-conformance.yml`, `.github/workflows/closure-certification.yml`, `.github/workflows/closure-validator-sufficiency.yml`, `.github/workflows/execution-role-validate.yml`, `.github/workflows/skills-validate.yml`, `.github/workflows/assurance-weight-gates.yml`, `.github/workflows/principles-governance-lint.yml`, `.github/workflows/filesystem-interfaces-runtime.yml`, `.github/workflows/uec-cutover-validate.yml`, `.github/workflows/unified-execution-constitution-closure.yml`, and `.github/workflows/validate-unified-execution-completion.yml` | Mixed push/PR validation workflows often use PR merge refs for review and push refs for main. | Preserve both push and PR triggers. Ensure direct-main Changes can satisfy push-side validation without PR metadata, while PR-backed Changes still use PR merge/ref validation. | implementation-specific | P1: route-aware validation must work for both no-PR and PR-backed Changes. |
| `.github/workflows/adr-prompt.yml` | ADR prompt is triggered from merged PR context and prompts links to PR and preview URL. | Retain PR-specific ADR prompts for PR-backed Changes and add or route to no-PR Change receipt context for direct-main Changes. | implementation-specific | P2: ADR guidance should not require PR metadata. |
| `.github/workflows/release-please.yml` and `.github/workflows/autonomy-release-health.yml` | Release automation creates release PRs. | Keep as explicitly PR-backed release route. | implementation-specific | P2: release PRs are valid optional outputs. |
| `.github/workflows/dependency-review.yml` | Dependency review is PR-native. | Keep dependency-risk Changes PR-backed unless a separate local dependency gate is created. | implementation-specific | P2: dependency review is a valid PR-required predicate. |
| `.github/workflows/ci-efficiency-guard.yml`, `.github/scripts/ci-efficiency-guard.sh`, and `.github/workflows/ci-latency-audit.yml` | CI efficiency logic distinguishes PR and push triggers and uses PR samples for latency. | Ensure route-aware push and PR triggers are both supported; do not require PR triggers for direct-main-only validation; define how direct-main push runs participate in latency reporting. | implementation-specific | P2: CI efficiency should not force one route. |
| `.github/workflows/runtime-binaries.yml`, `.github/workflows/smoke.yml`, `.github/workflows/filesystem-interfaces-perf-regression.yml`, `.github/workflows/filesystem-interfaces-slo-tune.yml`, `.github/workflows/flags-stale-report.yml`, `.github/workflows/kaizen.yaml`, `.github/workflows/principles-charter-overrides-audit.yml`, `.github/workflows/uec-cutover-certify.yml`, and `.github/workflows/uec-drift-watch.yml` | Scheduled, dispatch, or push-heavy workflows are not inherently PR-first but may publish branch or main evidence. | Confirm they do not require PR metadata for direct-main Changes and keep any branch or publication behavior scoped to the selected route. | implementation-specific | P3: lower-risk projection cleanup prevents residual PR assumptions. |

## Conformance Coverage Addendum

The implementation-conformance validator checks exact promotion-target coverage
in this map. The rows above group several related files by family; this
addendum binds grouped targets to their covered implementation intent.

| Promotion target | Coverage binding |
|---|---|
| `.octon/framework/orchestration/runtime/workflows/meta/closeout/README.md` | Covered by the closeout route-selection update. |
| `.octon/framework/orchestration/runtime/workflows/manifest.yml` | Covered by the closeout workflow registration update. |
| `.octon/framework/capabilities/runtime/skills/remediation/closeout-change/references/phases.md` | Covered by route-neutral `closeout-change` skill creation. |
| `.octon/framework/capabilities/runtime/skills/remediation/closeout-change/references/decisions.md` | Covered by route-neutral `closeout-change` skill creation. |
| `.octon/framework/capabilities/runtime/skills/remediation/closeout-change/references/checkpoints.md` | Covered by route-neutral `closeout-change` skill creation. |
| `.octon/framework/capabilities/runtime/skills/remediation/closeout-change/references/io-contract.md` | Covered by route-neutral `closeout-change` skill creation. |
| `.octon/framework/capabilities/runtime/skills/remediation/closeout-change/references/safety.md` | Covered by route-neutral `closeout-change` skill creation. |
| `.octon/framework/capabilities/runtime/skills/remediation/closeout-change/references/validation.md` | Covered by route-neutral `closeout-change` skill creation. |
| `.octon/framework/capabilities/runtime/skills/remediation/closeout-change/references/dependencies.md` | Covered by route-neutral `closeout-change` skill creation. |
| `.octon/framework/capabilities/runtime/skills/remediation/closeout-pr/references/phases.md` | Covered by PR-backed Change subflow scoping. |
| `.octon/framework/capabilities/runtime/skills/remediation/closeout-pr/references/decisions.md` | Covered by PR-backed Change subflow scoping. |
| `.octon/framework/capabilities/runtime/skills/remediation/closeout-pr/references/checkpoints.md` | Covered by PR-backed Change subflow scoping. |
| `.octon/framework/capabilities/runtime/skills/remediation/closeout-pr/references/io-contract.md` | Covered by PR-backed Change subflow scoping. |
| `.octon/framework/capabilities/runtime/skills/remediation/closeout-pr/references/safety.md` | Covered by PR-backed Change subflow scoping. |
| `.octon/framework/capabilities/runtime/skills/remediation/closeout-pr/references/validation.md` | Covered by PR-backed Change subflow scoping. |
| `.octon/framework/capabilities/runtime/skills/platforms/provider-github-gates/references/phases.md` | Covered by GitHub gate projection scoping. |
| `.octon/framework/capabilities/runtime/skills/platforms/provider-github-gates/references/decisions.md` | Covered by GitHub gate projection scoping. |
| `.octon/framework/capabilities/runtime/skills/platforms/provider-github-gates/references/safety.md` | Covered by GitHub gate projection scoping. |
| `.octon/framework/capabilities/runtime/skills/platforms/provider-github-gates/references/validation.md` | Covered by GitHub gate projection scoping. |
| `.octon/framework/assurance/runtime/_ops/tests/test-git-github-workflow-alignment.sh` | Covered by route-aware Git/GitHub alignment test updates. |
| `.octon/instance/governance/policies/branch-freshness.yml` | Covered by route-aware branch policy wording. |
| `.octon/instance/governance/policies/risk-materiality.yml` | Covered by Change-scoped risk policy wording. |
| `.octon/instance/governance/policies/mission-closeout.yml` | Covered by Change closeout policy alignment. |

## Implementation Order

1. Land canonical policy files and registry references.
2. Create Change receipt schema and route-neutral `closeout-change`.
3. Update routing and closeout contracts so Change route selection exists before any PR helper is invoked.
4. Update validators to enforce Change-first semantics and prove old PR-first assumptions are gone.
5. Update skills, commands, and helper scripts to use route selection.
6. Complete the Work Package to Change Package cutover across schemas, compiler specs, policies, validators, path families, and docs, with no active aliases or shims.
7. Create a linked repo-local proposal for `.github/**` host projections, then update those projections through that repo-local route.
8. Update operator-facing practice documents and historical prompt scaffolding.

## Done Gate

Implementation is complete only when:

- a direct-main no-PR Change can be selected, validated, committed, receipted, and rolled back without PR metadata;
- a branch-only Change can be checkpointed or completed without opening a PR;
- a PR-backed Change carries Change identity and evidence;
- GitHub PR workflows remain valid only as selected projections;
- Change Package surfaces are explicitly the internal execution bundle for a Change;
- validators fail if an authoritative surface reintroduces PRs, branches, GitHub, or Change Package as the product default work unit;
- validators fail active Work Package terminology outside historical archive or explicit migration notes.

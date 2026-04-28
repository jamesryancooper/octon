---
title: Git + GitHub Autonomous Workflow Hardening Full Implementation Prompt
description: Execution-grade prompt for fully implementing the Git + GitHub autonomous workflow hardening proposal in the live Octon repo.
---

You are the principal Octon Git, GitHub, worktree, and workflow-governance
hardening engineer for this repository.

Your job is to fully implement the architecture proposal at:

`/.octon/inputs/exploratory/proposals/architecture/git-github-autonomous-workflow-hardening/`

Treat this as a real implementation, alignment, validation, and closure
program. Do not stop at design commentary, packet summary, partial planning, or
documentation-only edits.

The proposal packet lives under `inputs/**` and is non-authoritative. Use it as
the implementation specification, but promote all durable outcomes only into
canonical authored or validated surfaces under:

- `/.octon/framework/**`
- `/.octon/instance/**`
- `/.octon/state/**`
- `/.github/**` only where same-branch host projections must align with the
  durable Octon workflow contract

## Working doctrine

This is a hardening follow-up, not a redesign.

Preserve the live workflow shape that is already directionally correct:

1. one clean primary `main` worktree or clone
2. one branch worktree per task or PR
3. same branch and same PR for the life of the task
4. draft-first PR posture
5. GitHub rulesets, checks, and reviewer or maintainer confirmation as the
   final merge authority
6. reviewer-owned thread resolution left to reviewer or maintainer
7. helper scripts as optional accelerators, not the only valid workflow

Your governing thesis is:

1. Octon needs one machine-readable workflow contract for Git, worktree, PR,
   remediation, and helper semantics.
2. Ingress, practice docs, helper behavior, remediation skill behavior, and
   validation must all conform to that one contract.
3. The hardened workflow must remain valid in plain `git` + `gh`, IDE
   worktree flows, Codex App, Claude Code, and any other environment that can
   operate a linked worktree and GitHub PR.
4. GitHub remains the final merge gate. No local helper, label, comment,
   prompt, or generated summary may mint merge authority.

## Required reading order

Read these before planning or implementation:

1. `AGENTS.md`
2. `/.octon/instance/ingress/AGENTS.md`
3. `/.octon/framework/constitution/CHARTER.md`
4. `/.octon/framework/constitution/charter.yml`
5. `/.octon/framework/constitution/obligations/fail-closed.yml`
6. `/.octon/framework/constitution/obligations/evidence.yml`
7. `/.octon/framework/constitution/precedence/normative.yml`
8. `/.octon/framework/constitution/precedence/epistemic.yml`
9. `/.octon/framework/constitution/ownership/roles.yml`
10. `/.octon/framework/constitution/contracts/registry.yml`
11. `/.octon/instance/charter/workspace.md`
12. `/.octon/instance/charter/workspace.yml`
13. `/.octon/framework/execution-roles/runtime/orchestrator/ROLE.md`
14. `/.octon/instance/cognition/context/shared/constraints.md`
15. `/.octon/framework/assurance/practices/complete.md`
16. `/.octon/instance/ingress/manifest.yml`
17. `/.octon/framework/execution-roles/practices/git-autonomy-playbook.md`
18. `/.octon/framework/execution-roles/practices/git-github-autonomy-workflow-v1.md`
19. `/.octon/framework/execution-roles/practices/pull-request-standards.md`
20. `/.octon/framework/execution-roles/practices/commits.md`
21. `/.octon/framework/agency/_ops/scripts/git/git-pr-ship.sh`
22. `/.octon/framework/capabilities/runtime/skills/remediation/resolve-pr-comments/SKILL.md`
23. `/.octon/framework/capabilities/runtime/skills/remediation/resolve-pr-comments/references/safety.md`
24. `.github/PULL_REQUEST_TEMPLATE.md`
25. `.github/workflows/pr-quality.yml`
26. `.github/workflows/pr-autonomy-policy.yml`
27. `.github/workflows/pr-auto-merge.yml`
28. `.github/workflows/commit-and-branch-standards.yml`
29. `/.octon/inputs/exploratory/proposals/architecture/git-github-autonomous-workflow-hardening/README.md`
30. `/.octon/inputs/exploratory/proposals/architecture/git-github-autonomous-workflow-hardening/proposal.yml`
31. `/.octon/inputs/exploratory/proposals/architecture/git-github-autonomous-workflow-hardening/architecture-proposal.yml`
32. `/.octon/inputs/exploratory/proposals/architecture/git-github-autonomous-workflow-hardening/navigation/source-of-truth-map.md`
33. `/.octon/inputs/exploratory/proposals/architecture/git-github-autonomous-workflow-hardening/architecture/current-state-gap-map.md`
34. `/.octon/inputs/exploratory/proposals/architecture/git-github-autonomous-workflow-hardening/architecture/concept-coverage-matrix.md`
35. `/.octon/inputs/exploratory/proposals/architecture/git-github-autonomous-workflow-hardening/architecture/target-architecture.md`
36. `/.octon/inputs/exploratory/proposals/architecture/git-github-autonomous-workflow-hardening/architecture/file-change-map.md`
37. `/.octon/inputs/exploratory/proposals/architecture/git-github-autonomous-workflow-hardening/architecture/implementation-plan.md`
38. `/.octon/inputs/exploratory/proposals/architecture/git-github-autonomous-workflow-hardening/architecture/migration-cutover-plan.md`
39. `/.octon/inputs/exploratory/proposals/architecture/git-github-autonomous-workflow-hardening/architecture/validation-plan.md`
40. `/.octon/inputs/exploratory/proposals/architecture/git-github-autonomous-workflow-hardening/architecture/acceptance-criteria.md`
41. `/.octon/inputs/exploratory/proposals/architecture/git-github-autonomous-workflow-hardening/architecture/cutover-checklist.md`
42. `/.octon/inputs/exploratory/proposals/architecture/git-github-autonomous-workflow-hardening/architecture/closure-certification-plan.md`
43. `/.octon/inputs/exploratory/proposals/architecture/git-github-autonomous-workflow-hardening/architecture/execution-constitution-conformance-card.md`
44. `/.octon/inputs/exploratory/proposals/architecture/git-github-autonomous-workflow-hardening/resources/risk-register.md`

Use this precedence while executing:

1. Live repo state and canonical authored/runtime surfaces determine current
   reality.
2. The constitutional kernel and workspace charter pair define the governing
   authority boundaries.
3. The proposal packet defines the intended target state only where it does
   not conflict with newer live durable authority.
4. `.github/**` companion surfaces must align in the same branch, but they do
   not replace ingress, practice standards, capability boundaries, or
   validators as the source of truth.
5. `inputs/**` remains non-authoritative and must not become a runtime or
   policy dependency.

## Profile Selection Receipt

Record and follow this profile before implementation:

- `release_state`: `pre-1.0`
- `change_profile`: `atomic`
- `selection_rationale`: this is an additive same-root hardening refinement
  that introduces no new top-level root, no new merge authority, and no
  support-target widening; the durable changes should land in one coordinated
  branch
- `transitional_exception_note`: `n/a` unless a true hard gate forces a
  temporary coexistence path

Emit a Profile Selection Receipt before implementation.

## Core objective

Fully implement the proposal so Octon reaches a contract-backed,
worktree-native, GitHub-gated autonomous workflow whose live behavior is
explicit, validator-backed, environment-neutral, and cross-surface coherent.

Completion means all of the following are true in substance, not only in prose:

1. A canonical workflow contract exists under
   `/.octon/framework/execution-roles/practices/standards/`.
2. `ready_pr` is explicitly handled in ingress and no longer falls through as
   an under-specified state.
3. Ready PRs report status instead of triggering redundant closeout prompts.
4. Review remediation is normalized to `fix + commit + push + reply`.
5. Ordinary remediation no longer instructs amend, rebase, force-push, or
   author-side review-thread resolution.
6. The remediation skill's promised behavior matches its safe Git/GitHub
   boundary.
7. `git-pr-open.sh` is treated as create-oriented and later PR updates are
   modeled as push-to-same-branch behavior.
8. `git-pr-ship.sh` is status-first and explicit-action rather than eager
   mutation.
9. A dedicated validator and tests fail on the exact drift classes named by
   the packet.
10. Plain Git lane and helper-lane scenario proof both exist.
11. Same-branch `.github/**` companion surfaces are aligned.

## Required implementation surfaces

Implement the proposal by creating or updating at minimum:

1. Canonical workflow contract:
   - add `/.octon/framework/execution-roles/practices/standards/git-worktree-autonomy-contract.yml`
   - define operating model, closeout contexts and suppressions, remediation
     policy, helper semantics, and validation scenarios
2. Ingress hardening:
   - edit `/.octon/instance/ingress/manifest.yml`
   - edit `/.octon/instance/ingress/AGENTS.md`
   - make `ready_pr` explicit and keep ingress parity
3. Practice-doc alignment:
   - edit `/.octon/framework/execution-roles/practices/git-autonomy-playbook.md`
   - edit `/.octon/framework/execution-roles/practices/git-github-autonomy-workflow-v1.md`
   - edit `/.octon/framework/execution-roles/practices/pull-request-standards.md`
4. Helper hardening:
   - edit `/.octon/framework/agency/_ops/scripts/git/git-pr-ship.sh`
5. Remediation capability alignment:
   - edit `/.octon/framework/capabilities/runtime/skills/remediation/resolve-pr-comments/SKILL.md`
   - edit `/.octon/framework/capabilities/runtime/skills/remediation/resolve-pr-comments/references/safety.md`
6. Drift validation:
   - add `/.octon/framework/assurance/runtime/_ops/scripts/validate-git-github-workflow-alignment.sh`
   - add `/.octon/framework/assurance/runtime/_ops/tests/test-git-github-workflow-alignment.sh`
7. Same-branch GitHub companion alignment:
   - edit `.github/PULL_REQUEST_TEMPLATE.md`
   - edit `.github/workflows/pr-quality.yml`
   - edit `.github/workflows/pr-autonomy-policy.yml`
   - edit `.github/workflows/pr-auto-merge.yml`
   - inspect `.github/workflows/commit-and-branch-standards.yml` and align it
     if it still encourages forbidden remediation behavior

Treat these adjacent surfaces as preserve-unless-evidence-requires-change:

1. `/.octon/framework/agency/_ops/scripts/git/git-wt-new.sh`
2. `/.octon/framework/agency/_ops/scripts/git/git-pr-open.sh`
3. `/.octon/framework/agency/_ops/scripts/git/git-pr-cleanup.sh`

## Required semantic outcomes

Implement and preserve all of the following:

1. The durable workflow is defined in standard Git/worktree/GitHub terms, not
   in host-app-specific terms.
2. The main closeout prompts remain:
   - primary `main` worktree -> branch into a feature worktree and prepare a
     draft PR
   - branch worktree with no PR -> stage, commit, push, and open a draft PR
   - branch worktree with a draft PR in the autonomous lane -> mark ready and
     request squash auto-merge
   - branch worktree with a draft PR in the manual lane -> mark ready for
     human review with auto-merge off
3. Ready PR states are status responses, not more closeout questions. Cover at
   least:
   - ready and waiting on required checks or auto-merge
   - ready and waiting on reviewer or maintainer confirmation
   - ready in the manual lane and waiting on human review or merge
4. Ordinary review remediation becomes:
   - fix
   - commit
   - push
   - reply
5. Ordinary review remediation forbids:
   - `git commit --amend`
   - `git rebase`
   - any force-push variant
   - programmatic review-thread resolution
   - merging `main` into the branch as a remediation shortcut
6. The minimal safe Git subset for the remediation skill is:
   - `git status`
   - `git diff`
   - `git add`
   - `git commit`
   - `git push`
7. `git-pr-open.sh` remains create-oriented. Later PR updates happen by
   pushing more commits to the same branch.
8. `git-pr-ship.sh` must:
   - report current status and blockers in no-argument mode
   - require explicit action flags for ready-for-review and auto-merge
     requests
   - state clearly that GitHub still decides final mergeability
9. Durable operator wording should standardize on:
   - `closeout`
   - `ready`
   - `request auto-merge`
10. `ship` may remain only as a compatibility alias, not the preferred durable
    label for PR-closeout intent.

## Execution plan requirements

Execute in this order unless live repo facts force a safer sequencing:

1. Establish the canonical workflow contract.
2. Harden ingress closeout handling around explicit `ready_pr` behavior.
3. Normalize remediation policy and capability boundaries.
4. Reframe helpers as explicit request and status surfaces.
5. Align same-branch `.github/**` projections.
6. Add validator coverage and tests.
7. Produce scenario proof and closeout evidence.

If a sequencing change is necessary, explain why and keep the same target
state.

## Delivery contract

You must satisfy all of the following:

1. Work on one branch only.
2. Continue through implementation, validation, and evidence capture until the
   acceptance criteria are met or a true hard blocker is reached.
3. Promote durable meaning only into canonical live surfaces, never back into
   the proposal tree.
4. Keep `.github/**` companion alignments in the same branch as the `.octon/**`
   changes.
5. Treat helper scripts as projections of the durable workflow, not as a
   second control plane.
6. Use the live `branch_closeout_gate` in
   `/.octon/instance/ingress/manifest.yml`. Do not invent a fixed closeout
   question.
7. Before declaring the work done, update
   `/.octon/state/continuity/repo/log.md` and verify against
   `/.octon/framework/assurance/practices/complete.md`.
8. Stop only for a true hard blocker:
   - unresolved constitutional or authority conflict
   - validation that cannot be completed credibly
   - required live GitHub scenario proof blocked by unavailable auth or
     network capability
   - unexpected repo drift that makes the packet target unsafe without human
     direction

## Non-negotiable negative constraints

Do not do any of the following:

1. Do not treat `inputs/**` as a durable authority source after implementation.
2. Do not make the workflow Codex-app-specific or host-app-specific.
3. Do not create a new merge authority outside GitHub rulesets, checks, and
   reviewer or maintainer confirmation.
4. Do not let helpers, labels, comments, checks, or generated summaries mint
   repo-local approval authority.
5. Do not widen support targets, adapter scope, or workflow claim scope beyond
   what the packet requires.
6. Do not leave mixed old and new remediation semantics live at the same time.
7. Do not leave stale prose that still teaches rebase, amend, or force-push
   remediation in ordinary review flow.
8. Do not let the remediation skill promise actions its tool boundary cannot
   safely perform.
9. Do not let helper docs overstate readiness proof or mergeability.
10. Do not resolve reviewer-owned threads programmatically from the author
    path.
11. Do not remove safe linked-worktree cleanup behavior unless validation
    proves a concrete defect.
12. Do not claim the packet is complete if only the helper lane is proven and
    the plain Git lane is not.

## Validation and evidence requirements

At minimum, run and retain evidence for:

1. The new workflow-alignment validator and its test script.
2. `bash .octon/framework/assurance/runtime/_ops/scripts/validate-harness-structure.sh`
3. `bash .octon/framework/assurance/runtime/_ops/scripts/validate-contract-governance.sh`
4. `bash .octon/framework/assurance/runtime/_ops/scripts/alignment-check.sh --profile harness`
5. `bash .octon/framework/assurance/runtime/_ops/scripts/alignment-check.sh --profile commit-pr`
6. `bash .octon/framework/assurance/runtime/_ops/scripts/validate-continuity-memory.sh`
   if continuity artifacts changed

Also produce scenario proof for:

1. Plain Git + GitHub lane:
   - create branch worktree with standard `git worktree`
   - commit with plain Git
   - push and open draft PR with `gh`
   - add follow-up commits to the same branch and confirm same PR updates
   - transition draft to ready only when checks and author action items are
     satisfied
   - observe ready-state handling for waiting-on-checks, waiting-on-auto-merge,
     waiting-on-reviewer-confirmation, and manual-lane review
2. Octon helper lane:
   - `git-wt-new.sh` creates the branch worktree
   - `git-pr-open.sh` creates the draft PR
   - `git-pr-ship.sh` reports status with no action flags
   - explicit action flags request ready and auto-merge transitions
   - helper output states GitHub remains the final merge gate
3. Review-remediation safety:
   - author addresses feedback with new commits rather than history rewrite
   - push occurs before author reply claiming the fix landed
   - reviewer-owned threads remain unresolved by the author
   - autonomous and manual lanes respect the same remediation rules
4. Multi-worktree cleanup:
   - merged branch cleanup converges refs safely
   - pruning stays safe when another worktree is current, dirty, or in use
   - cleanup prints an exact manual follow-up when automatic removal is unsafe

If any required live scenario cannot run, record the exact blocker and do not
claim full implementation complete.

## Acceptance and done gate

Do not close the work until all of the following are true:

1. The canonical workflow contract exists and is populated.
2. Ingress explicitly handles `ready_pr`.
3. Ingress `AGENTS.md` remains in parity with the manifest.
4. Ready PR states report status instead of prompting again.
5. No authoritative or supporting workflow surface instructs ordinary
   rebase, amend, or force-push remediation.
6. The remediation skill promise matches its allowed-tools boundary.
7. `git-pr-open.sh` is documented as create-oriented.
8. `git-pr-ship.sh` is status-first and explicit-action.
9. Helper output states GitHub is the final merge gate.
10. The dedicated workflow validator exists and passes.
11. The validator fails on the drift classes named by the audit.
12. Companion `.github/**` surfaces are aligned in the same branch.
13. Pass 1 contract coherence evidence is complete.
14. Pass 2 execution realism evidence is complete.

## Final response contract

Return a completion report with these sections:

1. `## Profile Selection Receipt`
2. `## Implementation Plan`
3. `## Impact Map (code, tests, docs, contracts)`
4. `## Compliance Receipt`
5. `## Validation`
6. `## Evidence`
7. `## Exceptions/Escalations`
8. `## Remaining Risks`

Include the exact files changed, the validators run, the scenario proof
captured, and any blockers that prevented full closure.

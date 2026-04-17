---
title: Git + GitHub Workflow SSOT Drift Hardening Prompt
description: Execution-grade prompt for hardening the live Git and GitHub workflow while preserving SSOT, minimal sufficient complexity, and existing functionality/capabilities.
---

You are the principal Octon Git, GitHub, workflow-governance, and drift
hardening engineer for this repository.

Your job is to harden the live Git + GitHub workflow so it is more
authoritative, more SSOT-aligned, and less drift-prone, without changing the
functional workflow model, widening capabilities, or adding unnecessary
complexity.

Treat this as a real implementation and validation task, not a design note or
policy brainstorm.

## Core objective

Harden the Git + GitHub workflow by removing authoritative drift and
consolidating workflow meaning into canonical surfaces, while preserving
existing functionality and capabilities.

The correct end state is:

1. one durable source of truth for workflow semantics
2. no conflicting or redundant guidance across ingress, docs, helpers,
   skills, and validators
3. minimal sufficient complexity only
4. no functional regression in the existing branch-worktree and PR model
5. no capability widening, support-target widening, or hidden authority
   expansion

## Non-negotiable doctrine

Follow these principles throughout:

1. SSOT first:
   - prefer one canonical machine-readable or repo-authoritative surface over
     parallel prose
   - remove drift instead of adding more layers that restate the same thing
2. Minimal sufficient complexity:
   - do not add new systems, abstractions, or helper flows unless required to
     remove real drift
   - if a validator, contract, or doc tightening is enough, stop there
3. No functionality or capability regression:
   - preserve the current live workflow shape unless a drift fix requires a
     bounded semantic clarification
   - do not remove valid operator environments or helper usage patterns
4. No capability impact:
   - do not widen packs, adapters, tool permissions, support targets, or merge
     authority beyond what the repo already intends
   - do not reduce working capability unless the current behavior is clearly
     unsafe and the safer replacement is fully wired

## Preserve these live workflow invariants

Do not change these unless the repository’s existing authoritative surfaces are
already inconsistent and a clarification is required:

1. one clean primary `main` worktree or clone
2. one branch worktree per task or PR
3. same branch and same PR for the life of the task
4. draft-first PR posture
5. GitHub required checks, policy, and reviewer or maintainer confirmation as
   the final merge gate
6. reviewer-owned thread resolution staying with reviewer or maintainer
7. helper scripts remaining optional accelerators rather than a second control
   plane

## Required reading order

Read these before making changes:

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
13. `/.octon/framework/agency/runtime/agents/orchestrator/AGENT.md`
14. `/.octon/instance/ingress/manifest.yml`
15. `/.octon/framework/agency/practices/standards/git-worktree-autonomy-contract.yml`
16. `/.octon/framework/agency/practices/git-autonomy-playbook.md`
17. `/.octon/framework/agency/practices/git-github-autonomy-workflow-v1.md`
18. `/.octon/framework/agency/practices/pull-request-standards.md`
19. `/.octon/framework/agency/_ops/scripts/git/git-pr-open.sh`
20. `/.octon/framework/agency/_ops/scripts/git/git-pr-ship.sh`
21. `/.octon/framework/agency/_ops/scripts/git/git-pr-cleanup.sh`
22. `/.octon/framework/capabilities/runtime/skills/remediation/resolve-pr-comments/SKILL.md`
23. `/.octon/framework/capabilities/runtime/skills/remediation/closeout-pr/SKILL.md`
24. `/.octon/framework/assurance/runtime/_ops/scripts/validate-git-github-workflow-alignment.sh`
25. `.github/PULL_REQUEST_TEMPLATE.md`
26. `.github/workflows/pr-quality.yml`
27. `.github/workflows/pr-autonomy-policy.yml`
28. `.github/workflows/pr-auto-merge.yml`

## What to improve

Look for drift such as:

1. duplicated workflow meaning across multiple surfaces
2. helper semantics that overstate what the helpers prove
3. doc wording that diverges from machine-readable contracts
4. capability or skill boundaries that promise more or less than they can
   actually do
5. validator blind spots where meaningful workflow drift could re-enter

Prioritize fixes that:

1. reduce drift without changing behavior
2. increase explicitness without adding parallel authority
3. improve validator coverage where the current workflow relies too heavily on
   prose

## Prohibited moves

Do not do any of the following:

1. do not redesign the workflow if a narrower drift fix is sufficient
2. do not add app-specific semantics or host-specific authority
3. do not add a new merge authority outside GitHub
4. do not widen permissions, tools, support targets, or autonomous claims
5. do not introduce a second orchestration layer if existing helpers/skills can
   be aligned instead
6. do not make purely cosmetic changes that do not improve SSOT or reduce drift
7. do not break current working flows in plain `git` + `gh`, helper lane, or
   existing PR policy

## Preferred implementation posture

When choosing between options:

1. prefer tightening an existing contract over adding a new doc
2. prefer deleting or consolidating redundant wording over duplicating it
3. prefer validating a behavior over re-explaining it in more prose
4. prefer preserving a functioning capability boundary and clarifying it over
   widening it

## Validation requirements

Run the smallest credible validation set that proves the hardening is real and
non-regressive:

1. `bash .octon/framework/assurance/runtime/_ops/scripts/validate-git-github-workflow-alignment.sh`
2. `bash .octon/framework/assurance/runtime/_ops/scripts/validate-commit-pr-alignment.sh`
3. `bash .octon/framework/assurance/runtime/_ops/scripts/alignment-check.sh --profile commit-pr`
4. any targeted helper or skill validation required by the specific surfaces
   you change

If your changes touch capability publication state, republish the affected
effective outputs and include the resulting receipt files only if they are
required to keep generated state coherent.

## Success criteria

The task is complete only when:

1. the hardened workflow is more SSOT-aligned than before
2. the change removes or reduces real drift
3. no existing workflow capability is regressed
4. no authority, capability, or support surface is widened
5. the implementation reflects minimal sufficient complexity
6. validation passes for the touched workflow surfaces

## Final response contract

Return:

1. the source-of-truth surface you treated as canonical
2. the drift you removed
3. why the chosen change is the minimal sufficient fix
4. what validation you ran
5. any remaining external blockers or deliberately deferred drift

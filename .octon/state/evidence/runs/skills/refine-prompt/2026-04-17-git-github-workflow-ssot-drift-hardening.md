# Refine Prompt Run Log

**Original:** Create a prompt that hardens the Git + GitHub Workflow, adheres
to SSOT, seeks minimal sufficient complexity, and addresses any drift without
impacting functionality or capabilities.
**Refined:** 2026-04-17T23:05:00Z
**Context Depth:** standard
**Status:** confirmed by direct execution request

## Execution Persona

Principal Octon Git, GitHub, workflow-governance, and drift-hardening
engineer.

## Repository Context

- Canonical workflow contract:
  `/.octon/framework/agency/practices/standards/git-worktree-autonomy-contract.yml`
- Workflow practice surfaces:
  `git-autonomy-playbook.md`,
  `git-github-autonomy-workflow-v1.md`,
  `pull-request-standards.md`
- Helper surfaces:
  `git-pr-open.sh`,
  `git-pr-ship.sh`,
  `git-pr-cleanup.sh`
- Capability surfaces:
  `resolve-pr-comments/`,
  `closeout-pr/`
- Drift validator:
  `validate-git-github-workflow-alignment.sh`

## Intent

Create an execution-grade prompt that drives workflow hardening through SSOT,
minimal sufficient complexity, and drift reduction without widening or
regressing functionality/capabilities.

## Requirements

1. Save the prompt under `/.octon/framework/scaffolding/practices/prompts/`.
2. Make the prompt implementation-grade rather than advisory.
3. Explicitly prioritize SSOT and minimal sufficient complexity.
4. Explicitly prohibit capability/functionality regression and authority
   widening.
5. Ground the prompt in the live workflow contract and adjacent repo surfaces.

## Negative Constraints

- Do not create only a chat-only prompt.
- Do not encourage redesign where narrower drift fixes suffice.
- Do not permit support-target or merge-authority widening.
- Do not allow helper or skill changes that regress working behavior.

## Self-Critique Results

- The prompt is narrower than a full redesign brief and centers on SSOT and
  drift reduction.
- It explicitly encodes minimal sufficient complexity as a selection rule,
  not just a preference.
- It protects against both behavioral regression and capability widening.

## Output

- Prompt artifact:
  `/.octon/framework/scaffolding/practices/prompts/2026-04-17-git-github-workflow-ssot-drift-hardening.prompt.md`

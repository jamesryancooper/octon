# Refine Prompt Run Log

**Original:** Create a prompt that will lead to the full implementation of the
architecture proposal packet
`/.octon/inputs/exploratory/proposals/architecture/git-github-autonomous-workflow-hardening/`.
**Refined:** 2026-04-17T21:30:00Z
**Context Depth:** standard
**Status:** confirmed by direct execution request

## Execution Persona

Principal Octon Git, GitHub, worktree, and workflow-governance hardening
engineer.

## Repository Context

- Proposal packet:
  `/.octon/inputs/exploratory/proposals/architecture/git-github-autonomous-workflow-hardening/`
- Primary durable implementation targets:
  `/.octon/instance/ingress/manifest.yml`,
  `/.octon/instance/ingress/AGENTS.md`,
  `/.octon/framework/agency/practices/standards/git-worktree-autonomy-contract.yml`,
  `/.octon/framework/agency/practices/git-autonomy-playbook.md`,
  `/.octon/framework/agency/practices/git-github-autonomy-workflow-v1.md`,
  `/.octon/framework/agency/practices/pull-request-standards.md`,
  `/.octon/framework/agency/_ops/scripts/git/git-pr-ship.sh`,
  `/.octon/framework/capabilities/runtime/skills/remediation/resolve-pr-comments/**`,
  `/.octon/framework/assurance/runtime/_ops/scripts/validate-git-github-workflow-alignment.sh`,
  `/.octon/framework/assurance/runtime/_ops/tests/test-git-github-workflow-alignment.sh`
- Same-branch companion GitHub surfaces:
  `.github/PULL_REQUEST_TEMPLATE.md`,
  `.github/workflows/pr-quality.yml`,
  `.github/workflows/pr-autonomy-policy.yml`,
  `.github/workflows/pr-auto-merge.yml`

## Intent

Create an execution-grade prompt artifact that can drive full implementation of
the Git + GitHub autonomous workflow hardening packet against the live Octon
repository.

## Requirements

1. Save the prompt under `/.octon/framework/scaffolding/practices/prompts/`.
2. Ground it in the live ingress, constitutional, workflow, helper, skill, and
   validation surfaces.
3. Make the prompt implementation-grade rather than analytical.
4. Include required reading order, profile selection, concrete file targets,
   semantic outcomes, negative constraints, validation, and done gates.
5. Preserve the packet's environment-neutral and GitHub-gated target state.

## Negative Constraints

- Do not leave the deliverable only in chat.
- Do not let the prompt treat proposal paths as durable authority.
- Do not make the implementation app-specific.
- Do not omit the `.github/**` companion alignments or the plain Git scenario
  proof requirement.
- Do not teach a stale closeout or remediation model while hardening the
  workflow.

## Self-Critique Results

- The prompt is tied to the exact file-change map and acceptance criteria of
  the packet rather than a loose summary.
- It tells the implementing agent what to preserve, what to change, and what
  evidence is required before claiming completion.
- It avoids the stale fixed closeout question and instead points the agent to
  the live contextual closeout contract.

## Output

- Prompt artifact:
  `/.octon/framework/scaffolding/practices/prompts/2026-04-17-git-github-autonomous-workflow-hardening-full-implementation.prompt.md`

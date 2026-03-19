# Agent Instructions

Root `AGENTS.md` and `CLAUDE.md` are ingress adapters to this canonical file.

## Behavioral Contract

Adopt the default agent persona defined by the harness:

- Enable reliable agent execution that is deterministic enough to trust, observable enough to debug, and flexible enough to evolve.
- **Default agent:** `{{DEFAULT_AGENT}}` (per `.octon/framework/agency/manifest.yml`)
- **Constitution:** `.octon/framework/agency/governance/CONSTITUTION.md`
- **Delegation policy:** `.octon/framework/agency/governance/DELEGATION.md`
- **Memory policy:** `.octon/framework/agency/governance/MEMORY.md`
- **Execution contract:** `{{DEFAULT_AGENT_EXECUTION_CONTRACT}}`
- **Identity contract:** `{{DEFAULT_AGENT_IDENTITY_CONTRACT}}`
- **Objective brief:** `.octon/instance/bootstrap/OBJECTIVE.md`
- **Active intent contract:** `.octon/instance/cognition/context/shared/intent.contract.yml`
- **All agents:** `.octon/framework/agency/runtime/agents/registry.yml`

Read and follow your agent contract and active objective contract before beginning work.

## Harness Orientation

This repository uses a `.octon/` harness. For full boot sequence and
structure, read `.octon/instance/bootstrap/START.md`.

`.octon/` is organized by domain. Each domain has a `README.md` for
orientation.

- **Agency:** `.octon/framework/agency/` (runtime, governance, practices)
- **Capabilities:** `.octon/framework/capabilities/` (runtime, governance, practices)
  - Commands: `.octon/framework/capabilities/runtime/commands/manifest.yml`
- **Cognition:** `.octon/framework/cognition/` (runtime, governance, practices)
  - Context index: `.octon/instance/cognition/context/index.yml`
- **Orchestration:** `.octon/framework/orchestration/` (workflows, missions)
- **Scaffolding:** `.octon/framework/scaffolding/` (runtime, governance, practices)
- **Assurance:** `.octon/framework/assurance/` (runtime, governance, practices)
- **Continuity:** `.octon/state/continuity/repo/` (progress log, tasks, next steps)
- **Ideation:** `.octon/inputs/exploratory/ideation/` (scratchpad, projects — human-led)
- **Output:** `.octon/generated/` (reports, drafts, artifacts)

## Skills

Read `.octon/framework/capabilities/runtime/skills/manifest.yml` for skill discovery.

### Skill Discovery

1. Read `manifest.yml` for skill index (id, name, summary, triggers)
2. For validation/expansion, read `capabilities.yml` (skill sets, capabilities, refs)
3. After matching, read `registry.yml` for extended metadata and I/O paths
4. Load `SKILL.md` when a skill is activated (includes `allowed-tools` for tool permissions)
5. Load `references/` or `scripts/` only if needed

### Skill Invocation

- Explicit command: `/synthesize-research <path>`
- Explicit call: `use skill: synthesize-research`
- Natural triggers: Match against `triggers` in manifest

### Safety

- Follow `deny-by-default` tool policy
- Log every execution to `/.octon/state/evidence/runs/skills/`

## Workflows

Read `.octon/framework/orchestration/runtime/workflows/manifest.yml` for workflow discovery.

### Workflow Discovery

1. Read `manifest.yml` for workflow index (id, name, summary, triggers)
2. After matching, read `registry.yml` for extended metadata and parameters
3. Load `README.md` when a workflow is activated
4. Load step files (01-*.md, 02-*.md, ...) during execution

### Workflow Invocation

- Explicit command: `/audit-orchestration manifest="..."`
- Explicit call: `use workflow: audit-orchestration`
- Natural triggers: Match against `triggers` in manifest

## Commit Discipline

- Follow `.octon/framework/agency/practices/commits.md` for branch naming, Conventional Commit
  format, and commit quality rules.
- Use commit messages in the form `<type>(<scope>): <summary>`.

## Pull Request Discipline

- Follow `.octon/framework/agency/practices/pull-request-standards.md` for PR scope,
  description quality, and reviewer expectations.
- Use `.github/PULL_REQUEST_TEMPLATE.md` (or a scoped template under
  `.github/PULL_REQUEST_TEMPLATE/`) when opening PRs.

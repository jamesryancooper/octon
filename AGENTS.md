# Agent Instructions

## Behavioral Contract

Adopt the default agent persona defined by the harness:

- **Default agent:** `architect` (per `.harmony/agency/manifest.yml`)
- **Contract:** `.harmony/agency/agents/architect/agent.md`
- **All agents:** `.harmony/agency/agents/registry.yml`

Read and follow your agent contract before beginning work.

## Harness Orientation

This repository uses a `.harmony/` harness. For full boot sequence and
structure, read `.harmony/START.md`.

`.harmony/` is organized by domain. Each domain has a `README.md` for
orientation.

- **Agency:** `.harmony/agency/` (agents, assistants, teams)
- **Capabilities:** `.harmony/capabilities/` (skills, commands, tools)
  - Commands: `.harmony/capabilities/commands/manifest.yml`
- **Cognition:** `.harmony/cognition/` (architecture, principles, methodology, context, decisions, analyses)
  - Context index: `.harmony/cognition/context/index.yml`
- **Orchestration:** `.harmony/orchestration/` (workflows, missions)
- **Scaffolding:** `.harmony/scaffolding/` (templates, prompts, examples)
- **Quality:** `.harmony/quality/` (completion checklists)
- **Continuity:** `.harmony/continuity/` (progress log, tasks, next steps)
- **Ideation:** `.harmony/ideation/` (scratchpad, projects — human-led)
- **Output:** `.harmony/output/` (reports, drafts, artifacts)

## Skills

Read `.harmony/capabilities/skills/manifest.yml` for skill discovery.

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
- Log every execution to `capabilities/skills/_state/logs/`

## Workflows

Read `.harmony/orchestration/workflows/manifest.yml` for workflow discovery.

### Workflow Discovery

1. Read `manifest.yml` for workflow index (id, name, summary, triggers)
2. After matching, read `registry.yml` for extended metadata and parameters
3. Load `WORKFLOW.md` when a workflow is activated
4. Load step files (01-*.md, 02-*.md, ...) during execution

### Workflow Invocation

- Explicit command: `/orchestrate-audit manifest="..."`
- Explicit call: `use workflow: orchestrate-audit`
- Natural triggers: Match against `triggers` in manifest

## Commit Discipline

- Follow `.harmony/agency/practices/commits.md` for branch naming, Conventional Commit
  format, and commit quality rules.
- Use commit messages in the form `<type>(<scope>): <summary>`.

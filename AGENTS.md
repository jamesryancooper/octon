# Claude Code Adapter

## Skills

**CRITICAL:** Read `.harmony/capabilities/skills/manifest.yml` for skill discovery.

### Quick Reference

- **Manifest:** `.harmony/capabilities/skills/manifest.yml` (Tier 1 discovery)
- **Capabilities Schema:** `.harmony/capabilities/skills/capabilities.yml` (skill sets, valid capabilities, refs)
- **Registry:** `.harmony/capabilities/skills/registry.yml` (extended metadata + I/O mappings)
- **Skill Definitions:** `.harmony/capabilities/skills/<skill-id>/SKILL.md`
- **Logs:** `.harmony/capabilities/skills/_state/logs/` (execution logs)

### Progressive Disclosure

1. Read `manifest.yml` for skill index (id, name, summary, triggers)
2. For validation/expansion, read `capabilities.yml` (skill sets, capabilities, refs)
3. After matching, read `registry.yml` for extended metadata and I/O paths
4. Load `SKILL.md` when a skill is activated (includes `allowed-tools` for tool permissions)
5. Load `references/` or `scripts/` only if needed

### Invocation

- Explicit command: `/synthesize-research <path>`
- Explicit call: `use skill: synthesize-research`
- Natural triggers: Match against `triggers` in manifest

### Safety

- Follow `deny-by-default` tool policy
- Log every execution to `capabilities/skills/_state/logs/`

## Workflows

Read `.harmony/orchestration/workflows/manifest.yml` for workflow discovery.

### Quick Reference

- **Manifest:** `.harmony/orchestration/workflows/manifest.yml` (Tier 1 discovery)
- **Registry:** `.harmony/orchestration/workflows/registry.yml` (extended metadata + parameters)
- **Workflow Definitions:** `.harmony/orchestration/workflows/<domain>/<workflow-id>/WORKFLOW.md`
- **Catalog:** `.harmony/orchestration/workflows/README.md`

### Progressive Disclosure

1. Read `manifest.yml` for workflow index (id, name, summary, triggers)
2. After matching, read `registry.yml` for extended metadata and parameters
3. Load `WORKFLOW.md` when a workflow is activated
4. Load step files (01-*.md, 02-*.md, ...) during execution

### Invocation

- Explicit command: `/orchestrate-audit manifest="..."`
- Explicit call: `use workflow: orchestrate-audit`
- Natural triggers: Match against `triggers` in manifest

## Foundation

`.harmony/` is organized by domain. Each domain has a `README.md` for orientation.

- **Agency:** `.harmony/agency/` (agents, assistants, subagents, teams)
- **Capabilities:** `.harmony/capabilities/` (skills, commands, tools)
  - Commands: `.harmony/capabilities/commands/manifest.yml`
- **Cognition:** `.harmony/cognition/` (context, decisions, analyses)
  - Context index: `.harmony/cognition/context/index.yml`
- **Orchestration:** `.harmony/orchestration/` (workflows, missions)
- **Scaffolding:** `.harmony/scaffolding/` (templates, prompts, examples)
- **Quality:** `.harmony/quality/` (completion checklists)
- **Continuity:** `.harmony/continuity/` (progress log, tasks, next steps)
- **Ideation:** `.harmony/ideation/` (scratchpad, projects — human-led)
- **Output:** `.harmony/output/` (reports, drafts, artifacts)

For domain-specific orientation, read `{domain}/README.md`.

## Entry Point

For full harness orientation, read `.harmony/START.md`.

## Commit Discipline

- Follow `docs/practices/commits.md` for branch naming, Conventional Commit
  format, and commit quality rules.
- Use commit messages in the form `<type>(<scope>): <summary>`.

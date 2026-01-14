# Claude Code Adapter

## Workspace Skills

**CRITICAL:** Read `.harmony/skills/registry.yml` for shared skills, then `.workspace/skills/registry.yml` for project-specific skills and mappings.

### Quick Reference

- **Shared Skills:** `.harmony/skills/registry.yml` (read first)
- **Local Skills:** `.workspace/skills/registry.yml` (project-specific mappings and skills)
- **Skill Definitions:** `.harmony/skills/<skill-id>/SKILL.md` or `.workspace/skills/<skill-id>/SKILL.md`
- **Outputs:** `.workspace/skills/outputs/` (all skill writes here)
- **Logs:** `.workspace/skills/logs/runs/` (execution logs)

### Progressive Disclosure

1. Read `.harmony/skills/registry.yml` for shared skill definitions
2. Read `.workspace/skills/registry.yml` for project-specific mappings and additional skills
3. Load `SKILL.md` only when a skill is selected
4. Load `reference/` or `scripts/` only if needed

### Invocation

- Explicit command: `/synthesize-research <path>`
- Explicit call: `use skill: research-synthesizer`
- Natural triggers: Match against `triggers` in registry

### Safety

- Write only to `.workspace/skills/outputs/**` and `.workspace/skills/logs/**`
- Follow `deny-by-default` tool policy
- Log every execution to `logs/runs/`

## Shared Foundation

`.harmony/` provides shared infrastructure that workspaces inherit:

- **Assistants:** `.harmony/assistants/` (reviewer, refactor, docs)
- **Templates:** `.harmony/templates/` (workspace scaffolding)
- **Workflows:** `.harmony/workflows/` (workspace management, missions)
- **Commands:** `.harmony/commands/` (recover, validate-frontmatter)
- **Context:** `.harmony/context/` (tools.md, compaction.md)

## Workspace Entry Point

For full workspace orientation, read `.workspace/START.md`.

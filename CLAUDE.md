# Claude Code Adapter

## Workspace Skills

**CRITICAL:** Read `.workspace/skills/registry.yml` immediately, then follow progressive disclosure rules.

### Quick Reference

- **Catalog:** `.workspace/skills/registry.yml` (read first for routing)
- **Skills:** `.workspace/skills/<skill-id>/SKILL.md` (load only when invoked)
- **Outputs:** `.workspace/skills/outputs/` (all skill writes here)
- **Logs:** `.workspace/skills/logs/runs/` (execution logs)

### Progressive Disclosure

1. Read `registry.yml` for available skills and routing
2. Load `SKILL.md` only when a skill is selected
3. Load `reference/` or `scripts/` only if needed

### Invocation

- Explicit command: `/synthesize-research <path>`
- Explicit call: `use skill: research-synthesizer`
- Natural triggers: Match against `triggers` in registry

### Safety

- Write only to `.workspace/skills/outputs/**` and `.workspace/skills/logs/**`
- Follow `deny-by-default` tool policy
- Log every execution to `logs/runs/`

## Workspace Entry Point

For full workspace orientation, read `.workspace/START.md`.

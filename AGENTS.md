# Claude Code Adapter

## Skills

**CRITICAL:** Read `.harmony/capabilities/skills/manifest.yml` for skill discovery.

### Quick Reference

- **Manifest:** `.harmony/capabilities/skills/manifest.yml` (Tier 1 discovery)
- **Capabilities Schema:** `.harmony/capabilities/skills/capabilities.yml` (skill sets, valid capabilities, refs)
- **Registry:** `.harmony/capabilities/skills/registry.yml` (extended metadata + I/O mappings)
- **Skill Definitions:** `.harmony/capabilities/skills/<skill-id>/SKILL.md`
- **Logs:** `.harmony/capabilities/skills/logs/` (execution logs)

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
- Log every execution to `capabilities/skills/logs/`

## Foundation

`.harmony/` is organized by capability:

- **Agency:** `.harmony/agency/` (agents, assistants, subagents, teams)
- **Capabilities:** `.harmony/capabilities/` (skills, commands, tools)
- **Cognition:** `.harmony/cognition/` (context, decisions, analyses)
- **Orchestration:** `.harmony/orchestration/` (workflows, missions)
- **Scaffolding:** `.harmony/scaffolding/` (templates, prompts, examples)
- **Quality:** `.harmony/quality/` (completion checklists)
- **Continuity:** `.harmony/continuity/` (progress log, tasks, next steps)
- **Ideation:** `.harmony/ideation/` (scratchpad, projects — human-led)
- **Output:** `.harmony/output/` (reports, drafts, artifacts)

## Entry Point

For full workspace orientation, read `.harmony/START.md`.

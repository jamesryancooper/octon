# Claude Code Adapter

## Workspace Skills

**CRITICAL:** Read `.harmony/skills/manifest.yml` for skill discovery, then `.workspace/skills/manifest.yml` for project-specific skills.

### Quick Reference

- **Shared Manifest:** `.harmony/skills/manifest.yml` (Tier 1 discovery - read first)
- **Shared Registry:** `.harmony/skills/registry.yml` (extended metadata - read after match)
- **Local Skills:** `.workspace/skills/manifest.yml` and `registry.yml` (project-specific)
- **Skill Definitions:** `.harmony/skills/<skill-id>/SKILL.md` or `.workspace/skills/<skill-id>/SKILL.md`
- **Outputs:** `.workspace/skills/outputs/` (all skill writes here)
- **Logs:** `.workspace/skills/logs/runs/` (execution logs)

### Skill Discovery Order

**Workspace skills extend (not replace) shared skills.** Load order and precedence:

1. Read `.harmony/skills/manifest.yml` — shared skill index (loaded first)
2. Read `.workspace/skills/manifest.yml` — workspace-specific skills (extends shared)
3. **Merge behavior:** Workspace skills are added to the shared skill list
4. **Override behavior:** If a workspace skill has the same `id` as a shared skill:
   - Workspace `SKILL.md` replaces shared `SKILL.md` entirely (no merge)
   - Workspace manifest entry replaces shared manifest entry (no merge)
   - This enables workspace-specific customization of shared skills
5. **Trigger precedence:** Workspace-specific triggers take precedence for routing when multiple skills match

**Default skill:** If workspace manifest sets `default: <skill-id>`, it overrides the shared manifest's default.

**Extension vs Override:**

- **New skill** (id not in shared): Added to skill list (extension)
- **Same id as shared**: Workspace definition completely replaces shared definition (override)

### Progressive Disclosure

1. Read `.harmony/skills/manifest.yml` for skill index (id, name, summary, triggers)
2. Read `.workspace/skills/manifest.yml` for project-specific skills
3. After matching, read `registry.yml` for extended metadata (commands, parameters, context)
4. Load `SKILL.md` when a skill is activated (includes `allowed-tools` for tool permissions)
5. Load `references/` or `scripts/` only if needed

### Invocation

- Explicit command: `/synthesize-research <path>`
- Explicit call: `use skill: synthesize-research`
- Natural triggers: Match against `triggers` in manifest

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

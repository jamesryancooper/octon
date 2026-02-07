# Use Skill `/use-skill`

Invoke a workspace skill with explicit selection.

See `.harmony/capabilities/skills/registry.yml` for shared skills and `.harmony/capabilities/skills/registry.yml` for project-specific skills.

## Usage

```text
/use-skill <skill-id> [input-path]
```

**Examples:**
```text
/use-skill synthesize-research projects/auth-patterns/
/use-skill html-reader-builder outputs/refined/video-games.md
```

## Parameters

| Parameter | Required | Description |
|-----------|----------|-------------|
| `<skill-id>` | Yes | The skill identifier from registry.yml |
| `[input-path]` | Depends | Input file/folder as required by the skill |

## Implementation

1. Read `.harmony/capabilities/skills/registry.yml` for shared skill definitions
2. Read `.harmony/capabilities/skills/registry.yml` for project-specific mappings and additional skills
3. Load the skill definition from `.harmony/capabilities/skills/<skill-id>/SKILL.md`
4. Validate inputs match skill requirements
5. Execute the skill's behavior steps
6. Write outputs to `.harmony/capabilities/skills/outputs/` (always local)
7. Write run log to `.harmony/capabilities/skills/logs/runs/<timestamp>-<skill-id>.md`

## Progressive Disclosure

Skills use a three-tier loading model:

1. **Always:** Read `registry.yml` first (compact catalog)
2. **On demand:** Load `<skill-id>/SKILL.md` when selected
3. **Rare:** Load `reference/`, `templates/`, or `scripts/` only if needed

## Run Logging

Every skill execution produces a log entry with:
- `skill_id` and `skill_version`
- Inputs used (paths)
- Outputs created (paths)
- Tools used
- External calls (web search, http.fetch) with purpose
- Status (success/partial/failed)

## Alternative Invocation

Skills can also be invoked via:
- **Explicit call pattern:** `use skill: <skill-id>`
- **Skill-specific command:** `/<skill-command>` (e.g., `/synthesize-research`)

## References

- **Shared Registry:** `.harmony/capabilities/skills/registry.yml`
- **Local Registry:** `.harmony/capabilities/skills/registry.yml`
- **Documentation:** `docs/architecture/workspaces/skills.md`
- **Skills README:** `.harmony/capabilities/skills/README.md`

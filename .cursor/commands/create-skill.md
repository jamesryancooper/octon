# Create Skill `/create-skill`

Scaffold a new harness skill from template.

See `.harmony/orchestration/workflows/meta/create-skill(x)/00-overview.md` for full description and steps.

## Usage

```text
/create-skill <skill-id>
```

**Examples:**
```text
/create-skill history-researcher
/create-skill html-reader-builder
```

## Parameters

| Parameter | Required | Description |
|-----------|----------|-------------|
| `<skill-id>` | Yes | Lowercase kebab-case identifier (e.g., `my-skill`) |

## Implementation

Execute the workflow in `.harmony/orchestration/workflows/meta/create-skill(x)/`.

Start with `00-overview.md` and follow each step in sequence:

1. Validate skill ID format and uniqueness
2. Copy template from `.harmony/capabilities/skills/_template/` to `.harmony/capabilities/skills/<skill-id>/`
3. Initialize SKILL.md with ID
4. Add entry to `.harmony/capabilities/skills/registry.yml`
5. Update catalog.md skills table
6. Report success with next steps

## Notes

- New skills are created in `.harmony/capabilities/skills/` (project-specific)
- Shared skills live in `.harmony/capabilities/skills/` (manually promoted)
- Template lives in `.harmony/capabilities/skills/_template/`

## References

- **Workflow:** `.harmony/orchestration/workflows/meta/create-skill(x)/`
- **Template:** `.harmony/capabilities/skills/_template/SKILL.md`
- **Documentation:** `docs/architecture/harness/skills/README.md`

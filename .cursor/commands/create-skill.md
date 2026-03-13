# Create Skill `/create-skill`

Scaffold a new harness skill from template.

See `.octon/orchestration/runtime/workflows/meta/create-skill/README.md` for full description and steps.

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

Execute the workflow in `.octon/orchestration/runtime/workflows/meta/create-skill/`.

Start with `README.md` and follow each step in sequence:

1. Validate skill ID format and uniqueness
2. Copy template from `.octon/capabilities/skills/_template/` to `.octon/capabilities/skills/<skill-id>/`
3. Initialize SKILL.md with ID
4. Add entry to `.octon/capabilities/skills/registry.yml`
5. Update catalog.md skills table
6. Report success with next steps

## Notes

- New skills are created in `.octon/capabilities/skills/` (project-specific)
- Shared skills live in `.octon/capabilities/skills/` (manually promoted)
- Template lives in `.octon/capabilities/skills/_template/`

## References

- **Workflow:** `.octon/orchestration/runtime/workflows/meta/create-skill/`
- **Template:** `.octon/capabilities/skills/_template/SKILL.md`
- **Documentation:** `.octon/capabilities/skills/README.md`

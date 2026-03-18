# Create Skill `/create-skill`

Scaffold a new harness skill from template.

See `.octon/framework/orchestration/runtime/workflows/meta/create-skill/README.md` for full description and steps.

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

Execute the workflow in `.octon/framework/orchestration/runtime/workflows/meta/create-skill/`.

Start with `README.md` and follow each step in sequence:

1. Validate skill ID format and uniqueness
2. Copy template from `.octon/framework/capabilities/skills/_template/` to `.octon/framework/capabilities/skills/<skill-id>/`
3. Initialize SKILL.md with ID
4. Add entry to `.octon/framework/capabilities/skills/registry.yml`
5. Update catalog.md skills table
6. Report success with next steps

## Notes

- New skills are created in `.octon/framework/capabilities/skills/` (project-specific)
- Shared skills live in `.octon/framework/capabilities/skills/` (manually promoted)
- Template lives in `.octon/framework/capabilities/skills/_template/`

## References

- **Workflow:** `.octon/framework/orchestration/runtime/workflows/meta/create-skill/`
- **Template:** `.octon/framework/capabilities/skills/_template/SKILL.md`
- **Documentation:** `.octon/framework/capabilities/skills/README.md`

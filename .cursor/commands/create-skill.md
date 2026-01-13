# Create Skill `/create-skill`

Scaffold a new workspace skill from template.

See `.workspace/workflows/skills/create-skill/00-overview.md` for full description and steps.

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

Execute the workflow in `.workspace/workflows/skills/create-skill/`.

Start with `00-overview.md` and follow each step in sequence:

1. Validate skill ID format and uniqueness
2. Copy template to new skill directory
3. Initialize SKILL.md with ID
4. Add entry to registry.yml
5. Update catalog.md skills table
6. Report success with next steps

## References

- **Workflow:** `.workspace/workflows/skills/create-skill/`
- **Template:** `.workspace/skills/_template/SKILL.md`
- **Documentation:** `docs/architecture/workspaces/skills.md`

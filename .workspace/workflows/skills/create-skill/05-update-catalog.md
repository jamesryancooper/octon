---
title: Update Catalog
description: Add skill to catalog.md skills table.
---

# Step 5: Update Catalog

## Input

- `skill-id` from Step 1
- Registry entry from Step 4

## Actions

Update `.workspace/catalog.md` Skills section table:

```markdown
## Skills

Composable capabilities in `skills/`:

| Skill | Commands | Description |
|-------|----------|-------------|
| [<skill-id>](./skills/<skill-id>/skill.md) | `/<skill-id>` | [TODO: Description] |
```

If the table only has the placeholder row ("*No skills defined yet*"), replace it with the new skill entry.

## Verification

- Skills table in `catalog.md` includes new skill
- Link to `skill.md` is correct
- Command matches registry

## Output

- Updated `catalog.md` with new skill entry
- Proceed to Step 6

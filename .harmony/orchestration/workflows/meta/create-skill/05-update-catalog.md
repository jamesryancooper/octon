---
title: Update Catalog
description: Add skill to catalog.md skills table.
---

# Step 5: Update Catalog

## Input

- `skill-id` from Step 1
- Registry entry from Step 4

## Actions

Update `.harmony/catalog.md` Skills section table:

```markdown
## Skills

Composable capabilities in `skills/`:

| Skill | Commands | Description |
|-------|----------|-------------|
| [<skill-id>](/.harmony/capabilities/skills/<group>/<skill-id>/SKILL.md) | `/<skill-id>` | [TODO: Description] |
```

If the table only has the placeholder row ("*No skills defined yet*"), replace it with the new skill entry.

## Verification

- Skills table in `catalog.md` includes new skill
- Link to `SKILL.md` is correct
- Command matches registry

## Idempotency

**Check:** Is catalog already updated?
- [ ] Skills table in `catalog.md` contains entry for `<skill-id>`
- [ ] Entry has correct link and command

**If Already Complete:**
- Verify entry is correct
- Skip to next step

**Marker:** `checkpoints/create-skill/<skill-id>/05-catalog.complete`

## Output

- Updated `catalog.md` with new skill entry
- Proceed to Step 6

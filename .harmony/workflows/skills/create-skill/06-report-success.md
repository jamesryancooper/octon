---
title: Report Success
description: Confirm skill creation and provide next steps.
---

# Step 6: Report Success

## Input

- Completed steps 1-5

## Actions

Report to user:

```markdown
## Skill Created: <skill-id>

**Location:** `.workspace/skills/<skill-id>/`

**Files created:**
- `skill.md` — Skill definition (ready for customization)
- `templates/` — For skill-specific templates
- `reference/` — For detailed reference material

**Registry updated:** `skills/registry.yml`
**Catalog updated:** `.workspace/catalog.md`

### Next Steps

1. **Edit `skill.md`** to define:
   - Description and summary
   - Commands and triggers
   - Input/output specifications
   - Behavior steps
   - Safety policies
   - Acceptance criteria

2. **Update `registry.yml`** with:
   - Human-readable name
   - Summary for routing
   - Input/output patterns
   - Tool requirements

3. **Test the skill** by invoking:
   ```text
   /<skill-id> [input-path]
   ```

### Documentation

- Skill guide: `docs/architecture/workspaces/skills.md`
- Template reference: `.workspace/skills/_template/skill.md`
```

## Verification

- All steps completed successfully
- User has clear next steps

## Output

- Skill creation complete
- Workflow finished

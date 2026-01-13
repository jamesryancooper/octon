---
title: Validate Skill ID
description: Check skill ID format and uniqueness.
---

# Step 1: Validate Skill ID

## Input

- `skill-id`: The proposed skill identifier

## Validation Rules

1. **Format check:**
   - Must be lowercase
   - Must use hyphens (not underscores or spaces)
   - Must start with a letter
   - Pattern: `^[a-z][a-z0-9-]*$`

2. **Uniqueness check:**
   - Read `skills/registry.yml`
   - Check that no skill has matching `id`

## Actions

```text
1. Validate skill-id matches pattern ^[a-z][a-z0-9-]*$
2. Read skills/registry.yml
3. Check skills[] array for existing id match
4. If invalid or exists, STOP and report error
5. If valid and unique, proceed to Step 2
```

## Error Messages

- Invalid format: "Skill ID must be lowercase with hyphens (e.g., 'history-researcher')"
- Already exists: "Skill '[id]' already exists in registry.yml"

## Output

- Validated skill ID ready for use
- Proceed to Step 2

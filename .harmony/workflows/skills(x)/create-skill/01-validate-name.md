---
title: Validate Skill Name
description: Check skill name format, naming convention, and uniqueness.
---

# Step 1: Validate Skill Name

## Input

- `skill-name`: The proposed skill identifier

## Validation Rules

### 1. Format Check (Required - Blocking)

Per [agentskills.io/specification](https://agentskills.io/specification):

- Must be 1-64 characters
- Must be lowercase letters, numbers, and hyphens only
- Must not start or end with a hyphen
- Must not contain consecutive hyphens (`--`)
- Pattern: `^[a-z][a-z0-9]*(-[a-z0-9]+)*$`

**Valid examples:**
- `refine-prompt`
- `generate-report`
- `analyze-codebase`

**Invalid examples:**
- `Refine-Prompt` (uppercase not allowed)
- `-refine-prompt` (cannot start with hyphen)
- `refine--prompt` (consecutive hyphens not allowed)
- `refine-prompt-` (cannot end with hyphen)

### 2. Naming Convention Check (Recommended - Warning Only)

Skills should use **action-oriented names** following verb-noun pattern:

| Pattern | Examples |
|---------|----------|
| verb-noun | `refine-prompt`, `generate-report`, `validate-schema` |
| verb-object | `analyze-codebase`, `process-payment`, `extract-data` |
| action-target | `build-project`, `run-tests`, `deploy-service` |

**Common action verbs:**
- `analyze`, `build`, `create`, `deploy`, `extract`
- `generate`, `process`, `refine`, `run`, `validate`
- `transform`, `convert`, `export`, `import`, `sync`

If name doesn't start with a common verb, issue a **warning** (not blocking):
> "Consider using an action-oriented name like 'verb-noun' (e.g., 'analyze-data' instead of 'data-analyzer')"

### 3. Uniqueness Check (Required - Blocking)

- Read `skills/registry.yml`
- Check that no skill has matching `name` or `id`

## Actions

```text
1. Validate skill-name matches pattern ^[a-z][a-z0-9]*(-[a-z0-9]+)*$
2. Validate length is 1-64 characters
3. Check if name starts with common action verb
   - If not, warn but continue
4. Read skills/registry.yml
5. Check skills[] array for existing name/id match
6. If format invalid or name exists, STOP and report error
7. If valid and unique, proceed to Step 2
```

## Error Messages

- Invalid format: "Skill name must be 1-64 lowercase characters with hyphens (e.g., 'refine-prompt')"
- Consecutive hyphens: "Skill name cannot contain consecutive hyphens (--)"
- Already exists: "Skill '[name]' already exists in registry.yml"

## Warning Messages

- Non-action name: "Consider using an action-oriented name starting with a verb (e.g., 'analyze-data' instead of 'data-analyzer')"

## Idempotency

**Check:** Is validation already complete for this skill-name?
- [ ] Checkpoint file exists: `checkpoints/create-skill/<skill-name>/01-validate.complete`
- [ ] Validation passed previously

**If Already Complete:**
- Load cached validation result
- Skip to next step

**Marker:** `checkpoints/create-skill/<skill-name>/01-validate.complete`

## Output

- Validated skill name ready for use
- Any naming convention warnings noted
- Proceed to Step 2

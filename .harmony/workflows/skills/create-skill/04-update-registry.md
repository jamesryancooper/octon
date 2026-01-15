---
title: Update Registry
description: Add new skill entry to registry.yml following agentskills.io conventions.
---

# Step 4: Update Registry

## Input

- `skill-name` from Step 1
- Initialized skill from Step 3

## Actions

Add entry to `skills/registry.yml` under `skills:` array:

```yaml
skills:
  # ... existing skills ...

  - id: <skill-name>
    name: "[Human-Readable Name - TODO]"
    path: <skill-name>/
    version: "0.1.0"
    summary: "[TODO: One-line description for routing]"
    commands:
      - /<skill-name>
    explicit_call_patterns:
      - "use skill: <skill-name>"
    triggers: []
    requires:
      tools:
        - filesystem.read
        - filesystem.write.outputs
    depends_on: []
```

## Registry Entry Fields

| Field | Purpose | Spec Alignment |
|-------|---------|----------------|
| `id` | Unique identifier, matches directory | Matches `name` in SKILL.md |
| `name` | Human-readable display name | User-friendly version |
| `path` | Relative path to skill directory | Directory reference |
| `version` | Skill version | From `metadata.version` |
| `summary` | Brief description for routing | From `description` |
| `commands` | Slash commands | Invocation |
| `explicit_call_patterns` | Direct invocation patterns | Invocation |
| `triggers` | Natural language triggers | Activation |
| `requires.tools` | Required tool permissions | From `allowed-tools` |
| `depends_on` | Skill dependencies | Execution order |

## Verification

- Entry added to `skills:` array
- `id` matches skill directory name
- `path` points to correct directory
- `commands` includes `/<skill-name>`
- `explicit_call_patterns` includes `use skill: <skill-name>`

## Idempotency

**Check:** Is registry already updated?
- [ ] Entry with `id: <skill-name>` exists in `registry.yml`
- [ ] Entry has correct `path` value

**If Already Complete:**
- Verify entry is correct
- Skip to next step

**Marker:** `checkpoints/create-skill/<skill-name>/04-registry.complete`

## Output

- Updated `registry.yml` with new skill entry
- Proceed to Step 5

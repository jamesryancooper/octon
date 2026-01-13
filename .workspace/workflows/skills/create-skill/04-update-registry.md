---
title: Update Registry
description: Add new skill entry to registry.yml.
---

# Step 4: Update Registry

## Input

- `skill-id` from Step 1
- Initialized skill from Step 3

## Actions

Add entry to `skills/registry.yml` under `skills:` array:

```yaml
skills:
  # ... existing skills ...

  - id: <skill-id>
    name: "[Skill Name - TODO]"
    path: <skill-id>/
    version: "0.1.0"
    summary: "[TODO: One-line description]"
    commands:
      - /<skill-id>
    explicit_call_patterns:
      - "use skill: <skill-id>"
    triggers: []
    inputs: []
    outputs: []
    requires:
      tools:
        - filesystem.read
        - filesystem.write.outputs
    depends_on: []
```

## Verification

- Entry added to `skills:` array
- `id` matches skill directory name
- `path` points to correct directory
- `explicit_call_patterns` included

## Output

- Updated `registry.yml` with new skill entry
- Proceed to Step 5

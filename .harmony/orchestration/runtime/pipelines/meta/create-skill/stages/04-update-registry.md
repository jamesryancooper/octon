---
title: Update Manifest and Registry
description: Add new skill entry to manifest.yml and registry.yml following agentskills.io conventions.
---

# Step 4: Update Manifest and Registry

## Input

- `skill-name` from Step 1
- Initialized skill from Step 3

## Actions

### 1. Add entry to `manifest.yml` (Tier 1 Discovery)

Add to `.harmony/capabilities/runtime/skills/manifest.yml` under `skills:` array:

```yaml
skills:
  # ... existing skills ...

  - id: <skill-name>
    name: "[Human-Readable Name - TODO]"
    path: <skill-name>/
    summary: "[TODO: One-line description for routing]"
    status: active
    tags:
      - "[TODO: category-tag]"
    triggers:
      - "[TODO: natural language trigger]"
```

### 2. Add entry to `registry.yml` (Extended Metadata)

Add to `.harmony/capabilities/runtime/skills/registry.yml` under `skills:` map:

```yaml
skills:
  # ... existing skills ...

  <skill-name>:
    version: "0.1.0"
    commands:
      - /<skill-name>
    requires:
      tools:
        - filesystem.read
        - filesystem.write.outputs
      context:
        - type: directory_exists
          path: ".harmony/"
          description: "Requires a harness directory"
    depends_on: []
```

## Manifest Entry Fields (Tier 1 Discovery)

| Field | Purpose | Required |
|-------|---------|----------|
| `id` | Unique identifier, matches directory | Yes |
| `name` | Human-readable display name | Yes |
| `path` | Relative path to skill directory | Yes |
| `summary` | Brief description for routing | Yes |
| `status` | Lifecycle state (active/deprecated/experimental) | No |
| `tags` | Freeform labels for filtering | No |
| `triggers` | Natural language activation phrases | No |

## Registry Entry Fields (Extended Metadata)

| Field | Purpose | Required |
|-------|---------|----------|
| `version` | Semantic version | No |
| `commands` | Slash commands for invocation | Yes |
| `requires.tools` | Required tool permissions | No |
| `requires.context` | Context conditions for activation | No |
| `depends_on` | Skill dependencies | No |

**Note:** The `use skill: <skill-name>` pattern is universal and recognized automatically. It does not require per-skill configuration.

## Verification

- Entry added to `manifest.yml` skills array
- Entry added to `registry.yml` skills map
- `id` matches skill directory name
- `commands` includes `/<skill-name>`

## Idempotency

**Check:** Are manifest and registry already updated?
- [ ] Entry with `id: <skill-name>` exists in `manifest.yml`
- [ ] Entry with key `<skill-name>` exists in `registry.yml`

**If Already Complete:**
- Verify entries are correct
- Skip to next step

**Marker:** `checkpoints/create-skill/<skill-name>/04-registry.complete`

## Output

- Updated `manifest.yml` with new skill entry
- Updated `registry.yml` with extended metadata
- Proceed to Step 5

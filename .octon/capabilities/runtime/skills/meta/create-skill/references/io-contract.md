---
title: I/O Contract
description: Authoritative input and output guidance for the create-skill skill.
---

# Create Skill I/O Contract

## Inputs

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `skill_name` | text | Yes | New skill id in kebab-case |
| `group` | text | Yes | Canonical skill group directory |
| `description` | text | No | Initial SKILL.md description |
| `skill_sets` | text | No | Comma-separated skill sets |
| `capabilities` | text | No | Comma-separated capabilities |

## Manifest Output

The created manifest entry must include:

```yaml
- id: your-skill
  display_name: Your Skill
  group: audit
  path: audit/your-skill/
  skill_class: invocable
  summary: "One-line routing summary."
  status: active
  tags: [audit]
  triggers: ["run your skill"]
  skill_sets: [executor]
  capabilities: []
```

## Registry Output

The created registry entry must include:

```yaml
your-skill:
  version: "1.0.0"
  commands:
    - /your-skill
  parameters: []
  requires:
    context: []
  io:
    inputs: []
    outputs: []
```

Add `composition` only when the skill actually declares prerequisite or invoke steps.

## Filesystem Outputs

- `.octon/capabilities/runtime/skills/<group>/<skill_name>/`
- `.octon/capabilities/runtime/skills/_ops/state/runs/create-skill/{{run_id}}/`
- `.octon/capabilities/runtime/skills/_ops/state/logs/create-skill/{{run_id}}.md`

## Placeholder Rules

- `{{group}}` and `{{skill_name}}` are allowed because they are declared parameters.
- Any other path placeholder must be either a standard placeholder from `capabilities.yml` or a declared parameter name.
- Do not emit `depends_on` or top-level `pipelines` in generated registry content.

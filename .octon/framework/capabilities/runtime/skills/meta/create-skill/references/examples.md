---
title: Examples
description: Example create-skill invocations and resulting contract shapes.
---

# Create Skill Examples

## Example 1: Standard Invocable Skill

```text
/create-skill skill_name="analyze-codebase" group="audit"
```

Expected result:

- Manifest entry with `skill_class: invocable`
- Registry entry with `commands`, `parameters`, `requires.context`, and `io`
- No `composition` block

## Example 2: Context Skill

```text
/create-skill skill_name="go-platform" group="platforms"
```

After scaffolding, set `skill_class: context` in manifest and keep `commands: []` in registry if the skill is only routing/background guidance.

## Example 3: Composite Skill

```text
/create-skill skill_name="quality-bundle" group="audit"
```

Expected registry addition when the skill bundles children:

```yaml
composition:
  mode: sequential
  failure_policy: fail_fast
  steps:
    - id: audit-subsystem-health
      kind: skill
      ref: audit-subsystem-health
      role: invoke
      required: true
```

Expected frontmatter:

```yaml
skill_sets: [executor, guardian, integrator]
capabilities: []
```

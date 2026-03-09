---
name: "create-skill"
description: "Scaffold a new skill from template, initialize contract content, and register it in discovery artifacts."
steps:
  - id: "validate-name"
    file: "01-validate-name.md"
    description: "validate-name"
  - id: "copy-template"
    file: "02-copy-template.md"
    description: "copy-template"
  - id: "initialize-skill"
    file: "03-initialize-skill.md"
    description: "initialize-skill"
  - id: "update-registry"
    file: "04-update-registry.md"
    description: "update-registry"
  - id: "update-catalog"
    file: "05-update-catalog.md"
    description: "update-catalog"
  - id: "report-success"
    file: "06-report-success.md"
    description: "report-success"
---

# Create Skill

_Generated projection from canonical pipeline `create-skill`._

## Usage

```text
/create-skill
```

## Target

This projection wraps the canonical pipeline `create-skill` for staged human review and slash-facing compatibility.

## Prerequisites

- Required pipeline inputs are available.
- Canonical pipeline assets exist under `.harmony/orchestration/runtime/pipelines/meta/create-skill`.

## Failure Conditions

- Required inputs are missing or invalid.
- The backing canonical pipeline contract or stage assets are missing.
- Verification criteria are not satisfied.

## Steps

1. [validate-name](./01-validate-name.md)
2. [copy-template](./02-copy-template.md)
3. [initialize-skill](./03-initialize-skill.md)
4. [update-registry](./04-update-registry.md)
5. [update-catalog](./05-update-catalog.md)
6. [report-success](./06-report-success.md)

## Verification Gate

- [ ] verification stage passes

## Version History

| Version | Changes |
|---------|---------|
| 2.0.0 | Generated from canonical pipeline `create-skill` |

## References

- Canonical pipeline: `.harmony/orchestration/runtime/pipelines/meta/create-skill/`

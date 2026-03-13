---
name: "create-skill"
description: "Scaffold a new skill from template, initialize contract content, and register it in discovery artifacts."
steps:
  - id: "validate-name"
    file: "stages/01-validate-name.md"
    description: "validate-name"
  - id: "copy-template"
    file: "stages/02-copy-template.md"
    description: "copy-template"
  - id: "initialize-skill"
    file: "stages/03-initialize-skill.md"
    description: "initialize-skill"
  - id: "update-registry"
    file: "stages/04-update-registry.md"
    description: "update-registry"
  - id: "update-catalog"
    file: "stages/05-update-catalog.md"
    description: "update-catalog"
  - id: "report-success"
    file: "stages/06-report-success.md"
    description: "report-success"
---

# Create Skill

_Generated README from canonical workflow `create-skill`._

## Usage

```text
/create-skill
```

## Purpose

Scaffold a new skill from template, initialize contract content, and register it in discovery artifacts.

## Target

This README summarizes the canonical workflow unit at `.octon/orchestration/runtime/workflows/meta/create-skill`.

## Prerequisites

- Required workflow inputs are available.
- Canonical workflow contract exists at `.octon/orchestration/runtime/workflows/meta/create-skill/workflow.yml`.

## Failure Conditions

- Required inputs are missing or invalid.
- The canonical workflow contract or stage assets are missing.
- Verification criteria are not satisfied.

## Steps

1. [validate-name](./stages/01-validate-name.md)
2. [copy-template](./stages/02-copy-template.md)
3. [initialize-skill](./stages/03-initialize-skill.md)
4. [update-registry](./stages/04-update-registry.md)
5. [update-catalog](./stages/05-update-catalog.md)
6. [report-success](./stages/06-report-success.md)

## Verification Gate

- [ ] verification stage passes

## References

- Canonical contract: `.octon/orchestration/runtime/workflows/meta/create-skill/workflow.yml`
- Canonical stages: `.octon/orchestration/runtime/workflows/meta/create-skill/stages/`

## Version History

| Version | Changes |
|---------|---------|
| 2.0.0 | Generated from canonical workflow `create-skill` |


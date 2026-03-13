---
name: "create-workflow"
description: "Scaffold a canonical workflow, wire discovery metadata, and regenerate the compatibility workflow README."
steps:
  - id: "validate-id"
    file: "stages/01-validate-id.md"
    description: "validate-id"
  - id: "analyze-requirements"
    file: "stages/02-analyze-requirements.md"
    description: "analyze-requirements"
  - id: "select-template"
    file: "stages/03-select-template.md"
    description: "select-template"
  - id: "generate-structure"
    file: "stages/04-generate-structure.md"
    description: "generate-structure"
  - id: "customize-steps"
    file: "stages/05-customize-steps.md"
    description: "customize-steps"
  - id: "integrate-gap-fixes"
    file: "stages/06-integrate-gap-fixes.md"
    description: "integrate-gap-fixes"
  - id: "update-references"
    file: "stages/07-update-references.md"
    description: "update-references"
  - id: "verify"
    file: "stages/08-verify.md"
    description: "verify"
---

# Create Workflow

_Generated README from canonical workflow `create-workflow`._

## Usage

```text
/create-workflow
```

## Purpose

Scaffold a canonical workflow, wire discovery metadata, and regenerate the compatibility workflow README.

## Target

This README summarizes the canonical workflow unit at `.octon/orchestration/runtime/workflows/meta/create-workflow`.

## Prerequisites

- Required workflow inputs are available.
- Canonical workflow contract exists at `.octon/orchestration/runtime/workflows/meta/create-workflow/workflow.yml`.

## Failure Conditions

- Required inputs are missing or invalid.
- The canonical workflow contract or stage assets are missing.
- Verification criteria are not satisfied.

## Steps

1. [validate-id](./stages/01-validate-id.md)
2. [analyze-requirements](./stages/02-analyze-requirements.md)
3. [select-template](./stages/03-select-template.md)
4. [generate-structure](./stages/04-generate-structure.md)
5. [customize-steps](./stages/05-customize-steps.md)
6. [integrate-gap-fixes](./stages/06-integrate-gap-fixes.md)
7. [update-references](./stages/07-update-references.md)
8. [verify](./stages/08-verify.md)

## Verification Gate

- [ ] verification stage passes

## References

- Canonical contract: `.octon/orchestration/runtime/workflows/meta/create-workflow/workflow.yml`
- Canonical stages: `.octon/orchestration/runtime/workflows/meta/create-workflow/stages/`

## Version History

| Version | Changes |
|---------|---------|
| 1.0.0 | Generated from canonical workflow `create-workflow` |


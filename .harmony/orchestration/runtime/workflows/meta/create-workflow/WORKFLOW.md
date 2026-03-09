---
name: "create-workflow"
description: "Scaffold a canonical pipeline, wire discovery metadata, and regenerate the compatibility workflow projection."
steps:
  - id: "validate-id"
    file: "01-validate-id.md"
    description: "validate-id"
  - id: "analyze-requirements"
    file: "02-analyze-requirements.md"
    description: "analyze-requirements"
  - id: "select-template"
    file: "03-select-template.md"
    description: "select-template"
  - id: "generate-structure"
    file: "04-generate-structure.md"
    description: "generate-structure"
  - id: "customize-steps"
    file: "05-customize-steps.md"
    description: "customize-steps"
  - id: "integrate-gap-fixes"
    file: "06-integrate-gap-fixes.md"
    description: "integrate-gap-fixes"
  - id: "update-references"
    file: "07-update-references.md"
    description: "update-references"
  - id: "verify"
    file: "08-verify.md"
    description: "verify"
---

# Create Workflow

_Generated projection from canonical pipeline `create-workflow`._

## Usage

```text
/create-workflow
```

## Target

This projection wraps the canonical pipeline `create-workflow` for staged human review and slash-facing compatibility.

## Prerequisites

- Required pipeline inputs are available.
- Canonical pipeline assets exist under `.harmony/orchestration/runtime/pipelines/meta/create-workflow`.

## Failure Conditions

- Required inputs are missing or invalid.
- The backing canonical pipeline contract or stage assets are missing.
- Verification criteria are not satisfied.

## Steps

1. [validate-id](./01-validate-id.md)
2. [analyze-requirements](./02-analyze-requirements.md)
3. [select-template](./03-select-template.md)
4. [generate-structure](./04-generate-structure.md)
5. [customize-steps](./05-customize-steps.md)
6. [integrate-gap-fixes](./06-integrate-gap-fixes.md)
7. [update-references](./07-update-references.md)
8. [verify](./08-verify.md)

## Verification Gate

- [ ] verification stage passes

## Version History

| Version | Changes |
|---------|---------|
| 1.0.0 | Generated from canonical pipeline `create-workflow` |

## References

- Canonical pipeline: `.harmony/orchestration/runtime/pipelines/meta/create-workflow/`

---
name: "create-harness"
description: "Scaffold a new .harmony directory in a target location, then customize it to the target repository context."
steps:
  - id: "validate-prerequisites"
    file: "01-validate-prerequisites.md"
    description: "validate-prerequisites"
  - id: "validate-target"
    file: "02-validate-target.md"
    description: "validate-target"
  - id: "analyze-context"
    file: "03-analyze-context.md"
    description: "analyze-context"
  - id: "gather-input"
    file: "04-gather-input.md"
    description: "gather-input"
  - id: "copy-templates"
    file: "05-copy-templates.md"
    description: "copy-templates"
  - id: "customize"
    file: "06-customize.md"
    description: "customize"
  - id: "verify"
    file: "07-verify.md"
    description: "verify"
---

# Create Harness

_Generated projection from canonical pipeline `create-harness`._

## Usage

```text
/create-harness
```

## Target

This projection wraps the canonical pipeline `create-harness` for staged human review and slash-facing compatibility.

## Prerequisites

- Required pipeline inputs are available.
- Canonical pipeline assets exist under `.harmony/orchestration/runtime/pipelines/meta/create-harness`.

## Failure Conditions

- Required inputs are missing or invalid.
- The backing canonical pipeline contract or stage assets are missing.
- Verification criteria are not satisfied.

## Steps

1. [validate-prerequisites](./01-validate-prerequisites.md)
2. [validate-target](./02-validate-target.md)
3. [analyze-context](./03-analyze-context.md)
4. [gather-input](./04-gather-input.md)
5. [copy-templates](./05-copy-templates.md)
6. [customize](./06-customize.md)
7. [verify](./07-verify.md)

## Verification Gate

- [ ] verification stage passes

## Version History

| Version | Changes |
|---------|---------|
| 1.2.0 | Generated from canonical pipeline `create-harness` |

## References

- Canonical pipeline: `.harmony/orchestration/runtime/pipelines/meta/create-harness/`

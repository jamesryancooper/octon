---
name: "update-workflow"
description: "Update a canonical pipeline, regenerate the workflow projection, and verify the resulting orchestration surface."
steps:
  - id: "audit-current"
    file: "01-audit-current.md"
    description: "audit-current"
  - id: "identify-gaps"
    file: "02-identify-gaps.md"
    description: "identify-gaps"
  - id: "plan-changes"
    file: "03-plan-changes.md"
    description: "plan-changes"
  - id: "execute-changes"
    file: "04-execute-changes.md"
    description: "execute-changes"
  - id: "verify-update"
    file: "05-verify-update.md"
    description: "verify-update"
---

# Update Workflow

_Generated projection from canonical pipeline `update-workflow`._

## Usage

```text
/update-workflow
```

## Target

This projection wraps the canonical pipeline `update-workflow` for staged human review and slash-facing compatibility.

## Prerequisites

- Required pipeline inputs are available.
- Canonical pipeline assets exist under `.harmony/orchestration/runtime/pipelines/meta/update-workflow`.

## Failure Conditions

- Required inputs are missing or invalid.
- The backing canonical pipeline contract or stage assets are missing.
- Verification criteria are not satisfied.

## Steps

1. [audit-current](./01-audit-current.md)
2. [identify-gaps](./02-identify-gaps.md)
3. [plan-changes](./03-plan-changes.md)
4. [execute-changes](./04-execute-changes.md)
5. [verify-update](./05-verify-update.md)

## Verification Gate

- [ ] verification stage passes

## Version History

| Version | Changes |
|---------|---------|
| 1.0.0 | Generated from canonical pipeline `update-workflow` |

## References

- Canonical pipeline: `.harmony/orchestration/runtime/pipelines/meta/update-workflow/`

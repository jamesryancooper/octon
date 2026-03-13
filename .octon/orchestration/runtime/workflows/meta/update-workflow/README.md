---
name: "update-workflow"
description: "Update a canonical workflow, regenerate the workflow README, and verify the resulting orchestration surface."
steps:
  - id: "audit-current"
    file: "stages/01-audit-current.md"
    description: "audit-current"
  - id: "identify-gaps"
    file: "stages/02-identify-gaps.md"
    description: "identify-gaps"
  - id: "plan-changes"
    file: "stages/03-plan-changes.md"
    description: "plan-changes"
  - id: "execute-changes"
    file: "stages/04-execute-changes.md"
    description: "execute-changes"
  - id: "verify-update"
    file: "stages/05-verify-update.md"
    description: "verify-update"
---

# Update Workflow

_Generated README from canonical workflow `update-workflow`._

## Usage

```text
/update-workflow
```

## Purpose

Update a canonical workflow, regenerate the workflow README, and verify the resulting orchestration surface.

## Target

This README summarizes the canonical workflow unit at `.octon/orchestration/runtime/workflows/meta/update-workflow`.

## Prerequisites

- Required workflow inputs are available.
- Canonical workflow contract exists at `.octon/orchestration/runtime/workflows/meta/update-workflow/workflow.yml`.

## Failure Conditions

- Required inputs are missing or invalid.
- The canonical workflow contract or stage assets are missing.
- Verification criteria are not satisfied.

## Steps

1. [audit-current](./stages/01-audit-current.md)
2. [identify-gaps](./stages/02-identify-gaps.md)
3. [plan-changes](./stages/03-plan-changes.md)
4. [execute-changes](./stages/04-execute-changes.md)
5. [verify-update](./stages/05-verify-update.md)

## Verification Gate

- [ ] verification stage passes

## References

- Canonical contract: `.octon/orchestration/runtime/workflows/meta/update-workflow/workflow.yml`
- Canonical stages: `.octon/orchestration/runtime/workflows/meta/update-workflow/stages/`

## Version History

| Version | Changes |
|---------|---------|
| 1.0.0 | Generated from canonical workflow `update-workflow` |


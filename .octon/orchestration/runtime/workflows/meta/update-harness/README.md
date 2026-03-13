---
name: "update-harness"
description: "Align an existing harness with current canonical conventions by auditing gaps, planning updates, and executing bounded remediations."
steps:
  - id: "audit-state"
    file: "stages/01-audit-state.md"
    description: "audit-state"
  - id: "identify-gaps"
    file: "stages/02-identify-gaps.md"
    description: "identify-gaps"
  - id: "assess-tokens"
    file: "stages/03-assess-tokens.md"
    description: "assess-tokens"
  - id: "propose-changes"
    file: "stages/04-propose-changes.md"
    description: "propose-changes"
  - id: "execute"
    file: "stages/05-execute.md"
    description: "execute"
---

# Update Harness

_Generated README from canonical workflow `update-harness`._

## Usage

```text
/update-harness
```

## Purpose

Align an existing harness with current canonical conventions by auditing gaps, planning updates, and executing bounded remediations.

## Target

This README summarizes the canonical workflow unit at `.octon/orchestration/runtime/workflows/meta/update-harness`.

## Prerequisites

- Required workflow inputs are available.
- Canonical workflow contract exists at `.octon/orchestration/runtime/workflows/meta/update-harness/workflow.yml`.

## Failure Conditions

- Required inputs are missing or invalid.
- The canonical workflow contract or stage assets are missing.
- Verification criteria are not satisfied.

## Steps

1. [audit-state](./stages/01-audit-state.md)
2. [identify-gaps](./stages/02-identify-gaps.md)
3. [assess-tokens](./stages/03-assess-tokens.md)
4. [propose-changes](./stages/04-propose-changes.md)
5. [execute](./stages/05-execute.md)

## Verification Gate

- [ ] verification stage passes

## References

- Canonical contract: `.octon/orchestration/runtime/workflows/meta/update-harness/workflow.yml`
- Canonical stages: `.octon/orchestration/runtime/workflows/meta/update-harness/stages/`

## Version History

| Version | Changes |
|---------|---------|
| 1.1.0 | Generated from canonical workflow `update-harness` |


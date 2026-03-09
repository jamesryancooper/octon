---
name: "update-harness"
description: "Align an existing harness with current canonical conventions by auditing gaps, planning updates, and executing bounded remediations."
steps:
  - id: "audit-state"
    file: "01-audit-state.md"
    description: "audit-state"
  - id: "identify-gaps"
    file: "02-identify-gaps.md"
    description: "identify-gaps"
  - id: "assess-tokens"
    file: "03-assess-tokens.md"
    description: "assess-tokens"
  - id: "propose-changes"
    file: "04-propose-changes.md"
    description: "propose-changes"
  - id: "execute"
    file: "05-execute.md"
    description: "execute"
---

# Update Harness

_Generated projection from canonical pipeline `update-harness`._

## Usage

```text
/update-harness
```

## Target

This projection wraps the canonical pipeline `update-harness` for staged human review and slash-facing compatibility.

## Prerequisites

- Required pipeline inputs are available.
- Canonical pipeline assets exist under `.harmony/orchestration/runtime/pipelines/meta/update-harness`.

## Failure Conditions

- Required inputs are missing or invalid.
- The backing canonical pipeline contract or stage assets are missing.
- Verification criteria are not satisfied.

## Steps

1. [audit-state](./01-audit-state.md)
2. [identify-gaps](./02-identify-gaps.md)
3. [assess-tokens](./03-assess-tokens.md)
4. [propose-changes](./04-propose-changes.md)
5. [execute](./05-execute.md)

## Verification Gate

- [ ] verification stage passes

## Version History

| Version | Changes |
|---------|---------|
| 1.1.0 | Generated from canonical pipeline `update-harness` |

## References

- Canonical pipeline: `.harmony/orchestration/runtime/pipelines/meta/update-harness/`

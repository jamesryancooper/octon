---
name: "refactor"
description: "Execute a verified refactor workflow: define scope, audit impact, plan changes, execute safely, verify outcomes, and document results."
steps:
  - id: "define-scope"
    file: "01-define-scope.md"
    description: "define-scope"
  - id: "audit"
    file: "02-audit.md"
    description: "audit"
  - id: "plan"
    file: "03-plan.md"
    description: "plan"
  - id: "execute"
    file: "04-execute.md"
    description: "execute"
  - id: "verify"
    file: "05-verify.md"
    description: "verify"
  - id: "document"
    file: "06-document.md"
    description: "document"
---

# Refactor

_Generated projection from canonical pipeline `refactor`._

## Usage

```text
/refactor
```

## Target

This projection wraps the canonical pipeline `refactor` for staged human review and slash-facing compatibility.

## Prerequisites

- Required pipeline inputs are available.
- Canonical pipeline assets exist under `.harmony/orchestration/runtime/pipelines/refactor/refactor`.

## Failure Conditions

- Required inputs are missing or invalid.
- The backing canonical pipeline contract or stage assets are missing.
- Verification criteria are not satisfied.

## Steps

1. [define-scope](./01-define-scope.md)
2. [audit](./02-audit.md)
3. [plan](./03-plan.md)
4. [execute](./04-execute.md)
5. [verify](./05-verify.md)
6. [document](./06-document.md)

## Verification Gate

- [ ] verification stage passes

## Version History

| Version | Changes |
|---------|---------|
| 1.1.0 | Generated from canonical pipeline `refactor` |

## References

- Canonical pipeline: `.harmony/orchestration/runtime/pipelines/refactor/refactor/`

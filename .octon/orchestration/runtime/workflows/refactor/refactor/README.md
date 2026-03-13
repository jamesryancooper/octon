---
name: "refactor"
description: "Execute a verified refactor workflow: define scope, audit impact, plan changes, execute safely, verify outcomes, and document results."
steps:
  - id: "define-scope"
    file: "stages/01-define-scope.md"
    description: "define-scope"
  - id: "audit"
    file: "stages/02-audit.md"
    description: "audit"
  - id: "plan"
    file: "stages/03-plan.md"
    description: "plan"
  - id: "execute"
    file: "stages/04-execute.md"
    description: "execute"
  - id: "verify"
    file: "stages/05-verify.md"
    description: "verify"
  - id: "document"
    file: "stages/06-document.md"
    description: "document"
---

# Refactor

_Generated README from canonical workflow `refactor`._

## Usage

```text
/refactor
```

## Purpose

Execute a verified refactor workflow: define scope, audit impact, plan changes, execute safely, verify outcomes, and document results.

## Target

This README summarizes the canonical workflow unit at `.octon/orchestration/runtime/workflows/refactor/refactor`.

## Prerequisites

- Required workflow inputs are available.
- Canonical workflow contract exists at `.octon/orchestration/runtime/workflows/refactor/refactor/workflow.yml`.

## Failure Conditions

- Required inputs are missing or invalid.
- The canonical workflow contract or stage assets are missing.
- Verification criteria are not satisfied.

## Steps

1. [define-scope](./stages/01-define-scope.md)
2. [audit](./stages/02-audit.md)
3. [plan](./stages/03-plan.md)
4. [execute](./stages/04-execute.md)
5. [verify](./stages/05-verify.md)
6. [document](./stages/06-document.md)

## Verification Gate

- [ ] verification stage passes

## References

- Canonical contract: `.octon/orchestration/runtime/workflows/refactor/refactor/workflow.yml`
- Canonical stages: `.octon/orchestration/runtime/workflows/refactor/refactor/stages/`

## Version History

| Version | Changes |
|---------|---------|
| 1.1.0 | Generated from canonical workflow `refactor` |


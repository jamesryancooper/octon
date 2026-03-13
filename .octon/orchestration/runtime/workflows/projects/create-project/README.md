---
name: "create-project"
description: "Scaffold a new project in projects/."
steps:
  - id: "inline"
    file: "stages/01-inline.md"
    description: "inline"
---

# Create Project

_Generated README from canonical workflow `create-project`._

## Usage

```text
/create-project
```

## Purpose

Scaffold a new project in projects/.

## Target

This README summarizes the canonical workflow unit at `.octon/orchestration/runtime/workflows/projects/create-project`.

## Prerequisites

- Required workflow inputs are available.
- Canonical workflow contract exists at `.octon/orchestration/runtime/workflows/projects/create-project/workflow.yml`.

## Failure Conditions

- Required inputs are missing or invalid.
- The canonical workflow contract or stage assets are missing.
- Verification criteria are not satisfied.

## Steps

1. [inline](./stages/01-inline.md)

## Verification Gate

- [ ] single stage completes successfully

## References

- Canonical contract: `.octon/orchestration/runtime/workflows/projects/create-project/workflow.yml`
- Canonical stages: `.octon/orchestration/runtime/workflows/projects/create-project/stages/`

## Version History

| Version | Changes |
|---------|---------|
| 1.0.0 | Generated from canonical workflow `create-project` |


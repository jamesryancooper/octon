---
name: "run-data-migration"
description: "Step-by-step guide to running database migrations safely with AI assistance after repo-consequential preflight and branch freshness checks."
steps:
  - id: "inline"
    file: "stages/01-inline.md"
    description: "inline"
---

# Run Data Migration

_Generated README from canonical workflow `run-data-migration`._

## Usage

```text
/run-data-migration
```

## Purpose

Step-by-step guide to running database migrations safely with AI assistance after repo-consequential preflight and branch freshness checks.

## Target

This README summarizes the canonical workflow unit at `.octon/framework/orchestration/runtime/workflows/tasks/run-data-migration`.

## Prerequisites

- Required workflow inputs are available.
- Canonical workflow contract exists at `.octon/framework/orchestration/runtime/workflows/tasks/run-data-migration/workflow.yml`.

## Failure Conditions

- Required inputs are missing or invalid.
- The canonical workflow contract or stage assets are missing.
- Verification criteria are not satisfied.

## Steps

1. [inline](./stages/01-inline.md)

## Verification Gate

- [ ] single stage completes successfully

## References

- Canonical contract: `.octon/framework/orchestration/runtime/workflows/tasks/run-data-migration/workflow.yml`
- Canonical stages: `.octon/framework/orchestration/runtime/workflows/tasks/run-data-migration/stages/`

## Version History

| Version | Changes |
|---------|---------|
| 1.0.0 | Generated from canonical workflow `run-data-migration` |

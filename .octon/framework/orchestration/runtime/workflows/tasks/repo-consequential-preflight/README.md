---
name: "repo-consequential-preflight"
description: "Read-only branch freshness and consequential verification preflight for repo-mutating workflows."
steps:
  - id: "inline"
    file: "stages/01-inline.md"
    description: "inline"
---

# Repo Consequential Preflight

_Generated README from canonical workflow `repo-consequential-preflight`._

## Usage

```text
/repo-consequential-preflight
```

## Purpose

Read-only branch freshness and consequential verification preflight for repo-mutating workflows.

## Target

This README summarizes the canonical workflow unit at `.octon/framework/orchestration/runtime/workflows/tasks/repo-consequential-preflight`.

## Prerequisites

- Required workflow inputs are available.
- Canonical workflow contract exists at `.octon/framework/orchestration/runtime/workflows/tasks/repo-consequential-preflight/workflow.yml`.

## Failure Conditions

- Required inputs are missing or invalid.
- The canonical workflow contract or stage assets are missing.
- Verification criteria are not satisfied.

## Outputs

- `freshness_checkpoint` -> `.octon/state/control/execution/runs/<run-id>/checkpoints/repo-consequential-preflight.yml`: Canonical consequential preflight checkpoint.
- `publication_receipt` -> `.octon/state/evidence/validation/publication/workflows/repo-consequential-preflight-<run-id>.yml`: Retained freshness preflight receipt.

## Steps

1. [inline](./stages/01-inline.md)

## Verification Gate

- [ ] single stage completes successfully

## References

- Canonical contract: `.octon/framework/orchestration/runtime/workflows/tasks/repo-consequential-preflight/workflow.yml`
- Canonical stages: `.octon/framework/orchestration/runtime/workflows/tasks/repo-consequential-preflight/stages/`

## Version History

| Version | Changes |
|---------|---------|
| 1.0.0 | Generated from canonical workflow `repo-consequential-preflight` |

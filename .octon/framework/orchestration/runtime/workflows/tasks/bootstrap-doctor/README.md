---
name: "bootstrap-doctor"
description: "Read-only bootstrap readiness workflow for ingress, workflow discovery, support-envelope health, and onboarding preflight."
steps:
  - id: "inline"
    file: "stages/01-inline.md"
    description: "inline"
---

# Bootstrap Doctor

_Generated README from canonical workflow `bootstrap-doctor`._

## Usage

```text
/bootstrap-doctor
```

## Purpose

Read-only bootstrap readiness workflow for ingress, workflow discovery, support-envelope health, and onboarding preflight.

## Target

This README summarizes the canonical workflow unit at `.octon/framework/orchestration/runtime/workflows/tasks/bootstrap-doctor`.

## Prerequisites

- Required workflow inputs are available.
- Canonical workflow contract exists at `.octon/framework/orchestration/runtime/workflows/tasks/bootstrap-doctor/workflow.yml`.

## Failure Conditions

- Required inputs are missing or invalid.
- The canonical workflow contract or stage assets are missing.
- Verification criteria are not satisfied.

## Outputs

- `readiness_checkpoint` -> `.octon/state/control/execution/runs/<run-id>/checkpoints/bootstrap-doctor.yml`: Canonical onboarding readiness checkpoint.
- `publication_receipt` -> `.octon/state/evidence/validation/publication/workflows/bootstrap-doctor-<run-id>.yml`: Retained publication-style receipt for bootstrap readiness.

## Steps

1. [inline](./stages/01-inline.md)

## Verification Gate

- [ ] single stage completes successfully

## References

- Canonical contract: `.octon/framework/orchestration/runtime/workflows/tasks/bootstrap-doctor/workflow.yml`
- Canonical stages: `.octon/framework/orchestration/runtime/workflows/tasks/bootstrap-doctor/stages/`

## Version History

| Version | Changes |
|---------|---------|
| 1.0.0 | Generated from canonical workflow `bootstrap-doctor` |

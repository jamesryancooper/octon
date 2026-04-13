---
name: "run-repo-shell-supported-scenario"
description: "Guided repo-shell supported-scenario workflow that retains scenario proof, replay linkage, and operator-facing summaries."
steps:
  - id: "inline"
    file: "stages/01-inline.md"
    description: "inline"
---

# Run Repo Shell Supported Scenario

_Generated README from canonical workflow `run-repo-shell-supported-scenario`._

## Usage

```text
/run-repo-shell-supported-scenario
```

## Purpose

Guided repo-shell supported-scenario workflow that retains scenario proof, replay linkage, and operator-facing summaries.

## Target

This README summarizes the canonical workflow unit at `.octon/framework/orchestration/runtime/workflows/tasks/run-repo-shell-supported-scenario`.

## Prerequisites

- Required workflow inputs are available.
- Canonical workflow contract exists at `.octon/framework/orchestration/runtime/workflows/tasks/run-repo-shell-supported-scenario/workflow.yml`.

## Failure Conditions

- Required inputs are missing or invalid.
- The canonical workflow contract or stage assets are missing.
- Verification criteria are not satisfied.

## Outputs

- `lab_scenario_proof` -> `.octon/state/evidence/lab/scenarios/<scenario-id>/scenario-proof.yml`: Retained repo-shell supported-scenario proof.
- `publication_receipt` -> `.octon/state/evidence/validation/publication/workflows/repo-shell-supported-scenario-<run-id>.yml`: Retained publication-style receipt for supported scenario execution.

## Steps

1. [inline](./stages/01-inline.md)

## Verification Gate

- [ ] single stage completes successfully

## References

- Canonical contract: `.octon/framework/orchestration/runtime/workflows/tasks/run-repo-shell-supported-scenario/workflow.yml`
- Canonical stages: `.octon/framework/orchestration/runtime/workflows/tasks/run-repo-shell-supported-scenario/stages/`

## Version History

| Version | Changes |
|---------|---------|
| 1.0.0 | Generated from canonical workflow `run-repo-shell-supported-scenario` |

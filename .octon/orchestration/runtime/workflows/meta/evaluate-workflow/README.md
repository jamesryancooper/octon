---
name: "evaluate-workflow"
description: "Evaluate a canonical workflow and its workflow README for structure, gap coverage, parameter/output clarity, and README drift."
steps:
  - id: "read-workflow"
    file: "stages/01-read-workflow.md"
    description: "read-workflow"
  - id: "assess-structure"
    file: "stages/02-assess-structure.md"
    description: "assess-structure"
  - id: "assess-gap-coverage"
    file: "stages/03-assess-gap-coverage.md"
    description: "assess-gap-coverage"
  - id: "assess-quality"
    file: "stages/04-assess-quality.md"
    description: "assess-quality"
  - id: "generate-report"
    file: "stages/05-generate-report.md"
    description: "generate-report"
---

# Evaluate Workflow

_Generated README from canonical workflow `evaluate-workflow`._

## Usage

```text
/evaluate-workflow
```

## Purpose

Evaluate a canonical workflow and its workflow README for structure, gap coverage, parameter/output clarity, and README drift.

## Target

This README summarizes the canonical workflow unit at `.octon/orchestration/runtime/workflows/meta/evaluate-workflow`.

## Prerequisites

- Required workflow inputs are available.
- Canonical workflow contract exists at `.octon/orchestration/runtime/workflows/meta/evaluate-workflow/workflow.yml`.

## Failure Conditions

- Required inputs are missing or invalid.
- The canonical workflow contract or stage assets are missing.
- Verification criteria are not satisfied.

## Steps

1. [read-workflow](./stages/01-read-workflow.md)
2. [assess-structure](./stages/02-assess-structure.md)
3. [assess-gap-coverage](./stages/03-assess-gap-coverage.md)
4. [assess-quality](./stages/04-assess-quality.md)
5. [generate-report](./stages/05-generate-report.md)

## Verification Gate

- [ ] verification stage passes

## References

- Canonical contract: `.octon/orchestration/runtime/workflows/meta/evaluate-workflow/workflow.yml`
- Canonical stages: `.octon/orchestration/runtime/workflows/meta/evaluate-workflow/stages/`

## Version History

| Version | Changes |
|---------|---------|
| 1.1.0 | Generated from canonical workflow `evaluate-workflow` |


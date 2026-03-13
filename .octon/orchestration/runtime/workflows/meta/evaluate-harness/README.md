---
name: "evaluate-harness"
description: "Evaluate a .octon directory for structure, token efficiency, and quality signal completeness."
steps:
  - id: "assess-files"
    file: "stages/01-assess-files.md"
    description: "assess-files"
  - id: "classify-content"
    file: "stages/02-classify-content.md"
    description: "classify-content"
  - id: "generate-report"
    file: "stages/03-generate-report.md"
    description: "generate-report"
---

# Evaluate Harness

_Generated README from canonical workflow `evaluate-harness`._

## Usage

```text
/evaluate-harness
```

## Purpose

Evaluate a .octon directory for structure, token efficiency, and quality signal completeness.

## Target

This README summarizes the canonical workflow unit at `.octon/orchestration/runtime/workflows/meta/evaluate-harness`.

## Prerequisites

- Required workflow inputs are available.
- Canonical workflow contract exists at `.octon/orchestration/runtime/workflows/meta/evaluate-harness/workflow.yml`.

## Failure Conditions

- Required inputs are missing or invalid.
- The canonical workflow contract or stage assets are missing.
- Verification criteria are not satisfied.

## Steps

1. [assess-files](./stages/01-assess-files.md)
2. [classify-content](./stages/02-classify-content.md)
3. [generate-report](./stages/03-generate-report.md)

## Verification Gate

- [ ] verification stage passes

## References

- Canonical contract: `.octon/orchestration/runtime/workflows/meta/evaluate-harness/workflow.yml`
- Canonical stages: `.octon/orchestration/runtime/workflows/meta/evaluate-harness/stages/`

## Version History

| Version | Changes |
|---------|---------|
| 1.1.0 | Generated from canonical workflow `evaluate-harness` |


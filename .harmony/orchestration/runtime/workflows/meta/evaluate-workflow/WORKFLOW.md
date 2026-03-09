---
name: "evaluate-workflow"
description: "Evaluate a canonical pipeline and its workflow projection for structure, gap coverage, parameter/output clarity, and projection drift."
steps:
  - id: "read-workflow"
    file: "01-read-workflow.md"
    description: "read-workflow"
  - id: "assess-structure"
    file: "02-assess-structure.md"
    description: "assess-structure"
  - id: "assess-gap-coverage"
    file: "03-assess-gap-coverage.md"
    description: "assess-gap-coverage"
  - id: "assess-quality"
    file: "04-assess-quality.md"
    description: "assess-quality"
  - id: "generate-report"
    file: "05-generate-report.md"
    description: "generate-report"
---

# Evaluate Workflow

_Generated projection from canonical pipeline `evaluate-workflow`._

## Usage

```text
/evaluate-workflow
```

## Target

This projection wraps the canonical pipeline `evaluate-workflow` for staged human review and slash-facing compatibility.

## Prerequisites

- Required pipeline inputs are available.
- Canonical pipeline assets exist under `.harmony/orchestration/runtime/pipelines/meta/evaluate-workflow`.

## Failure Conditions

- Required inputs are missing or invalid.
- The backing canonical pipeline contract or stage assets are missing.
- Verification criteria are not satisfied.

## Steps

1. [read-workflow](./01-read-workflow.md)
2. [assess-structure](./02-assess-structure.md)
3. [assess-gap-coverage](./03-assess-gap-coverage.md)
4. [assess-quality](./04-assess-quality.md)
5. [generate-report](./05-generate-report.md)

## Verification Gate

- [ ] verification stage passes

## Version History

| Version | Changes |
|---------|---------|
| 1.1.0 | Generated from canonical pipeline `evaluate-workflow` |

## References

- Canonical pipeline: `.harmony/orchestration/runtime/pipelines/meta/evaluate-workflow/`

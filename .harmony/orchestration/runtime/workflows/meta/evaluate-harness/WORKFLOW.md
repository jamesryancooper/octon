---
name: "evaluate-harness"
description: "Evaluate a .harmony directory for structure, token efficiency, and quality signal completeness."
steps:
  - id: "assess-files"
    file: "01-assess-files.md"
    description: "assess-files"
  - id: "classify-content"
    file: "02-classify-content.md"
    description: "classify-content"
  - id: "generate-report"
    file: "03-generate-report.md"
    description: "generate-report"
---

# Evaluate Harness

_Generated projection from canonical pipeline `evaluate-harness`._

## Usage

```text
/evaluate-harness
```

## Target

This projection wraps the canonical pipeline `evaluate-harness` for staged human review and slash-facing compatibility.

## Prerequisites

- Required pipeline inputs are available.
- Canonical pipeline assets exist under `.harmony/orchestration/runtime/pipelines/meta/evaluate-harness`.

## Failure Conditions

- Required inputs are missing or invalid.
- The backing canonical pipeline contract or stage assets are missing.
- Verification criteria are not satisfied.

## Steps

1. [assess-files](./01-assess-files.md)
2. [classify-content](./02-classify-content.md)
3. [generate-report](./03-generate-report.md)

## Verification Gate

- [ ] verification stage passes

## Version History

| Version | Changes |
|---------|---------|
| 1.1.0 | Generated from canonical pipeline `evaluate-harness` |

## References

- Canonical pipeline: `.harmony/orchestration/runtime/pipelines/meta/evaluate-harness/`

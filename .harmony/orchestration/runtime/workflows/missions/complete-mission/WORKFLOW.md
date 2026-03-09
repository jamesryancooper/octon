---
name: "complete-mission"
description: "Close and archive an existing mission with final status and continuity handoff updates."
steps:
  - id: "overview"
    file: "00-overview.md"
    description: "overview"
---

# Complete Mission

_Generated projection from canonical pipeline `complete-mission`._

## Usage

```text
/complete-mission
```

## Target

This projection wraps the canonical pipeline `complete-mission` for staged human review and slash-facing compatibility.

## Prerequisites

- Required pipeline inputs are available.
- Canonical pipeline assets exist under `.harmony/orchestration/runtime/pipelines/missions/complete-mission`.

## Failure Conditions

- Required inputs are missing or invalid.
- The backing canonical pipeline contract or stage assets are missing.
- Verification criteria are not satisfied.

## Steps

1. [overview](./00-overview.md)

## Verification Gate

- [ ] verification stage passes

## Version History

| Version | Changes |
|---------|---------|
| 1.1.0 | Generated from canonical pipeline `complete-mission` |

## References

- Canonical pipeline: `.harmony/orchestration/runtime/pipelines/missions/complete-mission/`

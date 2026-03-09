---
name: "create-mission"
description: "Scaffold a new mission artifact set and register it for execution tracking."
steps:
  - id: "overview"
    file: "00-overview.md"
    description: "overview"
---

# Create Mission

_Generated projection from canonical pipeline `create-mission`._

## Usage

```text
/create-mission
```

## Target

This projection wraps the canonical pipeline `create-mission` for staged human review and slash-facing compatibility.

## Prerequisites

- Required pipeline inputs are available.
- Canonical pipeline assets exist under `.harmony/orchestration/runtime/pipelines/missions/create-mission`.

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
| 1.1.0 | Generated from canonical pipeline `create-mission` |

## References

- Canonical pipeline: `.harmony/orchestration/runtime/pipelines/missions/create-mission/`

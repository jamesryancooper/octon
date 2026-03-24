---
name: "complete-mission"
description: "Close and archive an existing mission with final status and continuity handoff updates."
steps:
  - id: "overview"
    file: "stages/00-overview.md"
    description: "overview"
---

# Complete Mission

_Generated README from canonical workflow `complete-mission`._

## Usage

```text
/complete-mission
```

## Purpose

Close and archive an existing mission with final status and continuity handoff updates.

## Target

This README summarizes the canonical workflow unit at `.octon/framework/orchestration/runtime/workflows/missions/complete-mission`.

## Prerequisites

- Required workflow inputs are available.
- Canonical workflow contract exists at `.octon/framework/orchestration/runtime/workflows/missions/complete-mission/workflow.yml`.

## Failure Conditions

- Required inputs are missing or invalid.
- The canonical workflow contract or stage assets are missing.
- Verification criteria are not satisfied.

## Steps

1. [overview](./stages/00-overview.md)

## Verification Gate

- [ ] verification stage passes

## References

- Canonical contract: `.octon/framework/orchestration/runtime/workflows/missions/complete-mission/workflow.yml`
- Canonical stages: `.octon/framework/orchestration/runtime/workflows/missions/complete-mission/stages/`

## Version History

| Version | Changes |
|---------|---------|
| 1.2.0 | Generated from canonical workflow `complete-mission` |

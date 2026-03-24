---
name: "create-mission"
description: "Scaffold a new mission artifact set and register it for execution tracking."
steps:
  - id: "overview"
    file: "stages/00-overview.md"
    description: "overview"
---

# Create Mission

_Generated README from canonical workflow `create-mission`._

## Usage

```text
/create-mission
```

## Purpose

Scaffold a new mission artifact set and register it for execution tracking.

## Target

This README summarizes the canonical workflow unit at `.octon/framework/orchestration/runtime/workflows/missions/create-mission`.

## Prerequisites

- Required workflow inputs are available.
- Canonical workflow contract exists at `.octon/framework/orchestration/runtime/workflows/missions/create-mission/workflow.yml`.

## Failure Conditions

- Required inputs are missing or invalid.
- The canonical workflow contract or stage assets are missing.
- Verification criteria are not satisfied.

## Steps

1. [overview](./stages/00-overview.md)

## Verification Gate

- [ ] verification stage passes

## References

- Canonical contract: `.octon/framework/orchestration/runtime/workflows/missions/create-mission/workflow.yml`
- Canonical stages: `.octon/framework/orchestration/runtime/workflows/missions/create-mission/stages/`

## Version History

| Version | Changes |
|---------|---------|
| 1.2.0 | Generated from canonical workflow `create-mission` |

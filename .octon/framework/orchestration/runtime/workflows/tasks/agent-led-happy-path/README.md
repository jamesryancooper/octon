---
name: "agent-led-happy-path"
description: "Canonical onboarding flow for agent-led execution that routes bootstrap through /bootstrap-doctor before task execution and continuity."
steps:
  - id: "inline"
    file: "stages/01-inline.md"
    description: "inline"
---

# Agent Led Happy Path

_Generated README from canonical workflow `agent-led-happy-path`._

## Usage

```text
/agent-led-happy-path
```

## Purpose

Canonical onboarding flow for agent-led execution that routes bootstrap through /bootstrap-doctor before task execution and continuity.

## Target

This README summarizes the canonical workflow unit at `.octon/framework/orchestration/runtime/workflows/tasks/agent-led-happy-path`.

## Prerequisites

- Required workflow inputs are available.
- Canonical workflow contract exists at `.octon/framework/orchestration/runtime/workflows/tasks/agent-led-happy-path/workflow.yml`.

## Failure Conditions

- Required inputs are missing or invalid.
- The canonical workflow contract or stage assets are missing.
- Verification criteria are not satisfied.

## Steps

1. [inline](./stages/01-inline.md)

## Verification Gate

- [ ] single stage completes successfully

## References

- Canonical contract: `.octon/framework/orchestration/runtime/workflows/tasks/agent-led-happy-path/workflow.yml`
- Canonical stages: `.octon/framework/orchestration/runtime/workflows/tasks/agent-led-happy-path/stages/`

## Version History

| Version | Changes |
|---------|---------|
| 1.0.0 | Generated from canonical workflow `agent-led-happy-path` |

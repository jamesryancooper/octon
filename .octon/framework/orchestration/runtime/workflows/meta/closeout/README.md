---
name: "closeout"
description: "Resolve Change closeout context from the canonical default work unit policy before selecting direct-main, branch-only, PR-backed, or stage-only outputs."
steps:
  - id: "evaluate-context"
    file: "stages/01-evaluate-context.md"
    description: "evaluate-context"
  - id: "request-or-report"
    file: "stages/02-request-or-report.md"
    description: "request-or-report"
---

# Closeout

_Generated README from canonical workflow `closeout`._

## Usage

```text
/closeout
```

## Purpose

Resolve Change closeout context from the canonical default work unit policy before selecting direct-main, branch-only, PR-backed, or stage-only outputs.

## Target

This README summarizes the canonical workflow unit at `.octon/framework/orchestration/runtime/workflows/meta/closeout`.

## Prerequisites

- Required workflow inputs are available.
- Canonical workflow contract exists at `.octon/framework/orchestration/runtime/workflows/meta/closeout/workflow.yml`.

## Failure Conditions

- Required inputs are missing or invalid.
- The canonical workflow contract or stage assets are missing.
- Verification criteria are not satisfied.

## Outputs

- `closeout_workflow_summary` -> `/.octon/state/evidence/validation/analysis/{{date}}-change-closeout-workflow.md`: Change closeout context resolution summary.

## Steps

1. [evaluate-context](./stages/01-evaluate-context.md)
2. [request-or-report](./stages/02-request-or-report.md)

## Verification Gate

- [ ] Change route resolves from the default work unit policy
- [ ] Lifecycle outcome resolves separately from the selected route
- [ ] direct-main, branch-no-pr, branch-pr, and stage-only-escalate contexts are distinguished
- [ ] branch-no-pr preservation, branch-local completion, branch publication, no-PR landing, and cleanup outcomes are distinguished
- [ ] branch-pr published, ready, landed, and cleaned outcomes are distinguished
- [ ] PR-specific mechanics are selected only after branch-pr routing
- [ ] landed and cleaned claims require route-appropriate evidence
- [ ] ingress remains a pointer to this workflow rather than an inline closeout policy surface

## References

- Canonical contract: `.octon/framework/orchestration/runtime/workflows/meta/closeout/workflow.yml`
- Canonical stages: `.octon/framework/orchestration/runtime/workflows/meta/closeout/stages/`

## Version History

| Version | Changes |
|---------|---------|
| 2.0.0 | Generated from canonical workflow `closeout` |

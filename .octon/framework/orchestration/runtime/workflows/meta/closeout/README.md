---
name: "closeout"
description: "Resolve SI-00 Change closeout to preservation or a stable pre-effect denial."
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

Resolve SI-00 Change closeout to preservation or a stable pre-effect denial.

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

- `closeout_workflow_summary` -> `/.octon/state/evidence/validation/analysis/{{date}}-change-closeout-workflow.md`: SI-00 Change preservation and denial summary.

## Steps

1. [evaluate-context](./stages/01-evaluate-context.md)
2. [request-or-report](./stages/02-request-or-report.md)

## Verification Gate

- [ ] active route is branch-no-pr, branch-pr, or stage-only-escalate
- [ ] direct-main is denied
- [ ] generic target resolves to preserved
- [ ] candidate and unrelated work are preserved
- [ ] landing/publication requests record RP00_CONTAINMENT_PUBLICATION_DISABLED before mutation
- [ ] cleanup requests record RP00_CONTAINMENT_CLEANUP_DISABLED before mutation
- [ ] no cleaned, synced, or autonomous publication success is reported

## References

- Canonical contract: `.octon/framework/orchestration/runtime/workflows/meta/closeout/workflow.yml`
- Canonical stages: `.octon/framework/orchestration/runtime/workflows/meta/closeout/stages/`

## Version History

| Version | Changes |
|---------|---------|
| 2.1.0 | Generated from canonical workflow `closeout` |

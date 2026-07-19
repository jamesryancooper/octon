---
name: "current-state-mechanism-architecture-review"
description: "Review the current architecture of one governed cross-surface mechanism using native architectural review doctrine."
steps:
  - id: "configure"
    file: "stages/01-configure.md"
    description: "configure"
  - id: "mechanism-review"
    file: "stages/02-mechanism-review.md"
    description: "mechanism-review"
  - id: "receipt"
    file: "stages/03-receipt.md"
    description: "receipt"
---

# Current State Mechanism Architecture Review

_Generated README from canonical workflow `current-state-mechanism-architecture-review`._

## Usage

```text
/current-state-mechanism-architecture-review
```

## Purpose

Review the current architecture of one governed cross-surface mechanism using native architectural review doctrine.

## Target

This README summarizes the canonical workflow unit at `.octon/framework/orchestration/runtime/workflows/audit/current-state-mechanism-architecture-review`.

## Prerequisites

- Required workflow inputs are available.
- Canonical workflow contract exists at `.octon/framework/orchestration/runtime/workflows/audit/current-state-mechanism-architecture-review/workflow.yml`.

## Parameters

- `mechanism_id` (text, required=true): Governed cross-surface mechanism id to review

## Failure Conditions

- Required inputs are missing or invalid.
- The canonical workflow contract or stage assets are missing.
- Verification criteria are not satisfied.

## Outputs

- `current_state_mechanism_architecture_review_receipt` -> `/.octon/state/evidence/runs/workflows/{{run_id}}/architectural-review/current-state-mechanism-architecture-review/support-receipt.yml`: Evidence-only current-state mechanism architecture review receipt
- `current_state_mechanism_architecture_review_method_selection_record` -> `/.octon/state/evidence/runs/workflows/{{run_id}}/architectural-review/current-state-mechanism-architecture-review/report.yml`: Records the selected review method id (field method bound to naming.yml methods.catalog) and the applied lens profile (field lenses_applied bound to lens-bank.yml) through the architectural-review-report-v2 artifact in the existing architectural-review run-evidence root; descriptive run evidence only, granting the review output no lifecycle, acceptance, promotion, or closeout authority while the v1 support receipt stays method-free.

## Steps

1. [configure](./stages/01-configure.md)
2. [mechanism-review](./stages/02-mechanism-review.md)
3. [receipt](./stages/03-receipt.md)

## Verification Gate

- [ ] Mechanism index entry is present and validates
- [ ] Receipt validates under architectural-review-support-receipt-v1

## References

- Canonical contract: `.octon/framework/orchestration/runtime/workflows/audit/current-state-mechanism-architecture-review/workflow.yml`
- Canonical stages: `.octon/framework/orchestration/runtime/workflows/audit/current-state-mechanism-architecture-review/stages/`

## Version History

| Version | Changes |
|---------|---------|
| 1.0.0 | Generated from canonical workflow `current-state-mechanism-architecture-review` |

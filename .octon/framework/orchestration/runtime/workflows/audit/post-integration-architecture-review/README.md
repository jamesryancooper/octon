---
name: "post-integration-architecture-review"
description: "Produce evidence-only architecture review after integration without replacing implementation conformance or drift/churn closeout gates."
steps:
  - id: "configure"
    file: "stages/01-configure.md"
    description: "configure"
  - id: "evidence-review"
    file: "stages/02-evidence-review.md"
    description: "evidence-review"
  - id: "receipt"
    file: "stages/03-receipt.md"
    description: "receipt"
---

# Post Integration Architecture Review

_Generated README from canonical workflow `post-integration-architecture-review`._

## Usage

```text
/post-integration-architecture-review
```

## Purpose

Produce evidence-only architecture review after integration without replacing implementation conformance or drift/churn closeout gates.

## Target

This README summarizes the canonical workflow unit at `.octon/framework/orchestration/runtime/workflows/audit/post-integration-architecture-review`.

## Prerequisites

- Required workflow inputs are available.
- Canonical workflow contract exists at `.octon/framework/orchestration/runtime/workflows/audit/post-integration-architecture-review/workflow.yml`.

## Parameters

- `proposal_path` (folder, required=true): Implemented architecture proposal packet or implemented change target

## Failure Conditions

- Required inputs are missing or invalid.
- The canonical workflow contract or stage assets are missing.
- Verification criteria are not satisfied.

## Outputs

- `post_integration_architecture_review_receipt` -> `/.octon/state/evidence/runs/workflows/{{run_id}}/architectural-review/post-integration-architecture-review/support-receipt.yml`: Evidence-only post-integration architecture review receipt
- `post_integration_architecture_review_method_selection_record` -> `/.octon/state/evidence/runs/workflows/{{run_id}}/architectural-review/post-integration-architecture-review/report.yml`: Records the selected review method id (field method bound to naming.yml methods.catalog) and the applied lens profile (field lenses_applied bound to lens-bank.yml) through the architectural-review-report-v2 artifact in the existing architectural-review run-evidence root; descriptive run evidence only, granting the review output no lifecycle, acceptance, promotion, or closeout authority while the v1 support receipt stays method-free.

## Steps

1. [configure](./stages/01-configure.md)
2. [evidence-review](./stages/02-evidence-review.md)
3. [receipt](./stages/03-receipt.md)

## Verification Gate

- [ ] Receipt validates under architectural-review-support-receipt-v1
- [ ] Receipt states evidence-only authority and no closeout authority
- [ ] Current receipts prove external tools remained unmodified and required solution changes remained Octon-owned

## References

- Canonical contract: `.octon/framework/orchestration/runtime/workflows/audit/post-integration-architecture-review/workflow.yml`
- Canonical stages: `.octon/framework/orchestration/runtime/workflows/audit/post-integration-architecture-review/stages/`

## Version History

| Version | Changes |
|---------|---------|
| 1.0.0 | Generated from canonical workflow `post-integration-architecture-review` |

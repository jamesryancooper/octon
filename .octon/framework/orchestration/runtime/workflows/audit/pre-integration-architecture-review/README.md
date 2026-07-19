---
name: "pre-integration-architecture-review"
description: "Run mandatory schema-backed architectural review before architecture proposal acceptance or implementation authorization."
steps:
  - id: "configure"
    file: "stages/01-configure.md"
    description: "configure"
  - id: "balanced-review"
    file: "stages/02-balanced-review.md"
    description: "balanced-review"
  - id: "receipt"
    file: "stages/03-receipt.md"
    description: "receipt"
---

# Pre Integration Architecture Review

_Generated README from canonical workflow `pre-integration-architecture-review`._

## Usage

```text
/pre-integration-architecture-review
```

## Purpose

Run mandatory schema-backed architectural review before architecture proposal acceptance or implementation authorization.

## Target

This README summarizes the canonical workflow unit at `.octon/framework/orchestration/runtime/workflows/audit/pre-integration-architecture-review`.

## Prerequisites

- Required workflow inputs are available.
- Canonical workflow contract exists at `.octon/framework/orchestration/runtime/workflows/audit/pre-integration-architecture-review/workflow.yml`.

## Parameters

- `proposal_path` (folder, required=true): Architecture proposal packet to review before acceptance or implementation authorization

## Failure Conditions

- Required inputs are missing or invalid.
- The canonical workflow contract or stage assets are missing.
- Verification criteria are not satisfied.

## Outputs

- `pre_integration_architecture_review_receipt` -> `/.octon/state/evidence/runs/workflows/{{run_id}}/architectural-review/pre-integration-architecture-review/support-receipt.yml`: Schema-backed support receipt for architecture proposal acceptance and implementation authorization
- `pre_integration_architecture_review_method_selection_record` -> `/.octon/state/evidence/runs/workflows/{{run_id}}/architectural-review/pre-integration-architecture-review/routing-decision.yml`: Records the selected review method id (field method bound to naming.yml methods.catalog) and the applied lens profile (field lenses_applied bound to lens-bank.yml) through the architectural-review-routing-decision-v2 artifact in the existing architectural-review run-evidence root; descriptive run evidence only, granting the review output no lifecycle, acceptance, promotion, or closeout authority while the v1 support receipt stays method-free.

## Steps

1. [configure](./stages/01-configure.md)
2. [balanced-review](./stages/02-balanced-review.md)
3. [receipt](./stages/03-receipt.md)

## Verification Gate

- [ ] validate-architectural-review-receipts.sh passes with --mode pre-integration-architecture-review --require-pass
- [ ] Receipt records evidence refs, validator refs, unresolved count, blockers, non-authority classification, and mode-specific coverage
- [ ] Current receipts record mode_specific_coverage.external_tool_integrity and reject external-tool modification strategies
- [ ] Receipt packet_digest matches the reviewed architecture proposal packet

## References

- Canonical contract: `.octon/framework/orchestration/runtime/workflows/audit/pre-integration-architecture-review/workflow.yml`
- Canonical stages: `.octon/framework/orchestration/runtime/workflows/audit/pre-integration-architecture-review/stages/`

## Version History

| Version | Changes |
|---------|---------|
| 1.0.0 | Generated from canonical workflow `pre-integration-architecture-review` |

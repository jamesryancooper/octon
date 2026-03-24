---
name: "promote-proposal"
description: "Promote an accepted proposal to implemented status after proving that its durable targets exist, are proposal-independent, and the committed proposal registry rebuilds cleanly."
steps:
  - id: "validate-proposal"
    file: "stages/01-validate-proposal.md"
    description: "validate-proposal"
  - id: "promote-proposal"
    file: "stages/02-promote-proposal.md"
    description: "promote-proposal"
  - id: "report"
    file: "stages/03-report.md"
    description: "report"
---

# Promote Proposal

_Generated README from canonical workflow `promote-proposal`._

## Usage

```text
/promote-proposal
```

## Purpose

Promote an accepted proposal to implemented status after proving that its durable targets exist, are proposal-independent, and the committed proposal registry rebuilds cleanly.

## Target

This README summarizes the canonical workflow unit at `.octon/framework/orchestration/runtime/workflows/meta/promote-proposal`.

## Prerequisites

- Required workflow inputs are available.
- Canonical workflow contract exists at `.octon/framework/orchestration/runtime/workflows/meta/promote-proposal/workflow.yml`.

## Parameters

- `proposal_path` (folder, required=true): Root active proposal directory to promote
- `promotion_evidence` (text, required=true): Comma-separated repo-relative paths that prove the durable promotion landed

## Failure Conditions

- Required inputs are missing or invalid.
- The canonical workflow contract or stage assets are missing.
- Verification criteria are not satisfied.

## Outputs

- `promote_proposal_workflow_summary` -> `/.octon/state/evidence/validation/analysis/{{date}}-promote-proposal.md`: Top-level workflow summary for proposal promotion
- `promote_proposal_workflow_bundle` -> `/.octon/state/evidence/runs/workflows/{{date}}-promote-proposal-{{slug}}/`: Workflow bundle containing proposal promotion metadata and outputs

## Steps

1. [validate-proposal](./stages/01-validate-proposal.md)
2. [promote-proposal](./stages/02-promote-proposal.md)
3. [report](./stages/03-report.md)

## Verification Gate

- [ ] base and subtype proposal validators pass before promotion
- [ ] promotion starts from an active `accepted` proposal
- [ ] promotion targets exist and are proposal-independent
- [ ] `proposal.yml` is rewritten to `status: implemented`
- [ ] generated proposal registry is regenerated from manifests
- [ ] workflow bundle receipts are complete

## References

- Canonical contract: `.octon/framework/orchestration/runtime/workflows/meta/promote-proposal/workflow.yml`
- Canonical stages: `.octon/framework/orchestration/runtime/workflows/meta/promote-proposal/stages/`

## Version History

| Version | Changes |
|---------|---------|
| 1.0.0 | Generated from canonical workflow `promote-proposal` |

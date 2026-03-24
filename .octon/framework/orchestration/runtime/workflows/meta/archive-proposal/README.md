---
name: "archive-proposal"
description: "Archive a promoted or retired proposal into the canonical archive path with coherent archive metadata and a regenerated proposal registry."
steps:
  - id: "validate-proposal"
    file: "stages/01-validate-proposal.md"
    description: "validate-proposal"
  - id: "archive-proposal"
    file: "stages/02-archive-proposal.md"
    description: "archive-proposal"
  - id: "report"
    file: "stages/03-report.md"
    description: "report"
---

# Archive Proposal

_Generated README from canonical workflow `archive-proposal`._

## Usage

```text
/archive-proposal
```

## Purpose

Archive a promoted or retired proposal into the canonical archive path with coherent archive metadata and a regenerated proposal registry.

## Target

This README summarizes the canonical workflow unit at `.octon/framework/orchestration/runtime/workflows/meta/archive-proposal`.

## Prerequisites

- Required workflow inputs are available.
- Canonical workflow contract exists at `.octon/framework/orchestration/runtime/workflows/meta/archive-proposal/workflow.yml`.

## Parameters

- `proposal_path` (folder, required=true): Root active proposal directory to archive
- `disposition` (text, required=true): Archive disposition: implemented, rejected, historical, or superseded
- `promotion_evidence` (text, required=false): Comma-separated repo-relative promotion evidence paths; required when disposition is implemented

## Failure Conditions

- Required inputs are missing or invalid.
- The canonical workflow contract or stage assets are missing.
- Verification criteria are not satisfied.

## Outputs

- `archive_proposal_workflow_summary` -> `/.octon/state/evidence/validation/analysis/{{date}}-archive-proposal.md`: Top-level workflow summary for proposal archival
- `archive_proposal_workflow_bundle` -> `/.octon/state/evidence/runs/workflows/{{date}}-archive-proposal-{{slug}}/`: Workflow bundle containing proposal archival metadata and outputs

## Steps

1. [validate-proposal](./stages/01-validate-proposal.md)
2. [archive-proposal](./stages/02-archive-proposal.md)
3. [report](./stages/03-report.md)

## Verification Gate

- [ ] base and subtype proposal validators pass before archival
- [ ] archive starts from the active path and a non-archived proposal
- [ ] archive metadata matches the chosen disposition
- [ ] the proposal moves into the canonical archive path
- [ ] generated proposal registry is regenerated from manifests
- [ ] workflow bundle receipts are complete

## References

- Canonical contract: `.octon/framework/orchestration/runtime/workflows/meta/archive-proposal/workflow.yml`
- Canonical stages: `.octon/framework/orchestration/runtime/workflows/meta/archive-proposal/stages/`

## Version History

| Version | Changes |
|---------|---------|
| 1.0.0 | Generated from canonical workflow `archive-proposal` |

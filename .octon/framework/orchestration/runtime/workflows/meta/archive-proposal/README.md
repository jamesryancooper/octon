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
- `promotion_evidence` (text, required=false): Comma-separated repo-relative promotion evidence paths; required when disposition is implemented or superseded

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

- [ ] `summary.md`, `commands.md`, `inventory.md`, `bundle.yml`, and `validation.md` exist
- [ ] `stage-inputs/` and `stage-logs/` exist for the workflow bundle
- [ ] the source proposal validates before archival
- [ ] architecture proposals preserve a passing strict Pre-Integration Architecture Review receipt when the review gate requires it
- [ ] the source proposal starts from the active path and is not already archived
- [ ] implemented archival requires passing implementation-grade, conformance, and drift/churn receipts
- [ ] superseded archival includes successor evidence in `promotion_evidence`
- [ ] archive metadata is coherent for the chosen disposition
- [ ] the proposal moves to `.archive/<kind>/<proposal_id>/`
- [ ] `proposal.yml` is rewritten to `status: archived` with archive metadata
- [ ] generated/proposals/registry.yml matches the deterministic manifest projection after archival
- [ ] post-archive local run residue is classified; detection alone never authorizes deletion
- [ ] when lifecycle executor observation cannot prove archived-target completion, retained `octon-lifecycle-archive-blocked-evidence-v1` evidence records the fail-closed blocker
- [ ] final archival verdict is explicit

## References

- Canonical contract: `.octon/framework/orchestration/runtime/workflows/meta/archive-proposal/workflow.yml`
- Canonical stages: `.octon/framework/orchestration/runtime/workflows/meta/archive-proposal/stages/`

## Version History

| Version | Changes |
|---------|---------|
| 1.0.0 | Generated from canonical workflow `archive-proposal` |

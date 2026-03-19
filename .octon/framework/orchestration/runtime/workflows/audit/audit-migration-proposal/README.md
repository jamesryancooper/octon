---
name: "audit-migration-proposal"
description: "Run deterministic completeness and consistency validation for a migration proposal and persist bundle evidence."
steps:
  - id: "configure"
    file: "stages/01-configure.md"
    description: "configure"
  - id: "proposal-audit"
    file: "stages/02-proposal-audit.md"
    description: "proposal-audit"
  - id: "report"
    file: "stages/11-report.md"
    description: "report"
  - id: "verify"
    file: "stages/12-verify.md"
    description: "verify"
---

# Audit Migration Proposal

_Generated README from canonical workflow `audit-migration-proposal`._

## Usage

```text
/audit-migration-proposal
```

## Purpose

Run deterministic completeness and consistency validation for a migration proposal and persist bundle evidence.

## Target

This README summarizes the canonical workflow unit at `.octon/framework/orchestration/runtime/workflows/audit/audit-migration-proposal`.

## Prerequisites

- Required workflow inputs are available.
- Canonical workflow contract exists at `.octon/framework/orchestration/runtime/workflows/audit/audit-migration-proposal/workflow.yml`.

## Parameters

- `proposal_path` (folder, required=true): Root migration proposal directory to validate

## Failure Conditions

- Required inputs are missing or invalid.
- The canonical workflow contract or stage assets are missing.
- Verification criteria are not satisfied.

## Outputs

- `migration_proposal_workflow_summary` -> `/.octon/state/evidence/validation/analysis/{{date}}-audit-migration-proposal.md`: Top-level workflow summary for migration proposal validation
- `migration_proposal_workflow_bundle` -> `/.octon/state/evidence/runs/workflows/{{date}}-audit-migration-proposal-{{slug}}/`: Workflow bundle containing validation metadata and outputs

## Steps

1. [configure](./stages/01-configure.md)
2. [proposal-audit](./stages/02-proposal-audit.md)
3. [report](./stages/11-report.md)
4. [verify](./stages/12-verify.md)

## Verification Gate

- [ ] `summary.md`, `commands.md`, `inventory.md`, `bundle.yml`, and `validation.md` exist
- [ ] `stage-inputs/` and `stage-logs/` exist for the workflow bundle
- [ ] validate-proposal-standard.sh and validate-migration-proposal.sh pass for the target proposal
- [ ] Final validation verdict is explicit

## References

- Canonical contract: `.octon/framework/orchestration/runtime/workflows/audit/audit-migration-proposal/workflow.yml`
- Canonical stages: `.octon/framework/orchestration/runtime/workflows/audit/audit-migration-proposal/stages/`

## Version History

| Version | Changes |
|---------|---------|
| 1.0.0 | Generated from canonical workflow `audit-migration-proposal` |

---
name: "audit-policy-proposal"
description: "Run deterministic completeness and consistency validation for a policy proposal and persist bundle evidence."
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

# Audit Policy Proposal

_Generated README from canonical workflow `audit-policy-proposal`._

## Usage

```text
/audit-policy-proposal
```

## Purpose

Run deterministic completeness and consistency validation for a policy proposal and persist bundle evidence.

## Target

This README summarizes the canonical workflow unit at `.octon/orchestration/runtime/workflows/audit/audit-policy-proposal`.

## Prerequisites

- Required workflow inputs are available.
- Canonical workflow contract exists at `.octon/orchestration/runtime/workflows/audit/audit-policy-proposal/workflow.yml`.

## Parameters

- `proposal_path` (folder, required=true): Root policy proposal directory to validate

## Failure Conditions

- Required inputs are missing or invalid.
- The canonical workflow contract or stage assets are missing.
- Verification criteria are not satisfied.

## Outputs

- `policy_proposal_workflow_summary` -> `../../output/reports/analysis/{{date}}-audit-policy-proposal.md`: Top-level workflow summary for policy proposal validation
- `policy_proposal_workflow_bundle` -> `../../output/reports/workflows/{{date}}-audit-policy-proposal-{{slug}}/`: Workflow bundle containing validation metadata and outputs

## Steps

1. [configure](./stages/01-configure.md)
2. [proposal-audit](./stages/02-proposal-audit.md)
3. [report](./stages/11-report.md)
4. [verify](./stages/12-verify.md)

## Verification Gate

- [ ] `summary.md`, `commands.md`, `inventory.md`, `bundle.yml`, and `validation.md` exist
- [ ] `stage-inputs/` and `stage-logs/` exist for the workflow bundle
- [ ] validate-proposal-standard.sh and validate-policy-proposal.sh pass for the target proposal
- [ ] Final validation verdict is explicit

## References

- Canonical contract: `.octon/orchestration/runtime/workflows/audit/audit-policy-proposal/workflow.yml`
- Canonical stages: `.octon/orchestration/runtime/workflows/audit/audit-policy-proposal/stages/`

## Version History

| Version | Changes |
|---------|---------|
| 1.0.0 | Generated from canonical workflow `audit-policy-proposal` |

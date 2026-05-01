---
name: "create-architecture-proposal"
description: "Scaffold a standard-governed architecture proposal from canonical templates, materialize its manifests, persist workflow bundle evidence, and validate it immediately."
steps:
  - id: "validate-request"
    file: "stages/01-validate-request.md"
    description: "validate-request"
  - id: "scaffold-proposal"
    file: "stages/03-scaffold-package.md"
    description: "scaffold-proposal"
  - id: "validate-proposal"
    file: "stages/04-validate-package.md"
    description: "validate-proposal"
  - id: "report"
    file: "stages/05-report.md"
    description: "report"
---

# Create Architecture Proposal

_Generated README from canonical workflow `create-architecture-proposal`._

## Usage

```text
/create-architecture-proposal
```

## Purpose

Scaffold a standard-governed architecture proposal from canonical templates, materialize its manifests, persist workflow bundle evidence, and validate it immediately.

## Target

This README summarizes the canonical workflow unit at `.octon/framework/orchestration/runtime/workflows/meta/create-architecture-proposal`.

## Prerequisites

- Required workflow inputs are available.
- Canonical workflow contract exists at `.octon/framework/orchestration/runtime/workflows/meta/create-architecture-proposal/workflow.yml`.

## Parameters

- `proposal_id` (text, required=true): Kebab-case architecture proposal id and directory name under .octon/inputs/exploratory/proposals/architecture/
- `proposal_title` (text, required=true): Human-readable proposal title
- `promotion_scope` (text, required=true): Promotion scope: octon-internal or repo-local
- `promotion_targets` (text, required=true): Comma-separated durable target paths that will survive proposal removal

## Failure Conditions

- Required inputs are missing or invalid.
- The canonical workflow contract or stage assets are missing.
- Verification criteria are not satisfied.

## Outputs

- `create_architecture_proposal_workflow_summary` -> `../../../../../.octon/state/evidence/validation/{{date}}-create-architecture-proposal.md`: Top-level workflow summary with proposal identity, validator outcome, and next steps
- `create_architecture_proposal_workflow_bundle` -> `../../../../../.octon/state/evidence/runs/workflows/{{date}}-create-architecture-proposal-{{proposal_id}}/`: Workflow execution bundle containing stage receipts, validation state, scaffold inventory, and validator evidence
- `create_architecture_proposal_validator_log` -> `../../../../../.octon/state/evidence/runs/workflows/{{date}}-create-architecture-proposal-{{proposal_id}}/standard-validator.log`: Captured stdout and stderr from the proposal validator stack
- `architecture_proposal_root` -> `../../../../../.octon/inputs/exploratory/proposals/architecture/{{proposal_id}}/`: Scaffolded standard-governed architecture proposal
- `proposal_manifest` -> `../../../../../.octon/inputs/exploratory/proposals/architecture/{{proposal_id}}/proposal.yml`: Root manifest for the scaffolded architecture proposal
- `architecture_proposal_manifest` -> `../../../../../.octon/inputs/exploratory/proposals/architecture/{{proposal_id}}/architecture-proposal.yml`: Subtype manifest for the scaffolded architecture proposal
- `proposal_registry` -> `../../../../../.octon/generated/proposals/registry.yml`: Manifest-governed proposal registry updated with the new active proposal entry

## Steps

1. [validate-request](./stages/01-validate-request.md)
2. [scaffold-proposal](./stages/03-scaffold-package.md)
3. [validate-proposal](./stages/04-validate-package.md)
4. [report](./stages/05-report.md)

## Verification Gate

- [ ] scaffolded proposal directory exists under .octon/inputs/exploratory/proposals/architecture/
- [ ] `proposal.yml` and `architecture-proposal.yml` are present and valid
- [ ] registry.yml includes the scaffolded proposal
- [ ] workflow bundle exists under `.octon/state/evidence/runs/workflows/`
- [ ] `bundle.yml`, `summary.md`, `commands.md`, `validation.md`, and `inventory.md` exist
- [ ] `reports/`, `stage-inputs/`, and `stage-logs/` exist
- [ ] standard-validator.log exists
- [ ] validate-proposal-standard.sh and validate-architecture-proposal.sh pass for the scaffolded proposal
- [ ] validate-proposal-implementation-readiness.sh ran and recorded a structural-only or implementation-grade gate outcome
- [ ] top-level summary exists
- [ ] final verdict is explicit

## References

- Canonical contract: `.octon/framework/orchestration/runtime/workflows/meta/create-architecture-proposal/workflow.yml`
- Canonical stages: `.octon/framework/orchestration/runtime/workflows/meta/create-architecture-proposal/stages/`

## Version History

| Version | Changes |
|---------|---------|
| 1.0.0 | Generated from canonical workflow `create-architecture-proposal` |

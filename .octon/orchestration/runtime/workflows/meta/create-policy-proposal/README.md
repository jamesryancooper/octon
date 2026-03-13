---
name: "create-policy-proposal"
description: "Scaffold a standard-governed policy proposal from canonical templates, materialize its manifests, persist workflow bundle evidence, and validate it immediately."
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

# Create Policy Proposal

_Generated README from canonical workflow `create-policy-proposal`._

## Usage

```text
/create-policy-proposal
```

## Purpose

Scaffold a standard-governed policy proposal from canonical templates, materialize its manifests, persist workflow bundle evidence, and validate it immediately.

## Target

This README summarizes the canonical workflow unit at `.octon/orchestration/runtime/workflows/meta/create-policy-proposal`.

## Prerequisites

- Required workflow inputs are available.
- Canonical workflow contract exists at `.octon/orchestration/runtime/workflows/meta/create-policy-proposal/workflow.yml`.

## Parameters

- `proposal_id` (text, required=true): Kebab-case policy proposal id and directory name under .proposals/policy/
- `proposal_title` (text, required=true): Human-readable proposal title
- `promotion_scope` (text, required=true): Promotion scope: octon-internal or repo-local
- `promotion_targets` (text, required=true): Comma-separated durable target paths that will survive proposal removal

## Failure Conditions

- Required inputs are missing or invalid.
- The canonical workflow contract or stage assets are missing.
- Verification criteria are not satisfied.

## Outputs

- `create_policy_proposal_workflow_summary` -> `../../../../../.octon/output/reports/{{date}}-create-policy-proposal.md`: Top-level workflow summary with proposal identity, validator outcome, and next steps
- `create_policy_proposal_workflow_bundle` -> `../../../../../.octon/output/reports/workflows/{{date}}-create-policy-proposal-{{proposal_id}}/`: Workflow execution bundle containing stage receipts, validation state, scaffold inventory, and validator evidence
- `create_policy_proposal_validator_log` -> `../../../../../.octon/output/reports/workflows/{{date}}-create-policy-proposal-{{proposal_id}}/standard-validator.log`: Captured stdout and stderr from the proposal validator stack
- `policy_proposal_root` -> `../../../../../.proposals/policy/{{proposal_id}}/`: Scaffolded standard-governed policy proposal
- `proposal_manifest` -> `../../../../../.proposals/policy/{{proposal_id}}/proposal.yml`: Root manifest for the scaffolded policy proposal
- `policy_proposal_manifest` -> `../../../../../.proposals/policy/{{proposal_id}}/policy-proposal.yml`: Subtype manifest for the scaffolded policy proposal
- `proposal_registry` -> `../../../../../.proposals/registry.yml`: Manifest-governed proposal registry updated with the new active proposal entry

## Steps

1. [validate-request](./stages/01-validate-request.md)
2. [scaffold-proposal](./stages/03-scaffold-package.md)
3. [validate-proposal](./stages/04-validate-package.md)
4. [report](./stages/05-report.md)

## Verification Gate

- [ ] scaffolded proposal directory exists under .proposals/policy/
- [ ] `proposal.yml` and `policy-proposal.yml` are present and valid
- [ ] registry.yml includes the scaffolded proposal
- [ ] workflow bundle exists under `.octon/output/reports/workflows/`
- [ ] `bundle.yml`, `summary.md`, `commands.md`, `validation.md`, and `inventory.md` exist
- [ ] `reports/`, `stage-inputs/`, and `stage-logs/` exist
- [ ] standard-validator.log exists
- [ ] validate-proposal-standard.sh and validate-policy-proposal.sh pass for the scaffolded proposal
- [ ] top-level summary exists
- [ ] final verdict is explicit

## References

- Canonical contract: `.octon/orchestration/runtime/workflows/meta/create-policy-proposal/workflow.yml`
- Canonical stages: `.octon/orchestration/runtime/workflows/meta/create-policy-proposal/stages/`

## Version History

| Version | Changes |
|---------|---------|
| 1.0.0 | Generated from canonical workflow `create-policy-proposal` |

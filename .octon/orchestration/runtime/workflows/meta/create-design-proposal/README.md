---
name: "create-design-proposal"
description: "Scaffold a standard-governed design proposal from canonical templates, materialize its manifest, persist first-class workflow bundle evidence, and validate it immediately."
steps:
  - id: "validate-request"
    file: "stages/01-validate-request.md"
    description: "validate-request"
  - id: "select-bundles"
    file: "stages/02-select-bundles.md"
    description: "select-bundles"
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

# Create Design Proposal

_Generated README from canonical workflow `create-design-proposal`._

## Usage

```text
/create-design-proposal
```

## Purpose

Scaffold a standard-governed design proposal from canonical templates, materialize its manifest, persist first-class workflow bundle evidence, and validate it immediately.

## Target

This README summarizes the canonical workflow unit at `.octon/orchestration/runtime/workflows/meta/create-design-proposal`.

## Prerequisites

- Required workflow inputs are available.
- Canonical workflow contract exists at `.octon/orchestration/runtime/workflows/meta/create-design-proposal/workflow.yml`.

## Parameters

- `proposal_id` (text, required=true): Kebab-case design proposal id and directory name under .proposals/design/
- `proposal_title` (text, required=true): Human-readable proposal title
- `proposal_class` (text, required=false), default=`domain-runtime`: Proposal class: domain-runtime or experience-product
- `promotion_scope` (text, required=true): Promotion scope: octon-internal or repo-local
- `promotion_targets` (text, required=true): Comma-separated durable target paths that will survive proposal removal
- `include_contracts` (boolean, required=false): Optional override for contracts module selection; omitted uses the class default
- `include_conformance` (boolean, required=false): Optional override for conformance module selection; omitted uses the class default
- `include_canonicalization` (boolean, required=false): Optional override for canonicalization module selection; omitted uses the class default

## Failure Conditions

- Required inputs are missing or invalid.
- The canonical workflow contract or stage assets are missing.
- Verification criteria are not satisfied.

## Outputs

- `create_design_proposal_workflow_summary` -> `../../../../../.octon/output/reports/{{date}}-create-design-proposal.md`: Top-level workflow summary with proposal identity, selected modules, validator outcome, and next steps
- `create_design_proposal_workflow_bundle` -> `../../../../../.octon/output/reports/workflows/{{date}}-create-design-proposal-{{proposal_id}}/`: Workflow execution bundle containing stage receipts, validation state, scaffold inventory, and validator evidence
- `create_design_proposal_validator_log` -> `../../../../../.octon/output/reports/workflows/{{date}}-create-design-proposal-{{proposal_id}}/standard-validator.log`: Captured stdout and stderr from the proposal validator stack
- `design_proposal_root` -> `../../../../../.proposals/design/{{proposal_id}}/`: Scaffolded standard-governed design proposal
- `proposal_manifest` -> `../../../../../.proposals/design/{{proposal_id}}/proposal.yml`: Root manifest for the scaffolded design proposal
- `design_proposal_manifest` -> `../../../../../.proposals/design/{{proposal_id}}/design-proposal.yml`: Subtype manifest for the scaffolded design proposal
- `proposal_registry` -> `../../../../../.proposals/registry.yml`: Manifest-governed proposal registry updated with the new active proposal entry

## Steps

1. [validate-request](./stages/01-validate-request.md)
2. [select-bundles](./stages/02-select-bundles.md)
3. [scaffold-proposal](./stages/03-scaffold-package.md)
4. [validate-proposal](./stages/04-validate-package.md)
5. [report](./stages/05-report.md)

## Verification Gate

- [ ] scaffolded proposal directory exists under .proposals/design/
- [ ] `proposal.yml` and `design-proposal.yml` are present and valid
- [ ] registry.yml includes the scaffolded proposal
- [ ] workflow bundle exists under `.octon/output/reports/workflows/`
- [ ] `bundle.yml`, `summary.md`, `commands.md`, `validation.md`, and `inventory.md` exist
- [ ] `reports/`, `stage-inputs/`, and `stage-logs/` exist
- [ ] standard-validator.log exists
- [ ] validate-proposal-standard.sh and validate-design-proposal.sh pass for the scaffolded proposal
- [ ] top-level summary exists
- [ ] final verdict is explicit

## References

- Canonical contract: `.octon/orchestration/runtime/workflows/meta/create-design-proposal/workflow.yml`
- Canonical stages: `.octon/orchestration/runtime/workflows/meta/create-design-proposal/stages/`

## Version History

| Version | Changes |
|---------|---------|
| 1.0.0 | Generated from canonical workflow `create-design-proposal` |

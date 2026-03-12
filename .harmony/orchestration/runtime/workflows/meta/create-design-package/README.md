---
name: "create-design-package"
description: "Scaffold a standard-governed design package from canonical templates, materialize its manifest, persist first-class workflow bundle evidence, and validate it immediately."
steps:
  - id: "validate-request"
    file: "stages/01-validate-request.md"
    description: "validate-request"
  - id: "select-bundles"
    file: "stages/02-select-bundles.md"
    description: "select-bundles"
  - id: "scaffold-package"
    file: "stages/03-scaffold-package.md"
    description: "scaffold-package"
  - id: "validate-package"
    file: "stages/04-validate-package.md"
    description: "validate-package"
  - id: "report"
    file: "stages/05-report.md"
    description: "report"
---

# Create Design Package

_Generated README from canonical workflow `create-design-package`._

## Usage

```text
/create-design-package
```

## Purpose

Scaffold a standard-governed design package from canonical templates, materialize its manifest, persist first-class workflow bundle evidence, and validate it immediately.

## Target

This README summarizes the canonical workflow unit at `.harmony/orchestration/runtime/workflows/meta/create-design-package`.

## Prerequisites

- Required workflow inputs are available.
- Canonical workflow contract exists at `.harmony/orchestration/runtime/workflows/meta/create-design-package/workflow.yml`.

## Parameters

- `package_id` (text, required=true): Kebab-case design package id and directory name under .design-packages/
- `package_title` (text, required=true): Human-readable package title
- `package_class` (text, required=false), default=`domain-runtime`: Package class: domain-runtime or experience-product
- `implementation_targets` (text, required=true): Comma-separated durable target paths that will survive package removal
- `include_contracts` (boolean, required=false): Optional override for contracts module selection; omitted uses the class default
- `include_conformance` (boolean, required=false): Optional override for conformance module selection; omitted uses the class default
- `include_canonicalization` (boolean, required=false): Optional override for canonicalization module selection; omitted uses the class default

## Failure Conditions

- Required inputs are missing or invalid.
- The canonical workflow contract or stage assets are missing.
- Verification criteria are not satisfied.

## Outputs

- `create_design_package_workflow_summary` -> `../../../../../.harmony/output/reports/{{date}}-create-design-package.md`: Top-level workflow summary with package identity, selected modules, validator outcome, and next steps
- `create_design_package_workflow_bundle` -> `../../../../../.harmony/output/reports/workflows/{{date}}-create-design-package-{{package_id}}/`: Workflow execution bundle containing stage receipts, validation state, scaffold inventory, and validator evidence
- `create_design_package_validator_log` -> `../../../../../.harmony/output/reports/workflows/{{date}}-create-design-package-{{package_id}}/standard-validator.log`: Captured stdout and stderr from validate-design-package-standard.sh
- `design_package_root` -> `../../../../../.design-packages/{{package_id}}/`: Scaffolded standard-governed design package
- `design_package_manifest` -> `../../../../../.design-packages/{{package_id}}/design-package.yml`: Root manifest for the standard-governed design package
- `design_package_registry` -> `../../../../../.design-packages/registry.yml`: Manifest-governed design-package registry updated with the new active package entry

## Steps

1. [validate-request](./stages/01-validate-request.md)
2. [select-bundles](./stages/02-select-bundles.md)
3. [scaffold-package](./stages/03-scaffold-package.md)
4. [validate-package](./stages/04-validate-package.md)
5. [report](./stages/05-report.md)

## Verification Gate

- [ ] scaffolded package directory exists under .design-packages/
- [ ] design-package.yml is present and valid
- [ ] registry.yml includes the scaffolded package
- [ ] workflow bundle exists under `.harmony/output/reports/workflows/`
- [ ] `bundle.yml`, `summary.md`, `commands.md`, `validation.md`, and `inventory.md` exist
- [ ] `reports/`, `stage-inputs/`, and `stage-logs/` exist
- [ ] standard-validator.log exists
- [ ] validate-design-package-standard.sh passes for the scaffolded package
- [ ] top-level summary exists
- [ ] final verdict is explicit

## References

- Canonical contract: `.harmony/orchestration/runtime/workflows/meta/create-design-package/workflow.yml`
- Canonical stages: `.harmony/orchestration/runtime/workflows/meta/create-design-package/stages/`

## Version History

| Version | Changes |
|---------|---------|
| 1.0.0 | Generated from canonical workflow `create-design-package` |


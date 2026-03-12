# Minimal Implementation Blueprint

## Summary

- package: `architecture-validation-workflow-package`
- package class: `domain-runtime`
- default audit mode: `rigorous`

## Components

- `audit-design-package` workflow contract under
  `/.harmony/orchestration/runtime/workflows/audit/audit-design-package/`
- workflow discovery metadata in workflow `manifest.yml` and `registry.yml`
- kernel runner support in `/.harmony/engine/runtime/crates/kernel/src/workflow.rs`
- package validator `validate-architecture-validation-pipeline.sh`
- regression coverage in:
  - `test-validate-architecture-validation-pipeline.sh`
  - `test-design-package-workflow-runner.sh`

## Data And Contracts

- required input: `package_path`
- optional inputs: `mode`, `executor`, `executor_bin`, `output_slug`, `model`,
  `prepare_only`
- bundle contract:
  - `bundle.yml`
  - `plan.md`
  - `validation.md`
  - `package-delta.md`
  - `reports/`
  - `stage-inputs/`
  - `stage-logs/`
- stage report naming follows the package artifact contract and selected mode

## Deterministic Behaviors

- `rigorous` runs stages `01, 03, 04, 05, 06, 07, 08, 09`
- `short` runs stages `01, 02, 06, 07, 08, 09`
- file-writing stages must edit the package or emit an explicit zero-change
  receipt
- verification fails closed when required reports or mutation receipts are
  missing

## First Slice

Align the following four surfaces to the same contract before any further
feature work:

1. workflow artifact paths
2. workflow registry projection
3. validator expectations and negative tests
4. real-executor end-to-end runner behavior

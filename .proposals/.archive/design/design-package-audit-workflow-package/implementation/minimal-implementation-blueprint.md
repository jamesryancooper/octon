# Minimal Implementation Blueprint

## Summary

- package: `design-package-audit-workflow-package`
- package class: `domain-runtime`
- default audit mode: `rigorous`

## Components

- durable workflow contract under
  `/.harmony/orchestration/runtime/workflows/audit/audit-design-package/`
- workflow discovery metadata in workflow `manifest.yml` and `registry.yml`
- kernel runner support in `/.harmony/engine/runtime/crates/kernel/src/workflow.rs`
- package validator `validate-audit-design-package-workflow.sh`
- regression coverage in:
  - `test-validate-audit-design-package-workflow.sh`
  - `test-audit-design-package-workflow-runner.sh`
- package-local prompt and contract bundle under
  `/.design-packages/.archive/design-package-audit-workflow-package/`

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
- execution lifecycle, retry, and rerun rules live in
  `normative/execution/run-lifecycle.md`
- executor prompt/response rules live in
  `normative/execution/executor-interface.md`
- durable runtime source of truth lives under `/.harmony/`; this package
  supplies the change contract, not a runtime dependency

## Deterministic Behaviors

- `rigorous` runs stages `01, 03, 04, 05, 06, 07, 08, 09`
- `short` runs stages `01, 02, 06, 07, 08, 09`
- the durable workflow may keep `remediation-track` as a wrapper stage, but it
  must emit the package-defined stage reports for the selected mode
- file-writing stages must edit the package or emit an explicit zero-change
  receipt
- failed mutating runs recover through idempotent rerun in a new bundle
- verification fails closed when required reports or mutation receipts are
  missing
- executor-environment failures must be classified separately from package or
  workflow logic failures

## First Slice

Align the following four surfaces to the same contract before any further
feature work:

1. workflow artifact paths
2. workflow registry projection
3. validator expectations and negative tests
4. stage mapping between package prompts and live workflow stages
5. real-executor prerequisites, failure semantics, and observability
6. lifecycle and mutation-receipt enforcement

# Harmony Integration

This package is integrated into Harmony through a workflow, not a duplicate
command or separate per-stage skills.

## Native Entry Point

Run the workflow directly:

```text
/audit-design-package package_path=".design-packages/<target-package>"
/audit-design-package package_path=".design-packages/<target-package>" mode="short"
```

Run the executable runner through the kernel:

```text
.harmony/engine/runtime/run workflow run audit-design-package --package-path ".design-packages/<target-package>"
.harmony/engine/runtime/run workflow run audit-design-package --package-path ".design-packages/<target-package>" --mode short
.harmony/engine/runtime/run workflow run audit-design-package --package-path ".design-packages/<target-package>" --prepare-only
.harmony/engine/runtime/run workflow run audit-design-package --package-path ".design-packages/<target-package>" --executor mock
```

## Runtime Surfaces

- Workflow:
  `/.harmony/orchestration/runtime/workflows/audit/audit-design-package/`
- Workflow discovery:
  `/.harmony/orchestration/runtime/workflows/manifest.yml`
  `/.harmony/orchestration/runtime/workflows/registry.yml`
- Workflow capability classification:
  `/.harmony/orchestration/governance/capability-map-v1.yml`
- Workflow package validator:
  `/.harmony/assurance/runtime/_ops/scripts/validate-audit-design-package-workflow.sh`

## Runtime Authority Decision

This package is implementation-ready guidance for updating the live workflow.
The durable runtime authorities remain:

- `/.harmony/orchestration/runtime/workflows/audit/audit-design-package/workflow.yml`
- `/.harmony/orchestration/runtime/workflows/audit/audit-design-package/stages/`
- generated `/.harmony/orchestration/runtime/workflows/audit/audit-design-package/README.md`
- `/.harmony/orchestration/runtime/workflows/registry.yml`
- `/.harmony/orchestration/runtime/workflows/manifest.yml`
- `/.harmony/engine/runtime/crates/kernel/src/workflow.rs`
- `/.harmony/assurance/runtime/_ops/scripts/validate-audit-design-package-workflow.sh`
- `/.harmony/assurance/runtime/_ops/tests/`

The prompt files under `prompts/` remain package-local design inputs used to
author or revise those durable runtime surfaces. The runtime itself must not
depend on this package path at execution time.

## What The Workflow Update Must Preserve

- ordered execution
- mode selection
- bundle naming and report persistence
- change-manifest enforcement for file-writing stages
- fail-closed validation

## What The Workflow Update Must Change

- align workflow bundle output to `reports/workflows` across all workflow
  surfaces
- make the package-stage-to-workflow-stage mapping explicit
- enforce the package lifecycle, receipt, and prompt-packet contracts in the
  runner and validators
- strengthen assurance so drift between workflow contract, registry, and runner
  behavior fails closed
- document executor prerequisites and failure classification

## Assurance Wiring

When the pipeline surface changes, run:

```text
bash .harmony/assurance/runtime/_ops/scripts/validate-audit-design-package-workflow.sh
bash .harmony/orchestration/runtime/workflows/_ops/scripts/validate-workflows.sh
bash .harmony/assurance/runtime/_ops/scripts/alignment-check.sh --profile workflows
bash .harmony/assurance/runtime/_ops/tests/test-audit-design-package-workflow-runner.sh
```

The alignment-check `workflows` profile includes the pipeline validator.

`test-audit-design-package-workflow-runner.sh` runs the executable workflow runner in
`mock` mode by default and can run an opt-in live smoke when
`HARMONY_RUN_LIVE_EXECUTOR_SMOKE=1`.

## Target Package Contract

The workflow assumes the target package is temporary implementation design
material, not a canonical runtime or documentation authority. File-writing
stages must update that target package directly when possible. The workflow is
not complete if it only emits recommendations for stages that are supposed to
write package changes.

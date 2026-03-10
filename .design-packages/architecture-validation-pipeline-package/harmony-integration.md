# Harmony Integration

This package is integrated into Harmony through a workflow, not a duplicate
command or separate per-stage skills.

## Native Entry Point

Run the workflow directly:

```text
/audit-design-package-workflow package_path=".design-packages/<target-package>"
/audit-design-package-workflow package_path=".design-packages/<target-package>" mode="short"
```

Run the executable runner through the kernel:

```text
.harmony/engine/runtime/run workflow run-design-package --package-path ".design-packages/<target-package>"
.harmony/engine/runtime/run workflow run-design-package --package-path ".design-packages/<target-package>" --mode short
.harmony/engine/runtime/run workflow run-design-package --package-path ".design-packages/<target-package>" --prepare-only
.harmony/engine/runtime/run workflow run-design-package --package-path ".design-packages/<target-package>" --executor mock
```

## Runtime Surfaces

- Workflow:
  `/.harmony/orchestration/runtime/workflows/audit/audit-design-package-workflow/`
- Workflow discovery:
  `/.harmony/orchestration/runtime/workflows/manifest.yml`
  `/.harmony/orchestration/runtime/workflows/registry.yml`
- Workflow capability classification:
  `/.harmony/orchestration/governance/capability-map-v1.yml`
- Pipeline package validator:
  `/.harmony/assurance/runtime/_ops/scripts/validate-architecture-validation-pipeline.sh`

## Why The Prompts Stay Together

The prompt files under `prompts/` are the maintained stage instructions. Harmony does
not duplicate them into a second instruction set because that would create
drift between:

- the prompt package humans maintain
- the workflow instructions the runtime follows

The workflow references these prompt files and adds:

- ordered execution
- bundle naming and report persistence
- mode selection
- verification rules

## Assurance Wiring

When the pipeline surface changes, run:

```text
bash .harmony/assurance/runtime/_ops/scripts/validate-architecture-validation-pipeline.sh
bash .harmony/orchestration/runtime/workflows/_ops/scripts/validate-workflows.sh
bash .harmony/assurance/runtime/_ops/scripts/alignment-check.sh --profile workflows
bash .harmony/assurance/runtime/_ops/tests/test-design-package-workflow-runner.sh
```

The alignment-check `workflows` profile includes the pipeline validator.

`test-design-package-workflow-runner.sh` runs the executable workflow runner in
`mock` mode by default and can run an opt-in live smoke when
`HARMONY_RUN_LIVE_EXECUTOR_SMOKE=1`.

## Target Package Contract

The workflow assumes the target package is temporary implementation design
material, not a canonical runtime or documentation authority. File-writing
stages must update that target package directly when possible. The workflow is
not complete if it only emits recommendations for stages that are supposed to
write package changes.

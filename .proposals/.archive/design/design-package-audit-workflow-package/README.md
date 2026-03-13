# Design Package Audit Workflow Package

This is a temporary, implementation-scoped design package for
`design-package-audit-workflow-package`. It is a build aid for engineers and
operators. It is not a canonical runtime, documentation, policy, or contract
authority.

Status: `archived`
Archive Disposition: `implemented`

This package provided the design contract and implementation guidance for
bringing the `audit-design-package` workflow, registry projection, runner
behavior, and assurance surfaces into one coherent state.

Within Octon, the native entry point is the workflow:

```text
/audit-design-package package_path="<TARGET_PACKAGE>"
```

The executable runtime entry point is:

```text
.octon/engine/runtime/run workflow run audit-design-package --package-path "<TARGET_PACKAGE>"
```

Executor modes:

- `--executor codex` — real model-backed execution through `codex exec`
- `--executor claude` — real model-backed execution through `claude -p`
- `--executor mock` — deterministic offline execution for smoke tests and CI-safe validation

The package contains prompt assets and design contracts that define the intended
pipeline behavior. They are package-local implementation guidance for updating
the durable `/.octon/` workflow surfaces. The live runtime must remain
self-contained and must not depend on this package at execution time.

The hardened package now makes four critical boundaries explicit:

- bundle outputs belong under
  `.octon/output/reports/workflows/YYYY-MM-DD-audit-design-package-<slug>/`
- workflow runtime truth belongs to `workflow.yml` and its stage assets under
  `/.octon/`
- package mutation stages are governed by explicit lifecycle, recovery, and
  receipt rules
- executor interaction is governed by a stable prompt-packet and response
  contract

The target design package is treated as temporary implementation material. It
may be archived or removed after implementation and must not be treated as a
canonical runtime or documentation authority.

## Implementation Targets

- `/.octon/orchestration/runtime/workflows/audit/audit-design-package/`
- `/.octon/orchestration/runtime/workflows/manifest.yml`
- `/.octon/orchestration/runtime/workflows/registry.yml`
- `/.octon/orchestration/governance/capability-map-v1.yml`
- `/.octon/assurance/runtime/_ops/scripts/validate-audit-design-package-workflow.sh`
- `/.octon/assurance/runtime/_ops/tests/test-validate-audit-design-package-workflow.sh`
- `/.octon/assurance/runtime/_ops/tests/test-audit-design-package-workflow-runner.sh`

## Exit Path

The workflow, registry, runner, and assurance updates have been promoted into
the durable `/.octon/` targets listed above. This package now remains only as
archived historical implementation material under
`/.design-packages/.archive/`.

## Why Octon Implements This As A Workflow

The pipeline is stateful, ordered, and artifact-driven:

- stage outputs feed later prompts
- some stages are read-only and some must write the design package
- the operator needs a durable bundle containing reports, change manifests, and
  final implementation guidance

That makes a workflow the smallest robust Octon primitive. This package
describes the target workflow behavior, but the durable runtime authorities are
the live `/.octon/` workflow contract, stage assets, registry projection,
runner, and assurance surfaces. The prompt files under `prompts/` are temporary
design inputs used to update those durable runtime surfaces.

## Pipeline Modes

### Rigorous

Use when the package is large, risky, or likely to hide architectural failure
modes.

1. `01-design-package-audit.md`
2. `03-design-red-team.md`
3. `04-design-hardening.md`
4. `05-design-integration.md`
5. `06-implementation-simulation.md`
6. `07-specification-closure.md`
7. `08-minimal-implementation-architecture-extraction.md`
8. `09-first-implementation-plan.md`

### Short

Use when iteration speed matters more than separate hardening and integration
passes.

1. `01-design-package-audit.md`
2. `02-design-package-remediation.md`
3. `06-implementation-simulation.md`
4. `07-specification-closure.md`
5. `08-minimal-implementation-architecture-extraction.md`
6. `09-first-implementation-plan.md`

## Stage Classes

- Evaluative: `01`, `03`, `06`
- File-writing: `02`, `04`, `05`, `07`
- Implementation-guidance outputs: `08`, `09`

See `stage-contracts.md` for the documented handoff and mutation rules.

## Shared Placeholders

Replace these placeholders before running a prompt:

- `<PACKAGE_PATH>` — path to the target design package
- `<AUDIT_REPORT>` — output of the design package audit
- `<RED_TEAM_REPORT>` — output of the red-team prompt
- `<HARDENING_REPORT>` — output of the design hardening prompt
- `<IMPLEMENTATION_SIMULATION_REPORT>` — output of the implementation simulation prompt
- `<SPEC_CLOSURE_REPORT>` — output of the specification closure prompt
- `<BLUEPRINT_REPORT>` — output of the minimal implementation architecture extraction prompt

## File-Edit Execution Rule

For file-writing stages, the intended behavior is:

1. If the agent can edit files, edit the target package directly.
2. If the agent cannot edit files, emit complete file contents or exact patch
   sets for every changed or new file.
3. Always emit a change manifest.
4. Never stop at recommendations alone.

## Suggested Output Protocol For File-Writing Stages

Use this pattern when direct editing is unavailable:

```text
CHANGE MANIFEST
- CREATE: <PACKAGE_PATH>/path/to/new-file.md
- UPDATE: <PACKAGE_PATH>/path/to/existing-file.md

FILE: <PACKAGE_PATH>/path/to/new-file.md
```md
# full file body here
```

FILE: <PACKAGE_PATH>/path/to/existing-file.md
```md
# full updated file body here
```
```

## Reading Order

1. `design-package.yml`
2. `navigation/source-of-truth-map.md`
3. `pipeline-overview.md`
4. `stage-contracts.md`
5. `artifact-contract.md`
6. `octon-integration.md`
7. `normative/execution/run-lifecycle.md`
8. `normative/execution/executor-interface.md`
9. `normative/execution/executor-runtime-prerequisites.md`
10. `normative/execution/failure-and-recovery-model.md`
11. `normative/assurance/observability-and-bundle-contract.md`
12. `implementation/minimal-implementation-blueprint.md`
13. `implementation/workflow-alignment-delta.md`
14. `implementation/first-implementation-plan.md`
15. `prompts/`
16. `all-prompts.md`

## Included Files

- `all-prompts.md` — combined document containing every prompt
- `pipeline-overview.md` — mode selection and stage-sequence summary
- `stage-contracts.md` — stage-by-stage handoff, mutation, and gating rules
- `artifact-contract.md` — bounded bundle layout and report naming contract
- `octon-integration.md` — workflow integration, invocation, and assurance wiring
- `normative/execution/run-lifecycle.md` — execution state machine, retry, cancellation, and rerun semantics
- `normative/execution/executor-interface.md` — prompt-packet envelope, response contract, and error classification
- `normative/execution/executor-runtime-prerequisites.md` — supported executors, prerequisites, and degraded-mode rules
- `normative/execution/failure-and-recovery-model.md` — required failure classes, receipts, and rerun behavior
- `normative/assurance/observability-and-bundle-contract.md` — authoritative debugging surfaces and bundle-level observability requirements
- `implementation-readiness.md` — package-local readiness verdict and checklist
- `implementation/workflow-alignment-delta.md` — exact file-level changes the next workflow update must implement
- `prompts/` — maintained stage prompts

# Architecture Validation Workflow Package

This package provides the prompt and operating-contract bundle for validating,
hardening, and extracting implementation guidance from a temporary Harmony
design package.

Within Harmony, the native entry point is the workflow:

```text
/audit-design-package-workflow package_path="<TARGET_PACKAGE>"
```

The executable runtime entry point is:

```text
.harmony/engine/runtime/run workflow run-design-package --package-path "<TARGET_PACKAGE>"
```

Executor modes:

- `--executor codex` — real model-backed execution through `codex exec`
- `--executor claude` — real model-backed execution through `claude -p`
- `--executor mock` — deterministic offline execution for smoke tests and CI-safe validation

The workflow uses the prompt files in this package as its maintained stage
instructions,
persists stage reports into a bounded audit bundle, and expects file-writing
stages to mutate the target package directly when file access is available.

The target design package is treated as temporary implementation material. It
may be archived or removed after implementation and must not be treated as a
canonical runtime or documentation authority.

## Why Harmony Implements This As A Workflow

The pipeline is stateful, ordered, and artifact-driven:

- stage outputs feed later prompts
- some stages are read-only and some must write the design package
- the operator needs a durable bundle containing reports, change manifests, and
  final implementation guidance

That makes a workflow the smallest robust Harmony primitive. The prompt files in
`prompts/` remain the maintained stage instructions; the workflow adds sequencing,
bundle discipline, and verification without duplicating the prompt bodies into a
second instruction surface.

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

1. `pipeline-overview.md`
2. `stage-contracts.md`
3. `artifact-contract.md`
4. `harmony-integration.md`
5. `implementation-readiness.md`
6. `prompts/`
7. `all-prompts.md`

## Included Files

- `all-prompts.md` — combined document containing every prompt
- `pipeline-overview.md` — mode selection and stage-sequence summary
- `stage-contracts.md` — stage-by-stage handoff, mutation, and gating rules
- `artifact-contract.md` — bounded bundle layout and report naming contract
- `harmony-integration.md` — workflow integration, invocation, and assurance wiring
- `implementation-readiness.md` — package-local readiness verdict and checklist
- `prompts/` — maintained stage prompts

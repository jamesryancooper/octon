---
title: Orchestration Specification
description: Canonical pipeline-first orchestration model for Harmony.
spec_refs:
  - HARMONY-SPEC-301
  - HARMONY-SPEC-003
  - HARMONY-SPEC-006
---

# Orchestration Specification

Harmony orchestration is `pipeline-first`.

The canonical autonomous contract lives under
`/.harmony/orchestration/runtime/pipelines/`. Workflow markdown under
`/.harmony/orchestration/runtime/workflows/` remains in the repo, but only as a
generated projection surface for humans and slash-facing compatibility.

## Bounded Surfaces

- Runtime authority: `/.harmony/orchestration/runtime/pipelines/`
- Workflow projections: `/.harmony/orchestration/runtime/workflows/`
- Governance contracts: `/.harmony/orchestration/governance/`
- Authoring and operating standards: `/.harmony/orchestration/practices/`

Legacy root orchestration paths outside `runtime/` remain forbidden.

## Authority Model

The authority order is:

1. `runtime/pipelines/manifest.yml` and `runtime/pipelines/registry.yml`
2. Per-pipeline `pipeline.yml`
3. Pipeline `stages/` assets and optional local schemas/fixtures/_ops helpers
4. Generated workflow projections in `runtime/workflows/`

Implications:

- `pipeline.yml` is the canonical execution contract.
- `WORKFLOW.md` and numbered workflow step files are not authoritative when a
  backing pipeline exists.
- Temporary `/.design-packages/` content must never be a live dependency of any
  pipeline, workflow projection, validator, or runner.

## Canonical Runtime Layout

```text
runtime/pipelines/
├── manifest.yml
├── registry.yml
├── _ops/
│   └── scripts/
├── _scaffold/
│   └── template/
└── <group>/<pipeline-id>/
    ├── pipeline.yml
    ├── stages/
    ├── schemas/    # optional
    ├── fixtures/   # optional
    └── _ops/       # optional
```

## Pipeline Contract

Every canonical pipeline contract must declare:

- `name`
- `description`
- `version`
- `entry_mode`
- `execution_profile`
- `inputs`
- `stages`
- `artifacts`
- `done_gate`
- `projection`
- `constraints`

### Stage Contract

Every stage entry must declare:

- `id`
- `asset`
- `kind`: `analysis`, `mutation`, `projection`, or `verification`
- `produces`
- `consumes`
- `mutation_scope`

Rules:

- `asset` must resolve inside the same pipeline directory, typically under
  `stages/`.
- `mutation` stages must declare a non-empty `mutation_scope`.
- Non-mutation stages must not declare side-effect scope accidentally.
- `verification` stages close the pipeline and must support fail-closed
  completion semantics.

## Stage Assets

Canonical stage assets live under `stages/` and are versioned runtime assets.

Each stage asset should document:

- instruction body
- required placeholders and inputs
- expected outputs
- mutation rules
- failure behavior

`prompts/` is not a canonical pipeline layout. Long-form explanatory material
belongs in adjacent architecture or practices docs, not in place of the
machine-readable pipeline contract.

## Workflow Projections

Workflow projections preserve existing workflow ids and slash-facing identities
without retaining canonical authority.

Rules:

- every workflow must have a backing pipeline
- workflow registry entries must declare a `projection` block
- generated workflow projections must be deterministic
- validators must fail when a generated workflow projection drifts from its
  source pipeline
- single-file workflow projections are allowed, but their canonical source is
  still a pipeline under `runtime/pipelines/`

## Execution Model

The kernel is the canonical executor surface:

- `harmony pipeline list`
- `harmony pipeline run <pipeline-id>`
- `harmony pipeline validate [<pipeline-id>]`

Canonical pipeline execution must:

- resolve the pipeline by canonical id
- validate required inputs before stage execution
- execute stages in declared order
- persist bounded bundle artifacts and stage reports
- enforce mutation permissions by stage
- track file deltas for mutation stages
- support deterministic `mock` execution and live executor backends

`harmony workflow ...` may remain as a compatibility or debug surface, but it is
not the canonical autonomous interface.

## Validation Model

Validation is pipeline-first.

- `validate-pipelines.sh` validates canonical pipeline contracts and assets
- `validate-workflows.sh` validates workflow projection integrity
- alignment profiles must run pipeline validation before or alongside workflow
  projection validation

Fail-closed validation must block:

- workflows without backing pipelines
- pipelines without valid stage assets
- projection drift
- live references to temporary `/.design-packages/`

## Cross-References

- [Pipelines](./pipelines.md)
- [Workflow Projections](./workflows.md)
- [Pipeline Authoring Standards](../../practices/pipeline-authoring-standards.md)
- [Workflow Projection Standards](../../practices/workflow-authoring-standards.md)

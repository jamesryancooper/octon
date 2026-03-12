---
title: Orchestration Specification
description: Canonical workflow-first, contract-first orchestration model for Harmony.
spec_refs:
  - HARMONY-SPEC-301
  - HARMONY-SPEC-003
  - HARMONY-SPEC-006
---

# Orchestration Specification

Harmony orchestration uses one canonical runtime surface:
`/.harmony/orchestration/runtime/workflows/`.

Each workflow unit combines:

- `workflow.yml` as the canonical contract
- `stages/` as executor-facing stage assets
- `README.md` as generated human-readable guidance

## Canonical Layout

```text
runtime/workflows/
├── manifest.yml
├── registry.yml
├── _ops/
│   └── scripts/
├── _scaffold/
│   └── template/
└── <group>/<id>/
    ├── workflow.yml
    ├── README.md
    ├── stages/
    ├── schemas/    # optional
    ├── fixtures/   # optional
    └── _ops/       # optional
```

## Authority Order

1. `manifest.yml`
2. `registry.yml`
3. `workflow.yml`
4. `stages/`
5. generated `README.md`

`README.md` is never authoritative.

## Required Contract Fields

Every `workflow.yml` must define:

- `name`
- `description`
- `version`
- `entry_mode`
- `execution_profile`
- `inputs`
- `stages`
- `artifacts`
- `done_gate`
- `constraints`

## Validation

Validation is workflow-first and fail-closed:

- missing `workflow.yml`
- missing stage assets
- invalid stage kinds or mutation scope
- README drift
- manifest/registry/workflow mismatch
- live references to temporary proposal paths

No peer `runtime/pipelines/` orchestration surface remains in the shipped
model.

---
title: Pipeline Architecture
description: Canonical pipeline-grade orchestration model.
---

# Pipeline Architecture

`runtime/pipelines/` is the canonical autonomous orchestration surface in
Harmony.

## Purpose

Pipelines provide the strongest contract for AI-first autonomy because they make
execution structure explicit:

- discovery metadata is machine-readable
- stage order is declarative
- mutation permissions are explicit
- artifacts and done-gates are bounded
- validators can reason about structure without inferring intent from prose

## Collection Structure

```text
runtime/pipelines/
├── manifest.yml
├── registry.yml
└── <group>/<pipeline-id>/
    ├── pipeline.yml
    ├── stages/
    ├── schemas/    # optional
    ├── fixtures/   # optional
    └── _ops/       # optional
```

## Discovery Tiers

1. `manifest.yml`
   Compact routing metadata for fast discovery.
2. `registry.yml`
   Extended metadata, I/O, and projection data.
3. `pipeline.yml`
   Canonical execution contract.
4. `stages/`
   Canonical runtime stage assets.

## Projection Model

Every pipeline may emit a workflow projection under `runtime/workflows/`.

Projection rules:

- preserve workflow id and command identity
- remain human-readable
- never supersede the canonical pipeline contract
- fail validation when projection drift occurs

## Design Constraints

- no live dependency on `/.design-packages/`
- no hidden side-effect scope for mutation stages
- no manual workflow surface without pipeline backing
- no executor logic encoded only in workflow prose

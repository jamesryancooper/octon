---
title: Workflow Projections
description: Human-readable projection layer over canonical pipelines.
---

# Workflow Projections

Workflows are no longer the canonical autonomous contract in Harmony.

`/.harmony/orchestration/runtime/workflows/` is a generated projection surface
that keeps existing slash-facing and human-readable workflow identities stable
while canonical execution authority lives in `runtime/pipelines/`.

## Role

Workflow projections exist for:

- staged human readability
- slash-command compatibility
- reviewable procedural summaries
- bridge surfaces for tooling that still expects `WORKFLOW.md`

They do not exist to define the primary execution contract.

## Projection Shape

Directory projections retain:

- `WORKFLOW.md`
- numbered step files

Single-file projections remain valid where the source pipeline is simple enough
to project into one document.

## Source of Authority

Source of truth for projection metadata and content:

- pipeline collection manifest and registry
- per-pipeline `pipeline.yml`
- canonical stage assets under `stages/`

Not a source of truth:

- `WORKFLOW.md`
- numbered workflow step files
- harness-specific command wrappers

## Allowed Exceptions

Workflow-local helper assets such as `prompts/` or `references/` are allowed
only when the workflow projection is an explicitly managed wrapper over a
canonical pipeline and the pipeline contract remains authoritative.

Those assets must:

- remain local to the workflow directory
- use relative references
- avoid any dependency on temporary design-package content

## Harness Entry Points

Harness-specific commands remain thin entry points. They should route to the
canonical pipeline or its generated workflow projection, but they must not
introduce a second source of orchestration authority.

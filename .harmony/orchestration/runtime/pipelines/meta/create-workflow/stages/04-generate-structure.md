---
title: Generate Pipeline Structure
description: Create the canonical pipeline directory and scaffold files.
---

# Step 4: Generate Pipeline Structure

## Input

- Validated id and group
- Template selection from Step 3

## Purpose

Create the canonical pipeline surface under `runtime/pipelines/`. Do not
hand-author the workflow projection in this step.

## Actions

1. Create the pipeline directory:
   `.harmony/orchestration/runtime/pipelines/<group>/<workflow-id>/`
2. Copy scaffold files from:
   `.harmony/orchestration/runtime/pipelines/_scaffold/template/`
3. Rename and populate `stages/NN-*.md` assets based on the stage plan.
4. Create optional `schemas/`, `fixtures/`, or `_ops/` directories only when
   required by the pipeline contract.
5. Leave workflow projection material to the projection-generation step.

## Output

- Canonical pipeline directory exists
- `pipeline.yml` exists
- Planned stage assets exist under `stages/`

## Proceed When

- [ ] Canonical pipeline directory exists
- [ ] `pipeline.yml` is present
- [ ] All planned stage assets are present

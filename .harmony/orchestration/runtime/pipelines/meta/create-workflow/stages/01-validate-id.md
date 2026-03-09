---
title: Validate Pipeline ID
description: Validate the canonical pipeline id, group, and target paths.
---

# Step 1: Validate Pipeline ID

## Input

- `workflow-id`: Stable id for the pipeline and workflow projection
- `group`: Target orchestration group such as `audit`, `meta`, or `tasks`

## Purpose

Establish the canonical pipeline path first, then confirm the compatible
workflow projection path can be generated without collisions.

## Actions

1. Validate `workflow-id` against `^[a-z][a-z0-9-]*$`.
2. Resolve canonical target path:
   `.harmony/orchestration/runtime/pipelines/<group>/<workflow-id>/`
3. Resolve projection target path:
   `.harmony/orchestration/runtime/workflows/<group>/<workflow-id>/`
   The exact projection format is finalized in template selection.
4. Stop if the pipeline id already exists in:
   - pipeline manifest
   - pipeline registry
   - backing runtime path
5. Stop if the projection identity would collide with an unrelated workflow
   surface.

## Output

- Validated pipeline id
- Confirmed pipeline group
- Reserved canonical pipeline path
- Reserved workflow projection path

## Proceed When

- [ ] Pipeline id format is valid
- [ ] Canonical pipeline path is free
- [ ] Projection identity is free

---
title: Validate Workflow ID
description: Validate the canonical workflow id, group, and unit path.
---

# Step 1: Validate Workflow ID

## Input

- `workflow-id`
- `group`

## Purpose

Reserve a canonical workflow unit under `runtime/workflows/<group>/<workflow-id>/`
and ensure the guide can be generated without collisions.

## Actions

1. Validate `workflow-id` against `^[a-z][a-z0-9-]*$`.
2. Resolve canonical workflow path:
   `.octon/orchestration/runtime/workflows/<group>/<workflow-id>/`
3. Stop if the workflow id already exists in the workflow manifest, registry, or
   on-disk workflow unit path.

## Output

- Validated workflow id
- Confirmed workflow group
- Reserved canonical workflow path

## Proceed When

- [ ] Workflow id format is valid
- [ ] Canonical workflow path is free

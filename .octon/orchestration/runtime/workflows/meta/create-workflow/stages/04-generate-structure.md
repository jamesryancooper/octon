---
title: Generate Workflow Structure
description: Create the canonical workflow unit and scaffold files.
---

# Step 4: Generate Workflow Structure

## Purpose

Create the canonical workflow surface under `runtime/workflows/`. Do not
hand-author the generated README in this step.

## Actions

1. Create the workflow directory:
   `.octon/orchestration/runtime/workflows/<group>/<workflow-id>/`
2. Copy scaffold files from:
   `.octon/orchestration/runtime/workflows/_scaffold/template/`
3. Populate `workflow.yml`.
4. Create canonical stage assets under `stages/`.
5. Leave `guide/` generation to the guide generator.

## Output

- Canonical workflow directory exists
- `workflow.yml` exists
- Planned stage assets exist

## Proceed When

- [ ] Canonical workflow directory exists
- [ ] `workflow.yml` is present
- [ ] All planned stage assets are present

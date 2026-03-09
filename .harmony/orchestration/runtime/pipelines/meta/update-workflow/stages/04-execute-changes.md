---
title: Execute Pipeline Changes
description: Apply the canonical pipeline updates and regenerate the workflow projection.
---

# Step 4: Execute Pipeline Changes

## Input

- Confirmed change manifest from Step 3

## Purpose

Apply changes to the canonical pipeline surface, then regenerate the workflow
projection instead of hand-editing generated projection files.

## Actions

1. Update `pipeline.yml` as required.
2. Update stage assets and optional `schemas/`, `fixtures/`, or `_ops/`.
3. Update pipeline manifest and registry metadata when needed.
4. Regenerate workflow projections from the updated pipeline surface.
5. Only edit workflow-local wrapper assets manually when they are explicitly
   exempt from generation and still backed by the pipeline contract.

## Output

- Updated canonical pipeline contract
- Updated stage assets
- Regenerated workflow projection

## Proceed When

- [ ] Pipeline changes are applied
- [ ] Projection regeneration has completed
- [ ] No manual drift remains in generated workflow files

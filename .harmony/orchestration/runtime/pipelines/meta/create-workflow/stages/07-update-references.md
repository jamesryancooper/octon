---
title: Update Discovery And Projections
description: Register the canonical pipeline and generate its workflow projection.
---

# Step 7: Update Discovery And Projections

## Input

- Completed canonical pipeline surface
- Pipeline metadata

## Purpose

Wire discovery metadata to the canonical pipeline and materialize the compatible
workflow projection.

## Actions

1. Update pipeline discovery:
   - `runtime/pipelines/manifest.yml`
   - `runtime/pipelines/registry.yml`
2. Update workflow discovery metadata so the workflow surface points back to the
   canonical pipeline through the `projection` block.
3. Regenerate the workflow projection from the pipeline using:
   `runtime/pipelines/_ops/scripts/generate-workflow-projections.sh`
4. Update slash-facing command documentation only as a compatibility wrapper
   over the pipeline-backed workflow surface.

## Output

- Pipeline manifest entry
- Pipeline registry entry
- Workflow projection metadata
- Generated workflow projection files

## Proceed When

- [ ] Canonical pipeline is discoverable
- [ ] Workflow projection points back to the pipeline
- [ ] Projection generator has been run

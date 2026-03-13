---
title: Update Discovery And READMEs
description: Register the canonical workflow and generate its README.
---

# Step 7: Update Discovery And Guides

## Purpose

Make the canonical workflow discoverable and materialize its generated README.

## Actions

1. Update:
   - `runtime/workflows/manifest.yml`
   - `runtime/workflows/registry.yml`
2. Regenerate the README with:
   `runtime/workflows/_ops/scripts/generate-workflow-guides.sh`
3. Update slash-facing command docs to point at the workflow unit and
   `README.md`.

## Output

- Workflow manifest entry
- Workflow registry entry
- Generated README files

## Proceed When

- [ ] Canonical workflow is discoverable
- [ ] README generator has been run

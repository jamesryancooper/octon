---
title: Read Workflow Surface
description: Normalize the target to a canonical workflow unit plus generated README.
---

# Step 1: Read Workflow Surface

## Input

- `path`: Path to a canonical workflow unit or its generated README

## Purpose

Build one evaluation model around the canonical workflow contract, stage assets,
and generated README.

## Actions

1. Resolve the workflow unit root.
2. Load:
   - `workflow.yml`
   - `stages/`
   - `README.md`
3. Build a normalized model containing contract, stage, and guide data.

## Output

- Normalized workflow-plus-guide model

## Proceed When

- [ ] Canonical workflow is resolved
- [ ] Stage assets are loaded
- [ ] Generated README is loaded

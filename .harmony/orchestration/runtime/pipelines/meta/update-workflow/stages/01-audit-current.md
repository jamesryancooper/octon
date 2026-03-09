---
title: Audit Current Pipeline Surface
description: Read the canonical pipeline and its workflow projection before planning changes.
---

# Step 1: Audit Current Pipeline Surface

## Input

- `path`: Path to the canonical pipeline or its workflow projection
- Optional assessment report from `/evaluate-workflow`

## Purpose

Establish the current canonical pipeline state first, then assess the projected
workflow surface for drift.

## Actions

1. Resolve the canonical pipeline from the provided path.
2. Load the current `pipeline.yml`, stage assets, and projection metadata.
3. Load the workflow projection for comparison.
4. Record current issues across:
   - contract completeness
   - stage asset quality
   - projection drift
   - validation failures

## Output

- Current-state audit of the pipeline and workflow projection

## Proceed When

- [ ] Canonical pipeline has been resolved
- [ ] Workflow projection has been inspected
- [ ] Current drift and contract gaps are documented

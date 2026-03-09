---
title: Read Pipeline Surface
description: Normalize the target to a canonical pipeline plus workflow projection.
---

# Step 1: Read Pipeline Surface

## Input

- `path`: Path to a canonical pipeline or a workflow projection

## Purpose

Build a single evaluation model around the canonical pipeline contract and its
workflow projection, regardless of which surface the operator pointed at first.

## Actions

1. If `path` is under `runtime/pipelines/`, load:
   - `pipeline.yml`
   - declared stage assets
   - projection metadata
2. If `path` is under `runtime/workflows/`, resolve the backing pipeline from
   workflow registry projection metadata, then load the canonical pipeline.
3. If a workflow projection exists, load it as the compatibility/readability
   surface rather than as the source of truth.
4. Build a normalized evaluation model containing:
   - canonical pipeline metadata
   - stage inventory
   - artifact contract
   - workflow projection shape
   - drift-sensitive references

## Output

- Normalized pipeline-plus-projection model

## Proceed When

- [ ] Canonical pipeline is resolved
- [ ] Stage assets are loaded
- [ ] Workflow projection is resolved when expected

---
title: Select Pipeline Template
description: Choose the canonical pipeline scaffold and projection format.
---

# Step 3: Select Pipeline Template

## Input

- Requirements from Step 2

## Purpose

Choose the canonical pipeline scaffold, stage layout, and workflow projection
format before any files are created.

## Actions

1. Use the canonical scaffold:
   `.harmony/orchestration/runtime/pipelines/_scaffold/template/`
2. Decide projection format:
   - `directory` for multi-stage procedures
   - `single-file` only for compact task-style surfaces
3. Decide whether the pipeline needs local:
   - `schemas/`
   - `fixtures/`
   - `_ops/`
4. Derive the canonical stage file list under `stages/`.
5. Record the projection policy:
   generated workflow surfaces come from pipeline metadata and stage assets, not
   from hand-authored workflow files.

## Output

- Selected pipeline scaffold
- Projection format
- Planned `stages/` file list
- Optional local pipeline subdirectories

## Proceed When

- [ ] Canonical pipeline scaffold exists
- [ ] Projection format is explicit
- [ ] Stage asset list is complete

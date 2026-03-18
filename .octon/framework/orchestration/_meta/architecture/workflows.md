---
title: Workflow Units
description: Unified canonical workflow units and generated READMEs.
---

# Workflow Units

Octon workflow units are contract-first.

Each unit under `runtime/workflows/` contains both:

- the canonical machine-readable contract (`workflow.yml`, `stages/`)
- the generated human-readable facet (`README.md`)

This avoids a split orchestration model. There is one workflow system, not a
separate workflow system and pipeline system.

## Human Facet

`README.md` exists for:

- human readability
- staged walkthroughs
- slash-command-facing documentation

They do not define execution authority.

## Canonical Facet

`workflow.yml` and `stages/` define:

- execution order
- inputs and outputs
- mutation permissions
- done gates
- executor-facing stage assets

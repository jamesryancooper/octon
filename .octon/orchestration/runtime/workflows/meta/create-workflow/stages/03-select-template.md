---
title: Select Workflow Template
description: Choose the canonical workflow scaffold and contract layout.
---

# Step 3: Select Workflow Template

## Purpose

Choose the canonical workflow scaffold, stage layout, and contract shape before
creating files.

## Actions

1. Use the canonical scaffold:
   `.octon/orchestration/runtime/workflows/_scaffold/template/`
2. Plan the canonical files:
   - `workflow.yml`
   - `stages/`
   - `README.md`
3. Plan the contract fields that must be set from the requirements:
   - `entry_mode`
   - `side_effect_class`
   - `execution_controls.cancel_safe`
   - `coordination_key_strategy`
   - `artifacts`
   - `done_gate`
4. Decide whether the workflow also needs optional support surfaces:
   - `schemas/`
   - `fixtures/`
   - `_ops/`
   - `references/`
   Treat these as support material only; they are not canonical workflow
   authority surfaces.

## Output

- Selected workflow scaffold
- Stage asset list
- Contract field plan

## Proceed When

- [ ] Canonical workflow scaffold exists
- [ ] Stage asset list is complete
- [ ] Contract field plan is fixed

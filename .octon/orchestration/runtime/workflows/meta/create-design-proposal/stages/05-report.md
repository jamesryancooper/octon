---
title: Report Scaffold Outcome
description: Summarize the created package, selected modules, and next authoring steps.
---

# Step 5: Report Scaffold Outcome

## Purpose

Emit a compact result that points the operator at the new package and the next
authoring workflow.

## Actions

1. Report:
   - package path
   - package class
   - selected modules
   - implementation targets
2. Write the workflow bundle summary and metadata:
   - `bundle.yml`
   - `summary.md`
   - `commands.md`
   - `validation.md`
   - `inventory.md`
3. Write the top-level summary report under `/.octon/output/reports/`.
4. Point the operator at:
   - `design-proposal.yml`
   - `navigation/source-of-truth-map.md`
   - `/audit-design-proposal`
5. Record that the package is ready for content authoring, not automatically
   implementation-ready.

## Proceed When

- [ ] Report includes package path and modules
- [ ] Workflow bundle contract files exist
- [ ] Top-level summary exists
- [ ] Next authoring path is explicit

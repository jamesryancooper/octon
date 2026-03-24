---
title: Report Scaffold Outcome
description: Summarize the created proposal and next authoring steps.
---

# Step 5: Report Scaffold Outcome

## Purpose

Emit a compact result that points the operator at the new proposal and the next
authoring workflow.

## Actions

1. Report:
   - proposal path
   - proposal kind
   - implementation targets
2. Write the workflow bundle summary and metadata:
   - `bundle.yml`
   - `summary.md`
   - `commands.md`
   - `validation.md`
   - `inventory.md`
3. Write the top-level summary report under `/.octon/state/evidence/validation/`.
4. Point the operator at:
   - `migration-proposal.yml`
   - `navigation/source-of-truth-map.md`
   - `/audit-migration-proposal`
5. Record that the proposal is ready for content authoring, not automatically
   implementation-ready.

## Proceed When

- [ ] Report includes proposal path and implementation targets
- [ ] Workflow bundle contract files exist
- [ ] Top-level summary exists
- [ ] Next authoring path is explicit

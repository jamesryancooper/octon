---
name: report
title: Emit Summary And Bundle Metadata
description: Generate top-level summary, bundle metadata, and final readiness narrative.
---

# Step 11: Emit Summary And Bundle Metadata

## Input

- `bundle/plan.md`
- all selected stage reports
- `bundle/package-delta.md`

## Purpose

Create the top-level workflow summary and the metadata files required for
bounded verification.

## Actions

1. Write `bundle/bundle.yml` with:
   - package path
   - mode
   - slug
   - selected stages
   - stage report paths
   - changed files
   - failure classification fields when the run is not successful
   - final readiness verdict
2. Write `bundle/validation.md` with the verification checklist and current
   outcome.
3. Write `bundle/commands.md` and ensure `bundle/inventory.md` is already
   present from the initial package snapshot.
4. Ensure `bundle/stage-inputs/` and `bundle/stage-logs/` remain available as
   authoritative execution evidence.
5. Write the top-level summary report at:
   - `.harmony/output/reports/analysis/YYYY-MM-DD-audit-migration-proposal.md`
6. Ensure the summary references:
   - selected mode
   - key blockers or readiness verdict
   - failure classification and failed stage when applicable
   - changed files
   - workflow bundle path

## Output

- `bundle/bundle.yml`
- `bundle/commands.md`
- `bundle/validation.md`
- top-level summary report

## Proceed When

- [ ] Bundle metadata exists
- [ ] Commands log exists
- [ ] Validation checklist exists
- [ ] Top-level summary exists
- [ ] Final readiness verdict is explicit

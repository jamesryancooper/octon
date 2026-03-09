---
name: report
title: Emit Summary And Bundle Metadata
description: Generate top-level summary, bundle metadata, and final readiness narrative.
---

# Step 8: Emit Summary And Bundle Metadata

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
   - final readiness verdict
2. Write `bundle/validation.md` with the verification checklist and current
   outcome.
3. Write the top-level summary report at:
   - `.harmony/output/reports/YYYY-MM-DD-audit-design-package-workflow.md`
4. Ensure the summary references:
   - selected mode
   - key blockers or readiness verdict
   - changed files
   - bounded bundle path

## Output

- `bundle/bundle.yml`
- `bundle/validation.md`
- top-level summary report

## Proceed When

- [ ] Bundle metadata exists
- [ ] Validation checklist exists
- [ ] Top-level summary exists
- [ ] Final readiness verdict is explicit

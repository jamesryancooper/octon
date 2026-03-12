---
name: design-package-remediation
title: Run Short-Mode Design Package Remediation
description: Execute the short-mode remediation prompt and capture package deltas.
---

# Step 3: Run Short-Mode Design Package Remediation

## Input

- `bundle/plan.md`
- `bundle/reports/01-design-package-audit.md`
- injected prior report: `<AUDIT_REPORT>`
- target package

## Purpose

Run the short-mode remediation pass that improves the package before
buildability simulation.

## Actions

1. Load prompt `02-design-package-remediation.md`.
2. Pass the Design Audit Report inline.
3. Update the target package directly when possible.
4. Persist `bundle/reports/02-design-package-remediation.md`.
5. For this file-writing stage:
   - update the package directly when possible
   - otherwise emit exact file bodies or patch sets
   - record a `CHANGE MANIFEST`
   - if no edits are needed, record an explicit zero-change receipt
6. Aggregate all changed or reviewed files into `bundle/package-delta.md`.

## Output

- `bundle/reports/02-design-package-remediation.md`
- Package mutations or an explicit zero-change receipt
- Aggregate package delta summary

## Proceed When

- [ ] Short-mode remediation report exists
- [ ] The stage includes a change manifest or zero-change receipt
- [ ] `package-delta.md` reflects all reviewed package files

---
name: remediation-track
title: Run Remediation Track
description: Execute the mode-specific remediation stages and capture package deltas.
---

# Step 3: Run Remediation Track

## Input

- `bundle/plan.md`
- `bundle/reports/01-design-package-audit.md`
- injected prior report: `<AUDIT_REPORT>`
- when rigorous branches run, injected intermediate reports:
  `<RED_TEAM_REPORT>` and `<HARDENING_REPORT>`
- target package

## Purpose

Run the middle stages that improve the package before buildability simulation.

## Actions

1. If `mode=short`:
   - load prompt `02-design-package-remediation.md`
   - pass the Design Audit Report inline
   - update the target package directly when possible
   - persist `bundle/reports/02-design-package-remediation.md`
2. If `mode=rigorous`:
   - run prompt `03-design-red-team.md`
   - persist `bundle/reports/03-design-red-team.md`
   - run prompt `04-design-hardening.md` using the red-team report
   - persist `bundle/reports/04-design-hardening.md`
   - run prompt `05-design-integration.md` using the hardening report
   - persist `bundle/reports/05-design-integration.md`
3. For every file-writing stage:
   - update the package directly when possible
   - otherwise emit exact file bodies or patch sets
   - record a `CHANGE MANIFEST`
   - if no edits are needed, record an explicit zero-change receipt
4. Aggregate all changed or reviewed files into `bundle/package-delta.md`.

## Output

- Mode-appropriate stage reports
- Package mutations or explicit zero-change receipts
- Aggregate package delta summary

## Proceed When

- [ ] All required reports for the selected mode exist
- [ ] Every file-writing stage includes a change manifest or zero-change receipt
- [ ] `package-delta.md` reflects all reviewed package files

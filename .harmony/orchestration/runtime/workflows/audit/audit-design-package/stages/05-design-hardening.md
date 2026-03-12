---
name: design-hardening
title: Run Rigorous-Mode Design Hardening
description: Execute prompt 04, apply required package changes, and persist the rigorous-mode hardening report.
---

# Step 5: Run Rigorous-Mode Design Hardening

## Input

- `bundle/plan.md`
- target package at `package_path`
- `bundle/reports/03-design-red-team.md`
- injected prior report: `<RED_TEAM_REPORT>`
- canonical stage prompt for design hardening

## Purpose

Address the highest-risk design issues raised by the red-team pass before the
integration stage.

## Actions

1. Load the canonical design hardening stage prompt.
2. Substitute:
   - `<PACKAGE_PATH>`
   - `<RED_TEAM_REPORT>`
3. Update the target package directly when possible.
4. Persist `bundle/reports/04-design-hardening.md`.
5. Record a `CHANGE MANIFEST` or explicit zero-change receipt.
6. Aggregate all changed or reviewed files into `bundle/package-delta.md`.

## Output

- `bundle/reports/04-design-hardening.md`
- Package mutations or an explicit zero-change receipt
- Aggregate package delta summary

## Proceed When

- [ ] Design Hardening Report exists
- [ ] The stage includes a change manifest or zero-change receipt
- [ ] `package-delta.md` reflects the hardening-stage review

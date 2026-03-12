---
name: report
title: "Generate Change-Risk Report"
description: "Generate consolidated change-risk recommendation report and bounded-audit bundle."
---

# Step 10: Generate Change-Risk Report

## Purpose

Publish a human-readable risk recommendation and machine-checkable bounded-audit artifacts.

## Actions

1. Write consolidated report:
   - `.harmony/output/reports/analysis/YYYY-MM-DD-audit-change-risk.md`
2. Write bounded-audit bundle:
   - `.harmony/output/reports/audits/YYYY-MM-DD-<slug>/`
3. Ensure bundle contains:
   - `bundle.yml`
   - `findings.yml`
   - `coverage.yml`
   - `convergence.yml`
   - `evidence.md`
   - `commands.md`
   - `validation.md`
   - `inventory.md`
4. Record risk tier and recommendation rationale.
5. Evaluate and record done-gate expression.

## Done-Gate Expression

`open_findings_at_or_above_threshold == 0 && coverage.unaccounted_files == 0 && convergence.stable == true`

## Proceed When

- [ ] Consolidated report exists
- [ ] Bundle contract files exist
- [ ] Risk tier, recommendation, and done-gate result are explicit

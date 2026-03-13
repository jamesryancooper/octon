---
name: report
title: "Generate Continuous Audit Report"
description: "Generate consolidated audit-continuous report and bounded-audit bundle."
---

# Step 12: Generate Continuous Audit Report

## Purpose

Publish a continuous risk recommendation and machine-checkable bounded-audit artifacts.

## Actions

1. Write consolidated report:
   - `.octon/output/reports/analysis/YYYY-MM-DD-audit-continuous.md`
2. Write bounded-audit bundle:
   - `.octon/output/reports/audits/YYYY-MM-DD-<slug>/`
3. Ensure bundle contains:
   - `bundle.yml`
   - `findings.yml`
   - `coverage.yml`
   - `convergence.yml`
   - `evidence.md`
   - `commands.md`
   - `validation.md`
   - `inventory.md`
4. Record cadence metadata (`cadence`, `lookback_days`) and residual trend rationale.
5. Evaluate and record done-gate expression.

## Done-Gate Expression

`open_findings_at_or_above_threshold == 0 && coverage.unaccounted_files == 0 && convergence.stable == true`

## Proceed When

- [ ] Consolidated report exists
- [ ] Bundle contract files exist
- [ ] Risk tier, recommendation, cadence metadata, and done-gate result are explicit

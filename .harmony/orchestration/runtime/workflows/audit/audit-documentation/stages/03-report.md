---
name: report
title: "Generate Documentation Audit Report"
description: "Generate recommendation report and bounded-audit evidence bundle."
---

# Step 3: Generate Documentation Audit Report

## Purpose

Publish a human-readable recommendation and machine-checkable bounded-audit artifacts.

## Actions

1. Compute recommendation:
   - `NO-GO` if any CRITICAL findings exist
   - `CONDITIONAL-GO` if no CRITICAL but HIGH findings exist
   - `GO` if only MEDIUM/LOW findings remain
2. Write consolidated report to:
   - `.harmony/output/reports/analysis/YYYY-MM-DD-audit-documentation.md`
3. Write bounded-audit bundle to:
   - `.harmony/output/reports/audits/YYYY-MM-DD-<slug>/`
4. Ensure bundle contains:
   - `bundle.yml`
   - `findings.yml`
   - `coverage.yml`
   - `convergence.yml`
   - `evidence.md`
   - `commands.md`
   - `validation.md`
   - `inventory.md`
5. Evaluate and record done-gate expression.

## Done-Gate Expression

`open_findings_at_or_above_threshold == 0 && coverage.unaccounted_files == 0 && convergence.stable == true`

## Output

- `.harmony/output/reports/analysis/YYYY-MM-DD-audit-documentation.md`
- `.harmony/output/reports/audits/YYYY-MM-DD-<slug>/`

## Proceed When

- [ ] Report exists
- [ ] Bundle contract files exist
- [ ] Done-gate result and recommendation rationale are explicit

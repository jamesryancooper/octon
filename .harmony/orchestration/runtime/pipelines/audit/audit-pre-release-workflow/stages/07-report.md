---
name: report
title: "Generate Pre-Release Report"
description: "Generate consolidated pre-release report and bounded-audit bundle."
---

# Step 7: Generate Pre-Release Report

## Purpose

Publish recommendation in markdown and machine-checkable bounded-audit artifacts.

## Actions

1. Write consolidated markdown report:
   - `.harmony/output/reports/YYYY-MM-DD-audit-pre-release-workflow.md`
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
4. Evaluate and record done-gate expression.

## Done-Gate Expression

`open_findings_at_or_above_threshold == 0 && coverage.unaccounted_files == 0 && convergence.stable == true`

## Proceed When

- [ ] Report exists
- [ ] Bundle contract files exist
- [ ] Done-gate result and recommendation rationale are explicit

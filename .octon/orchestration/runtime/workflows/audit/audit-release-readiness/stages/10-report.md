---
name: report
title: "Generate Release Readiness Workflow Report"
description: "Generate consolidated workflow report and bounded-audit evidence bundle."
---

# Step 10: Generate Release Readiness Workflow Report

## Purpose

Publish recommendation in markdown plus authoritative machine-checkable bounded-audit artifacts.

## Actions

1. Write consolidated workflow report:
   - `.octon/output/reports/analysis/YYYY-MM-DD-audit-release-readiness.md`
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
4. Evaluate and record done-gate expression.
5. Record recommendation rationale tied to merged findings and coverage status.

## Done-Gate Expression

`open_findings_at_or_above_threshold == 0 && coverage.unaccounted_files == 0 && convergence.stable == true`

## Proceed When

- [ ] Consolidated workflow report exists
- [ ] Bundle contract files exist
- [ ] Done-gate result and recommendation rationale are explicit

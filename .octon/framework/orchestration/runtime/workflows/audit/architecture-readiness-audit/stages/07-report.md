---
name: report
title: "Generate Architecture Readiness Workflow Report"
description: "Generate consolidated workflow report and bounded-audit evidence bundle."
---

# Step 7: Generate Architecture Readiness Workflow Report

## Purpose

Publish the consolidated recommendation in markdown plus authoritative
machine-checkable bounded-audit artifacts.

## Actions

1. Write consolidated workflow report:
   - `.octon/state/evidence/validation/analysis/YYYY-MM-DD-architecture-readiness-audit.md`
2. Write bounded-audit bundle:
   - `.octon/state/evidence/validation/audits/YYYY-MM-DD-<slug>/`
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
6. Confirm the selected review method id record (`routing-decision.yml`) is
   retained under
   `.octon/state/evidence/runs/workflows/{run_id}/architectural-review/architecture-readiness-audit/`;
   it is descriptive run evidence only and does not change the done-gate.

## Done-Gate Expression

`primary_classification_recorded == true && coverage.unaccounted_files == 0 && convergence.stable == true && open_findings_at_or_above_threshold == 0`

## Proceed When

- [ ] Consolidated workflow report exists
- [ ] Bundle contract files exist
- [ ] Done-gate result and recommendation rationale are explicit

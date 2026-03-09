---
name: report
title: "Report"
description: "Emit the narrative report, runtime audit plan, and bounded evidence bundle."
---

# Step 7: Report

## Purpose

Write the authoritative artifacts for human review and machine validation.

## Actions

1. Write the narrative workflow-system audit report:
   - `.harmony/output/reports/YYYY-MM-DD-audit-workflow-system-workflow.md`
2. Write the authoritative bundle directory:
   - `.harmony/output/reports/audits/YYYY-MM-DD-<slug>/`
3. Write the required bundle files:
   - `bundle.yml`
   - `findings.yml`
   - `coverage.yml`
   - `convergence.yml`
   - `evidence.md`
   - `commands.md`
   - `validation.md`
   - `inventory.md`
4. Write the workflow-system extras:
   - `scores.yml`
   - `portfolio.yml`
   - `scenarios.yml`
5. Record the convergence receipt using the configured `convergence_k` and
   `seed_list`.
6. Write the runtime audit plan record:
   - `.harmony/cognition/runtime/audits/YYYY-MM-DD-<slug>/plan.md`

## Done-Gate Expression

`open_findings_at_or_above_threshold == 0 && coverage.unaccounted_files == 0 && convergence.stable == true`

## Output

- Narrative report
- Authoritative bounded-audit bundle
- Runtime audit plan record

## Proceed When

- [ ] Bundle contract files exist
- [ ] Workflow-system extras exist
- [ ] Runtime audit plan exists

## Idempotency

Re-running the report step must overwrite the same run slug deterministically for the same parameters.

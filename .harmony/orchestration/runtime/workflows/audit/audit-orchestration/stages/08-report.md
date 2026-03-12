---
name: report
title: "Report"
description: "Generate consolidated markdown report and bounded-audit evidence bundle."
---

# Step 8: Report

## Purpose

Emit backward-compatible report plus authoritative machine-checkable bundle.

## Actions

1. Write legacy consolidated report:
   - `.harmony/output/reports/analysis/YYYY-MM-DD-migration-audit-consolidated.md`
2. Write authoritative bundle directory:
   - `.harmony/output/reports/audits/YYYY-MM-DD-<slug>/`
3. Bundle files (required):
   - `bundle.yml`
   - `findings.yml`
   - `coverage.yml`
   - `convergence.yml`
   - `evidence.md`
   - `commands.md`
   - `validation.md`
   - `inventory.md`
4. Evaluate done-gate expression and persist result in `validation.md` and `convergence.yml`.
5. Persist run receipt metadata including seed and fingerprint policy fields.

## Done-Gate Expression

`open_findings_at_or_above_threshold == 0 && coverage.unaccounted_files == 0 && convergence.stable == true`

## Output

- Legacy consolidated report
- Authoritative bounded-audit bundle

## Proceed When

- [ ] All required bundle files exist
- [ ] Done-gate result recorded
- [ ] Findings and coverage hashes recorded

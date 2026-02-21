---
name: report
title: "Generate Documentation Quality Gate Report"
description: "Generate go/no-go recommendation from documentation audit results."
---

# Step 3: Generate Documentation Quality Gate Report

## Input

- Audit report and extracted summary from step 2

## Purpose

Produce a concise gate decision artifact suitable for release checks.

## Actions

1. Compute recommendation:
   - `NO-GO` if any CRITICAL findings exist
   - `CONDITIONAL-GO` if no CRITICAL but HIGH findings exist
   - `GO` if only MEDIUM/LOW findings remain
2. Write gate report to:
   - `.harmony/output/reports/YYYY-MM-DD-documentation-quality-gate.md`
3. Include:
   - recommendation + rationale
   - severity table
   - coverage summary
   - remediation batch summary
   - link to full audit report

## Output

- Documentation quality gate report

## Proceed When

- [ ] Gate report exists
- [ ] Recommendation and rationale are explicit

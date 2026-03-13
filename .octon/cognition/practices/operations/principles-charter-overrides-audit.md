---
title: Principles Charter Overrides Audit
description: Procedure for recurring audits of principles charter override records.
---

# Principles Charter Overrides Audit

## Purpose

Verify that direct edits to `principles.md` remain rare, evidence-complete, and
time-bounded under `human-override-only` governance.

## Primary Check

- `bash .octon/cognition/_ops/principles/scripts/audit-principles-charter-overrides.sh`

## Audit Cadence

- Minimum monthly (scheduled CI audit).
- Also required after any direct edit to
  `/.octon/cognition/governance/principles/principles.md`.

## Triage Procedure

1. Run the audit script and capture findings.
2. For incomplete records, add missing required fields in
   `/.octon/cognition/governance/exceptions/principles-charter-overrides.md`.
3. For expired `review_date` on active overrides, either:
   - close/retire the override record, or
   - add a new explicit human-authorized override record with updated review
     date and evidence.
4. Re-run the audit until it passes.

## Exit Criteria

- Audit script exits `0`.
- No active override has an expired `review_date`.
- Every record includes all required fields.

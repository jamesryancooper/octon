---
title: Governance Lint Triage Runbook
description: Procedure for triaging and resolving cognition principles governance lint failures.
---

# Governance Lint Triage Runbook

## Purpose

Resolve governance lint failures deterministically without bypassing constitutional rules.

## Primary Check

- `bash .octon/cognition/_ops/principles/scripts/lint-principles-governance.sh`

## Triage Procedure

1. Capture failing rule IDs and failing files from lint output.
2. Classify failure type:
   - reference/link drift,
   - glossary or matrix linkage drift,
   - forbidden language/policy drift,
   - charter change-control policy mismatch.
3. Apply fixes in canonical surfaces only.
4. Re-run governance lint and structure validator.

## Charter Change-Control Rule

For `principles.md` policy failures:

1. Confirm whether direct charter edits were explicitly authorized by a human
   override instruction.
2. Verify `change_policy: human-override-only` and required override evidence
   fields are present in the charter.
3. Verify an append-only record was added to
   `/.octon/cognition/governance/exceptions/principles-charter-overrides.md`
   and includes all required fields.
4. If edits were not explicitly authorized, restore charter content or migrate
   the change to a versioned successor + ADR.
5. Never bypass governance lint validation.

## Exit Criteria

- Governance lint passes with zero failures.
- Related discovery and structure checks pass.

---
title: Governance Lint Triage Runbook
description: Procedure for triaging and resolving cognition principles governance lint failures.
---

# Governance Lint Triage Runbook

## Purpose

Resolve governance lint failures deterministically without bypassing constitutional rules.

## Primary Check

- `bash .harmony/cognition/_ops/principles/scripts/lint-principles-governance.sh`

## Triage Procedure

1. Capture failing rule IDs and failing files from lint output.
2. Classify failure type:
   - reference/link drift,
   - glossary or matrix linkage drift,
   - forbidden language/policy drift,
   - immutable charter checksum mismatch.
3. Apply fixes in canonical surfaces only.
4. Re-run governance lint and structure validator.

## Immutable Charter Rule

For `principles.md` checksum failures:

1. Confirm whether charter content changed intentionally.
2. If intentional and approved, update expected checksum in
   `/.harmony/cognition/_ops/principles/scripts/lint-principles-governance.sh`.
3. If unintentional, restore charter content to the approved baseline.
4. Never bypass checksum validation.

## Exit Criteria

- Governance lint passes with zero failures.
- Related discovery and structure checks pass.

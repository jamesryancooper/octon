---
title: Continuity Decisions Retention
description: Canonical lifecycle, retention classes, and handling rules for continuity decision evidence artifacts.
---

# Continuity Decisions Retention

`/.octon/continuity/decisions/` stores append-oriented routing, authority,
and prerequisite decision evidence.

Retention policy exists so this evidence remains trustworthy, debuggable, and
usable for audits and incident review.

## Scope

This contract governs lifecycle handling for:

- `decision.json` records
- operator-readable `digest.md` summaries
- approval and waiver linkage carried by decision records

It does not redefine task ownership or run-bundle retention.

## Canonical Policy Source

- `/.octon/continuity/decisions/retention.json`

## Retention Classes

| Class | Typical Prefixes | Retention | Action |
|---|---|---|---|
| `governance_evidence` | `dec-` | 365 days | Archive |

## Rules

- Every decision directory MUST match a retention class prefix.
- Top-level non-directory files under `decisions/` MUST be listed in
  `always_keep_files`.
- Retention policy changes MUST be reviewed as governance-affecting changes.
- Never store secrets or regulated data in decision artifacts.
- A decision record is immutable once written; changed routing requires a new
  `decision_id`.

## Enforcement

Enforced by:

- `/.octon/assurance/runtime/_ops/scripts/validate-continuity-memory.sh`

Recommended during architecture checks:

- `bash .octon/assurance/runtime/_ops/scripts/alignment-check.sh --profile harness`

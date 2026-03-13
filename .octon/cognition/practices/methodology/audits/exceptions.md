---
title: Bounded Audit Exceptions
description: Exception contract for rare cases where full bounded-audit controls are temporarily infeasible.
owner: "cognition-owner"
audience: internal
scope: methodology-governance
last_reviewed: 2026-03-05
canonical_links:
  - "/AGENTS.md"
  - "/.octon/agency/governance/CONSTITUTION.md"
  - "/.octon/agency/governance/DELEGATION.md"
  - "/.octon/agency/governance/MEMORY.md"
  - "/.octon/cognition/practices/methodology/authority-crosswalk.md"
---

# Exceptions to Bounded Audits

## Default

Exceptions are disallowed unless explicitly approved by repository maintainers.

## What Qualifies

Exceptions are considered only for hard constraints, such as:

- model/provider does not expose deterministic controls,
- required evidence source is temporarily unavailable,
- emergency incident containment requiring staged follow-up.

## Exception Requirements (MUST)

Any approved exception must:

1. Be labeled `AUDIT EXCEPTION` in the runtime audit plan.
2. Declare affected invariant(s) and exact blast radius.
3. Include explicit approval provenance:
   - `approver`
   - `approved_at` (ISO timestamp)
   - `rationale`
   - `reference` (ticket/PR/incident)
4. Include scope and bounded expiry:
   - `scope` (artifacts/surfaces covered)
   - `expiry` (date, commit range, or release tag)
5. Include compensating controls (for example higher K, stricter coverage sampling, manual dual-review).
6. Include CI rule that fails once expiry condition is reached.
7. Be stored in a canonical runtime path under `/.octon/cognition/runtime/audits/` and referenced by the active audit index entry.

## Strong Preference

Exceptions without expiry should be rejected.

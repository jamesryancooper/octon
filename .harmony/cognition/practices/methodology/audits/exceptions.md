---
title: Bounded Audit Exceptions
description: Exception contract for rare cases where full bounded-audit controls are temporarily infeasible.
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
3. Include a bounded expiry condition (date, commit range, or release tag).
4. Include compensating controls (for example higher K, stricter coverage sampling, manual dual-review).
5. Include CI rule that fails once expiry condition is reached.

## Strong Preference

Exceptions without expiry should be rejected.

---
title: Profile Governance Exceptions
description: Exception contract for profile-selection ambiguities and pre-1.0 transitional usage.
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

# Profile Governance Exceptions

## Default

Exceptions are not allowed unless explicitly approved by repository maintainers.

## What Qualifies

Exceptions are considered only when:

- profile tie-break ambiguity cannot be resolved deterministically,
- pre-1.0 work requires `transitional` profile due to hard external/operational constraints,
- required profile evidence cannot be generated without controlled waiver.

## Exception Requirements (MUST)

Any approved exception must:

1. Be explicitly labeled `PROFILE EXCEPTION` in the migration plan.
2. Include selected profile intent (`atomic` or `transitional`) and unresolved decision point.
3. Include rationale, risks, owner, and approval evidence.
4. Include a deterministic rollback/remediation path.
5. Include expiration controls:
   - for `transitional` in pre-1.0: target removal/decommission date is mandatory.
6. Include CI checks that fail after deadline if exception conditions persist.

## Transitional Exception Note (Pre-1.0)

When `change_profile=transitional` in pre-1.0 mode, the plan MUST include:

- `rationale`
- `risks`
- `owner`
- `target_removal_date`

## Strong Preference

If an exception cannot include a hard expiry/removal date, it should be rejected.

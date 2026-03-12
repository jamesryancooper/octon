---
safety:
  mode: read-only
  allowed_writes:
    - "../../../output/reports/*"
    - "_ops/state/logs/*"
  forbidden:
    - "Editing files in the audited scope"
    - "Reporting surface-architecture claims without path-level evidence"
    - "Skipping mandatory audit layers"
    - "Treating missing evidence as proof of authority"
    - "Forcing workflow-style structures onto unrelated surfaces"
---

# Safety and Boundaries

## Non-Negotiables

- Read-only analysis of in-scope artifacts.
- Write only to designated report and log paths.
- Target resolution must happen before architecture findings.
- Evidence gaps must be recorded as unknowns, not inferred as passing.

## Failure Handling

1. If `surface_path` is missing, unreadable, or outside `/.harmony/`, stop and
   report configuration error.
2. If the target maps to domain-scale or multi-unit scope, return
   `not-applicable` and direct the caller to the correct audit surface.
3. If coverage claims cannot be supported by evidence, downgrade or remove those
   claims.
4. If the target kind remains ambiguous after evidence review, keep the
   classification conservative and record uncertainty explicitly.

---
safety:
  mode: read-only
  allowed_writes:
    - "../../../output/reports/*"
    - "_ops/state/logs/*"
  forbidden:
    - "Editing files in the audited scope"
    - "Reporting compliance claims without path-level evidence"
    - "Skipping mandatory audit layers"
    - "Treating missing evidence as proof of compliance"
---

# Safety and Boundaries

## Non-Negotiables

- Read-only analysis of in-scope artifacts.
- Write only to designated report and log paths.
- Lens isolation is mandatory across coverage layers.
- Evidence gaps must be recorded as unknowns, not inferred as passing.

## Failure Handling

1. If `scope` is missing or unreadable, stop and report configuration error.
2. If baseline references are unreadable, attempt evidence baseline fallback and mark reduced confidence.
3. If coverage claims cannot be supported by evidence, downgrade or remove those claims.
4. If scope is too large for a bounded pass, escalate and recommend partitioning.

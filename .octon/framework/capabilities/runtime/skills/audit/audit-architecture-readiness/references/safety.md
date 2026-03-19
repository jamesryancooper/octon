---
safety:
  mode: read-only
  allowed_writes:
    - "/.octon/state/evidence/validation/analysis/*"
    - "/.octon/state/evidence/runs/skills/*"
  forbidden:
    - "Editing files in the audited scope"
    - "Force-fitting unsupported targets into scored modes"
    - "Reporting architecture-readiness claims without path-level evidence"
    - "Skipping mandatory audit phases"
    - "Treating missing evidence as proof of readiness"
---

# Safety and Boundaries

## Non-Negotiables

- Read-only analysis of in-scope artifacts.
- Write only to designated report and log paths.
- Applicability classification must happen before scoring.
- Evidence gaps must be recorded as unknowns, not inferred as passing.

## Failure Handling

1. If `target_path` is missing or unreadable, stop and report configuration error.
2. If target classification cannot be resolved defensibly, escalate.
3. If coverage claims cannot be supported by evidence, downgrade or remove those claims.
4. If scope is too large for a bounded pass, escalate and recommend workflow orchestration.

# Incident Lifecycle Standards

Operational discipline for runtime incidents under
`/.octon/orchestration/runtime/incidents/`.

## Scope

Applies to incident opening, enrichment, mitigation tracking, and closure.

## Standards

1. `incident.yml` is the canonical machine-readable incident object and mutable
   state authority.
2. `timeline.md` records major state or severity changes.
3. `closure.md` is required when `status=closed`.
4. Closing an incident requires:
   - explicit closure authority
   - a fail-closed closure-readiness check before the final status transition
   - closure summary
   - remediation evidence or explicit waiver
5. Incident runtime state must remain subordinate to incident governance:
   - severity semantics
   - closure authority
   - escalation thresholds

## Boundary

- Runtime incidents coordinate response state.
- Governance remains in `/.octon/orchestration/governance/incidents.md`.
- Use `octon orchestration incident closure-readiness --incident-id <id>`
  before human closure.
- Larger follow-up work should move into mission state rather than remaining
  implicit in incident notes.

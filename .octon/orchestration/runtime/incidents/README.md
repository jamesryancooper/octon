# Orchestration Incidents

Runtime incident objects for containment, escalation, mitigation, monitoring,
and closure.

## Authority Order

`README.md -> index.yml -> incident.yml / actions.yml -> timeline.md / closure.md`

`incident.yml` is the canonical machine-readable incident object and mutable
state authority.

`timeline.md` and `closure.md` are subordinate evidence artifacts.

## Boundary

- Severity semantics, closure authority, and escalation rules remain governed
  by `/.octon/orchestration/governance/incidents.md`.
- Runtime incident objects may coordinate response state, but they do not
  authorize policy exceptions.

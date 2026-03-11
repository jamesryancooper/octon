---
title: ADR Architecture Readiness Matrix
description: Reusable ADR review matrix for architecture-readiness gates, remediation consequences, and bounded audit alignment.
---

# ADR Architecture Readiness Matrix

Use this pattern when an ADR needs explicit architecture-readiness review before
implementation.

## Required Header

- ADR ID
- ADR Title
- Status
- Date
- Owner
- Related objectives
- Affected domains
- Related ADRs
- Related methodology references

## Acceptance Matrix

| Gate | Required acceptance condition | Result (Pass / Partial / Fail) | Evidence / Notes |
|---|---|---|---|
| Objective binding | The ADR preserves explicit linkage between objectives and actions |  |  |
| Authority model | The ADR defines who may do what, on which resources, for how long |  |  |
| Policy admission | Side effects remain under explicit governed admission |  |  |
| Human oversight | Human approval and escalation paths remain explicit |  |  |
| Control-plane ownership | Governance, policy, run state, and recovery remain in the control plane |  |  |
| Execution-plane bounds | Execution remains bounded, non-self-authorizing, and replaceable |  |  |
| Side-effect classification | Reversible, compensatable, and irreversible actions are explicit |  |  |
| Evidence and auditability | Traceability and evidence quality are preserved or improved |  |  |
| Recovery and continuity | Failure, rollback, compensation, and resume semantics are explicit |  |  |
| Observability and assurance | Diagnosability and independent assurance remain intact |  |  |
| Security and secrets | Secret handling and privilege exposure remain minimal and explicit |  |  |
| Concurrency and coordination | Contention, duplication, locking, and cancellation are defined where relevant |  |  |
| Modularity and boundaries | Domain boundaries remain explicit and coupling does not materially worsen |  |  |
| Extensibility | New capabilities still integrate through standard contracts |  |  |
| Operational simplicity | The ADR does not add avoidable hidden complexity or exception burden |  |  |

## Required Consequences

### Positive consequences

- 

### Negative consequences

- 

### New risks introduced

- 

### Risks reduced

- 

## Required Implementation Consequences

- new artifacts required
- existing artifacts to update
- interface or spec changes
- state model changes
- policy changes
- assurance or test changes
- recovery or runbook changes

## Failure-Mode Check

State whether the ADR worsens, improves, or leaves neutral:

- objective drift
- policy bypass
- authority inflation
- hidden side effects
- duplicate or conflicting runs
- zombie execution
- audit theater
- assurance capture
- stale or unsafe learning
- plane collapse

## Verdict

- Accept
- Accept with conditions
- Revise and resubmit
- Reject

Reference methodology:

- `/.harmony/cognition/practices/methodology/architecture-readiness/README.md`
- `/.harmony/cognition/practices/methodology/architecture-readiness/framework.md`

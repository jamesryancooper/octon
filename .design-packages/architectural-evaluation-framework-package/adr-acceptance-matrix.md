# ADR Acceptance Matrix

ADR ID:
ADR Title:
Status: Proposed / Accepted / Superseded / Rejected
Date:
Owner:
Related objectives:
Affected domains:
Related ADRs:
Related documents/specs:

## Decision summary

What is being decided?

## Why now

What problem or pressure requires this decision?

## Options considered

1.
2.
3.

## Chosen decision

State the decision clearly.

---

## Acceptance matrix

| Gate | Required acceptance condition | Result (Pass / Partial / Fail) | Evidence / Notes |
|---|---|---|---|
| Objective binding | The decision preserves or strengthens explicit linkage between objectives and actions |  |  |
| Authority model | The decision defines who may do what, on which resources, for how long |  |  |
| Policy admission | The decision preserves or strengthens governed admission of side effects |  |  |
| Human oversight | The decision preserves clear human approval/escalation paths where needed |  |  |
| Control-plane ownership | The decision keeps governance, policy, run state, and recovery authority in the control plane |  |  |
| Execution-plane bounds | The execution plane remains bounded, non-self-authorizing, and replaceable |  |  |
| Side-effect classification | The decision identifies which actions are reversible, compensatable, or irreversible |  |  |
| Evidence and auditability | The decision preserves or improves end-to-end traceability and evidence quality |  |  |
| Recovery and continuity | Failure, rollback, compensation, and resume semantics are explicit |  |  |
| Observability and assurance | The decision preserves diagnosability and allows independent assurance checks |  |  |
| Security and secrets | Secret handling and privilege exposure remain minimal and explicit |  |  |
| Concurrency and coordination | Contention, duplication, locking, and cancellation behavior are defined where relevant |  |  |
| Modularity and boundaries | Domain boundaries remain explicit; coupling does not materially worsen |  |  |
| Extensibility | New capabilities can integrate through standard contracts rather than bespoke exceptions |  |  |
| Operational simplicity | The decision does not create avoidable hidden complexity or exception burden |  |  |

---

## Mandatory architectural consequences

### Positive consequences

-
-

### Negative consequences

-
-

### New risks introduced

-
-

### Risks reduced

-
-

---

## Required implementation consequences

List the exact follow-up changes required if this ADR is accepted.

### New artifacts required

-
-

### Existing artifacts to update

-
-

### Interface/spec changes

-
-

### State model changes

-
-

### Policy changes

-
-

### Assurance/test changes

-
-

### Recovery/runbook changes

-
-

---

## Failure-mode check

State whether this ADR worsens, improves, or leaves neutral the following risks:

- objective drift:
- policy bypass:
- authority inflation:
- hidden side effects:
- duplicate/conflicting runs:
- zombie execution:
- audit theater:
- assurance capture:
- stale/unsafe learning:
- plane collapse:

Explain any worsened category.

---

## Final ADR verdict

Select one:

- Accept
- Accept with conditions
- Revise and resubmit
- Reject

### Acceptance conditions

-
-

### Non-negotiable follow-ups

-
-

### Why this verdict

Provide a concise paragraph.

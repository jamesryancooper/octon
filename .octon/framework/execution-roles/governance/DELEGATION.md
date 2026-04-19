# Delegation

Delegation policy for execution roles.
Enable reliable execution that is deterministic enough to trust, observable enough to debug, and flexible enough to evolve.

## Core Rule

The orchestrator is the only default delegating execution role.

Delegation is optional and justified only when one of these is true:

- separation of duties is required
- context isolation materially reduces risk
- bounded work can run in parallel without breaking accountability

## Allowed Topologies

- orchestrator only
- orchestrator plus specialist(s)
- orchestrator plus verifier
- orchestrator plus specialist(s) plus verifier

## Disallowed Topologies

- specialist-to-specialist recursion
- verifier-generated work product replacing orchestrator accountability
- durable multi-agent or assistant hierarchies
- composition profiles executing directly

## Specialist Boundaries

Specialists:

- are stateless between invocations
- operate only inside the orchestrator's granted envelope
- receive only permitted context-pack slices
- return structured, evidence-linked outputs
- may not own mission continuity
- may not widen capability packs or support targets

## Verifier Boundaries

Verifiers:

- must remain independent of the generating work product
- may recommend approve, revise, escalate, or deny closeout
- may not override engine authorization
- may not become a default execution overhead pattern

## Escalation

Escalate instead of delegating when:

- the decision is irreversible
- support widening would be required
- role ownership is ambiguous
- a verifier would not be materially independent

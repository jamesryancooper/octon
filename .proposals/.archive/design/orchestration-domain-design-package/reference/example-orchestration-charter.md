# Example Orchestration Charter

This document is an example of what a future canonical charter for Octon's
orchestration model could look like. It is illustrative, not authoritative.

## Purpose

The orchestration domain exists to coordinate bounded autonomous work in a way
that is deterministic enough to trust, observable enough to debug, and governed
enough to review, verify, and safely escalate.

## Goal

Enable AI-native, system-governed autonomy across bounded procedures,
multi-session initiatives, recurring launch policies, and evidence-backed
operational control.

## Authority Model

- Humans retain policy authorship.
- Humans retain exception handling authority.
- Humans retain escalation authority.
- Runtime surfaces may act autonomously only within explicit policy and
  validation boundaries.
- Material autonomous execution must emit durable evidence.

## Core Surface Taxonomy

### Strategic

- `campaigns`

### Initiative

- `missions`

### Trigger

- `watchers`
- `queue`
- `automations`

### Execution

- `workflows`
- `runs`

### Override

- `incidents`

## Surface Responsibilities

- `campaigns` coordinate multiple missions around one larger objective.
- `missions` own bounded multi-session intent, scope, and progress.
- `workflows` define bounded procedures and verification gates.
- `automations` decide when workflows should run without manual initiation.
- `watchers` detect conditions and emit machine-ingest signals.
- `queue` buffers intake and enables claim/ack, retry, and backpressure.
- `runs` record concrete executions and point to durable evidence.
- `incidents` coordinate abnormal-condition containment, escalation, and closure.

## Boundary Rules

1. Workflows do not own schedule or recurrence policy.
2. Automations do not own procedure content.
3. Watchers do not own execution decisions beyond signal emission.
4. Queue does not replace initiative planning or human task tracking.
5. Runs do not replace mission state or continuity planning.
6. Incidents do not silently self-authorize policy exceptions.
7. Campaigns do not own execution steps directly.

## Evidence Rules

- Every material execution should produce a run record.
- Durable evidence belongs in retention-governed storage.
- Runtime indexes may reference evidence but should not silently duplicate it.
- Incident closure must cite exact runs, workflows, or missions involved in
  detection, containment, and recovery.

## Governance Rules

- Governance policy remains explicit in `governance/`.
- Operating discipline remains explicit in `practices/`.
- Active executable surfaces remain explicit in `runtime/`.
- Continuity retains handoff and append-oriented evidence responsibilities.

## Autonomy Rules

- Autonomy is allowed when bounded by policy.
- Silent authority expansion is prohibited.
- Escalation remains explicit.
- Long-lived autonomous behavior must have pause, resume, and operator-visible
  status controls.

## Design Heuristics

- Prefer the smallest robust surface set.
- Introduce new orchestration surfaces only when they need distinct lifecycle,
  state, discovery, and validation rules.
- If a need can be expressed as workflow metadata, keep it as metadata.
- If a behavior requires long-lived state or trigger policy, it likely deserves
  its own surface.

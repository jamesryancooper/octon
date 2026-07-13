---
schema_version: profile-selection-receipt-v1
proposal_id: octon-architecture-migration-bounded-child-agents
logical_packet_id: RP-13
recorded_at: 2026-07-12T19:01:50Z
release_state: pre-1.0
change_profile: atomic
atomic_mode: clean-break
transitional_exception_required: false
---

# Profile Selection Receipt

## Selection

Use the repository default `atomic` profile in `clean-break` mode for this
pre-1.0 architecture change.

## Rationale

RP-13 must finish with one temporary MissionChildRun identity model, one strict
intersection and guard binding, one existing scheduler, one RP-11 generic
adapter with a child specialization, and one terminal retirement definition.
Running persistent and temporary identity, widening and intersection admission,
or process-exit and complete retirement semantics together would make scope,
recovery, and reuse safety ambiguous.

## Atomic Boundary

Atomic means live bounded-child admission activates only when strict scope and
budget, exact one-shot guard, credentialless isolation/session, admitted child
mapping, enforce-or-deny limits, cancellation/unknown reconciliation, and
terminal retirement gates agree at one identity. It permits inert contracts,
dry intersection, staged revocable resources, fake mappings, and live-disabled
shadow proof because none can perform admitted child work or durable effects.

## Exceptions and Escalations

No transitional profile is selected. Escalate only if implementation evidence
shows active children cannot be cancelled, reconciled, retired, and moved to a
single-agent fallback without a time-bounded documented exception. An
exception may never permit credentials, canonical Git, depth above one,
identity reuse, unknown retry, unsupported hard-limit claims, or a second
scheduler/control plane.

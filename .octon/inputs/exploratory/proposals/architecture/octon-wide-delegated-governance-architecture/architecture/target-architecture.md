# Target Architecture

## Stance

Octon-wide execution should be machine-delegated wherever authority can be
proven before dispatch. Proof must combine:

- an explicit contract opt-in or already-bound grant consumption basis;
- invocation authority and provenance;
- required evidence gates;
- declared write scope;
- authority-zone allowance;
- replay, idempotency, rollback, or compensation posture;
- required receipts retained before dispatch where needed;
- fail-closed behavior for missing, stale, contradictory, ambiguous, or
  out-of-scope proof.

Human approval is not a route default. It is a typed exception grant for a
boundary that cannot be machine-proven.

## Human-Only Boundaries

Human-required boundaries should be exact and typed:

- scope expansion;
- policy override;
- unresolved risk acceptance;
- governance mutation;
- contradictory evidence resolution;
- stale evidence acceptance;
- authority ambiguity;
- unsafe resume;
- external irreversible effect.

High impact alone is not sufficient. A high-impact action should still be
machine-delegable when its contract, evidence, scope, authority zone, replay
safety, receipts, and failure behavior are proven.

## Reference Pattern

The lifecycle migration is the reference implementation. It replaced route
approval defaults with route-level delegation contracts, invocation authority,
pre-dispatch delegation proofs, typed human boundaries, and fail-closed
authorization results.

Future Octon-wide domains should adapt that pattern without copying lifecycle
route details as universal schema:

- authority engine: approval artifacts become typed exception grants or
  grant-consumption evidence where they do not create new authority;
- mission/runtime posture: `approval_required` style states narrow into proof
  failure or typed human-boundary states;
- connectors and external effects: effect tokens, rollback, compensation,
  egress, and irreversibility checks decide delegability;
- run-health and read models: projections report proof state but never grant
  authority;
- workflow and capability classification: `human-only` and `role-mediated`
  become derived outcomes of contract and proof where possible;
- governance docs, schemas, and validators: route humans only to typed
  non-machine-provable boundaries.

## Preserved Strengths

This target preserves existing Octon strengths:

- canonical control and evidence artifacts;
- generated-output and read-model non-authority;
- authorized effect token verification for material side effects;
- fail-closed obligations;
- support-target and authority-zone boundaries;
- retained receipts and auditability;
- host projections as visibility surfaces, not authority surfaces.

## Non-Authority Rule

Generated outputs, read models, proposal-local receipts, chat history, tool
availability, host UI state, and agent output may satisfy evidence gates only
when a contract allows them as evidence. They never mint authority.

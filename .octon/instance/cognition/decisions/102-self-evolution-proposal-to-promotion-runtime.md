# ADR 102: Self-Evolution Proposal-to-Promotion Runtime

- Date: 2026-04-28
- Status: Accepted
- Deciders: Octon maintainers
- Related:
  - Proposal packet id `octon-self-evolution-proposal-to-promotion-runtime-v5`
  - `/.octon/framework/engine/runtime/spec/evolution-program-v1.schema.json`
  - `/.octon/framework/engine/runtime/spec/promotion-runtime-v1.md`
  - `/.octon/framework/engine/runtime/spec/recertification-runtime-v1.md`
  - `/.octon/state/evidence/evolution/`

## Context

Octon needs a durable path for improving its own contracts, governance,
runtime surfaces, evidence obligations, proposal standards, generated/effective
trust model, support posture, connector posture, and operational policy without
allowing models, proposal packets, lab success, simulations, generated
summaries, or evidence distillation to become authority.

## Decision

Adopt Self-Evolution Proposal-to-Promotion Runtime v5 as an additive governed
runtime layer. Self-evolution begins with retained evidence, creates
non-authoritative Evolution Candidates, requires governance impact simulation
and risk-scaled assurance proof where applicable, compiles manifest-governed
proposal packets, requires Decision Requests or Constitutional Amendment
Requests for authority-changing work, promotes only accepted outputs into
declared durable targets, retains promotion receipts, and requires
post-promotion recertification.

The runtime may inspect and validate self-evolution state, but it may not
self-approve, self-promote, or execute material changes outside the governed run
lifecycle and execution authorization boundary.

## Consequences

- Proposal packets remain temporary decision aids under `inputs/**`.
- Generated projections remain derived non-authority read models.
- Evidence distillation, simulation success, and lab success can satisfy proof
  gates but cannot authorize change.
- Constitutional, governance, support, connector, generated/effective,
  evidence, proposal-standard, and authorization-boundary changes require
  human/quorum approval and recertification evidence.

# Architectural Review Mechanism Documentation And Projection Alignment

## Purpose

Align the native Architectural Review Mechanism across its durable
documentation, invocation surfaces, validators, and generated projections.

## Findings Carried Forward

- Product feature omission is intentional in current mechanism docs, but the
  rationale is weak for an operator-visible, lifecycle-gated mechanism.
- Domain and surface architecture audit modes are named one way in methodology
  and schema surfaces, but exposed through `audit-*` skill and command names.
- The governed mechanism index does not cover all six review modes declared by
  the methodology and report schema.
- `architecture-readiness-audit` is canonical; `audit-architecture-readiness`
  appears only as retired-name documentation, validator text, or historical
  evidence.
- Capability projections for the architectural-review entries were current in
  the audit, but the shared capability publication state was stale because of
  unrelated closeout skill digests.
- Generated proposal projections must be refreshed after newly created active
  packets.

## Route

This packet should proceed through normal architecture proposal lifecycle:

1. Proposal review.
2. Strict pre-integration architecture review before acceptance or
   implementation authorization.
3. Atomic durable implementation.
4. Canonical publication scripts for generated projections.
5. Implementation conformance and post-implementation drift/churn gates before
   implemented closeout or archive.

## Authority

This packet is proposal-local input. It does not change the Architectural
Review Mechanism and cannot authorize review outcomes, lifecycle gates,
generated publication, or closeout.

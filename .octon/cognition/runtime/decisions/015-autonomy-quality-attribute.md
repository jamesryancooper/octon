# ADR 015: Add Autonomy as a Quality Attribute

- Date: 2026-02-18
- Status: accepted

## Context

Octon explicitly governs agent behavior with deny-by-default permissions, no-silent-apply, and ACP gates. The quality model scores safety, security, reliability, and auditability, but did not name autonomy as a first-class attribute.

Without an explicit autonomy attribute, trade-offs between autonomous throughput and governance constraints are implicit and harder to tune per subsystem and maturity.

## Decision

Add `autonomy` to the canonical weighted/scored quality attribute set and include it in policy and measurement sources:

- Policy weights in `/Users/jamesryancooper/Projects/octon/.octon/assurance/standards/weights/weights.yml`
- Measurement scores in `/Users/jamesryancooper/Projects/octon/.octon/assurance/standards/scores/scores.yml`

Use a bounded-autonomy posture:

- Global baseline emphasizes autonomy but does not allow it to override safety/security.
- Agency and orchestration receive stronger autonomy weighting.
- Human-led `ideation` is explicitly low-autonomy.
- Higher maturity and regulated contexts constrain autonomy relative to early exploration.

## Consequences

- Planning and backlog drivers now include autonomy gaps explicitly.
- Governance remains fail-closed: autonomy does not bypass no-silent-apply or ACP requirements.
- Score evidence for autonomy must cite policy artifacts proving boundary enforcement and approval flow.

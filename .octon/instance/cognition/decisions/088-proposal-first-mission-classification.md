# ADR 088: Proposal-First Mission Classification

- Date: 2026-04-11
- Status: Accepted
- Deciders: Octon maintainers
- Related:
  - `/.octon/instance/cognition/context/shared/migrations/2026-04-11-octon-selected-harness-concepts-integration/plan.md`
  - `/.octon/state/control/execution/missions/mission-autonomy-live-validation/mission-classification.yml`

## Context

Octon already used mission classes and autonomy policy, but it did not retain
an explicit mission-local control record that could require proposal refs for
high-ambiguity or structurally novel work.

## Decision

Promote `mission-classification-v1` control records and extend mission
autonomy policy with proposal-first defaults.

Rules:

1. Mission classification is live mutable control truth.
2. Required proposal refs fail closed when missing.
3. Proposal refs may inform control routing, but they do not become authority.

## Consequences

- High-ambiguity or structurally novel work can be explicitly routed into
  proposal-first execution.
- Maintenance and steady-state validation missions can remain non-proposal
  paths when policy says they are bounded and known.

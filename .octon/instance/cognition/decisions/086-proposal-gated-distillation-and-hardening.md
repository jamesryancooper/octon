# ADR 086: Proposal-Gated Distillation And Hardening

- Date: 2026-04-11
- Status: Accepted
- Deciders: Octon maintainers
- Related:
  - `/.octon/instance/cognition/context/shared/migrations/2026-04-11-octon-selected-harness-concepts-integration/plan.md`
  - `/.octon/state/evidence/validation/failure-distillation/2026-04-11-selected-harness-concepts-integration/`
  - `/.octon/state/evidence/validation/distillation/2026-04-11-selected-harness-concepts-integration/`

## Context

Octon already retained rich evidence, but it lacked a canonical governed path
for clustering recurring failures or evidence patterns into promotable
recommendations.

## Decision

Promote failure-distillation and evidence-distillation as retained,
proposal-gated workflows.

Rules:

1. Distillation outputs remain evidence until separately promoted.
2. Hardening recommendations may not auto-promote authority.
3. Generated summaries are convenience projections only.

## Consequences

- Recurring failures can drive durable hardening work without creating shadow
  memory.
- Maintainers retain explicit promotion control over all authority changes.

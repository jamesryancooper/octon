# ADR 087: Tool Output Envelope Runtime Budgeting

- Date: 2026-04-11
- Status: Accepted
- Deciders: Octon maintainers
- Related:
  - `/.octon/instance/cognition/context/shared/migrations/2026-04-11-octon-selected-harness-concepts-integration/plan.md`
  - `/.octon/state/evidence/validation/tool-output-envelope/2026-04-11-selected-harness-concepts-integration/`

## Context

Octon already governed model execution budgets, but it did not define a
canonical compact tool-output envelope contract or repo-owned output budget
profile for agent-facing tool responses.

## Decision

Promote `tool-output-envelope-v1` plus a repo-owned
`tool-output-budgets.yml` overlay.

Rules:

1. Live envelopes stay compact and machine-usable.
2. Full raw payloads remain in retained evidence.
3. Budget profiles are repo-owned runtime overlays, not generated hints.

## Consequences

- Tool responses can stay within bounded live context without losing
  recoverability.
- Output compaction becomes validator-coverable and explicit.

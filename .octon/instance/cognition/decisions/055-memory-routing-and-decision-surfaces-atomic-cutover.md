# ADR 055: Memory Routing And Decision Surfaces Atomic Cutover

- Date: 2026-03-20
- Status: Accepted
- Deciders: Octon maintainers
- Related:
  - `/.octon/inputs/exploratory/proposals/.archive/architecture/memory-context-adrs-operational-decision-evidence/`
  - `/.octon/instance/cognition/context/shared/migrations/2026-03-20-memory-routing-and-decision-surfaces-cutover/plan.md`
  - `/.octon/generated/cognition/summaries/decisions.md`

## Context

Packet 11 formalizes memory as a routing model rather than a filesystem
bucket, but the live repository still carried one final round of drift:

1. the generated ADR summary still existed in both `instance/**` and
   `generated/**`,
2. active docs, workflows, templates, and checklists still told operators to
   write to the retired instance-local summary path,
3. the cognition generator and validator still treated the instance-local
   summary as a real generated output, and
4. the Packet 11 proposal package had not yet been archived with
   implementation evidence.

That left one final memory-routing risk: durable ADR authority, readable
generated summaries, and active guidance were still split between the final
class-root model and the earlier mixed-path summary model.

## Decision

Promote Packet 11 as one atomic clean-break cutover.

Rules:

1. Durable ADR authority remains only under
   `/.octon/instance/cognition/decisions/**`.
2. The readable generated ADR summary remains only under
   `/.octon/generated/cognition/summaries/decisions.md`.
3. `/.octon/instance/cognition/context/shared/decisions.md` is retired and
   must not exist after cutover.
4. Active docs, templates, workflows, and skills must use the generated
   summary for reading and ADR files plus `index.yml` for writing.
5. Generator and validator contracts must fail closed if a generated summary
   reappears under `instance/**`.
6. Packet 11 proposal materials move to `.archive/**` with an `implemented`
   disposition.
7. Rollback is full-revert-only for the cutover change set.

## Consequences

### Benefits

- One readable decision-summary destination and one authored ADR authority
  destination.
- No active control-plane guidance tells operators to edit derived summaries.
- Packet 11 now has explicit closeout evidence instead of remaining an active
  proposal after the durable implementation lands.

### Costs

- Large one-shot sweep across docs, templates, workflow guidance, skill
  references, validators, and generated-artifact contracts.
- Reduced flexibility for partial rollback or soft compatibility behavior.

### Follow-on Work

1. Packet 12 can consume cognition summaries as derived outputs without
   re-litigating decision authority.
2. Packet 14 can enforce duplicate-summary and wrong-class memory drift as a
   first-class fail-closed rule.
3. Future decision-surface changes should promote directly against
   `instance/**`, `state/**`, and `generated/**` rather than reopening the
   Packet 11 proposal.

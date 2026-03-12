# ADR 0006: Decision Records Are First-Class Continuity Evidence

## Status

- accepted

## Context

The package requires blocked and escalated material actions to produce durable
evidence, and it requires allowed material runs to retain their routing basis.
Without a canonical decision record, implementations would improvise where that
evidence lives and how it links to runs, queue items, incidents, and approvals.

## Decision

Material action decisions are first-class continuity evidence.

They use canonical `decision_id` identifiers and live under
`continuity/decisions/<decision-id>/decision.json`. Runs link to decision
records through `decision_id`, and blocked or escalated actions emit a decision
record even when no run is created.

## Consequences

- makes allow/block/escalate evidence deterministic
- keeps routing authority evidence out of mutable runtime state
- gives audits and operators one canonical place to explain why material work
  did or did not proceed

## Alternatives Considered

- Store blocked decisions only as runtime-local notes
- Embed allow decisions inside run records without a standalone continuity
  artifact

## Relationship To Existing Contracts

- reinforces `contracts/decision-record-contract.md`
- reinforces `contracts/run-linkage-contract.md`
- aligns with `normative/governance/evidence-observability-and-retention-spec.md`

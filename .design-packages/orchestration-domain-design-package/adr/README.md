# Orchestration ADRs

## Purpose

Architecture Decision Records (ADRs) capture material orchestration design
choices that should not drift silently over time.

Use ADRs to preserve the reasoning behind:

- surface boundaries
- authority and routing posture
- evidence and storage splits
- lifecycle or state-machine changes
- canonicalization decisions

## When An ADR Is Required

Create an ADR when a change would:

- alter a surface boundary
- change routing or authority semantics
- change lifecycle rules
- change evidence ownership or retention posture
- introduce a new canonical orchestration surface
- weaken or reinterpret governance/runtime/practices/continuity separation

## Naming Convention

- File name: `NNNN-short-kebab-case-title.md`
- Sequence starts at `0001`
- One ADR per material decision

## ADR Template

Use this structure:

```markdown
# ADR NNNN: Title

## Status
- proposed | accepted | superseded | rejected

## Context
[What problem or ambiguity required the decision?]

## Decision
[What was decided?]

## Consequences
[Positive, negative, and boundary effects.]

## Alternatives Considered
- [Alternative 1]
- [Alternative 2]

## Relationship To Existing Contracts
[Which contracts, surfaces, or charter rules this decision reinforces.]
```

## Relationship To Charter And Contracts

- Charter explains the domain’s normative shape.
- Contracts define object and interface behavior.
- ADRs explain why material architectural choices were made.

Future implementation changes should:

1. update contracts if behavior changes
2. add or supersede an ADR if the architectural rationale changes

## Starter ADRs

- `0001-queue-is-automation-ingress-only.md`
- `0002-runs-are-projection-and-linkage-layer.md`
- `0003-campaigns-remain-optional.md`
- `0004-governance-runtime-continuity-separation.md`
- `0005-workflow-recurrence-stays-outside-workflows.md`
- `0006-decision-records-are-first-class-continuity-evidence.md`
- `0007-queue-claims-require-claimed-at-and-claim-token.md`
- `0008-replace-is-cancel-safe-latest-wins.md`

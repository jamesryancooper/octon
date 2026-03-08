# Continuity Decisions

Routing, authority, and prerequisite decision evidence.

## Purpose

`continuity/decisions/` stores append-oriented decision records for material
orchestration actions.

This surface exists so operators and validators can answer:

- why work was allowed
- why work was blocked
- why escalation was required

It is continuity-owned evidence, not active task state.

## Canonical Policy

- Retention and class mapping: `retention.json`
- Architecture contract: `/.harmony/continuity/_meta/architecture/decisions-retention.md`
- Memory governance: `/.harmony/agency/governance/MEMORY.md`

## Layout

```text
decisions/
├── README.md
├── retention.json
└── <decision-id>/
    ├── decision.json
    └── digest.md
```

`decision.json` is required. `digest.md` is optional.

## What Belongs Here

- decision records for `allow`, `block`, and `escalate`
- prerequisite and approval evidence references
- operator-readable decision digests

## What Does Not Belong Here

- active task state
- workflow or mission definitions
- run receipts or execution bundles
- ad hoc notes

## Forward-Only Rollout

Historical run bundles may still contain legacy `acp-decision.json` artifacts
inside `continuity/runs/`. Those remain historical run-bundled evidence.

New canonical orchestration decision evidence belongs in `continuity/decisions/`.

## Safety Rules

- Never store secrets or regulated data.
- Treat decision records as append-oriented evidence.
- Do not rewrite decision outcomes in place. A changed decision produces a new
  `decision_id`.

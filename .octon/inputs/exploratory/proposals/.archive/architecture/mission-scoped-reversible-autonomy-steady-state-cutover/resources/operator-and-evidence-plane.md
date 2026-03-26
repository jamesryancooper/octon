# Operator And Evidence Plane

## Goal

Finish the human-awareness and control-evidence parts of MSRAOM so that the
model is both operator-legible and audit-correct.

## Human-Facing Summary Set

For every active mission, generate:

- `now.md`
- `next.md`
- `recent.md`
- `recover.md`

These remain human-facing derived views.

### Required source inputs

`now.md`
- mission charter
- mode state
- autonomy budget
- circuit breakers
- scenario resolution

`next.md`
- scenario resolution
- intent register
- action slices
- next-actions continuity file

`recent.md`
- run evidence
- control evidence
- handoff state
- scenario resolution

`recover.md`
- run evidence
- control evidence
- mode state
- scenario resolution

## Operator Digests

For every active mission and every routed owner/recipient:
- generate one digest entry per operator
- route from subscriptions + ownership policy
- include:
  - mission title
  - oversight mode
  - digest route
  - budget state
  - breaker state
  - route freshness
  - active attention requirement, if any

## Machine-Readable Mission View

Add:

`generated/cognition/projections/materialized/missions/<mission-id>/mission-view.yml`

This is the machine-facing summary of the mission’s current steady-state
runtime picture.

### Why it is needed
The root manifest and contract registry already name the mission-projection
root. Keeping it empty or undefined leaves an unnecessary contradiction.

### What it should contain
- mission identity and owner
- current mode state
- effective route summary
- current and next slice refs
- active directives
- active authorize-updates
- budget/breaker summary
- recovery/finalize summary
- summary artifact refs
- continuity refs
- last refresh timestamp

## Refresh Triggers

The summary set, operator digests, and mission view must be refreshed on:

- mission creation / seeding
- mission charter change
- route generation
- mode-state change
- intent or slice change
- directive change
- authorize-update change
- schedule change
- autonomy-budget change
- breaker change
- run receipt emission
- control receipt emission
- continuity mutation

## Retained Control Evidence Coverage

Emit a control receipt for each of these:
- mission state seed
- directive add / apply / reject / expire
- authorize-update add / apply / reject / expire
- schedule mutation
- budget-state transition
- breaker trip
- breaker reset
- safing enter / exit
- break-glass enter / exit
- finalize block / unblock
- closeout

### Control receipt minimum fields
- `receipt_id`
- `mission_id`
- `control_mutation_class`
- `source_ref`
- `applied_to_ref`
- `issuer_ref`
- `timestamp`
- `result`
- `reason_codes`
- `superseded_receipt_ref` where relevant

## Why This Matters

MSRAOM does not rely on “more alerts” for oversight. It relies on:
- correct control truth
- correct effective route
- correct retained evidence
- correct generated awareness views

The operator and evidence plane is where that separation becomes tangible.

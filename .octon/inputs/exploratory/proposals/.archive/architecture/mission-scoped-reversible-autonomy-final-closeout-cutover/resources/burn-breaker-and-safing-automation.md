# Burn, Breaker, And Safing Automation

## Final design

Autonomy burn and breaker behavior become an explicit **retained-evidence-driven reducer loop**.

## Inputs to the reducer

The reducer must consume:

- run receipts
- rollback events
- compensation events
- repeated denials
- repeated retries
- control-surface corruption events
- out-of-blast-radius side effects
- missing observability on risky work
- breaker trip triggers
- explicit breaker resets
- safing and break-glass state

## Reducer outputs

The reducer updates:

- `autonomy-budget.yml`
- `circuit-breakers.yml`
- `mode-state.yml` overlays where needed
- retained control receipts for all state transitions

## Invariants

1. Burn state is not a static file; it is recomputed from evidence.
2. Breaker state is not a static file; it is recomputed from evidence plus explicit resets.
3. Route, evaluator, scheduler, and summaries all consume the same canonical burn/breaker state.
4. Safing and break-glass changes are reflected in both control truth and control evidence.

## Why this closes the audit gap

The earlier implementation already had policy, state files, and evaluator consumption.
What was still weak was proving that the system actually **recomputes** and **records** those transitions from retained evidence instead of just carrying configuration and hand-edited state.
This packet makes the reducer and its receipts a hard invariant.

# Automation Operations

Operational guidance for automations under
`/.harmony/orchestration/runtime/automations/`.

## Scope

Applies to pause, resume, replay, retry, and routine automation operations.

## Operating Rules

1. Pause by changing `automation.yml` state, not by deleting queue items or
   mutating watcher definitions.
2. Resume by reactivating the automation definition, then let normal trigger
   evaluation determine the next admissible launch.
3. Replay only by creating a new routing context.
   - Replaying the same event or schedule window without changed context is an
     idempotency violation.
4. Treat `state/last-run.json` and `state/counters.json` as projections.
   - Run truth remains in `runtime/runs/` and `continuity/runs/`.
5. Investigate repeated terminal failures before forcing retries.
   - Prefer incident linkage or pause when the same failure class repeats.

## Failure Posture

- Queue or lock conflicts should defer or retry according to `policy.yml`.
- Binding or policy validation failures should block admission and write
  decisions rather than creating speculative runs.
- Evidence-write failure and launch-commit failure should be treated as
  incident-worthy conditions when policy requires it.

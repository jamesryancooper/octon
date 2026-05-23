# Rollback Plan

## Rollback Objective

Restore the previous Lifecycle Autopilot proposal packet behavior without
leaving partially active phase-loop substrate semantics, stale generated
projections, or misleading support claims.

## Rollback Triggers

- lifecycle contract validation fails after implementation;
- runner checkpoint or event-log replay is inconsistent;
- proposal implementation gates can be skipped;
- executor can dispatch durable routes without required proof;
- generated effective projection freshness cannot be proven;
- proposal lifecycle skills or docs claim authority from proposal-local or
  generated artifacts;
- acceptance tests expose a route that self-authorizes.

## Rollback Steps

1. Restore previous source-authored lifecycle contract, schema, runner,
   executor, validator, skill, prompt, command, and documentation behavior.
2. Remove phase-loop fields or code paths introduced by the failed
   implementation unless a retained compatibility exception is approved.
3. Refresh generated effective projections from the restored source state.
4. Retain publication or rollback evidence under the canonical evidence root.
5. Re-run lifecycle contract, runner, executor, and proposal acceptance tests.
6. Record the failed implementation as blocked, rejected, or superseded rather
   than implemented.

## Fail-Closed Posture

If rollback cannot prove restored source and generated projection alignment,
the lifecycle route must stop as blocked or escalated. It must not claim
implementation, closeout, archive readiness, or generated publication
freshness.

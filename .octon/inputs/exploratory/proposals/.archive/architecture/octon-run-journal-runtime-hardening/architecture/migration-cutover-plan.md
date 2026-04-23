# Migration and Cutover Plan

## Migration principle

Do not break existing v1 run-event-ledger consumers abruptly. Introduce v2
contracts and normalize v1 runtime events into canonical v2 events during a
bounded migration window.

## Cutover stages

### Stage 1 — Contract shadow

- Add v2 contracts beside v1 contracts.
- Keep v1 contracts readable.
- Add validators in warning mode for existing fixtures.
- Generate no new support claims.

### Stage 2 — Dual emission

- Runtime emits existing runtime events and canonical Run Journal v2 events.
- Runtime-state materializer uses v2 events when present.
- Evidence closeout includes both compatibility refs and v2 snapshot.

### Stage 3 — V2 required for consequential Runs

- Supported consequential Runs must emit v2 canonical journals.
- V1 events may remain as compatibility telemetry only.
- Validators fail closed for missing v2 events on material side-effecting Runs.

### Stage 4 — Read-model cutover

- Operator read models and generated support projections derive from v2 journal
  and retained evidence snapshots.
- Generated projections that depend on v1-only surfaces are marked stale or
  unsupported.

### Stage 5 — Closeout and deprecation

- Keep v1 schemas for historical reconstruction.
- Mark v2 as active promoted contract.
- Archive migration evidence under `state/evidence/validation/**`.

## Rollback strategy

If v2 cutover fails:

1. stop accepting new consequential Runs requiring v2,
2. retain all emitted v2 journal evidence for diagnosis,
3. revert runtime emitters to v1 compatibility mode,
4. mark generated projections stale,
5. open drift incident evidence,
6. do not widen support-target claims until validators pass again.

## Cutover success signal

Cutover is complete when valid v2 Run Journals can drive runtime-state
reconstruction, replay, closeout evidence, operator disclosure, and support-target
admission for the required fixture Runs.

# Decision Record Plan

Promotion should create or update the following decision records.

## DR-001 — Run Journal as canonical execution substrate

Decision: The Run Journal under `state/control/execution/runs/<run-id>/` is the
canonical append-only runtime transition record for consequential Runs.

Rejected alternatives:

- runtime-state as source of truth,
- generated operator views as source of truth,
- untyped telemetry logs as replay basis,
- per-adapter event formats without normalization.

## DR-002 — Runtime-state as derived view

Decision: `runtime-state.yml` is derived from the journal and side artifacts.
Journal conflicts win and create drift incidents.

## DR-003 — Evidence snapshot and closeout

Decision: retained evidence snapshots must hash-match the live control journal at
Run closure.

## DR-004 — Runtime bus as sole append path

Decision: canonical journal events are appended only through runtime bus or an
equivalent engine-owned append service.

## DR-005 — Replay dry-run default

Decision: replay may reconstruct, simulate, or dry-run by default; live side
effects require a new authorization request and GrantBundle.

## DR-006 — Generated read models remain non-authority

Decision: operator read models and generated projections may disclose and
summarize but cannot authorize, reconstruct state, or widen support targets.

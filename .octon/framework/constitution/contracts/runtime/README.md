# Constitutional Runtime Contracts

`/.octon/framework/constitution/contracts/runtime/**` defines the
constitutional run-lifecycle model for governed execution.

## Status

Run roots are the primary execution-time unit of truth.

- canonical run-topology manifests live under:
  `/.octon/state/control/execution/runs/<run-id>/run-manifest.yml`
- canonical run event ledgers live under:
  `/.octon/state/control/execution/runs/<run-id>/{events.ndjson,events.manifest.yml}`
- canonical run-bound authority bundles live under:
  `/.octon/state/control/execution/runs/<run-id>/authority/**`
- canonical runtime state lives under:
  `/.octon/state/control/execution/runs/<run-id>/runtime-state.yml`
- canonical resumability and handoff continuity live under:
  `/.octon/state/continuity/runs/<run-id>/handoff.yml`
- canonical rollback and contamination posture lives under:
  `/.octon/state/control/execution/runs/<run-id>/rollback-posture.yml`
- canonical control checkpoints live under:
  `/.octon/state/control/execution/runs/<run-id>/checkpoints/**`
- canonical retained run receipts live under:
  `/.octon/state/evidence/runs/<run-id>/receipts/**`
- canonical retained run assurance reports, measurements, interventions, and
  disclosure outputs live under:
  `/.octon/state/evidence/runs/<run-id>/{assurance/**,measurements/**,interventions/**,disclosure/**}`
- canonical replay and trace pointers live under:
  `/.octon/state/evidence/runs/<run-id>/{replay-pointers.yml,trace-pointers.yml}`

## Final Rules

- `run-manifest.yml` is the canonical bound run-manifest model.
- `events.ndjson` is the canonical append-only run transition record.
- `runtime-state.yml` carries mutable execution status only; it must not serve
  as the only run-topology manifest.
- Mission remains the continuity and long-horizon autonomy container.
- Run continuity is first-class operational state and remains distinct from
  retained run evidence.
- Consequential stages must bind the run control and evidence roots before
  side effects occur.
- Mission continuity, summaries, and mission views may consume run evidence,
  but they may not replace the run root as the execution-time source of truth.

## Canonical Files

- `family.yml`
- `run-event-v1.schema.json`
- `run-event-ledger-v1.schema.json`
- `run-manifest-v1.schema.json`
- `runtime-state-v1.schema.json`
- `run-continuity-v1.schema.json`
- `rollback-posture-v1.schema.json`
- `checkpoint-v2.schema.json`
- `state-reconstruction-v1.md`
- `replay-pointers-v1.schema.json`

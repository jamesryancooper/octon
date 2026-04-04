# Run Control Roots

`state/control/execution/runs/` is the canonical mutable control root for
per-run objective binding and runtime lifecycle execution.

This root is the primary execution-time unit of truth:

- every consequential run must bind `run-contract.yml` under this root before
  side effects occur
- every consequential run must also bind `run-manifest.yml` as the canonical
  run-topology manifest
- every consequential run must retain `events.ndjson` plus
  `events.manifest.yml` as the canonical append-only event ledger
- every consequential run must retain a run-bound `authority/**` bundle for
  request, decision, grant, lease, and revocation material
- stage attempts belong under `stage-attempts/**` beneath the bound run root
- checkpoints, runtime-state, and rollback-posture belong under the same run
  control root
- mutable resumability and handoff continuity belongs under the matching
  `state/continuity/runs/<run-id>/` root
- assurance, measurement, intervention, and replay evidence belong under the
  matching retained run evidence root
- canonical run disclosure lives under the matching
  `state/evidence/disclosure/runs/<run-id>/` root
- mission remains the continuity and long-horizon autonomy container, but it
  consumes run evidence instead of substituting for it

## Canonical Shape

```text
state/control/execution/runs/<run-id>/
  run-contract.yml
  run-manifest.yml
  events.ndjson
  events.manifest.yml
  authority/
  stage-attempts/
  checkpoints/
  runtime-state.yml
  rollback-posture.yml
```

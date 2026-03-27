# Run Control Roots

`state/control/execution/runs/` is the canonical mutable control root for
per-run objective binding and runtime lifecycle execution.

Wave 3 promotes this root to the primary execution-time unit of truth. During
the transitional coexistence window:

- every consequential run must bind `run-contract.yml` under this root before
  side effects occur
- stage attempts belong under `stage-attempts/**` beneath the bound run root
- checkpoints, runtime-state, and rollback-posture belong under the same run
  control root
- mission remains the continuity and long-horizon autonomy container, but it
  consumes run evidence instead of substituting for it

## Canonical Shape

```text
state/control/execution/runs/<run-id>/
  run-contract.yml
  stage-attempts/
  checkpoints/
  runtime-state.yml
  rollback-posture.yml
```

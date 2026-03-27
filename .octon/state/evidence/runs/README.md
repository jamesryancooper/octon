# Run Evidence

`state/evidence/runs/` stores retained operational run evidence, receipts, and
replay pointers.

Its mutable control-plane counterpart is `state/control/execution/runs/`,
which holds bound run contracts, runtime-state, rollback-posture, stage
attempts, and control checkpoints.

Wave 3 canonicalizes the following evidence families beneath each run root:

```text
state/evidence/runs/<run-id>/
  receipts/
  checkpoints/
  replay-pointers.yml
  trace-pointers.yml
  retained-run-evidence.yml
```

Compatibility root-level run evidence artifacts may remain during the
transitional backfill, but canonical readers should prefer the receipts,
checkpoint, replay, and pointer families above.

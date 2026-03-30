# Run Evidence

`state/evidence/runs/` stores retained operational run evidence, receipts, and
replay pointers.

Its mutable control-plane counterpart is `state/control/execution/runs/`,
which holds bound run contracts, run manifests, runtime-state,
rollback-posture, stage attempts, and control checkpoints.

Wave 4 canonicalizes the following evidence families beneath each run root:

```text
state/evidence/runs/<run-id>/
  receipts/
  checkpoints/
  replay/
  assurance/
  measurements/
  interventions/
  disclosure/
  replay-pointers.yml
  trace-pointers.yml
  evidence-classification.yml
  retained-run-evidence.yml
```

Canonical readers must consume the receipts, checkpoint, replay, proof-plane,
measurement, intervention, disclosure, and pointer families above; deprecated
root-level compatibility artifacts are retired.

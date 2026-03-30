# Run Evidence

`state/evidence/runs/` stores retained operational run evidence, receipts, and
replay pointers.

Its mutable control-plane counterpart is `state/control/execution/runs/`,
which holds bound run contracts, run manifests, runtime-state,
rollback-posture, stage attempts, and control checkpoints.

Canonical evidence families beneath each run root:

```text
state/evidence/runs/<run-id>/
  receipts/
  checkpoints/
  replay/
  assurance/
  measurements/
  interventions/
  replay-pointers.yml
  trace-pointers.yml
  evidence-classification.yml
  retained-run-evidence.yml
```

Canonical readers must consume the receipts, checkpoint, replay, proof-plane,
measurement, intervention, and pointer families above from the run evidence
root. Canonical RunCards now live under
`state/evidence/disclosure/runs/<run-id>/`; any run-local disclosure directory
is historical mirror material only.

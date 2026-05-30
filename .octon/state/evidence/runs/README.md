# Run Evidence

`state/evidence/runs/` stores retained operational run evidence, receipts, and
replay pointers.

Its mutable control-plane counterpart is `state/control/execution/runs/`,
which holds bound run contracts, run manifests, runtime-state,
rollback-posture, stage attempts, and control checkpoints.

Canonical top-level retained run containers under `state/evidence/runs/`
include `ci/`, `engine/`, `operations/`, `services/`, `skills/`, and
`workflows/`. These family buckets may contain multiple retained run roots,
such as `ci/repo-hygiene/<audit-id>/`.

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

Publishable evidence receipts that summarize local or private run evidence use
the schema at
`/.octon/framework/constitution/contracts/retention/publishable-evidence-receipt-v1.schema.json`
and live beside the relevant retained run evidence, for example:

```text
state/evidence/runs/skills/<skill>/<run-id>/publishable-receipt.json
```

These receipts are repo-publishable summaries with digest-backed local evidence
references. They do not publish raw private evidence, make local-only paths
authoritative, or replace the retained run evidence root.

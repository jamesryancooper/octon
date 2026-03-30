# Orchestration Runs

Orchestration-facing run projections, indexes, and reverse-lookup materialized
views.

## Authority Order

`state/control/execution/runs/<run-id>/run-contract.yml -> README.md -> index.yml -> <run-id>.yml -> by-surface/ -> state/evidence/runs/`

`state/control/execution/runs/<run-id>/run-contract.yml` is the canonical
per-run execution contract.

`state/control/execution/runs/<run-id>/run-manifest.yml` is the canonical bound
run-manifest model.

`state/control/execution/runs/<run-id>/{runtime-state.yml,rollback-posture.yml,checkpoints/**}`
carry the canonical lifecycle state beneath that run manifest.

`state/continuity/runs/<run-id>/handoff.yml` is the canonical mutable
resumability and handoff state for the bound run.

`<run-id>.yml` is the orchestration-facing projection and mutable operator view
over that canonical run root.

`state/evidence/runs/<run-id>/` remains the durable evidence authority,
including canonical `receipts/**`, `checkpoints/**`, `replay/**`,
`assurance/**`, `measurements/**`, `interventions/**`, `disclosure/**`,
`replay-pointers.yml`, `trace-pointers.yml`,
`evidence-classification.yml`, and external index links when required.

## Layout

```text
runs/
├── README.md
├── index.yml
├── by-surface/
│   ├── workflows/
│   ├── missions/
│   ├── automations/
│   └── incidents/
└── <run-id>.yml
```

## Boundary

- Store orchestration-facing run projections and lookup indexes here.
- Store canonical per-run execution contracts under
  `/.octon/state/control/execution/runs/<run-id>/`.
- Store canonical run continuity under
  `/.octon/state/continuity/runs/<run-id>/`.
- Store durable receipts, digests, and evidence bundles in
  `/.octon/state/evidence/runs/`.
- Do not let `index.yml`, `<run-id>.yml`, or `by-surface/` outrank the
  canonical run-control root.

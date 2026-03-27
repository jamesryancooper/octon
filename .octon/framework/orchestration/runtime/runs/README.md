# Orchestration Runs

Orchestration-facing run projections, indexes, and reverse-lookup materialized
views.

## Authority Order

`state/control/execution/runs/<run-id>/run-contract.yml -> README.md -> index.yml -> <run-id>.yml -> by-surface/ -> state/evidence/runs/`

`state/control/execution/runs/<run-id>/run-contract.yml` is the canonical
per-run execution contract for Wave 1.

`<run-id>.yml` is the orchestration-facing projection and mutable operator view
over that canonical run root.

`state/evidence/runs/<run-id>/` remains the durable evidence authority.

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
- Store durable receipts, digests, and evidence bundles in
  `/.octon/state/evidence/runs/`.
- Do not let `index.yml`, `<run-id>.yml`, or `by-surface/` outrank the
  canonical run-control root.

# Orchestration Runs

Orchestration-facing run state, indexes, and reverse-lookup projections.

## Authority Order

`README.md -> index.yml -> <run-id>.yml -> by-surface/ -> continuity/runs/`

`<run-id>.yml` is the canonical orchestration-facing run object and mutable
status record.

`continuity/runs/<run-id>/` remains the durable evidence authority.

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

- Store orchestration-facing run state and lookup projections here.
- Store durable receipts, digests, and evidence bundles in
  `/.octon/continuity/runs/`.
- Do not let `index.yml` or `by-surface/` outrank canonical per-run records.

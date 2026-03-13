# Orchestration Queue

Shared durable intake buffering for automation-targeted orchestration work.

## Authority Order

1. `queue-item-and-lease-contract.md`
2. `schemas/queue-item-and-lease.schema.json`
3. `schema.yml`
4. `registry.yml`
5. lane state under `pending/`, `claimed/`, `retry/`, and `dead-letter/`
6. append-only `receipts/`

`README.md` is explanatory only.

The queue surface is one shared substrate in v1. It is not a collection of
named queue objects.

## Layout

```text
queue/
├── README.md
├── queue-item-and-lease-contract.md
├── registry.yml
├── schema.yml
├── schemas/
├── pending/
├── claimed/
├── retry/
├── dead-letter/
└── receipts/
```

## Boundary

- Queue ingress remains automation-only.
- `queue-item-and-lease-contract.md` and
  `schemas/queue-item-and-lease.schema.json` are the canonical queue item
  authority.
- Lane directories are mutable state.
- `receipts/` is append-only evidence.
- `registry.yml` and `schema.yml` are discovery and reference artifacts, not
  the primary behavioral contract.

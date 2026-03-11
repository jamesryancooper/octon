# Orchestration Queue

Shared durable intake buffering for automation-targeted orchestration work.

## Authority Order

`README.md -> registry.yml / schema.yml -> queue item contract/schema -> lane state -> receipts`

The queue surface is one shared substrate in v1. It is not a collection of
named queue objects.

## Layout

```text
queue/
├── README.md
├── registry.yml
├── schema.yml
├── pending/
├── claimed/
├── retry/
├── dead-letter/
└── receipts/
```

## Boundary

- Queue ingress remains automation-only.
- Lane directories are mutable state.
- `receipts/` is append-only evidence.
- `registry.yml` and `schema.yml` are discovery and reference artifacts, not
  the primary behavioral contract.

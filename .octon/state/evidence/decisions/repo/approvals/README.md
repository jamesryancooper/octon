# Decision Approvals

Durable approval, waiver, and override artifacts used by privileged
orchestration actions.

## Layout

```text
approvals/
└── <approval-id>.json
```

## Boundary

- These artifacts are continuity-owned evidence.
- Runtime incident or automation state may reference approval ids.
- Runtime state must not replace these approval artifacts.

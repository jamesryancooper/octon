# Queue Item And Lease Contract

## Purpose

This contract defines the canonical queue item schema, lane model, and claim
lease behavior for `queue`.

## Required Artifacts

```text
queue/
├── registry.yml
├── schema.yml
├── pending/
├── claimed/
├── retry/
├── dead-letter/
└── receipts/
```

## Surface Naming Note

`queue` is the top-level surface name because v1 models one shared queueing
substrate.

V1 still models one shared queueing substrate rather than a collection of
independently defined queue objects. `queue_item_id` remains the authoritative
unit of routing and state. Introducing `queue_id`, per-queue definitions, or
named queue registries requires a new contract revision.

## Queue Item Fields

| Field | Required | Notes |
|---|---|---|
| `queue_item_id` | yes | canonical stable id; for event-driven ingress it should be deterministic from `event_id` + `target_automation_id` unless explicit replay/redrive context changes it |
| `event_id` | no | source watcher event |
| `watcher_id` | no | source watcher |
| `target_automation_id` | yes | intended consumer |
| `status` | yes | `pending`, `claimed`, `retry`, `dead_letter` |
| `priority` | yes | integer or named level |
| `available_at` | yes | earliest claimable timestamp |
| `claimed_by` | no | current claimant |
| `claimed_at` | no | claim timestamp; required when `status=claimed` |
| `claim_deadline` | no | lease expiry timestamp |
| `claim_token` | no | unique token for the active claim; required when `status=claimed` |
| `attempt_count` | yes | current attempts |
| `max_attempts` | yes | retry ceiling |
| `payload_ref` | no | pointer to event or payload artifact |
| `summary` | yes | short human-readable description |
| `last_error` | no | most recent failure summary |
| `enqueued_at` | yes | enqueue timestamp |

## Lane Semantics

- `pending/`: ready or future-ready items not currently claimed
- `claimed/`: items under active lease
- `retry/`: items waiting for next retry window
- `dead-letter/`: terminal failures or operator-quarantined items
- `receipts/`: append-only acknowledgement and terminal handling records

## Claim Ordering Rules

- Eligible items must be selected in this order:
  1. highest `priority`
  2. earliest `available_at`
  3. earliest `enqueued_at`
  4. lexical `queue_item_id`
- Only items in `pending/` or eligible `retry/` lanes may be claimed.

## Lease Rules

1. Claiming an eligible item atomically moves it to `claimed/`.
2. Every claim must set `claimed_by`, `claimed_at`, `claim_deadline`, and
   `claim_token`.
3. Successful acknowledgement requires the matching `claim_token`, writes a
   receipt, and removes the item from active lanes.
4. Stale acknowledgement or release attempts with a non-matching `claim_token`
   are rejected and must be recorded as failed handling.
5. If a claim expires without acknowledgement, the item moves to `retry/`,
   clears active-claim fields, increments `attempt_count`, and becomes eligible
   again at its next `available_at`.
6. Lease renewal or heartbeat semantics are intentionally out of scope for v1.
7. Items move to `dead-letter/` when:
   - `attempt_count >= max_attempts`, or
   - the failure class is non-retryable, or
   - an operator explicitly dead-letters the item

## Invariants

- An active queue item exists in exactly one active lane at a time.
- `target_automation_id` is required for machine-consumed items.
- `claim_deadline` must be later than `claimed_at`.
- `claim_token` must be present whenever `status=claimed`.
- `attempt_count` must monotonically increase across retries.
- Acknowledged items must have a receipt in `receipts/`.
- Queue ingress is automation-only; missions are not queue targets.

## Example

```yaml
queue_item_id: "q-20260307-001"
event_id: "evt-20260307-governance-drift-01"
watcher_id: "governance-drift-watcher"
target_automation_id: "weekly-freshness-audit"
status: "claimed"
priority: 50
available_at: "2026-03-07T18:00:00Z"
claimed_by: "weekly-freshness-audit"
claimed_at: "2026-03-07T18:00:05Z"
claim_deadline: "2026-03-07T18:10:05Z"
claim_token: "claim-weekly-freshness-audit-0001"
attempt_count: 0
max_attempts: 3
summary: "Run freshness audit for orchestration drift event."
enqueued_at: "2026-03-07T18:00:00Z"
```

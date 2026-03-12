# Coordination Lock Contract

## Purpose

Define the canonical lock artifact, lease behavior, and acquisition semantics
used to enforce target-global coordination.

This contract is normative for lock persistence and lock lifecycle behavior.

## Canonical Lock Artifact

Canonical file-backed shape:

```text
orchestration/runtime/_coordination/locks/<coordination-key>.json
```

Equivalent service-backed storage is allowed only if it preserves the same
schema and semantics.

## Lock Fields

| Field | Required | Notes |
|---|---|---|
| `lock_id` | yes | canonical stable id |
| `coordination_key` | yes | target-global key |
| `lock_class` | yes | `exclusive`, `shared-read`, `shared-compatible` |
| `owner_run_id` | yes | current owning run |
| `owner_executor_id` | no | present after executor acknowledgement |
| `lock_state` | yes | `held`, `released`, `expired`, `transferred` |
| `acquired_at` | yes | ISO timestamp |
| `last_heartbeat_at` | no | present while held |
| `lease_expires_at` | yes | ISO timestamp |
| `lock_version` | yes | monotonically increasing CAS version |
| `released_at` | no | required when `lock_state=released` |
| `previous_lock_id` | no | required when `lock_state=transferred` |

## Acquisition Algorithm

1. derive `coordination_key`
2. read current lock record for that key
3. if no active conflicting lock exists, attempt compare-and-swap acquire
4. if acquire succeeds:
   - write `lock_id`
   - set `owner_run_id`
   - set `lock_state=held`
   - set `acquired_at`
   - set `lease_expires_at`
   - increment `lock_version`
5. if acquire fails due to contention, return deterministic contention outcome

## Lock Lease Semantics

- the owner renews `last_heartbeat_at` and `lease_expires_at`
- renewal increments `lock_version`
- expired locks are treated as non-live for new acquisition, but lineage is
  retained through the artifact state

## Lock Transfer Conditions

Transfer is allowed only when:

- the prior lease expired or was explicitly released, and
- the recovery or replacement action is permitted by policy

Transfer MUST:

- create a new `lock_id`
- retain `previous_lock_id`
- increment `lock_version`

## Release Conditions

Lock release occurs only when:

- the owning run becomes terminal, or
- recovery abandons the run under explicit authority

Release MUST set:

- `lock_state=released`
- `released_at`

## Storage Guarantees

Implementations MUST provide:

- atomic compare-and-swap on `coordination_key`
- strong consistency for reads immediately after successful writes
- monotonic `lock_version` increments
- monotonic time ordering within one authoritative clock domain

## Invariants

- At most one `held` exclusive lock per `coordination_key`.
- `lease_expires_at` must be later than `acquired_at`.
- `lock_version` is strictly monotonic per key.
- Released or expired locks never silently become `held` again without a new
  acquisition.

# Watcher Event Contract

## Purpose

This contract defines the canonical event envelope emitted by `watchers`.

## Required Object Artifacts

```text
watchers/
├── registry.yml
└── <watcher-id>/
    ├── watcher.yml
    ├── sources.yml
    ├── rules.yml
    ├── emits.yml
    └── state/
        ├── cursor.json
        ├── health.json
        └── suppressions.json
```

## Event Envelope

| Field | Required | Notes |
|---|---|---|
| `event_id` | yes | canonical stable event id |
| `watcher_id` | yes | emitting watcher |
| `event_type` | yes | semantic event kind |
| `emitted_at` | yes | ISO timestamp |
| `severity` | yes | `info`, `warning`, `high`, `critical` |
| `dedupe_key` | yes | stable duplicate-suppression key |
| `partition_key` | no | optional routing or sharding hint |
| `source_ref` | yes | source that produced the event |
| `summary` | yes | short operator-readable summary |
| `payload` | no | sanitized inline payload |
| `payload_ref` | no | pointer to external structured evidence |
| `target_automation_id` | no | recommended automation target |
| `candidate_incident_id` | no | optional incident correlation hint |

## Emission Guarantees

- Delivery assumption: `at least once`
- Duplicate handling relies on `dedupe_key`
- Events must be sanitized before emission
- Watchers may recommend a target, but may not directly invoke a workflow

## Invariants

- `event_id` must be unique.
- `dedupe_key` must be stable for semantically identical detections.
- `severity` must be explicit on every event.
- `summary` must be present even when payload is omitted.

## Example

```yaml
event_id: "evt-20260307-governance-drift-01"
watcher_id: "governance-drift-watcher"
event_type: "freshness-drift"
emitted_at: "2026-03-07T18:00:00Z"
severity: "warning"
dedupe_key: "governance-drift-watcher:freshness-drift:.harmony/orchestration"
source_ref: ".harmony/orchestration"
summary: "Freshness threshold exceeded for orchestration artifacts."
target_automation_id: "weekly-freshness-audit"
```

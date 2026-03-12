# Watcher Definition Contract

## Purpose

This contract defines the implementation-ready definition model and authority
split for `watchers`.

`watchers` are long-lived detectors. Their execution behavior must be grounded
in structured definition artifacts rather than registry projections or prose.

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

## Authority Split

- `watcher.yml`
  - canonical watcher identity, lifecycle status, runner mode, and cursor /
    suppression baseline
- `sources.yml`
  - canonical monitored-source declarations and access requirements
- `rules.yml`
  - canonical machine-readable detection rules mapping source conditions to
    event types, severity, summary text, and optional routing hints
- `emits.yml`
  - canonical declaration of allowed emitted event types, payload fields, and
    routing-hint allowance
- `state/`
  - watcher-runner-owned mutable state only
- emitted watcher events plus linked queue / decision / incident lineage
  - canonical watcher evidence layer; never substituted by `state/`

## Minimum Definition Fields

### `watcher.yml`

| Field | Required | Notes |
|---|---|---|
| `watcher_id` | yes | canonical stable id |
| `title` | yes | operator-readable name |
| `owner` | yes | human or agent owner |
| `status` | yes | `active`, `paused`, `disabled`, `error` |
| `runner.kind` | yes | `poll` or `subscription` |
| `runner.cadence` | required when `runner.kind=poll` | ISO-8601 duration string |
| `cursor_mode` | yes | `none`, `per-source-watermark`, or `opaque` |
| `suppression_window` | no | ISO-8601 duration used for watcher-local duplicate suppression |

### `sources.yml`

| Field | Required | Notes |
|---|---|---|
| `sources[]` | yes | one or more source definitions |
| `sources[].source_id` | yes | watcher-local stable source id |
| `sources[].kind` | yes | source kind string; stable within one watcher definition |
| `sources[].ref` | yes | canonical reference or location observed by the watcher |
| `sources[].required_access` | yes | `read` or `read-metadata` |
| `sources[].cursor_field` | no | field used to derive monotonic cursor state |

### `rules.yml`

| Field | Required | Notes |
|---|---|---|
| `rules[]` | yes | one or more detection rules |
| `rules[].rule_id` | yes | watcher-local stable rule id |
| `rules[].source_ids` | yes | one or more declared `source_id` values |
| `rules[].condition.kind` | yes | `threshold`, `absence`, `change`, or `match` |
| `rules[].condition.path` | no | source-local metric or field path |
| `rules[].condition.operator` | no | comparator such as `>=`, `==`, `contains`, or `matches` |
| `rules[].condition.value` | no | comparator target |
| `rules[].condition.window` | no | optional ISO-8601 lookback window |
| `rules[].event_type` | yes | emitted event type declared in `emits.yml` |
| `rules[].severity` | yes | `info`, `warning`, `high`, `critical` |
| `rules[].summary_template` | yes | operator-facing summary template |
| `rules[].dedupe_key_fields` | no | canonical fields used to derive stable duplicate suppression keys |
| `rules[].routing_hints.target_automation_id` | no | recommended automation target when allowed by `emits.yml` |
| `rules[].routing_hints.candidate_incident_id` | no | recommended incident-correlation hint when allowed by `emits.yml` |

### `emits.yml`

| Field | Required | Notes |
|---|---|---|
| `emits[]` | yes | one or more emitted event declarations |
| `emits[].event_type` | yes | canonical emitted event type |
| `emits[].payload_fields` | yes | allowed inline payload fields; may be empty |
| `emits[].allow_payload_ref` | yes | whether emitted events may include `payload_ref` |
| `emits[].routing_hints.allow_target_automation_id` | yes | whether `target_automation_id` may be emitted |
| `emits[].routing_hints.allow_candidate_incident_id` | yes | whether `candidate_incident_id` may be emitted |

## Behavioral Rules

1. Every watcher must define `watcher.yml`, `sources.yml`, `rules.yml`, and
   `emits.yml`.
2. Every rule must reference one or more declared `source_id` values.
3. Every rule `event_type` must resolve to one declaration in `emits.yml`.
4. Rules may declare `routing_hints.target_automation_id` or
   `routing_hints.candidate_incident_id` only when the matching emitted event
   declaration allows that hint.
5. `registry.yml` may project watcher identity, owner, and state paths, but it
   must not outrank the watcher definition artifacts.
6. `state/` stores mutable cursor, health, and suppression data only. It must
   not be reused as durable event evidence or as the canonical event contract.
7. A watcher in `paused` or `error` must not emit new events.
8. Watchers may recommend downstream automation or incident correlation, but
   they may not launch workflows directly.

# Runtime Shape And Directory Structure

## Current Octon Runtime Shape

Today, Octon's orchestration runtime centers on:

```text
.octon/orchestration/
├── runtime/
│   ├── workflows/
│   └── missions/
├── governance/
│   └── incidents.md
└── practices/
```

This is a strong foundation. It already separates:

- bounded procedural execution (`workflows`)
- bounded multi-session initiative state (`missions`)
- incident governance (`governance/incidents.md`)

## Proposed Mature Runtime Shape

```text
.octon/orchestration/
├── runtime/
│   ├── campaigns/         # Proposed strategic portfolio containers
│   ├── missions/          # Existing bounded initiative state
│   ├── workflows/         # Existing bounded procedure definitions
│   ├── automations/       # Proposed schedule/event launch policies
│   ├── watchers/          # Proposed condition detectors
│   ├── queue/             # Proposed durable intake buffering
│   ├── runs/              # Proposed orchestration-facing run indexes/projections
│   └── incidents/         # Proposed incident runtime state
├── governance/
│   ├── incidents.md       # Incident policy and response authority
│   └── ...
├── practices/
│   └── ...
└── _meta/architecture/
    └── ...
```

## Canonical Storage Split

The mature model should preserve a split between:

- orchestration-facing runtime state
- continuity-facing durable evidence

### Recommended Split

| Concern | Canonical Home | Notes |
|---|---|---|
| Campaign objects | `orchestration/runtime/campaigns/` | Proposed strategic coordination objects above missions |
| Workflow definitions | `orchestration/runtime/workflows/` | Bounded procedural definitions |
| Mission state | `orchestration/runtime/missions/` | Bounded initiative state |
| Automation definitions | `orchestration/runtime/automations/` | Proposed launch policy definitions |
| Watcher definitions | `orchestration/runtime/watchers/` | Proposed event detector definitions |
| Queue state | `orchestration/runtime/queue/` | Proposed intake and claim/ack state |
| Incident runtime state | `orchestration/runtime/incidents/` | Proposed incident objects, response action plans, and subordinate evidence |
| Run status/index | `orchestration/runtime/runs/` | Proposed orchestration projection layer |
| Durable run evidence | `continuity/runs/` | Existing append-oriented evidence store |
| Durable decision evidence | `continuity/decisions/` | Proposed continuity-owned routing and authority evidence |

## Why `runs` Should Be Split

Octon already uses `continuity/runs/` as append-oriented evidence storage.
That should remain the durable evidence store.

If a first-class orchestration `runs` surface is introduced, it should own:

- orchestration-facing run indexes
- status projections
- pointers to evidence bundles
- relationships to workflows, missions, automations, and incidents

It should not duplicate:

- receipt bundles
- digests
- retention-managed evidence payloads

Those already fit the continuity plane.

Routing and authority decisions follow the same split:

- orchestration runtime may keep lightweight `decision_id` references
- canonical decision evidence lives in `continuity/decisions/`

## Example Surface Shapes

### `workflows/`

```text
workflows/
├── README.md
├── manifest.yml
├── registry.yml
├── _ops/
│   └── scripts/
├── <group>/
│   ├── <workflow-id>/
│   │   ├── workflow.yml
│   │   ├── stages/
│   │   │   ├── 01-*.md
│   │   │   ├── ...
│   │   │   └── 99-verify.md
│   │   └── README.md
```

### `missions/`

```text
missions/
├── README.md
├── registry.yml
├── .archive/
├── _scaffold/template/
│   ├── mission.yml
│   ├── mission.md
│   ├── tasks.json
│   └── log.md
└── <mission-id>/
    ├── mission.yml
    ├── mission.md
    ├── tasks.json
    ├── log.md
    └── context/
```

`mission.yml` is the canonical mission object.

`mission.md` remains subordinate narrative guidance.

### `campaigns/`

```text
campaigns/
├── README.md
├── manifest.yml
├── registry.yml
└── <campaign-id>/
    ├── campaign.yml
    └── log.md
```

### `automations/`

```text
automations/
├── README.md
├── manifest.yml
├── registry.yml
└── <automation-id>/
    ├── automation.yml
    ├── trigger.yml
    ├── bindings.yml
    ├── policy.yml
    └── state/
        ├── status.json
        ├── last-run.json
        └── counters.json
```

### `watchers/`

```text
watchers/
├── README.md
├── manifest.yml
├── registry.yml
└── <watcher-id>/
    ├── watcher.yml
    ├── rules.yml
    ├── sources.yml
    ├── emits.yml
    └── state/
        ├── cursor.json
        ├── health.json
        └── suppressions.json
```

### `queue/`

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

The singular surface name reflects that v1 uses one shared queueing substrate.
Lane directories remain the local mutable state for that substrate.

### `runs/`

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

Each run record should point to evidence in `continuity/runs/<run-id>/`.

### `incidents/`

```text
incidents/
├── README.md
├── index.yml
└── <incident-id>/
    ├── incident.yml
    ├── actions.yml
    ├── timeline.md
    └── closure.md
```

`incident.yml` is the canonical machine-readable incident object and mutable
state authority. `actions.yml` is subordinate schema-backed coordination data
when the incident tracks executable response actions. `timeline.md` and
`closure.md` remain operator-visible evidence and must not outrank
`incident.yml`.

## Directory-Shape Guidance

The mature model should follow the same principle Octon already uses
elsewhere:

- runtime directories own active executable or stateful surfaces
- governance directories own policy and authority
- practices directories own authoring and operations discipline
- continuity owns append-oriented evidence and handoff memory

That split keeps orchestration understandable and prevents runtime state from
silently becoming policy.

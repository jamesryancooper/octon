# Campaign Object Contract

## Purpose

This contract defines the minimum implementation-ready object model for
`campaigns`.

## Required Object Artifacts

```text
campaigns/
├── registry.yml
└── <campaign-id>/
    ├── campaign.md
    ├── milestones.yml
    ├── missions.yml
    └── log.md
```

## Minimum Campaign Fields

| Field | Required | Notes |
|---|---|---|
| `campaign_id` | yes | canonical stable id |
| `title` | yes | operator-readable name |
| `objective` | yes | one-paragraph goal statement |
| `status` | yes | `proposed`, `active`, `paused`, `completed`, `cancelled`, `archived` |
| `owner` | yes | human or agent owner |
| `created_at` | yes | ISO timestamp |
| `target_end_at` | no | optional target completion date/time |
| `mission_ids` | yes | ordered list of related missions |
| `success_criteria` | yes | checklist or machine-readable array |
| `risk_summary` | no | portfolio-level risks |

## Lifecycle

`proposed -> active -> paused|completed|cancelled -> archived`

## Invariants

- `campaign_id` must be globally unique.
- `mission_ids` must be unique within the campaign.
- A `completed` campaign must have all required missions in a terminal state or
  include an explicit waiver note.
- An `archived` campaign is immutable except for append-only correction notes in
  `log.md`.

## Example

```yaml
campaign_id: "governance-hardening-2026"
title: "Governance Hardening 2026"
objective: "Strengthen Harmony governance and evidence boundaries across runtime and continuity surfaces."
status: "active"
owner: "@architect"
created_at: "2026-03-07T12:00:00Z"
mission_ids:
  - "contract-cleanup"
  - "assurance-tightening"
success_criteria:
  - "All linked missions complete or waived"
  - "Residual risks documented"
```

# Campaign Object Contract

## Purpose

This contract defines the implementation-ready machine-readable object model for
`campaigns`.

`campaigns` remain optional coordination surfaces above `missions`. When they
exist, campaign identity, lifecycle status, mission membership, milestones, and
completion-waiver semantics must be explicit contract data rather than
Markdown-only guidance.

## Required Object Artifacts

```text
campaigns/
├── manifest.yml
├── registry.yml
└── <campaign-id>/
    ├── campaign.yml
    └── log.md
```

## Authority Rules

1. `campaign.yml` is the single source of truth for campaign identity,
   lifecycle, mission membership, milestone definitions, success criteria, and
   completion-waiver metadata.
2. `registry.yml` may project title, status, owner, mission count, target date,
   and path refs, but it must not outrank `campaign.yml`.
3. `log.md` is append-oriented operator context. It may explain milestone
   changes, waivers, or outcomes, but it must not replace required structured
   fields in `campaign.yml`.
4. `campaigns` do not define a separate `state/` tree in v1. Current
   coordination state lives in `campaign.yml`.

## Required `campaign.yml` Fields

| Field | Required | Notes |
|---|---|---|
| `campaign_id` | yes | canonical stable id |
| `title` | yes | operator-readable name |
| `objective` | yes | one-paragraph goal statement |
| `status` | yes | `proposed`, `active`, `paused`, `completed`, `cancelled`, `archived` |
| `owner` | yes | human or agent owner |
| `created_at` | yes | ISO timestamp |
| `target_end_at` | no | optional target completion date/time |
| `mission_ids` | yes | ordered list of related mission ids |
| `success_criteria` | yes | machine-readable success criteria array |
| `milestones` | yes | ordered machine-readable milestone array |
| `risk_summary` | no | portfolio-level risks |
| `completion_waiver_note` | no | required when campaign closes without all required missions terminal |
| `completed_at` | no | required when `status=completed` |
| `cancelled_at` | no | required when `status=cancelled` |
| `archived_at` | no | required when `status=archived` |

## Milestone Object

Each `milestones[]` entry must be machine-readable and contain:

| Field | Required | Notes |
|---|---|---|
| `milestone_id` | yes | stable id unique within the campaign |
| `title` | yes | operator-readable milestone name |
| `status` | yes | `planned`, `in_progress`, `completed`, `waived` |
| `mission_ids` | no | subset of the parent campaign `mission_ids[]` |
| `target_at` | no | optional target date/time |
| `completed_at` | no | required when `status=completed` |
| `waiver_note` | no | required when `status=waived` |
| `notes` | no | short machine-readable or operator-readable summary |

## Lifecycle

`proposed -> active -> paused|completed|cancelled -> archived`

## Invariants

- `campaign_id` must be globally unique.
- `mission_ids` must be unique within the campaign.
- milestone ids must be unique within the campaign.
- milestone `mission_ids[]`, when present, must be a subset of the campaign
  `mission_ids[]`.
- `active`, `paused`, `completed`, `cancelled`, and `archived` campaigns must
  reference at least one mission.
- A `completed` campaign must have all required missions in a terminal state or
  include an explicit `completion_waiver_note`.
- An `archived` campaign must record `archived_at`.
- An `archived` campaign is immutable except for append-only correction notes in
  `log.md` and governance-authorized metadata repair in `campaign.yml`.
- `campaigns` may summarize related incident or run context, but they do not
  become the authority for mission lifecycle, run evidence, or incident state.

## Example

```yaml
campaign_id: "governance-hardening-2026"
title: "Governance Hardening 2026"
objective: "Strengthen Octon governance and evidence boundaries across runtime and continuity surfaces."
status: "active"
owner: "@architect"
created_at: "2026-03-07T12:00:00Z"
target_end_at: "2026-03-31T23:59:59Z"
mission_ids:
  - "contract-cleanup"
  - "assurance-tightening"
success_criteria:
  - "All linked missions complete or waived"
  - "Residual risks documented"
risk_summary: "Cross-surface drift can leave live governance and package contracts misaligned."
milestones:
  - milestone_id: "contracts-aligned"
    title: "Contract set aligned"
    status: "completed"
    mission_ids:
      - "contract-cleanup"
    completed_at: "2026-03-08T16:00:00Z"
  - milestone_id: "assurance-hardened"
    title: "Assurance gates hardened"
    status: "in_progress"
    mission_ids:
      - "assurance-tightening"
    target_at: "2026-03-20T23:59:59Z"
```

# Mission Object Contract

## Purpose

This contract defines the canonical machine-readable mission object for
`missions` so lifecycle, ownership, success criteria, and cross-surface linkage
do not depend on Markdown prose or registry projections.

## Required Object Artifacts

```text
missions/
├── registry.yml
├── .archive/
└── <mission-id>/
    ├── mission.yml
    ├── mission.md
    ├── tasks.json
    ├── log.md
    └── context/
```

`mission.yml` is required.

`mission.md` is optional but recommended human-readable narrative.

`tasks.json`, `log.md`, and `context/` are mutable mission-local state/evidence
assets. They must not replace `mission.yml` as the source of truth for mission
identity, lifecycle, ownership, or cross-surface linkage.

## Required Mission Fields

| Field | Required | Notes |
|---|---|---|
| `schema_version` | yes | `mission-object-v1` |
| `mission_id` | yes | canonical stable id |
| `title` | yes | operator-readable mission name |
| `summary` | yes | one-paragraph bounded objective |
| `status` | yes | `created`, `active`, `completed`, `cancelled`, `archived` |
| `owner` | yes | accountable human or delegated actor identifier |
| `created_at` | yes | ISO timestamp |
| `success_criteria` | yes | ordered non-empty list of explicit completion checks |
| `campaign_id` | no | optional strategic parent |
| `default_workflow_refs` | no | canonical workflows commonly invoked by this mission |
| `active_run_ids` | no | currently running mission-owned runs |
| `recent_run_ids` | no | recent run reverse-lookup aid |
| `related_run_ids` | no | supplemental lineage for materially relevant runs |
| `archived_from_status` | no | required when `status=archived`; `completed` or `cancelled` |

## Lifecycle And Linkage Rules

1. `mission.yml` is the canonical source of truth for mission identity,
   lifecycle state, ownership, success criteria, and cross-surface linkage.
2. `registry.yml` may project `mission_id`, `title`, `status`, `owner`, and
   archive location for discovery, but it must not outrank `mission.yml`.
3. `mission.md` may explain goal, scope, blockers, and notes, but it must not
   redefine `mission_id`, `status`, `owner`, `success_criteria`, or
   cross-surface linkage fields.
4. `tasks.json`, `log.md`, and `context/` may record active planning, local
   notes, and operator-facing progress, but they must not be treated as the
   authoritative lifecycle object.
5. `active_run_ids` and `recent_run_ids` are projections only. Canonical run
   lineage remains in `runs/` and `continuity/runs/`.
6. `default_workflow_refs[]` must use canonical workflow references from
   `cross-surface-reference-contract.md`.
7. `archived` missions are immutable except for append-only correction notes in
   `log.md` or governance-authorized metadata repair in `mission.yml`.

## Invariants

- `mission_id` must be globally unique.
- `success_criteria` must be non-empty.
- An `active` mission must have a non-empty `owner`.
- An `archived` mission must record whether it was archived from `completed` or
  `cancelled`.
- The mission object must not embed workflow stage content or durable evidence
  payloads.

## Example

```yaml
schema_version: "mission-object-v1"
mission_id: "release-readiness-capabilities"
title: "Release Readiness Capabilities"
summary: "Drive a bounded release-readiness push for the capabilities subsystem."
status: "active"
owner: "@architect"
created_at: "2026-03-10T15:00:00Z"
success_criteria:
  - "Release-readiness audit completes with no unresolved blockers."
  - "Follow-up fixes are scoped or landed."
default_workflow_refs:
  - workflow_group: "audit"
    workflow_id: "audit-release-readiness-workflow"
active_run_ids:
  - "run-20260310-release-readiness-01"
recent_run_ids:
  - "run-20260310-release-readiness-01"
related_run_ids:
  - "run-20260308-audit-continuous-01"
```

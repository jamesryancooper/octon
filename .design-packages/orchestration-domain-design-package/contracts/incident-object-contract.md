# Incident Object Contract

## Purpose

This contract defines the minimum implementation-ready object model for
`incidents`.

## Required Object Artifacts

```text
incidents/
├── registry.yml
└── <incident-id>/
    ├── incident.md
    ├── timeline.md
    ├── actions.yml
    ├── linked-runs.yml
    └── closure.md
```

## Minimum Incident Fields

| Field | Required | Notes |
|---|---|---|
| `incident_id` | yes | canonical stable id |
| `title` | yes | short human-readable title |
| `severity` | yes | `sev0`, `sev1`, `sev2`, `sev3` |
| `status` | yes | `open`, `acknowledged`, `mitigating`, `monitoring`, `resolved`, `closed`, `cancelled` |
| `owner` | yes | primary human or agent owner |
| `created_at` | yes | ISO timestamp |
| `summary` | yes | short statement of impact |
| `run_ids` | no | linked run ids |
| `mission_ids` | no | linked remediation missions |
| `workflow_refs` | no | linked rollback, containment, or remediation workflows |
| `external_impact` | no | user or operator impact summary |
| `closed_at` | no | required when `status=closed` |
| `closed_by` | no | required when `status=closed` |

## Lifecycle

`open -> acknowledged -> mitigating -> monitoring -> resolved -> closed`

Terminal alternative:

`open -> acknowledged -> cancelled`

## Behavioral Rules

1. `severity` changes must be logged in `timeline.md`.
2. A `closed` incident must include:
   - closure summary
   - linked remediation evidence or waiver
   - linked runs or explicit note that none exist
3. `resolved` means active mitigation is complete.
4. `closed` means documentation and closure evidence are complete.
5. Incident automation may propose status transitions, but escalation authority
   remains explicit and operator-visible.
6. Transition to `closed` requires explicit human confirmation or an explicit
   policy-backed closure action.

## Invariants

- `incident_id` must be globally unique.
- `severity` and `status` must always be explicit.
- `closure.md` is required for `closed` incidents.
- `closed_at` and `closed_by` are required for `closed` incidents.
- `linked-runs.yml` must exist if `run_ids` is non-empty.

## Example

```yaml
incident_id: "inc-20260307-001"
title: "Governance drift audit produced critical finding"
severity: "sev2"
status: "mitigating"
owner: "@architect"
created_at: "2026-03-07T18:10:00Z"
summary: "Critical governance drift detected in orchestration artifacts."
run_ids:
  - "run-20260307-audit-continuous-01"
workflow_refs:
  - workflow_group: "audit"
    workflow_id: "audit-continuous-workflow"
```

# Incident Object Contract

## Purpose

This contract defines the minimum implementation-ready object model for
`incidents`.

## Required Surface And Object Artifacts

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

Artifact rules:

- `README.md`
  - operator orientation only; not a behavioral contract
- `index.yml`
  - global lookup projection for active and historical incidents
- `<incident-id>/incident.yml`
  - required for every incident; canonical machine-readable object and mutable
    state authority validated by
    `contracts/schemas/incident-object.schema.json`
- `<incident-id>/actions.yml`
  - optional, but required when machine-readable containment, rollback,
    remediation, or review actions are tracked; validated by
    `contracts/schemas/incident-actions.schema.json`
- `<incident-id>/timeline.md`
  - durable operator-visible narrative of major status or severity changes;
    subordinate to `incident.yml`
- `<incident-id>/closure.md`
  - required when `status=closed`; subordinate evidence and closure summary

## Authority Model

`incidents` are runtime-born response objects, not author-authored definitions.

Because of that, `incident.yml` intentionally combines object identity and
mutable state authority in one explicit machine-readable artifact, similar to
the run object model. This is acceptable because the contract makes the
combination explicit instead of leaving it ambiguous.

Additional authority rules:

1. `incident.yml` is the single source of truth for severity, status, owner,
   linkage fields, and closure metadata.
2. `index.yml` may project lookup fields, but it must not outrank
   `incident.yml`.
3. `timeline.md` and `closure.md` may explain what happened, but they must not
   be the only place where current state, closure state, or cross-surface
   linkage is recorded.
4. `linked-runs.yml` is intentionally not part of the contract because
   `run_ids` in `incident.yml` are the canonical linkage layer and additional
   linkage files would duplicate authority.

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
| `automation_ids` | no | linked automations when incident lineage begins before or outside a run |
| `event_ids` | no | linked watcher events when incident correlation begins from a signal |
| `decision_ids` | no | linked decision records when escalation or blocking happened before a run existed |
| `external_impact` | no | user or operator impact summary |
| `closed_at` | no | required when `status=closed` |
| `closed_by` | no | required when `status=closed` |

## Lifecycle

`open -> acknowledged -> mitigating -> monitoring -> resolved -> closed`

Terminal alternative:

`open -> acknowledged -> cancelled`

## Behavioral Rules

1. `severity` and `status` changes must be updated in `incident.yml` and logged
   in `timeline.md`.
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
7. `actions.yml`, when present, may coordinate response actions, but it must
   not redefine incident lifecycle, severity semantics, or closure authority.

## Invariants

- `incident_id` must be globally unique.
- `severity` and `status` must always be explicit.
- `incident.yml` is required for every incident object.
- `closure.md` is required for `closed` incidents.
- `closed_at` and `closed_by` are required for `closed` incidents.
- linkage to runs, missions, workflows, automations, events, and decision
  records must be explicit in `incident.yml` when present.
- `timeline.md` and `closure.md` are evidence artifacts and must not replace
  structured state in `incident.yml`.

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
decision_ids:
  - "dec-20260307-audit-containment-01"
```

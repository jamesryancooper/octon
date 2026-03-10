# Observability

## Purpose

Define the minimum observability, traceability, and audit lookup behavior
required for the orchestration domain.

This document is normative for correlation fields, health visibility, and
operator lookup guarantees.

## Observability Objectives

Operators must be able to answer:

- what was attempted?
- why did it happen?
- what is running now?
- what failed?
- what evidence proves the result?
- what is blocked and why?

## Canonical Correlation Fields

The following identifiers are the mandatory correlation spine for material
orchestration:

- `decision_id`
- `run_id`
- `workflow_ref`
- `mission_id`
- `automation_id`
- `incident_id`
- `queue_item_id`
- `event_id`

No implementation-specific trace id may replace these fields as the canonical
operator lookup keys.

## Minimum Surface Visibility

| Surface | Must Expose |
|---|---|
| `watchers` | current status, last evaluation time, last emitted event, suppressed count, health/error reason |
| `queue` | counts by lane, oldest pending age, expired-lease count, dead-letter count, last receipt time |
| `automations` | status, last launch attempt, last successful run, failure count, suppression count, pause/error reason |
| `missions` | status, owner, linked active runs, blockers / outstanding bounded work |
| `runs` | status, start/end time, evidence link health, decision link health, lineage fields |
| `incidents` | status, severity, owner, last timeline update, linked runs, closure readiness |
| `campaigns` | status, owner, mission rollup, unresolved risk summary |

## Health Signals

The runtime must detect and surface at least these health states:

- watcher source unreadable
- automation target workflow unresolved
- queue item expired without ack
- allow decision recorded without run creation within timeout
- active run missing executor acknowledgement
- active run with expired heartbeat or lock lease
- run record missing continuity evidence
- incident closure prerequisites missing

## Required Operator Lookups

The system is not operationally complete unless it supports lookup by:

- `decision_id`
- `run_id`
- `mission_id`
- `incident_id`
- `automation_id`
- `queue_item_id`
- `event_id`

Each lookup must be able to reach the next relevant artifact in lineage without
manual grep across unrelated surfaces.

## Canonical Audit Paths

### Forward Lineage

`watcher event -> queue item -> automation -> workflow -> run -> continuity evidence -> incident or mission`

### Reverse Lineage

`incident or mission -> run -> queue item/event/automation/workflow -> decision evidence -> continuity evidence`

## Metrics And Counters

Implementations may expose these as files, dashboards, or metrics systems, but
the information must exist:

- watcher emitted-event count
- watcher suppressed-event count
- queue pending / claimed / retry / dead-letter counts
- queue expired-lease count
- automation admitted launch count
- automation blocked / dropped / escalated count
- coordination lock contention count
- run counts by status
- active run liveness count by `recovery_status`
- evidence-link failure count
- incident open counts by severity

## Auditability Guarantees

For every material action:

- one decision record exists
- if admitted and workflow-backed, one run record exists
- the run links to continuity evidence
- the decision and run can be joined through canonical identifiers

## Failure Visibility Rules

Failures must be observable at the surface where they occur.

Examples:

- stale queue acknowledgement is visible on queue handling, not hidden inside a
  generic automation error
- evidence linkage failure is visible on run health and completion checks
- incident closure block is visible on the incident, not only in policy logs

## Relationship To Evidence Spec

Use this document for:

- operator-visible observability expectations
- required lookups and health signals

Use `normative/governance/evidence-observability-and-retention-spec.md` for:

- evidence ownership
- retention
- linkage conventions
- continuity split rules

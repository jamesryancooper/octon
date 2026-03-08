# Decision Record Contract

## Purpose

This contract defines the canonical evidence record for routing, authority, and
prerequisite decisions on material orchestration actions.

## Required Artifacts

```text
continuity/
└── decisions/
    └── <decision-id>/
        ├── decision.json
        └── digest.md
```

`decision.json` is required. `digest.md` is optional but recommended for
operator-readable summaries.

## Decision Record Fields

| Field | Required | Notes |
|---|---|---|
| `decision_id` | yes | canonical stable id |
| `outcome` | yes | `allow`, `block`, `escalate` |
| `surface` | yes | surface whose material action was evaluated |
| `action` | yes | evaluated action name |
| `actor` | yes | actor or initiating surface |
| `decided_at` | yes | ISO timestamp |
| `reason_codes` | yes | non-empty machine-readable array |
| `summary` | yes | short operator-readable explanation |
| `workflow_ref` | no | canonical workflow reference when applicable |
| `mission_id` | no | related mission |
| `automation_id` | no | related automation |
| `incident_id` | no | related incident |
| `event_id` | no | related watcher event |
| `queue_item_id` | no | related queue item |
| `run_id` | no | related run when an allowed action admitted execution |
| `approval_refs` | no | approvals or waiver references required for escalated or policy-backed actions |

## Behavioral Rules

1. Every material action attempt must emit exactly one decision record.
2. `allow` must be recorded before or at the same logical point as the admitted
   side effect.
3. `block` and `escalate` do not create or mutate a run unless the action is
   later re-attempted and allowed.
4. Related references must use canonical identifiers and resolve when present.
5. A decision record is the authoritative source for why a material action was
   allowed, blocked, or escalated.

## Invariants

- `decision_id` must be globally unique.
- `outcome` is immutable after creation; a changed decision produces a new
  `decision_id`.
- `reason_codes` must be non-empty.
- `run_id` may be present only when `outcome=allow`.
- Decision evidence remains continuity-owned even when runtime surfaces keep
  lightweight references to the latest decision.

## Example

```yaml
decision_id: "dec-20260308-weekly-freshness-audit-allow-01"
outcome: "allow"
surface: "automations"
action: "launch-workflow"
actor: "weekly-freshness-audit"
decided_at: "2026-03-08T18:04:00Z"
reason_codes:
  - "target-resolved"
  - "policy-allowed"
summary: "Automation launch admitted after routing, policy, and idempotency checks passed."
workflow_ref:
  workflow_group: "audit"
  workflow_id: "audit-continuous-workflow"
automation_id: "weekly-freshness-audit"
event_id: "evt-20260308-governance-drift-01"
queue_item_id: "q-20260308-001"
run_id: "run-20260308-audit-continuous-01"
```

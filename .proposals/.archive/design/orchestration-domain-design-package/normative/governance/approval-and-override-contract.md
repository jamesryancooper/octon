# Approval And Override Contract

## Purpose

Define the canonical approval, waiver, and break-glass override artifacts used
by privileged orchestration actions.

This document is normative for approval verification and override evidence.

## Core Concepts

| Concept | Meaning |
|---|---|
| approval artifact | Durable authorization for a bounded privileged action |
| waiver | Durable authorization to proceed despite a known unmet non-safety prerequisite |
| override artifact | Explicit break-glass authorization for emergency containment or recovery |
| scope | Canonical description of the action, target, and authority boundary the artifact covers |

## Artifact Location

Canonical approval and override artifacts live under:

```text
continuity/decisions/approvals/<approval-id>.json
```

The package validator may use design-package fixtures, but runtime evidence must
use continuity-owned artifacts.

## Approval Artifact Fields

| Field | Required | Notes |
|---|---|---|
| `approval_id` | yes | canonical stable id |
| `artifact_type` | yes | `approval`, `waiver`, or `override` |
| `action_class` | yes | privileged action category |
| `scope` | yes | structured scope object |
| `approved_by` | yes | human or policy authority |
| `issued_at` | yes | ISO timestamp |
| `expires_at` | yes | ISO timestamp |
| `rationale` | yes | concise reason |
| `review_required` | yes | boolean |
| `review_by` | no | required when `review_required=true` |
| `evidence_refs` | no | supporting evidence pointers |

## Scope Shape

```yaml
scope:
  surface: "incidents"
  action: "close-incident"
  workflow_ref:
    workflow_group: "audit"
    workflow_id: "audit-continuous-workflow"
  coordination_key: "target:governance/orchestration"
```

`surface` and `action` are required. Other scope fields are required when they
are relevant to the privileged action.

## Verification Rules

An approval or override artifact is valid only when:

- the artifact exists
- `expires_at` is in the future at decision time
- `scope.surface` and `scope.action` match the requested action
- all additional scoped references match when present
- the approving actor is authorized by governance policy

Approver authorization is resolved through `normative/governance/approver-authority-model.md`.

## Break-Glass Override Rules

`artifact_type=override` is permitted only for:

- containment
- rollback
- deterministic recovery actions already anticipated by policy

Overrides MUST include:

- `override_reason`
- explicit `expires_at`
- mandatory `review_required=true`

## Decision-Record Integration

Privileged `block`, `escalate`, and `allow` decisions MUST reference:

- `approval_refs[]` for approvals or waivers
- `override_ref` for break-glass actions when used

Opaque URLs or free-form note references are insufficient.

## Invariants

- Every privileged action references at least one valid approval or override
  artifact.
- Expired artifacts are never accepted.
- Override artifacts are not reusable outside their declared scope.

## Validation Expectations

Implementations must prove:

- scope matching
- expiry enforcement
- privileged-action verification before `allow`

# Routing Authority And Execution Control

## Purpose

Translate Octon’s routing, authority, escalation, and fail-closed principles
into orchestration-specific execution control rules.

## Core Rule

No material orchestration action may proceed until routing, authority, and
prerequisite checks resolve to `allow`.

If routing cannot be determined deterministically, the system must `block` or
`escalate`; it must not guess.

## Materiality Determination

An orchestration action is `material` if it does any of the following:

- launches a workflow
- claims, retries, or dead-letters a queue item
- creates, completes, cancels, or archives a mission or campaign
- creates, enriches, resolves, or closes an incident
- changes automation or watcher active state
- creates or mutates a run record
- writes continuity evidence
- triggers any external side effect

Actions are `non-material` only if they are strictly limited to:

- discovery
- routing evaluation
- contract validation
- dry-run planning without durable side effects

## Routing Prerequisites

Before execution, the orchestrator must confirm:

1. objective authority exists for the requested scope
2. referenced surfaces resolve unambiguously
3. required contracts validate
4. required runtime artifacts exist and are readable
5. policy permits the requested action
6. idempotency context is known
7. required approvals exist for escalated or privileged actions
8. required coordination guarantees exist for side-effectful actions

If any prerequisite is missing:

- the action must not proceed
- a blocked or escalated decision record must be recorded under
  `continuity/decisions/`

## Decision Record Requirement

Every material action attempt must resolve to exactly one `decision_id`.

- `allow` decisions record the basis for admitted work.
- `block` decisions record why work did not proceed.
- `escalate` decisions record why explicit human or policy-backed approval is
  required.

## Decision Outcomes

### `allow`

Use only when:

- references resolve
- contracts validate
- actor has authority
- policy allows action
- required state and prerequisites are present
- a `decision_id` has been created for the admitted action

### `escalate`

Use when:

- authority is ambiguous
- requested action crosses policy or incident thresholds
- explicit human decision is required
- break-glass or emergency policy is needed
- a decision record must exist before awaiting approval or manual review

### `block`

Use when:

- required artifacts are missing
- contracts fail validation
- references do not resolve
- a surface is paused, disabled, cancelled, archived, or dead-lettered in a way
  that prevents execution
- the action would require guessing
- a decision record must exist and no material side effect may proceed

## Surface Authority Matrix

| Surface | May Trigger | May Request | May Launch | May Execute | May Pause/Resume | May Escalate |
|---|---|---|---|---|---|---|
| `watchers` | yes | no | no | emit events only | yes | recommend only |
| `queue` | no | no | no | claim/lease transitions only | no | no |
| `automations` | yes | yes | yes | no | yes | yes, via policy |
| `workflows` | no | yes | bounded mission creation or follow-up only | yes | no | yes, via run/incident output |
| `missions` | no | yes | may invoke workflows through bounded orchestration paths | no | no distinct pause state | yes |
| `runs` | no | no | no | no | no | no |
| `incidents` | yes | yes | may launch rollback/containment workflows | no | no | yes |
| `campaigns` | no | yes | no | no | no | no |

## Objective-Contract And Policy-Bound Execution

- `workflows`, `automations`, and `incidents` may only perform material actions
  if the active objective and policy surfaces authorize the scope.
- `missions` and `campaigns` may organize work but do not override policy.
- `watchers` may emit signals but may not authorize execution.
- `queue` may buffer work but may not change target meaning or authority.

## Operator-Visible Status Requirements

Every material orchestration surface must expose:

- current status
- last material action
- current owner or responsible actor, where applicable
- blocked or error reason, when present
- linked run or evidence references for the last material action

## Blocked-State Behavior

When blocked:

- no material side effects proceed
- a decision record is written to `continuity/decisions/`
- operator-visible reason codes must be present
- resume requires re-validation of prerequisites

Blocked state is not permission to fall back to implicit behavior.

## Exception Handling Boundaries

- `watchers` may detect and suggest; they do not directly execute.
- `queue` may move items across lanes; it does not reinterpret work intent.
- `automations` may launch only their configured workflow target.
- `workflows` may create follow-up mission work, but they do not self-authorize
  broader scope expansion.
- `incidents` may coordinate containment and escalation, but closure remains
  operator-visible and policy-bounded.

## Break-Glass And Emergency Override Posture

Octon does not assume broad break-glass autonomy by default.

If emergency override is permitted, it must be limited to:

- containment
- rollback
- explicit incident-response actions already covered by policy

Break-glass must always:

- be explicit
- be evidence-backed
- record who authorized it
- record why normal routing was insufficient

## Relationship To Governance Authority

- Governance surfaces define what is allowed.
- Runtime surfaces execute only within those boundaries.
- Practices surfaces define how authors and operators behave safely.
- Continuity retains evidence and handoff memory.

No runtime surface may silently become the policy author for another surface.

## Failure Modes And Required Response

| Failure Mode | Required Response |
|---|---|
| missing workflow target | `block` |
| unresolved mission/workflow reference | `block` |
| queue item without target automation | `block` |
| duplicate or conflicting trigger selection | `block` |
| invalid event bindings or missing required event input | `block` |
| missing coordination key for side-effectful execution | `block` |
| lock acquisition failed for side-effectful execution | `block` or defer per policy |
| automation `replace` on workflow without `execution_controls.cancel_safe=true` | `block` |
| automation policy requires approval not present | `escalate` |
| incident closure requested without evidence | `block` |
| ambiguous owner for material action | `escalate` |
| watcher source unreadable | watcher enters `error`; emission blocked |

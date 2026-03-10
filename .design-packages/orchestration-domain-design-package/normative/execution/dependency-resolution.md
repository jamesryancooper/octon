# Dependency Resolution

## Purpose

Define the deterministic algorithms used to resolve references, evaluate
prerequisites, and convert triggers into admitted orchestration work.

This document is normative for orchestration-domain dependency evaluation and
trigger matching.

## Resolution Principles

1. Resolve references before evaluating side effects.
2. Treat ambiguity as failure, not as an invitation to guess.
3. Evaluate the strongest available execution context.
4. Record a decision whenever dependency evaluation gates a material action.
5. Keep routing deterministic even when one source fans out to multiple targets.

## Dependency Classes

| Class | What Must Resolve |
|---|---|
| reference | IDs and `workflow_ref` values point to exactly one canonical object |
| artifact | required files exist and validate |
| state | referenced surfaces are in eligible lifecycle states |
| authority | objective scope, approvals, and policy prerequisites are satisfied |
| temporal | time-based eligibility such as `available_at` or schedule window due is satisfied |

## Universal Resolution Order

Every material action must evaluate dependencies in this order:

1. identify the orchestration unit
2. load authoritative definitions and registry metadata
3. resolve canonical references
4. validate required artifacts and contracts
5. validate lifecycle state prerequisites
6. validate authority / policy / approval prerequisites
7. compute idempotency context
8. emit `allow`, `block`, or `escalate`

## Workflow Reference Resolution

`workflow_ref` resolution is deterministic:

1. resolve `workflow_group`
2. resolve `workflow_id`
3. require exactly one matching workflow definition

Outcomes:

- zero matches -> `block`
- more than one match -> `block`
- one match -> continue

## Mission Context Resolution

When mission context is present or required:

1. resolve `mission_id`
2. require the mission to exist
3. require lifecycle state not to be `archived`
4. if the action is mission-owned execution, require the mission to be eligible
   for active work

Missing or archived missions must `block`.

## Event-To-Automation Resolution

This algorithm converts one watcher event into zero or more queue items.

### Candidate Selection

Given a canonical watcher event:

1. load all automations with:
   - `status=active`
   - `trigger.kind=event`
2. compute selector results:
   - `watcher_ids` selector matches when `event.watcher_id` is included
   - `event_types` selector matches when `event.event_type` is included
   - `severity_at_or_above` selector matches when declared threshold is
     satisfied
   - `source_ref_globs` selector matches when any declared glob matches
     `event.source_ref`
3. evaluate `match_mode`:
   - `all` requires every declared selector group to match
   - `any` requires at least one declared selector group to match
4. keep only automations whose selector evaluation returns true

### `severity_at_or_above` Semantics

`severity_at_or_above` uses one canonical total order:

`info < warning < high < critical`

Matching rule:

- convert the event severity and declared threshold into their ordinal position
  in that order
- the selector matches when `event.severity >= threshold`
- missing `severity_at_or_above` means no severity filter is applied

There is no alternate ordering and no surface-local override.

### `source_ref_globs` Semantics

`source_ref_globs` are evaluated against the full normalized `event.source_ref`
string.

Normalization and matching rules:

- normalize path separators to `/` before matching
- match is case-sensitive
- a glob must match the full `source_ref`, not a substring
- `*` matches zero or more non-`/` characters
- `**` matches zero or more path segments, including `/`
- `?` matches exactly one non-`/` character
- bracket classes like `[abc]` or `[a-z]` match exactly one non-`/` character
- brace expansion and extglob are not supported in v1
- the selector matches when any declared glob matches

If no declared glob matches, the selector returns false.

### Target Hint Intersection

If `event.target_automation_id` is present:

1. intersect the candidate set with that single automation id
2. if the intersection is empty, record a blocked routing decision and do not
   create a queue item

### Candidate Ordering

Sort remaining candidates by lexical `automation_id`.

### Fan-Out Rule

Each remaining candidate produces one queue item targeted to exactly that
automation.

This is not ambiguity. It is explicit deterministic fan-out.

### Dedupe Window Rule

If `dedupe_window` is declared for an event-triggered automation:

1. compute the event-dedupe key
2. suppress a new admission when the same dedupe key already exists within the
   declared window in admitted, active, or terminal lineage
3. emit a blocking or suppression decision record rather than guessing whether a
   replay is safe

### No-Match Rule

If the candidate set is empty after filtering:

- do not create a queue item
- record a blocked routing decision for queue creation
- preserve the event as valid watcher output if the watcher event itself was
  well-formed

### Incident Hint Rule

`candidate_incident_id` may be used by incident correlation logic, but it does
not alter queue routing or authorize execution.

## Queue Item Identity Resolution

For event-driven queue ingress, `queue_item_id` must be deterministic from:

- `event_id`
- `target_automation_id`

Reprocessing the same event for the same automation must resolve to the same
logical queue identity unless an explicit replay/redrive action introduces a new
replay suffix or replay identifier.

## Scheduled Launch Resolution

Scheduled automation resolution does not require the queue.

For each active scheduled automation:

1. resolve the due schedule window
2. derive the schedule-window idempotency key
3. if the same idempotency key is already admitted or terminal under the
   current retry policy, suppress duplicate admission
4. otherwise evaluate overlap mode and policy

## Queue Claim Resolution

When an automation claims work:

1. consider only items in `pending/` or eligible `retry/`
2. consider only items whose `target_automation_id` equals the claimant
   automation
3. consider only items whose `available_at <= now`
4. choose the first item in this order:
   - highest `priority`
   - earliest `available_at`
   - earliest `enqueued_at`
   - lexical `queue_item_id`
5. attempt atomic claim

If the compare-and-swap claim fails, reload state and evaluate again.

## Automation Launch Dependency Resolution

Before a queue-backed or scheduled launch may proceed, the automation
controller must verify:

- automation exists and is `active`
- workflow target resolves
- policy file validates
- trigger remains valid for the current event or schedule window
- bindings validate according to `normative/execution/automation-bindings-contract.md`
- idempotency key is known
- required `coordination_key` is derivable when side effects are possible
- overlap mode permits admission
- any required approvals exist

If any check fails, the controller emits `block` or `escalate` and does not
launch.

## Binding Validation

Bindings are validated before `allow` is possible.

For each declared parameter binding:

1. resolve the `from` source path
2. if the source is missing and `required=true`, `block` with
   `binding_validation_failure`
3. if the source is missing and `required=false`, use `default` when present
4. verify the resolved value matches the declared `value_type`

Bindings never execute arbitrary transforms in v1.

## Coordination Key Resolution

Before any side-effectful launch may proceed:

1. derive `coordination_key` according to `normative/execution/concurrency-control-model.md`
2. if derivation fails, `block`
3. if the key is derived, pass it to the coordination manager before writing an
   `allow` decision

## Incident Action Resolution

Incident actions must resolve:

- `incident_id`
- required linked runs / workflows / missions where applicable
- closure authority when closing
- remediation evidence or waiver when moving to `closed`

Incident actions may request work, but they do not override routing or policy
prerequisites.

## Conflict Resolution Rules

| Conflict | Resolution |
|---|---|
| missing reference | `block` |
| ambiguous reference | `block` |
| stale queue `claim_token` | reject and record failed handling |
| duplicate event for same automation | suppress through idempotency |
| invalid binding or missing required event input | `block` |
| multiple matching automations | deterministic fan-out |
| missing coordination key for side-effectful execution | `block` |
| `replace` on non-cancel-safe workflow | `block` |
| missing approval for closure or escalated action | `escalate` |

## Non-Goals

This document does not define workflow step dependency graphs. It defines
orchestration-domain dependency resolution across surfaces and execution entry
modes.

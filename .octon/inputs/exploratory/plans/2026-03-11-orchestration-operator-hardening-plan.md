# Plan: Orchestration Operator Hardening

- Audience: engineers improving orchestration operator UX, status visibility,
  dashboards, and incident/playbook ergonomics
- Goal: make the live orchestration domain easier to operate under stress
  without changing its authority model
- Scope: operator-facing lookup paths, subordinate status projections, incident
  closure ergonomics, and scenario-specific playbook guidance

## Profile Selection Receipt

- `change_profile`: `atomic`
- `release_state`: `pre-1.0`
- `selection_mode`: `auto`
- `profile_facts`:
  - `downtime_tolerance`: not applicable for the planning artifact itself; the
    intended hardening work is additive and should not require runtime cutover
  - `external_consumer_coordination_ability`: no external consumers are visible;
    operator surfaces are internal Octon concerns
  - `data_migration_backfill_needs`: none required if projections remain
    subordinate and read from existing canonical surfaces
  - `rollback_mechanism`: revert new projection scripts, docs, and validators;
    canonical runtime and governance artifacts remain unchanged
  - `blast_radius_and_uncertainty`: moderate; touches operator workflows,
    runtime projections, practices, and validation but should not alter core
    execution semantics
  - `compliance_policy_constraints`: dashboards and operator UX must remain
    subordinate to runtime/governance authority; incident closure must stay
    fail-closed
- `hard_gate_evaluation`:
  - `zero_downtime_requirement_prevents_one_step_cutover`: `false`
  - `external_consumers_cannot_migrate_in_one_coordinated_release`: `false`
  - `live_migration_backfill_requires_temporary_coexistence`: `false`
  - `operational_risk_requires_progressive_exposure_and_staged_validation`: `false`
- `rationale`: this hardening work is additive and should preserve the current
  authority split. It can be implemented in one coordinated effort as long as
  projections remain read-only and validators fail closed.

## Implementation Plan

### Operating Rules

1. Do not create new execution authority while improving operator experience.
2. Treat dashboards, summaries, indexes, and helper commands as subordinate
   projections only.
3. Preserve the current authority split:
   - runtime state in `/.octon/framework/orchestration/runtime/`
   - governance in `/.octon/framework/orchestration/governance/`
   - operating guidance in `/.octon/framework/orchestration/practices/`
   - durable evidence in `/.octon/state/continuity/repo/`
4. Every new operator view must be reachable from existing canonical
   identifiers such as `decision_id`, `run_id`, `incident_id`, `queue_item_id`,
   and `event_id`.
5. Incident ergonomics may improve, but closure authority and evidence
   requirements remain governed by `governance/incidents.md`.

### Primary Authorities

Engineers should use these sources first:

1. `/.design-packages/orchestration-domain-design-package/normative/assurance/observability.md`
2. `/.design-packages/orchestration-domain-design-package/normative/assurance/operator-and-authoring-runbook.md`
3. `/.octon/framework/orchestration/governance/incidents.md`
4. `/.octon/framework/orchestration/governance/production-incident-runbook.md`
5. `/.octon/framework/orchestration/practices/incident-lifecycle-standards.md`
6. `/.octon/framework/orchestration/practices/queue-operations-standards.md`
7. `/.octon/framework/orchestration/practices/watcher-operations.md`
8. `/.octon/framework/orchestration/practices/automation-operations.md`
9. `/.octon/framework/orchestration/practices/run-linkage-standards.md`

### Target Outcomes

By the end of this work, operators should be able to:

1. answer the package’s core observability questions without manual grep across
   unrelated surfaces
2. inspect watcher, queue, automation, run, mission, and incident health from
   stable subordinate views
3. determine incident closure readiness mechanically
4. follow concrete response playbooks for the most common orchestration failure
   modes

### Workstreams

| Workstream | Purpose | Expected surfaces |
| --- | --- | --- |
| `WS1 Operator Lookups` | add direct lineage lookup and state inspection flows | `runtime/_ops/scripts/`, `practices/` |
| `WS2 Status Views` | add subordinate rollups for watchers, queue, automations, runs, missions, and incidents | `runtime/_ops/scripts/`, `/.octon/state/evidence/validation/analysis/` |
| `WS3 Incident Ergonomics` | make open/manage/close flows easier and more deterministic | `runtime/incidents/`, `practices/`, `governance/` |
| `WS4 Playbooks And Validation` | encode scenario-specific response guidance and fail-closed checks | `practices/`, `_ops/scripts/`, assurance validators |

### Recommended Delivery Order

#### Slice 1: Operator Lookup Spine

Build:

- a lineage lookup helper for `decision_id`, `run_id`, `incident_id`,
  `queue_item_id`, and `event_id`
- a compact operator practice doc that explains lookup order and expected next
  artifact hops

Acceptance criteria:

- lookup by canonical id reaches the next relevant artifact without cross-tree
  manual search
- lookup output is projection-only and cites canonical source artifacts

#### Slice 2: Status Rollups

Build:

- generated status summaries for `watchers`, `queue`, `automations`, `runs`,
  `missions`, and `incidents`
- one operator-facing “ops snapshot” report or command that consolidates the
  package’s minimum surface visibility table

Acceptance criteria:

- rollups expose the minimum visibility fields named in the package
- rollups do not become authoritative state
- stale or missing linkage is surfaced explicitly, not hidden

#### Slice 3: Incident Closure Ergonomics

Build:

- an incident closure-readiness checker
- a more explicit incident evidence checklist
- operator guidance for linking runs, decisions, waivers, and follow-up mission
  state

Acceptance criteria:

- incident closure can be evaluated mechanically before a human closes it
- missing evidence is visible on the incident path itself
- follow-up work larger than one bounded response is routed into mission state

#### Slice 4: Scenario-Specific Playbooks

Build playbooks for at least these cases:

1. watcher source unreadable
2. automation target workflow unresolved
3. queue item expired without ack
4. stale queue acknowledgement with wrong `claim_token`
5. active run missing acknowledgement or heartbeat
6. incident closure blocked by missing evidence

Acceptance criteria:

- each playbook references the governing policy or runtime artifact
- each playbook states the first reversible action, the evidence to inspect,
  and the escalation point
- playbooks do not authorize policy exceptions on their own

## Concrete Backlog

| ID | Item | Authority | Expected outputs |
| --- | --- | --- | --- |
| `OPR-001` | Define the operator lookup matrix for canonical ids and next-hop lineage. | `observability.md`, `operator-and-authoring-runbook.md` | lookup practice doc; acceptance checklist |
| `OPR-002` | Add a lineage inspection script for `decision_id`, `run_id`, `incident_id`, `queue_item_id`, and `event_id`. | `observability.md` | `runtime/_ops/scripts/lookup-orchestration-lineage.*` |
| `OPR-003` | Add a run health inspection helper that surfaces evidence-link and decision-link health. | `observability.md`, `run-linkage-standards.md` | `runtime/_ops/scripts/inspect-run-health.*` |
| `OPR-004` | Add a queue health summary that exposes lane counts, oldest pending age, expired leases, and dead-letter counts. | `observability.md`, `queue-operations-standards.md` | queue summary script/report |
| `OPR-005` | Add a watcher health summary exposing status, last evaluation, last emitted event, suppression count, and error reason. | `observability.md`, `watcher-operations.md` | watcher summary script/report |
| `OPR-006` | Add an automation health summary exposing launch attempts, last success, suppression count, and pause/error reason. | `observability.md`, `automation-operations.md` | automation summary script/report |
| `OPR-007` | Add an incident status and closure-readiness summary exposing owner, severity, linked runs, and missing evidence. | `observability.md`, `incidents.md`, `incident-lifecycle-standards.md` | incident summary script/report |
| `OPR-008` | Add a consolidated ops snapshot command or report spanning the minimum visibility table. | `observability.md` | top-level operator snapshot |
| `OPR-009` | Add a fail-closed closure-readiness checker for runtime incidents. | `incidents.md`, `incident-lifecycle-standards.md` | `runtime/_ops/scripts/check-incident-closure-readiness.*` |
| `OPR-010` | Tighten incident authoring guidance so closure evidence, waivers, and linked runs are explicit. | `incidents.md`, `incident-lifecycle-standards.md` | updated incident practice docs |
| `OPR-011` | Author playbook guidance for watcher source failures. | `watcher-operations.md`, `operator-and-authoring-runbook.md` | playbook doc |
| `OPR-012` | Author playbook guidance for queue expiry and stale-ack failures. | `queue-operations-standards.md`, `operator-and-authoring-runbook.md` | playbook doc |
| `OPR-013` | Author playbook guidance for automation-target resolution failures. | `automation-operations.md`, `automation-policy.md` | playbook doc |
| `OPR-014` | Author playbook guidance for run liveness and heartbeat-expiry failures. | `run-liveness-and-recovery-spec.md`, `observability.md` | playbook doc |
| `OPR-015` | Add validators or smoke checks that operator projections remain subordinate and internally resolvable. | `orchestration-domain-implementation-agreement.md`, `observability.md` | assurance checks |

## Impact Map (code, tests, docs, contracts)

- `code`:
  - expected additions under `/.octon/framework/orchestration/runtime/_ops/scripts/`
  - possible subordinate report generators under `/.octon/framework/orchestration/runtime/`
- `tests`:
  - script-level smoke tests for lookup helpers and closure-readiness logic
  - harness validation hooks for projection integrity
- `docs`:
  - new operator lookup and playbook docs under
    `/.octon/framework/orchestration/practices/`
  - possible runbook refinements under `/.octon/framework/orchestration/governance/`
- `contracts`:
  - no new execution authority contracts should be introduced by default
  - if a new projection contract is needed, it must remain explicitly
    subordinate to runtime/governance authority

## Compliance Receipt

- This plan keeps operator UX and dashboards subordinate to canonical runtime
  and governance artifacts.
- It preserves the package’s observability and lookup requirements.
- It preserves incident closure as a human-governed, evidence-backed action.
- It does not propose `campaigns`, new execution containers, or mutable
  dashboard authority.

## Exceptions/Escalations

- No exception requested for the planning artifact.
- Reassess before implementation if a proposed dashboard or operator surface
  starts carrying mutable state or becomes an attempted source of truth.

# Assurance And Acceptance Matrix

## Purpose

Define how the orchestration model will be validated before promotion into live
`.harmony` surfaces.

## Assurance Domains

| Domain | What Must Be Proven |
|---|---|
| Contract conformance | all object and interface contracts validate |
| Shape conformance | runtime layout and discovery artifacts match the package |
| Routing determinism | routing resolves without guessing |
| Fail-closed behavior | missing prerequisites block or escalate cleanly |
| Authority boundaries | surfaces do not exceed their allowed actions |
| Queue correctness | leases, retries, acks, and dead-letter behavior are deterministic |
| Evidence traceability | lineage and evidence links resolve both directions |
| Incident control | incidents contain, escalate, and close correctly |
| Discovery conformance | progressive-disclosure and SSOT rules hold |
| Coordination safety | side-effectful actions acquire and retain required coordination |
| Run liveness | active executor ownership and recovery are deterministic |

## Validation Expectations

### Contract Validation Checks

- every surface object validates against its contract
- every schema-backed contract has a machine-readable schema and fixtures
- required fields exist
- prohibited fields or states are rejected
- package-normative and schema-backed contracts are explicitly marked in
  `implementation-readiness.md`
- automation identity, trigger selection, bindings, and policy authority are
  validated at `automation.yml`, `trigger.yml`, `bindings.yml`, and
  `policy.yml`, not in registry projections or prose
- workflow execution authority is validated at `workflow.yml`, not in README or
  registry prose
- watcher authority is validated at `watcher.yml`, `sources.yml`, `rules.yml`,
  and `emits.yml`, not in registry projections or state files
- queue execution authority is validated at the queue-item contract/schema, not
  in `registry.yml` prose or a local `schema.yml` projection
- run execution authority is validated at the canonical `<run-id>.yml` record
  plus continuity evidence linkage, not in `index.yml` or `by-surface/`
  projections
- incident response authority is validated at schema-backed `incident.yml` and
  `actions.yml` when present, not in `timeline.md`, `closure.md`, or lookup
  projections
- mission identity, lifecycle, and linkage authority are validated at
  `mission.yml`, not in `mission.md` or registry projections

### Schema And Shape Validation

- runtime tree matches canonical shapes
- required top-level discovery artifacts exist
- every automation unit contains valid `automation.yml`, `trigger.yml`,
  `bindings.yml`, and `policy.yml`
- every workflow unit contains a valid `workflow.yml`
- every mission unit contains a valid `mission.yml`
- every stage asset referenced from `workflow.yml` resolves under `stages/`
- every watcher unit contains valid `watcher.yml`, `sources.yml`, `rules.yml`,
  and `emits.yml`
- queue preserves lane directories and `receipts/`, while keeping queue-item
  definition authority external to mutable runtime state
- runs preserve `index.yml`, canonical `<run-id>.yml` records, and
  `by-surface/` reverse-lookup projections without collapsing authority into a
  single projection layer
- incidents preserve `index.yml`, canonical per-incident `incident.yml`
  records, optional `actions.yml`, and subordinate evidence artifacts without
  collapsing authority into prose
- state directories and indexes are present where required
- schema-backed fixtures pass/fail under
  `validate-orchestration-design-package.sh`

### Routing Determinism Checks

- queue items resolve to exactly one automation target
- one watcher event may fan out deterministically to zero or more queue items
- automations resolve to exactly one workflow target
- event-trigger selection is deterministic under the declared match mode
- `dedupe_window` suppression is deterministic
- bindings are validated before admission
- automation launch eligibility is derived from the split definition artifacts,
  not inferred from registry fields or operator prose
- schedule-window resolution is deterministic across timezone and DST handling
- every material action attempt resolves to exactly one `decision_id`
- unresolved references block
- watcher `rule_id` and `event_type` resolve back to the emitting watcher
  definition without ambiguous fallback
- watcher routing hints appear only when the corresponding emitted-event
  declaration permits them

### Fail-Closed Checks

- missing target workflow blocks launch
- invalid trigger definition blocks automation activation
- queue item with missing target does not enter active claim path
- blocked or escalated material actions write decision records
- incident closure without evidence blocks
- orphan allow decisions are detected before speculative relaunch
- privileged actions without valid approval or override artifacts do not pass
- side-effectful launches without acquired coordination do not pass

### Authority-Boundary Checks

- watchers cannot launch workflows
- queue cannot target missions directly
- workflows do not own recurrence
- campaigns do not become execution containers
- runtime surfaces do not self-authorize policy exceptions
- watcher `state/` does not become the canonical event or evidence surface

### Queue Lease And Retry Checks

- claim writes `claimed_at`, `claim_deadline`, and `claim_token`
- expired claims move to retry deterministically
- stale ack with the wrong `claim_token` is rejected
- ack removes item from active lanes and writes receipt
- dead-letter transition happens at retry ceiling or non-retryable failure

### Evidence Traceability Checks

- material runs always link to continuity evidence
- material runs always link to `decision_id`
- blocked and escalated actions resolve to continuity decision records
- mission-linked runs resolve both directions
- incident-linked runs resolve both directions
- queue/event/automation provenance resolves where present
- active runs expose executor ownership and liveness state

### Coordination And Liveness Checks

- side-effectful executions derive deterministic `coordination_key`
- coordination lock contention is handled deterministically across entry modes
- active runs require `executor_id`, heartbeat, and lease state
- stale active runs move into deterministic recovery behavior

### Incident Containment And Closure Checks

- incident severity/status always explicit
- closure requires closure evidence
- closure requires human or policy-backed closure authority
- remediation linkage must resolve or include waiver

### Discovery Metadata Conformance

- promoted collection surfaces have `manifest.yml` and `registry.yml`
- infrastructure surfaces satisfy the discovery-and-authority contract
- routing metadata stays lightweight and does not carry mutable state
- promoted automation surfaces preserve `manifest.yml -> registry.yml ->
  automation.yml + trigger.yml + bindings.yml + policy.yml -> state/`
  authority order
- existing workflow surfaces preserve `manifest.yml -> registry.yml ->
  workflow.yml` authority order and keep `README.md` non-authoritative
- watcher surfaces preserve `manifest.yml -> registry.yml -> watcher definition
  family -> state -> evidence` authority order
- queue preserves `README.md -> registry.yml / schema.yml projection -> queue
  item contract/schema -> lane state -> receipts` authority order
- runs preserve `README.md -> index.yml -> <run-id>.yml -> by-surface/ ->
  continuity/runs/` authority order
- incidents preserve `README.md -> index.yml -> incident.yml / actions.yml ->
  timeline/closure evidence` authority order
- existing mission surfaces preserve `registry.yml -> mission.yml -> mission.md`
  authority order and keep task/log/context state subordinate to the canonical
  mission object

## Surface Acceptance Criteria

| Surface | Acceptance Criteria |
|---|---|
| `workflows` | `workflow.yml` validates, stage references resolve, registry projections do not outrank the definition artifact, execution context can emit runs, and evidence linkage rules hold |
| `missions` | `mission.yml` validates, registry projections do not outrank the mission object, workflow bindings and run linkage validate, and no recurrence leakage occurs |
| `runs` | continuity evidence linkage validates; `decision_id` resolves; `index.yml` and `by-surface/` projections resolve back to canonical `<run-id>.yml`; projections do not outrank the canonical run record or continuity evidence |
| `automations` | `automation.yml`, `trigger.yml`, `bindings.yml`, and `policy.yml` validate; trigger selection stays in `trigger.yml`; bindings/policy do not leak authority; concurrency and idempotency rules are enforced across `serialize`, `drop`, `parallel`, and `replace` |
| `watchers` | watcher definition family validates; rule and emitted-event references resolve; event envelope valid; mutable state and evidence stay separate; no direct launch authority |
| `queue` | automation-ingress only; event fan-out, claim token, lease, retry, and dead-letter semantics deterministic |
| `incidents` | `incident.yml` validates; `actions.yml` validates when present; lifecycle and closure evidence rules hold; escalation is visible; prose evidence remains subordinate to machine state |
| `campaigns` | aggregation only; no execution ownership; optionality preserved |

## Portability And Support-Target Considerations

- file formats should remain plain-text and reviewable
- discovery and registry artifacts should remain tool-agnostic
- validators should not assume a single platform when avoidable
- continuity evidence linkage must remain repository-local and reproducible
- schema validation should rely only on repository-local artifacts and bundled
  validator logic

## Promotion Gate Matrix

| Gate | Requirement | Must Be True |
|---|---|---|
| `G0` | package completeness | required docs, contracts, and indexes exist |
| `G1` | contract validity | all surface contracts validate with no unresolved ambiguities |
| `G2` | routing safety | allow/escalate/block behavior proven by scenarios |
| `G3` | evidence safety | material runs and blocked/escalated actions produce required evidence |
| `G4` | authority safety | no surface exceeds its bounded authority |
| `G5` | operational safety | pause/resume, queue retry, and incident closure behave correctly |
| `G6` | hardened runtime safety | coordination, approvals, bindings, and run recovery behave correctly |
| `G7` | canonicalization readiness | runtime/governance/practices/validation targets defined for promotion |

## Minimum Promotion Recommendation

Do not promote a proposed surface into live `.harmony/orchestration/` authority
surfaces until it passes:

- `G0` through `G4` for prototype implementation
- `G0` through `G7` for canonical rollout

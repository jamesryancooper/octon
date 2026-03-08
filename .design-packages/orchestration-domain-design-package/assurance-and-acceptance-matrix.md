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

### Schema And Shape Validation

- runtime tree matches canonical shapes
- required top-level discovery artifacts exist
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
- schedule-window resolution is deterministic across timezone and DST handling
- every material action attempt resolves to exactly one `decision_id`
- unresolved references block

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

## Surface Acceptance Criteria

| Surface | Acceptance Criteria |
|---|---|
| `workflows` | execution context can emit runs; evidence linkage rules hold |
| `missions` | workflow bindings and run linkage validate; no recurrence leakage |
| `runs` | continuity evidence linkage validates; `decision_id` resolves; projections do not outrank evidence |
| `automations` | trigger selection deterministic; concurrency and idempotency rules enforced across `serialize`, `drop`, `parallel`, and `replace` |
| `watchers` | event envelope valid; emits only through contract; no direct launch authority |
| `queue` | automation-ingress only; event fan-out, claim token, lease, retry, and dead-letter semantics deterministic |
| `incidents` | lifecycle valid; closure evidence required; escalation visible |
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

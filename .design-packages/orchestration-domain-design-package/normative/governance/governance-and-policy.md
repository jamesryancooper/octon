# Governance And Policy

## Purpose

Define how orchestration policy is layered, where enforcement occurs, and what
must be true before material work may proceed.

This document is normative for governance posture and policy enforcement points.

## Governance Model

Orchestration is autonomous inside explicit policy boundaries. It is not
self-governing.

The policy stack is:

| Layer | Scope | What It Controls |
|---|---|---|
| repository / agency governance | repo-wide | safety, escalation, change control, human override boundaries |
| objective / intent authority | active objective scope | what kinds of work the system may pursue in the current context |
| orchestration governance | orchestration domain | incident policy, queue safety, watcher signal rules, automation policy |
| surface-local policy | one surface instance | trigger rules, overlap mode, retry policy, closure prerequisites |
| operator approval / incident override | explicit case-by-case authority | exceptional actions such as incident closure or break-glass containment |

## Privileged Action Classes

The following actions require approval or override verification before `allow`:

- incident closure
- break-glass containment or rollback
- destructive workflow execution
- manual redrive after ambiguous prior execution

## Materiality Rule

Material actions are governed actions. They always require:

- prerequisite evaluation
- one decision record
- operator visibility when blocked or escalated

Materiality is defined in
`normative/governance/routing-authority-and-execution-control.md`.

## Enforcement Points

| Enforcement Point | Purpose | Must Enforce |
|---|---|---|
| authoring time | keep invalid definitions from entering runtime | contract conformance, required fields, supported schedule grammar, required artifacts |
| activation time | prevent unsafe active states | trigger validity, target resolution, readable artifacts, policy presence |
| admission time | gate every orchestration unit before side effects | dependencies, authority, idempotency, overlap mode, approvals |
| pre-side-effect | ensure evidence exists before work executes | decision record created, run record created for workflow-backed actions |
| terminalization time | keep completion and closure truthful | evidence linkage, queue receipts, incident closure prerequisites |
| promotion time | keep the design canonicalization-safe | assurance gates, compatibility policy, validation coverage |

## Decision Outcomes

| Outcome | Meaning | Required Evidence |
|---|---|---|
| `allow` | prerequisites satisfied and work admitted | decision record, and run record when execution starts |
| `block` | work may not proceed because prerequisites or state are missing or invalid | decision record with reason codes |
| `escalate` | work may proceed only after explicit approval or operator action | decision record with approval need / policy threshold |

## Policy Enforcement Inputs

Before any material action, the orchestrator must evaluate:

- active objective scope
- resolved surface definitions
- contract validity
- lifecycle state eligibility
- idempotency context
- overlap / retry / incident policy
- approvals or waivers where required

Approvals and overrides must resolve through
`normative/governance/approval-and-override-contract.md`.

Approver authorization must additionally resolve through
`normative/governance/approver-authority-model.md`.

## Surface-Specific Policy Boundaries

| Surface | Policy Boundary |
|---|---|
| `watchers` | may emit events, never launch workflows directly |
| `queue` | may move items across lanes, never reinterpret work intent |
| `automations` | may launch only their configured workflow target |
| `workflows` | may execute bounded procedures, never self-authorize policy exceptions |
| `missions` | may organize work, never override policy |
| `runs` | record execution state, never define future intent |
| `incidents` | may coordinate containment, never become policy authors |
| `campaigns` | aggregate mission state, never own execution |

## Validation Gates

The implementation is not acceptable unless it proves:

- routing determinism
- fail-closed behavior on missing prerequisites
- authority boundaries for every surface
- evidence traceability for material runs and decisions
- queue lease correctness
- incident closure correctness

The full gate matrix remains in
`normative/assurance/assurance-and-acceptance-matrix.md`.

## Auditability Guarantees

The orchestration domain must guarantee that operators and auditors can answer:

- what action was attempted?
- why was it allowed, blocked, or escalated?
- what workflow or surface performed the work?
- what evidence proves the outcome?
- who approved the action when approval was required?

The following are mandatory for that guarantee:

- exactly one `decision_id` per material action attempt
- one canonical `run_id` per admitted workflow-backed execution
- canonical continuity evidence locations for material runs and decisions
- canonical identifiers across all references

## Break-Glass Posture

Break-glass is never implicit.

If supported, it is limited to:

- containment
- rollback
- explicit incident-response actions already authorized by policy

Break-glass always requires:

- explicit authority
- durable evidence
- operator-visible reason
- explicit override artifact with bounded scope and expiry

## Acceptance Criteria

The system is governance-complete only when:

- invalid or ambiguous references block
- blocked and escalated outcomes are durable and operator-visible
- incident closure cannot bypass evidence or authority checks
- runtime state never becomes de facto policy
- canonical validation hooks exist for promoted surfaces

## Non-Goals

This document does not replace the detailed routing matrix or state-machine
rules. It defines the policy model those documents operate within.

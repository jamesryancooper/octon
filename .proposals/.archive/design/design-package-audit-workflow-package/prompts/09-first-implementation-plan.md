# First Implementation Plan Prompt

You are a **principal engineer and implementation lead**.

You have already been given a **Minimal Implementation Architecture Blueprint** for the following package:

```text
<PACKAGE_PATH>
```

Your task is to convert that blueprint into a **practical implementation plan for the first production build**.

Do not perform another architecture review.
Do not redesign the system.
Do not reopen already-closed design questions unless they block implementation sequencing.

Your goal is to produce the engineering plan that a team would actually execute.

---

## Inputs

1. The existing design package
```text
<PACKAGE_PATH>
```

2. The minimal implementation architecture blueprint
```text
<BLUEPRINT_REPORT>
```

3. Any specification-closure artifacts already created

---

## Objective

Produce a **First Implementation Plan** that translates the blueprint into:

- concrete implementation phases
- workstreams
- dependencies
- milestones
- done criteria
- test and conformance plan
- first end-to-end slice
- implementation risks

The plan should optimize for:

- proving the architecture early
- minimizing unsafe partial implementations
- validating the highest-risk control-plane behavior first

---

## Phase 1 — Implementation Strategy

Define the implementation strategy for the first production-capable version.

Explain:

- what must be built first
- what can be deferred
- what should be stubbed or faked initially
- what must be real from day one because it protects invariants

Pay special attention to:

- decision/run persistence
- lock enforcement
- executor ack/liveness
- approval verification
- reconciliation

---

## Phase 2 — Workstreams

Organize implementation into concrete workstreams.

At minimum include:

- contracts and schemas
- storage primitives
- queue and claim handling
- coordination lock handling
- decision/run persistence
- automation controller
- workflow launcher/executor interface
- liveness and reconciliation
- approvals and authority verification
- validator and conformance tests

For each workstream provide:

- purpose
- scope
- prerequisites
- outputs
- key risks

---

## Phase 3 — Dependency Graph

Show the dependency order between workstreams.

Identify:

- which workstreams can proceed in parallel
- which are strict prerequisites
- which should not start until invariants are enforceable

Make the implementation order explicit.

---

## Phase 4 — First End-to-End Slice

Define the smallest end-to-end slice that should be implemented first.

It must exercise:

- one trigger path
- one queue claim path
- one lock acquisition path
- one decision write
- one run creation
- one executor ack
- one heartbeat/liveness path
- one recovery path

Specify:

- exact scope
- required components
- fake vs real components allowed
- success criteria
- failure cases that must be tested

---

## Phase 5 — Milestones

Define concrete implementation milestones.

For each milestone provide:

- milestone name
- objective
- required completed work
- evidence of completion
- what risks are retired by that milestone

Examples:
- schemas closed
- storage primitives ready
- admission path working
- launch path working
- liveness path working
- privileged-action enforcement working
- conformance suite green

---

## Phase 6 — Done Criteria

Define done criteria at three levels:

### Component Done
What makes an individual component complete?

### Slice Done
What makes the first end-to-end slice complete?

### System Done
What minimum conditions must be true before calling the first implementation production-capable?

---

## Phase 7 — Test and Conformance Plan

Define the minimum test plan required to prove the implementation matches the blueprint.

Include:

### Static validation
- schema checks
- required artifact checks
- fixture validation

### Runtime conformance
- no side effects before lock + decision + run + ack
- stale-run recovery
- claim token enforcement
- approval verification
- lock contention handling
- retry taxonomy enforcement

### Failure injection
- missed ack
- heartbeat loss
- lock expiry
- policy subsystem unavailability
- invalid approval
- binding failure

---

## Phase 8 — Residual Risks

Identify the top remaining implementation risks even if the team follows the blueprint correctly.

For each risk provide:

- why it remains risky
- what early signal would reveal trouble
- how to reduce the risk during implementation

---

## Phase 9 — Team Execution Format

Present the final plan in this structure:

# First Implementation Plan

## A. Build strategy
## B. Workstreams
## C. Dependency order
## D. First end-to-end slice
## E. Milestones
## F. Done criteria
## G. Test and conformance plan
## H. Residual implementation risks

Keep the plan concrete and execution-oriented.

---

## Important Rules

Do not:

- redo architecture analysis
- propose alternative architectures
- broaden scope beyond the blueprint
- produce generic agile/process advice

Do:

- turn the blueprint into executable engineering work
- preserve invariants
- force risky behavior to be validated early
- prioritize the smallest real slice that proves the system

---

## Desired Outcome

At the end of this exercise, an engineering team should know:

- what to build first
- what order to build it in
- how to prove it works
- what must be true before side effects are allowed
- how to reach the first production-capable implementation safely

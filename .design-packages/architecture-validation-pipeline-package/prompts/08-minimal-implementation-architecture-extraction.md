# Minimal Implementation Architecture Extraction Prompt

You are a **principal systems architect and implementation lead**.

Your task is to convert the following design package into a **minimal implementer blueprint** that a competent engineering team can use to begin building the system immediately:

```text
<PACKAGE_PATH>
```

Assume the package has already gone through:

- architecture audit
- red-team review
- hardening / remediation
- integration / specification closure
- implementation simulation

Your job is **not** to critique the package further.

Your job is to **extract the minimum complete implementation architecture** from the design package and present it in a form that is directly useful to implementers.

The output should function as a **practical engineering blueprint** for the first production implementation.

---

## Objective

Produce a **concise but complete implementation architecture** that translates the design package into:

- concrete runtime components
- core data contracts
- key algorithms
- service boundaries
- state models
- validation points
- implementation order

The blueprint must preserve the package’s architecture and constraints.

Do **not** redesign the system.
Do **not** propose alternatives unless the package explicitly leaves a choice open.

---

## Critical Rule

Act as though the design phase is over and the engineering team is starting implementation now.

You must answer questions such as:

- What are we building first?
- What services/processes exist?
- What data must each service own or read?
- What contracts must be implemented before anything else?
- What invariants must never be violated?
- What sequence should implementation follow?

If a detail is still ambiguous, identify it explicitly as a **residual ambiguity**, but keep the blueprint focused on what can be built.

---

## Deliverable Form

Produce a document titled:

# Minimal Implementation Architecture Blueprint

Keep it implementation-oriented, structured, and compact.

Target length: approximately **10–20 pages worth of material** if rendered as an engineering document.

Favor precision and structure over prose.

---

## Section 1 — System Purpose and Build Target

Summarize, in implementation terms:

- what system is being built
- what responsibilities are in scope
- what responsibilities are explicitly out of scope

This must be written for implementers, not reviewers.

---

## Section 2 — Minimal Production Architecture

Identify the **minimum production-capable set of runtime components** required.

For each component provide:

- name
- purpose
- responsibilities
- required inputs
- required outputs
- state owned
- critical dependencies

Only include components actually supported by the package.

---

## Section 3 — Core Service Boundaries

Define the service/process boundaries the team should implement.

For each boundary explain:

- what crosses the boundary
- whether the interaction is synchronous or asynchronous
- what contract governs the interaction
- what must be stable vs implementation-private

If the package does not require separate deployable services, say so and define logical modules instead.

---

## Section 4 — Core Data Model

Extract the **minimum required data model**.

For each core entity define:

- purpose
- required fields
- identity
- lifecycle
- relationships
- validation constraints

Make a distinction between:

- authoritative records
- projections / derived records
- ephemeral runtime state

---

## Section 5 — State Machines

Extract the **minimum state machines** that implementers need.

At minimum cover:

- run lifecycle
- queue item lifecycle
- coordination lock lifecycle
- approval validity lifecycle
- recovery / stale-run lifecycle

For each state machine provide:

- states
- allowed transitions
- transition triggers
- invalid transitions
- required invariants

Use compact tabular form where possible.

---

## Section 6 — Core Algorithms

Define the core algorithms the first implementation must include.

At minimum cover:

- trigger matching
- schedule evaluation
- event dedupe
- parameter binding validation
- dependency resolution
- policy evaluation
- approval verification
- coordination-key derivation
- lock acquisition / renewal / release
- launch admission
- retry classification
- stale-run reconciliation

For each algorithm provide:

- purpose
- required inputs
- required outputs
- ordered steps
- fail-closed behavior
- unresolved implementation choices, if any

---

## Section 7 — Runtime and Storage Model

Describe the minimal runtime model needed for production.

Cover:

- which components need persistent storage
- what data requires atomicity
- where CAS semantics are required
- what requires leasing / heartbeats
- what can be eventually consistent
- what time assumptions exist
- where idempotency must be enforced

Do not choose a specific database unless the package does so.
Instead define the required behavioral guarantees.

---

## Section 8 — Enforcement Points and Invariants

Extract the non-negotiable enforcement points in the system.

Examples:

- no side effects before decision record
- no side effects before lock acquisition
- no privileged execution without valid approval
- no active run without executor ownership or deterministic recovery eligibility

For each invariant specify:

- the invariant
- where it is enforced
- what artifact proves compliance
- what happens when the invariant is violated

---

## Section 9 — Validator Scope

Define what the validator must enforce before runtime and what runtime must enforce during execution.

Split into:

### Static/package validation
Examples:
- schema validation
- required artifact presence
- retry taxonomy validity
- workflow metadata completeness

### Runtime enforcement
Examples:
- lock acquisition
- lease validity
- approval freshness
- heartbeat liveness

Be explicit about what cannot be proven statically.

---

## Section 10 — Failure Handling Blueprint

Extract the minimum failure-handling model needed for safe implementation.

Cover:

- trigger errors
- binding failures
- policy subsystem unavailability
- queue claim failures
- lock contention
- executor crash
- stale lease
- orphaned decision
- incomplete side-effect evidence
- approval expiry during execution

For each one define:

- expected behavior
- required persistence updates
- whether recovery is automatic, blocked, or escalated

---

## Section 11 — First Implementation Slice

Define the **smallest end-to-end implementation slice** that proves the architecture works.

This should include:

- a minimal supported trigger path
- one workflow launch path
- one decision record path
- one lock acquisition path
- one run lifecycle path
- one recovery path
- one validator path

Explain exactly what should be built first and why.

---

## Section 12 — Recommended Implementation Order

Provide the recommended engineering sequence.

For each stage provide:

- objective
- dependencies
- done criteria

---

## Section 13 — Open Residual Ambiguities

List only the ambiguities that still remain after extracting the blueprint.

For each one provide:

- ambiguity
- implementation risk
- temporary default assumption, if safe
- whether it must be resolved before coding or can wait

Do not re-open already closed issues.

---

## Section 14 — Implementer Handoff Summary

End with a compact handoff section containing:

- what must be built
- what must be true before side effects are allowed
- what artifacts are authoritative
- what the team should not improvise
- the top 5 implementation failure risks to avoid

---

## Important Rules

Do not:

- perform another broad architecture review
- re-run red-team analysis
- recommend redesigns
- expand scope beyond the design package
- produce generic best practices

Do:

- extract the implementation architecture already implied by the package
- make hidden dependencies explicit
- translate design into build steps
- preserve system guarantees
- keep the blueprint minimal but sufficient

---

## Desired Outcome

At the end of this exercise, a competent engineering team should be able to use the blueprint to answer:

- what we are building
- how the major pieces fit together
- what contracts and invariants matter most
- what order to implement the system in
- where the sharp edges are

The blueprint should function as the **practical bridge between the design package and the first production implementation**.

# Implementation Simulation Prompt

You are a **senior systems engineer tasked with implementing a production system directly from a design specification**.

Your task is to **simulate the implementation of the system described in the following design package**:

```text
<PACKAGE_PATH>
```

Assume this package is the **only temporary implementation input you have
available right now**. It is not a canonical authority and may be archived or
removed after implementation.

You do **not** have access to the original designers.

If something is unclear or missing, you must **identify it as a specification gap**.

---

## Objective

Determine whether the design package is **actually buildable**.

Your goal is to simulate how a real engineering team would attempt to implement the system and identify where the specification fails to provide enough information.

---

## Critical Rule

Act as if you are beginning implementation **today**.

You must attempt to answer questions like:

- What services need to exist?
- What data structures must be created?
- What algorithms must be implemented?
- What APIs must be exposed?

If the design package does not provide enough information to answer these questions, that is a **design gap**.

---

## Phase 1 — System Implementation Plan

Based on the design package, determine what must be built.

Describe the system components required.

Examples might include:

- controller
- dependency resolver
- scheduler
- run registry
- lock/coordination service
- policy evaluator
- validator system

For each component explain:

- its responsibilities
- the inputs it consumes
- the outputs it produces

If the design does not clearly imply these components, note that as a gap.

---

## Phase 2 — Data Model Definition

Attempt to define the core data structures required to implement the system.

Examples might include:

- Workflow
- ExecutionRun
- DecisionRecord
- ApprovalArtifact
- CoordinationLock
- Policy
- TriggerDefinition

For each data structure identify:

- required fields
- relationships to other entities
- lifecycle expectations

If the specification does not clearly define these, mark it as a missing design detail.

---

## Phase 3 — Algorithm Implementation

Attempt to implement the core algorithms defined by the system.

Examples include:

### Trigger evaluation
How inputs are matched.

### Dependency resolution
How readiness for execution is determined.

### Policy evaluation
How safety checks are applied.

### Execution coordination
How concurrent runs are prevented from conflicting.

### Retry and recovery
How failed executions are handled.

For each algorithm determine whether the design package provides **sufficient detail to implement it deterministically**.

If not, identify the missing specification elements.

---

## Phase 4 — Runtime Architecture

Attempt to define how the system runs in production.

Explain:

- which components run as services
- how they communicate
- how state is stored
- how execution is coordinated

If the design does not clearly support a runtime model, identify the missing details.

---

## Phase 5 — Failure and Recovery Simulation

Simulate several real-world failure scenarios.

Examples:

### Crash During Execution
What happens if an executor crashes mid-run?

### Concurrent Launch
What happens if multiple triggers launch the same target simultaneously?

### Policy Enforcement Failure
What happens if a policy evaluator becomes unavailable?

### Orphaned Execution
What happens if a run becomes detached from its executor?

If the design does not clearly define behavior for these cases, identify the gap.

---

## Phase 6 — Validator Implementation

Attempt to implement the design package validator.

Determine:

- what invariants must be checked
- what schemas must exist
- what semantic guarantees must be enforced

Identify validation logic that cannot be implemented due to incomplete specification.

---

## Phase 7 — Implementation Blockers

Identify **blocking issues that would stop an engineering team from implementing the system correctly**.

Examples:

- missing schemas
- undefined execution semantics
- unclear state transitions
- incomplete concurrency model

Focus on **high-impact blockers**.

---

## Phase 8 — Engineering Friction Points

Identify areas where implementation would likely produce:

- inconsistent implementations
- unsafe behavior
- excessive engineering guesswork

These represent **design weaknesses** even if implementation is technically possible.

---

## Phase 9 — Buildability Assessment

Provide a final assessment:

| Dimension | Rating | Explanation |
|---|---|---|
| Implementation Clarity | Poor / Partial / Good / Excellent |
| Algorithmic Completeness | Poor / Partial / Good / Excellent |
| Runtime Architecture | Poor / Partial / Good / Excellent |
| Operational Robustness | Poor / Partial / Good / Excellent |

---

## Final Output

Produce an **Implementation Feasibility Report** containing:

1. System implementation plan
2. Data model reconstruction
3. Algorithm implementation analysis
4. Runtime architecture model
5. Failure simulations
6. Validator implementation feasibility
7. Implementation blockers
8. Engineering friction points
9. Buildability assessment

---

## Important Rules

Do not:

- redesign the system
- propose alternative architectures
- speculate beyond the design package

Focus only on:

> **Whether the system can actually be implemented from the provided specification.**

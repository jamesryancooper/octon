# Design Red-Team Prompt

You are acting as a **red-team principal architect** tasked with stress-testing a system design before implementation.

Your objective is to **identify ways this design could fail, break, or be misimplemented** in the real world.

Target design package:

```text
<PACKAGE_PATH>
```

Assume the package is intended to serve as a **temporary implementation aid**,
not a canonical runtime or documentation authority.

Your task is to **attack the design intellectually** to uncover risks, ambiguities, and missing constraints.

---

## Critical Rule

Do not assume the design is correct.

Instead assume:

> If something is not clearly specified, engineers will implement it differently.

Your job is to identify **where this will happen**.

---

## Phase 1 — Architecture Reconstruction

First reconstruct the architecture described by the package.

Explain:

- the system boundaries
- the core domain concepts
- the execution model
- the state model
- governance and safety mechanisms

If the architecture cannot be clearly reconstructed, mark this as a **critical design failure**.

---

## Phase 2 — Failure Mode Analysis

Identify ways the system could fail in practice.

Consider scenarios such as:

### Execution Failures
Examples:

- workflow partially executes
- dependencies become inconsistent
- retries cause duplicate actions
- workflows become stuck

Explain whether the design clearly specifies behavior for these cases.

### Concurrency Problems
Examples:

- two orchestrations modify the same target
- parallel workflows conflict
- race conditions during dependency resolution

Does the design define safe behavior?

### State Corruption
Examples:

- state becomes inconsistent
- state updates fail mid-operation
- recovery after crash

Does the package define recovery behavior?

### Policy Bypass
Examples:

- actions executed without proper validation
- policy checks skipped due to architecture gaps

Explain how this could occur.

### Misimplementation Risk
Identify areas where:

- the design leaves too much interpretation
- engineers could implement incompatible versions

---

## Phase 3 — Operational Reality Test

Evaluate whether the design handles real-world operational concerns.

Consider:

### Observability
- Can operators understand what the system is doing?

### Debuggability
- Can engineers diagnose failures?

### Safety
- What prevents destructive actions?

### Rollback & Recovery
- What happens when execution fails mid-flight?

---

## Phase 4 — Design Ambiguity Scan

Identify concepts that are **not precisely defined**.

Examples:

- unclear lifecycle
- unclear state transitions
- undefined behavior in edge cases

Explain how these ambiguities could cause **system instability or unsafe behavior**.

---

## Phase 5 — Missing Safeguards

Identify safeguards expected in mature systems that appear missing.

Examples:

- idempotency guarantees
- execution locking
- dependency graph validation
- safety gates before execution

Explain the risk created by each missing safeguard.

---

## Phase 6 — Implementation Divergence Risk

Explain where **two engineering teams could implement the design differently** while both believing they followed the specification.

These are **dangerous architecture weaknesses**.

---

## Phase 7 — Worst-Case Scenarios

Describe the **most dangerous failure scenarios** this design might allow.

Examples:

- runaway orchestration
- destructive operations executed automatically
- inconsistent system state
- irrecoverable deadlocks

Explain whether the design mitigates these risks.

---

## Phase 8 — Red-Team Summary

Provide a structured summary:

| Category | Risk Level | Explanation |
|---|---|---|
| Architecture Clarity | Low / Medium / High |
| Implementation Divergence | Low / Medium / High |
| Operational Risk | Low / Medium / High |
| Safety & Governance Risk | Low / Medium / High |

---

## Final Output

Produce a **Design Red-Team Report** identifying:

1. Critical architectural risks
2. Major ambiguities
3. Missing safeguards
4. Real-world failure scenarios
5. Recommended design improvements

Focus on **serious system risks**, not documentation style issues.

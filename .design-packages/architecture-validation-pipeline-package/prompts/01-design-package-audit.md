# Design Package Audit Prompt

You are an **independent principal software architect** performing a **design integrity audit** of a software architecture package.

Your objective is to determine whether the design package is **complete, internally coherent, and implementation-ready** for engineering teams.

Target package:

```text
<PACKAGE_PATH>
```

Treat this package as a **temporary implementation aid** for the domain. It may
be archived or removed after implementation and is **not** a canonical runtime
or documentation authority.

Your responsibility is **not to summarize the documents**.
Your responsibility is to determine whether **engineers could actually build the system from this package**.

---

## Critical Rule

You must **reconstruct the system architecture from the documents before evaluating it**.

If the architecture cannot be clearly reconstructed, that is itself a major design issue.

---

## Phase 1 — Document Inventory

List all documents in the package and identify their apparent purpose.

Example categories:

- domain model
- orchestration model
- contracts/interfaces
- governance/policy
- runtime behavior
- validation/assurance
- lifecycle
- architecture diagrams
- operational model

Identify **any obvious missing categories** expected in a mature design package.

---

## Phase 2 — Architecture Reconstruction

Using only the documents in the package, reconstruct the system's intended architecture.

Describe:

### System Boundaries
- where the domain begins and ends
- what other domains it interacts with

### Core Concepts
Identify the primary domain concepts such as:

- workflow
- orchestration unit
- capability
- contract
- policy
- execution state
- dependency

Explain how these concepts relate to each other.

### Execution Model
Describe:

- how workflows are triggered
- how decisions are made
- how execution progresses
- how dependencies are resolved

### State Model
Explain:

- what state the system tracks
- how state evolves during execution
- what persistence model is implied

### Control & Governance
Describe:

- how safety or policy enforcement occurs
- what prevents unsafe execution

If any of these cannot be reconstructed from the documents, note it explicitly.

---

## Phase 3 — Implementation Feasibility

Evaluate whether a competent engineering team could **implement the system from this package without major guesswork**.

Assess the following areas:

### Domain Model Completeness
Are the primary entities and relationships sufficiently defined?

### Behavioral Semantics
Are behaviors clearly defined?

Examples:

- execution lifecycle
- scheduling
- dependency resolution
- retries
- cancellation

### Failure Model
Does the design define how failures are handled?

Examples:

- partial execution
- retries
- rollback
- conflict handling

### System Contracts
Are interfaces and boundaries clearly defined?

Examples:

- input/output expectations
- interactions with other domains

### Observability
Does the design support:

- traceability
- execution visibility
- debugging

### Governance
Does the system clearly define:

- validation rules
- acceptance criteria
- enforcement points

---

## Phase 4 — Cross-Document Consistency

Check whether documents:

- use the same terminology
- define concepts consistently
- reference each other correctly

Identify contradictions or mismatches.

---

## Phase 5 — Risk & Ambiguity Analysis

Identify areas where the design could lead to:

- multiple incompatible implementations
- unclear behavior
- unsafe behavior

Focus on **architectural ambiguity**, not minor wording issues.

---

## Phase 6 — Design Maturity Assessment

Provide a rating for:

| Dimension | Rating | Explanation |
|---|---|---|
| Completeness | Poor / Partial / Good / Excellent |
| Internal Consistency | Poor / Partial / Good / Excellent |
| Implementation Readiness | Poor / Partial / Good / Excellent |
| Operational Realism | Poor / Partial / Good / Excellent |

---

## Phase 7 — Missing Design Elements

Identify **important artifacts that appear to be missing** from the package.

Examples might include:

- execution state machine
- runtime architecture
- lifecycle diagrams
- failure handling model
- extension model

Explain why each missing element matters.

---

## Phase 8 — Recommendations

Provide concrete suggestions for improving the design package so that it becomes:

- easier to implement
- easier to reason about
- safer to operate

Prioritize **high-impact improvements**.

---

## Review Standards

Focus on **system architecture quality**, not documentation style.

Avoid:

- rewriting documents
- stylistic critique
- minor wording feedback

Prioritize:

- missing architecture
- unclear execution semantics
- undefined system behavior
- governance gaps

---

## Desired Outcome

At the end of the audit it should be clear whether this package can realistically
serve as a **usable implementation aid** before archival or removal.

---

## Output

Produce a **Design Audit Report** with these sections:

1. Document Inventory
2. Architecture Reconstruction
3. Implementation Feasibility
4. Cross-Document Consistency
5. Risk & Ambiguity Analysis
6. Design Maturity Assessment
7. Missing Design Elements
8. Recommendations

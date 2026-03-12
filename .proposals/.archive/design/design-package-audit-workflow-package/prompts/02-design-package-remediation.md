# Design Package Remediation Prompt

You are a **principal software architect responsible for improving the design package based on the audit findings**.

The previous audit identified **gaps, ambiguities, inconsistencies, and missing architectural elements** in the following design package:

```text
<PACKAGE_PATH>
```

Your task is to **systematically resolve the issues identified in the audit and evolve the package into a fully implementation-usable design aid.**

The audit report is provided below.

---

## Inputs

1. **Original Design Package**
```text
<PACKAGE_PATH>
```

2. **Architecture Audit Report**
```text
<AUDIT_REPORT>
```

---

## Critical Execution Rule

You must **implement the remediation in the design package itself**.

Do not stop at recommendations.

- **If you have file-system access:** create/update the files directly under `<PACKAGE_PATH>`.
- **If you do not have file-system access:** output a **change manifest** plus the **complete final contents** of every new or updated file.
- Do not return recommendation-only commentary.
- Do not describe a patch without providing the exact file content or exact patch set.

Your output must make it possible for a maintainer to apply the changes **without inventing missing details**.

---

## Objectives

Your goal is to transform the design package into a **complete, coherent, and implementation-ready orchestration/domain specification**.

You must:

1. **Resolve critical gaps**
2. **Clarify ambiguous behavior**
3. **Introduce missing architectural artifacts**
4. **Strengthen cross-document consistency**
5. **Improve implementation clarity**
6. **Write the actual updates**

Do **not redesign the system unnecessarily**.
Preserve the existing architecture where possible and **evolve it responsibly**.

---

## Phase 1 — Gap Resolution Plan

Start by analyzing the audit findings.

Produce a **gap resolution plan** that:

- groups issues by category
- prioritizes the most critical issues
- explains how each issue will be addressed
- maps each issue to the specific file(s) that will be created or updated

Example categories:

- Missing architecture
- Behavioral ambiguity
- Domain model gaps
- Failure semantics
- Governance gaps
- Operational/runtime gaps
- Cross-document inconsistencies

---

## Phase 2 — Architecture Clarification

Where the audit identified **unclear or ambiguous architecture**, produce clear definitions for:

### Core Domain Concepts

Define:

- orchestration unit
- workflow
- capability
- contract
- policy
- execution state
- dependency

Clarify:

- responsibilities
- relationships
- lifecycle

### Execution Model

Clearly define:

- how orchestration begins
- how tasks are scheduled
- dependency resolution
- concurrency behavior
- idempotency expectations

### State Model

Define:

- what state exists
- how state transitions occur
- persistence expectations

Include a **clear lifecycle description**.

### Failure Model

Define:

- retry behavior
- partial execution handling
- rollback or compensation
- conflict resolution

### Governance & Safety

Clarify:

- validation gates
- policy enforcement points
- acceptance criteria
- auditability guarantees

---

## Phase 3 — Missing Design Artifacts

Where the audit identified missing artifacts, create them.

Examples might include:

- orchestration lifecycle definition
- execution state machine
- runtime architecture description
- event model
- dependency resolution algorithm
- extension model for new capabilities

Create these artifacts as **clear, implementation-oriented specifications**.

---

## Phase 4 — Cross-Document Alignment

Ensure that:

- terminology is consistent
- concepts are defined once and referenced elsewhere
- documents do not contradict each other

If necessary:

- introduce clear definitions
- recommend document restructuring
- update indexes / README / reading order

---

## Phase 5 — Implementation Guidance

Improve the package so engineers understand:

- how components interact
- where policy enforcement occurs
- how workflows are executed
- how failures are handled

Provide **concrete examples where useful**.

---

## Phase 6 — Updated Design Package Outline

Produce an improved package structure showing the files that now exist after remediation.

Explain the purpose of each artifact.

---

## Required Output Format

Your output must contain all of the following:

### A. Change Manifest
List every file created, updated, renamed, or deprecated.

Example:

```text
CHANGE MANIFEST
- CREATE: <PACKAGE_PATH>/runtime-architecture.md
- UPDATE: <PACKAGE_PATH>/dependency-resolution.md
- UPDATE: <PACKAGE_PATH>/README.md
```

### B. Implementation Summary
Explain what problems were fixed and how the package is now stronger.

### C. File Bodies or Exact Patches
For every created or updated file, provide one of:

- the **complete final file body**, or
- an **exact unified diff**

Prefer **complete final file bodies**.

Use this format:

```text
FILE: <PACKAGE_PATH>/runtime-architecture.md
```md
# full file content
```
```

### D. Final Package Outline
Show the resulting package structure.

---

## Review Principles

Prioritize:

- clarity
- implementability
- architectural coherence
- safety and governance
- actual file changes

Avoid:

- unnecessary complexity
- speculative abstractions
- expanding beyond the domain scope
- recommendation-only output

---

## Desired Outcome

At the end of this process, the design package should function as a **true buildable implementation aid**.

Engineers should be able to:

- understand the system model
- implement behavior
- enforce governance and safety
- extend the domain safely

without requiring major architectural clarification.

# Design Hardening Prompt

You are a **principal software architect responsible for hardening a system design after a red-team architecture review**.

A **red-team analysis has already been performed** on the following design package:

```text
<PACKAGE_PATH>
```

The red-team report identified **risks, ambiguities, missing safeguards, and potential failure scenarios** in the architecture.

Use the **red-team findings as your primary input**.

---

## Inputs

1. The current design package
```text
<PACKAGE_PATH>
```

2. The red-team report
```text
<RED_TEAM_REPORT>
```

---

## Critical Execution Rule

You must **apply the hardening to the design package itself**.

Do not stop at recommendations.

- **If you have file-system access:** create/update the files directly under `<PACKAGE_PATH>`.
- **If you do not have file-system access:** output a **change manifest** plus the **complete final contents** of every new or updated file.
- Do not return recommendation-only commentary.
- Every critical or major issue that you address must map to concrete file changes.

Your output must make the hardening **directly usable**, not advisory.

---

## Critical Goal

Convert the red-team findings into **concrete design improvements** that can be incorporated into the design package.

Avoid vague recommendations.

Focus on:

- architectural corrections
- missing system guarantees
- clearer execution semantics
- additional design artifacts
- exact file updates

---

## Phase 1 — Issue Prioritization

Review the red-team findings and categorize issues by severity:

| Severity | Meaning |
|---|---|
| Critical | System could behave incorrectly or unsafely |
| Major | Likely to cause inconsistent implementations |
| Moderate | Creates engineering friction or ambiguity |
| Minor | Documentation clarity improvements |

Focus primarily on **Critical and Major issues**.

Map each significant issue to the specific file(s) that will be created or updated.

---

## Phase 2 — Root Cause Analysis

For each significant issue:

Explain **why the design allowed this problem to exist**.

Examples:

- missing lifecycle definitions
- insufficient state model
- unclear execution semantics
- weak policy enforcement boundaries

---

## Phase 3 — Architectural Corrections

For each issue identified by the red-team report:

Propose and then **write** specific architectural improvements, such as:

### Clarifying System Behavior
Examples:

- define execution lifecycle
- define dependency resolution semantics
- define retry behavior

### Adding Safeguards
Examples:

- idempotency requirements
- execution locking
- policy enforcement points
- safety gates

### Strengthening Contracts
Examples:

- explicit interface definitions
- clearer capability boundaries
- defined inputs/outputs

### Defining Failure Semantics
Examples:

- retry model
- partial execution handling
- rollback behavior

---

## Phase 4 — Required Design Artifacts

Identify **new or improved documents** that should be added to the design package.

Examples:

- lifecycle specification
- execution state machine
- runtime architecture
- failure handling model
- concurrency control model
- policy enforcement architecture

Explain the purpose of each artifact and provide the actual file contents.

---

## Phase 5 — Specification Improvements

Recommend and then **write** specific additions or clarifications within existing documents.

Examples:

- diagrams
- lifecycle definitions
- data model details
- reference execution flows

---

## Phase 6 — Implementation Safety Improvements

Identify improvements that make the system safer to implement:

Examples:

- invariant definitions
- safety guarantees
- validation rules
- contract enforcement mechanisms

Write the actual invariants and enforcement language into the affected files.

---

## Phase 7 — Hardened Architecture Summary

Describe what the **improved architecture** looks like after addressing the red-team findings.

Explain:

- how the system prevents unsafe execution
- how behavior is deterministic
- how engineers can implement it consistently

---

## Required Output Format

Your output must contain:

### A. Change Manifest
List every file created or updated.

### B. Hardening Summary
Summarize what was strengthened and why.

### C. File Bodies or Exact Patches
For every changed file, provide the complete final file body or an exact diff.
Prefer complete file bodies.

### D. Post-Hardening Package Outline
Show the resulting package structure.

---

## Important Rules

Do not:

- rewrite the entire package unnecessarily
- propose unnecessary complexity
- introduce unrelated architecture
- return only commentary

Focus only on **changes required to resolve the red-team findings**.

The objective is to make the design **clearer, safer, and more implementation-ready**.

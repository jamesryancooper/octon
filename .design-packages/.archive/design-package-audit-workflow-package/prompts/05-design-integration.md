# Design Integration Prompt

You are a **principal software architect responsible for integrating architectural hardening into an existing design package**.

A red-team review and hardening analysis has already been performed for the following package:

```text
<PACKAGE_PATH>
```

The analysis identified **architectural risks and required corrections** and produced a **hardening report**.

Your task is to **convert those findings into concrete updates to the design package**.

Do not produce general recommendations.
Produce **specific specification changes and new artifacts**.

---

## Inputs

1. The current design package
```text
<PACKAGE_PATH>
```

2. The hardening report
```text
<HARDENING_REPORT>
```

---

## Critical Execution Rule

You must **update the design package itself**.

- **If you have file-system access:** create/update files in place under `<PACKAGE_PATH>`.
- **If you do not have file-system access:** output a **change manifest** plus the **complete final contents** of every new or updated file.
- Do not stop at recommendations or outlines.
- Do not describe intended edits without providing the actual changes.

Your response must be sufficient for a maintainer to apply the integration directly.

---

## Objective

Update the design package so that it:

- resolves all **Critical and Major issues**
- becomes **implementation-ready**
- preserves the **existing architecture wherever possible**

The goal is **hardening the current design**, not redesigning it.

---

## Phase 1 — Map Issues to Design Changes

For each **Critical and Major issue**, determine:

| Issue | Affected Document(s) | Required Change |
|---|---|---|

Example:

| Issue | Affected Document | Change |
|---|---|---|
| Trigger semantics incomplete | dependency-resolution.md | Define algorithm for match_mode, dedupe_window, and event bindings |

---

## Phase 2 — Produce Concrete Specification Changes

For each affected document:

Provide the **exact specification additions or modifications** needed and write them into the actual file content.

Examples:

### Document: `dependency-resolution.md`
Add or update a section such as: **Trigger Matching Algorithm**

Define the normative algorithm for evaluating trigger matches.

Also define:

- dedupe evaluation
- parameter binding validation

---

## Phase 3 — Define New Artifacts

Create specification files for each required new document.

Examples:

- concurrency-control-model.md
- approval-and-override-contract.md
- run-liveness-and-recovery-spec.md
- automation-bindings-contract.md
- surface-artifact-schemas.md

For each artifact provide:

### Purpose
What architectural gap this document resolves.

### Core Concepts
The key concepts introduced.

### Required Sections
A detailed outline and the actual file content.

---

## Phase 4 — Update Existing Contracts

Identify required changes to existing contracts such as:

- run-linkage-contract.md
- decision-record-contract.md

Specify and write:

- new fields
- updated validation rules
- lifecycle semantics

Define required invariants.

---

## Phase 5 — Validator Improvements

Update the validator coverage to enforce the hardened guarantees.

Identify new checks required in the validation system and write the actual updated validation file(s) or the exact patches.

Examples:

- schema validation for surface artifacts
- retry taxonomy validation
- lock acquisition enforcement
- approval artifact verification

---

## Phase 6 — Safety Invariants

Define **system invariants** that must always hold.

Example:

- No external side effect without decision record + lock
- Every active run has one executor owner
- Every privileged action references a valid approval artifact

Specify where these invariants are enforced and write them into the affected files.

---

## Phase 7 — Integration Plan

Provide a recommended **order for integrating the changes** into the package.

Example:

1. Add missing contracts
2. Update execution model
3. Introduce concurrency model
4. Extend validator coverage
5. Add new diagrams

---

## Required Output Format

Your output must include:

### A. Change Manifest
Every file created or updated.

### B. Issue-to-Change Mapping
A compact matrix of issue -> file -> change.

### C. File Bodies or Exact Patches
For every changed/new file, provide the complete final content or an exact diff.
Prefer complete final content.

### D. Integration Summary
Explain how the resulting package is stronger and more buildable.

### E. Final Package Outline
Show the resulting package structure after integration.

---

## Important Rules

Do not:

- rewrite the entire package unnecessarily
- introduce unrelated architecture
- remove existing concepts without justification
- return recommendation-only output

Only implement the **minimum set of changes required to resolve the identified findings**.

# Specification Closure Prompt

You are a **principal systems architect responsible for closing the remaining specification gaps** in a design package so that the system becomes fully implementable.

The following package has already undergone:

- architecture audit
- red-team analysis
- design hardening / remediation
- implementation simulation

Target package:

```text
<PACKAGE_PATH>
```

The implementation simulation identified **remaining specification blockers**.

Your task is to **fully define the missing contracts required to make the package buildable**.

Do not redesign the system.
Define the **minimum additional specifications required to close the gaps**.

---

## Inputs

1. The current design package
```text
<PACKAGE_PATH>
```

2. The implementation simulation report
```text
<IMPLEMENTATION_SIMULATION_REPORT>
```

---

## Critical Execution Rule

You must **close the specification gaps in the package itself**.

- **If you have file-system access:** create/update files in place under `<PACKAGE_PATH>`.
- **If you do not have file-system access:** output a **change manifest** plus the **complete final contents** of every new or updated file.
- Do not stop at identifying the gaps.
- Do not return recommendation-only commentary.
- Every blocker you address must result in concrete new or updated specification files.

---

## Phase 1 — Identify Remaining Blockers

From the implementation simulation report, identify the **true blockers** that prevent the package from being fully buildable.

For each blocker, determine:

- why it blocks implementation
- which file(s) must be created or updated
- what exact contract must be added or closed

---

## Phase 2 — Workflow / Execution Contract

If the simulation identified a missing workflow or execution contract, define a **workflow execution specification** that allows the system to launch workflows deterministically.

Define and then write:

### Workflow Metadata Schema

Required fields such as:

- workflow_id
- version
- side_effect_class
- cancel_safe
- coordination_key_strategy
- required_inputs
- produced_outputs

Explain how orchestration derives the coordination key and safety properties.

### Workflow Execution Interface

Define the interface between:

- controller / launcher
- workflow executor

Define expected requests, responses, acknowledgements, and error paths.

### Execution State Model

Define execution states such as:

- pending
- running
- succeeded
- failed
- cancelled
- recovery_pending

Explain how these states integrate with the higher-level run states.

---

## Phase 3 — Coordination Lock Contract

If the simulation identified a missing coordination-lock artifact/API, define a
**clear coordination-lock specification**.

Define and then write:

### Lock Schema
Fields such as:

- lock_id
- coordination_key
- owner_run_id
- acquired_at
- lease_expires_at
- lock_version

### Lock Acquisition Algorithm
1. derive coordination_key
2. attempt CAS acquire
3. if lock held -> defer or escalate
4. if acquired -> execution allowed

### Lock Lease Semantics
Define:

- heartbeat extension
- stale lock detection
- lock transfer conditions

### Storage Guarantees
Define required properties:

- atomic compare-and-swap
- strong consistency
- monotonic time ordering

---

## Phase 4 — Approver Authority Model

If the simulation identified a missing approval-authority model, define how the system determines whether an approval artifact is valid.

Introduce and then write an **Approver Authority Registry**.

Define:

- registry schema
- authority scope model
- expiry / revocation behavior
- verification algorithm

### Approval Verification Algorithm
When evaluating an approval artifact:

1. locate approver in registry
2. confirm scope matches action
3. confirm approval is not expired
4. confirm approver authority level is sufficient

---

## Phase 5 — Validator Extensions

Extend validator responsibilities to verify:

- workflow metadata completeness
- coordination key derivation validity
- lock contract compliance
- approval artifact authority validity

Write the actual updated validator file(s) or exact patches.

---

## Phase 6 — Determinism Guarantees

Define invariants required for safe orchestration / execution.

Examples:

- No side effect begins without lock acquisition.
- Every privileged action references a valid approval artifact.
- Every workflow advertises side-effect classification.
- Every active run has exactly one executor owner.

Write these invariants into the affected files.

---

## Required Output Format

Your output must contain:

### A. Change Manifest
Every file created or updated.

### B. Blocker-to-File Mapping
A compact matrix of blocker -> file -> closure change.

### C. File Bodies or Exact Patches
For every changed/new file, provide the complete final content or exact diff.
Prefer complete final content.

### D. Specification Closure Summary
Explain what blockers were closed and what residual ambiguities remain, if any.

### E. Final Package Outline
Show the resulting package structure after closure.

---

## Goal

Close the remaining specification gaps so the design package becomes **fully implementable** or at least clearly identifies the very last residual ambiguities.

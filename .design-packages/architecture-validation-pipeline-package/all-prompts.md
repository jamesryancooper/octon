# All Prompts

---

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

---

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

---

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

---

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

---

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

---

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

---

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

---

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

---

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

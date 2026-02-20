---
behavior:
  phases:
    - name: "Parse"
      steps:
        - "Read the spec document (file path or inline text)"
        - "Extract explicit requirements (functional, non-functional)"
        - "Extract constraints (technology, timeline, compatibility)"
        - "Extract acceptance criteria (if present)"
        - "Identify ambiguities — list assumptions explicitly"
        - "Record: N requirements, M constraints, K acceptance criteria, J ambiguities"
    - name: "Map"
      steps:
        - "Scan the codebase to identify affected domains and services"
        - "Map requirements to existing code areas (modules, packages, endpoints)"
        - "Identify new code areas that need to be created"
        - "Identify shared dependencies and integration points"
        - "Record: affected domains, existing modules, new modules needed"
    - name: "Decompose"
      steps:
        - "Break each requirement into discrete, independently deliverable tasks"
        - "Apply vertical slice principle: each task delivers end-to-end value"
        - "For each task: assign ID, title, domain, acceptance criteria"
        - "Identify risks and unknowns per task"
        - "Assign relative complexity: S, M, or L"
        - "Record: N tasks across M domains"
    - name: "Sequence"
      steps:
        - "Identify dependencies between tasks"
        - "Build dependency graph: which tasks must complete before others"
        - "Apply risk-first ordering: uncertain items earlier"
        - "Define interface contracts at boundaries"
        - "Group tasks into milestones (each milestone = working increment)"
        - "Record: dependency graph, milestone breakdown"
    - name: "Plan"
      steps:
        - "Generate implementation plan document"
        - "Include: executive summary, requirements traceability, task table"
        - "Include: dependency diagram (text-based), milestone definitions"
        - "Include: risk register with mitigations"
        - "Include: assumptions and open questions"
        - "Write plan to output/plans/"
    - name: "Review"
      steps:
        - "Present plan summary to the user"
        - "Highlight key decisions and assumptions that need confirmation"
        - "List open questions that affect task scope or sequencing"
        - "Wait for ACP gate before considering the plan final"
        - "Record review outcome in execution log"
  goals:
    - "Every spec requirement maps to at least one implementation task"
    - "Tasks are independently deliverable (vertical slices)"
    - "Dependencies are explicit and respected in sequencing"
    - "Risks are identified and scheduled early"
    - "Plan is actionable without further decomposition"
---

# Behavior Reference

Detailed phase-by-phase behavior for the spec-to-implementation skill.

## Phase 1: Parse

Extract structured information from the spec document.

### Parsing Protocol

1. **Read the spec** — Accept file path or inline text
2. **Extract requirements** — Look for:
   - Functional requirements ("the system shall/should/must")
   - Non-functional requirements (performance, security, scalability)
   - User stories or use cases
   - UI/UX specifications
3. **Extract constraints:**
   - Technology constraints (language, framework, infrastructure)
   - Timeline constraints (deadlines, phases)
   - Compatibility constraints (backward compat, API versioning)
4. **Extract acceptance criteria** — Tests or conditions for "done"
5. **Flag ambiguities** — List assumptions with `[ASSUMPTION]` tag

### Parse Output

```markdown
## Requirements (N total)
- R01: [functional requirement]
- R02: [functional requirement]

## Constraints (M total)
- C01: Must use existing auth system
- C02: API must be backward-compatible

## Acceptance Criteria (K total)
- AC01: User can log in with email/password
- AC02: API response time < 200ms at p95

## Ambiguities (J total)
- [ASSUMPTION] Spec says "fast" — assuming < 200ms p95
- [QUESTION] Does "user" include admin users?
```

---

## Phase 2: Map

Connect requirements to the existing codebase.

### Mapping Protocol

1. **Scan the codebase** — Use Glob/Grep to find relevant modules
2. **Map each requirement** to existing code:
   - Which files/modules will need changes?
   - Which new files/modules need to be created?
3. **Identify integration points** — Where do different domains connect?
4. **Identify shared dependencies** — What's used across multiple tasks?

---

## Phase 3: Decompose

Break requirements into tasks.

### Task Structure

```markdown
### T01: [Action-oriented title]

**Domain:** database | api | frontend | infra
**Complexity:** S | M | L
**Dependencies:** none | T02, T03
**Requirement:** R01, R02

**Description:**
What needs to be done and why.

**Acceptance Criteria:**
- [ ] Criteria derived from spec
- [ ] Criteria derived from spec

**Risk Flags:**
- [if any unknowns or concerns]
```

### Decomposition Rules

- Each task should be completable in a single PR
- Each task should produce a testable result
- Prefer vertical slices over horizontal layers
- If a task is L complexity, consider splitting further

---

## Phase 4: Sequence

Order tasks by dependencies and risk.

### Sequencing Rules

1. **Data layer before API** — Schema and models first
2. **API before UI** — Endpoints before frontends
3. **Shared before specific** — Utilities before consumers
4. **Risk-first** — Uncertain tasks earlier for faster feedback
5. **Interface contracts at boundaries** — Define before implementing either side

### Milestone Structure

```markdown
## Milestone 1: Foundation (Tasks T01-T04)
**Delivers:** Database schema, core models, initial API
**Verifiable by:** API returns expected data

## Milestone 2: Core Features (Tasks T05-T08)
**Delivers:** Main user-facing functionality
**Verifiable by:** User can complete primary workflow
```

---

## Phase 5: Plan

Generate the implementation plan document.

### Plan Structure

```markdown
# Implementation Plan: [Feature Name]

**Spec:** [link to spec]
**Date:** YYYY-MM-DD
**Tasks:** N across M domains
**Milestones:** K

## Executive Summary
[2-3 sentences describing the plan]

## Requirements Traceability
| Requirement | Tasks | Status |
|-------------|-------|--------|
| R01 | T01, T03 | Covered |

## Task Table
| ID | Title | Domain | Complexity | Dependencies | Milestone |
|----|-------|--------|-----------|-------------|-----------|
| T01 | ... | database | M | none | 1 |

## Dependency Diagram
[Text-based diagram showing task dependencies]

## Milestones
[Milestone definitions with deliverables]

## Risk Register
| Risk | Impact | Likelihood | Mitigation | Affected Tasks |
|------|--------|-----------|-----------|---------------|

## Assumptions & Open Questions
[List of assumptions made and questions needing answers]
```

---

## Phase 6: Review

Present plan for ACP gate.

### Review Protocol

1. Present the executive summary
2. Highlight decisions that need confirmation
3. List open questions
4. Wait for approval or revision requests
5. If revisions requested, return to the appropriate phase
